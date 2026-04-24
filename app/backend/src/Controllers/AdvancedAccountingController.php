<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class AdvancedAccountingController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function authorizePermission(string $permission)
    {
        $middleware = new PermissionMiddleware($this->request, $this->db, $permission);
        return $middleware->handle();
    }

    private function userId(): ?int
    {
        $user = $this->request->getUser();
        if (!$user || empty($user['user_id'])) {
            return null;
        }
        return (int) $user['user_id'];
    }

    private function farmId(): int
    {
        $input = $this->request->getBody();
        if (!empty($input['farm_id'])) {
            return (int) $input['farm_id'];
        }
        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function logAudit(string $action, string $entity, ?int $entityId, array $data = []): void
    {
        try {
            $this->db->execute(
                'INSERT INTO accounting_audit_log (farm_id, user_id, action, entity, entity_id, data)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $this->farmId(),
                    $this->userId(),
                    $action,
                    $entity,
                    $entityId,
                    json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
                ]
            );
        } catch (\Throwable $e) {
        }
    }

    private function safeAlter(string $sql): void
    {
        try {
            $this->db->execute($sql);
        } catch (\Throwable $e) {
        }
    }

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_entities (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                code VARCHAR(40) NOT NULL,
                name VARCHAR(255) NOT NULL,
                type VARCHAR(40) NOT NULL,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_entity_code_farm (farm_id, code),
                INDEX idx_entity_farm_type (farm_id, type)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_books (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                entity_id INT NULL,
                name VARCHAR(140) NOT NULL,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                base_currency VARCHAR(10) NOT NULL DEFAULT "USD",
                is_primary TINYINT(1) NOT NULL DEFAULT 0,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_book_farm_entity (farm_id, entity_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_currencies (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                code VARCHAR(10) NOT NULL,
                name VARCHAR(100) NOT NULL,
                rate DECIMAL(18,6) NOT NULL DEFAULT 1.000000,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_currency_code_farm (farm_id, code)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_periods (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                entity_id INT NULL,
                book_id INT NULL,
                name VARCHAR(120) NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_period_book_name (farm_id, book_id, name),
                INDEX idx_period_date (farm_id, start_date, end_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_bank_accounts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(180) NOT NULL,
                bank_name VARCHAR(180) NOT NULL,
                account_number VARCHAR(80) NULL,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                balance DECIMAL(18,2) NOT NULL DEFAULT 0,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_bank_farm (farm_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_bank_statements (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                bank_account_id INT NOT NULL,
                statement_date DATE NOT NULL,
                imported_by INT NULL,
                imported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                lines JSON NULL,
                status VARCHAR(30) NOT NULL DEFAULT "imported",
                total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_statement_bank (bank_account_id, statement_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_bank_reconciliations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                statement_id INT NOT NULL,
                cashbook_entry_id INT NULL,
                payment_id INT NULL,
                reconciled_by INT NULL,
                reconciled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                status VARCHAR(30) NOT NULL DEFAULT "reconciled",
                note TEXT NULL,
                INDEX idx_reconciliation_statement (statement_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_cashbook_entries (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                book_id INT NULL,
                account_id INT NULL,
                type VARCHAR(20) NOT NULL,
                amount DECIMAL(18,2) NOT NULL,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                exchange_rate DECIMAL(18,6) NOT NULL DEFAULT 1.000000,
                transaction_date DATE NOT NULL,
                description VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_cashbook_farm_date (farm_id, transaction_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_tax_codes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                code VARCHAR(30) NOT NULL,
                name VARCHAR(150) NOT NULL,
                rate_percent DECIMAL(8,4) NOT NULL,
                type VARCHAR(40) NOT NULL,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_tax_code_farm (farm_id, code)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_fixed_assets (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                asset_code VARCHAR(80) NOT NULL,
                name VARCHAR(255) NOT NULL,
                purchase_date DATE NOT NULL,
                purchase_amount DECIMAL(18,2) NOT NULL,
                salvage_value DECIMAL(18,2) NOT NULL DEFAULT 0,
                useful_life_months INT NOT NULL,
                depreciation_method VARCHAR(40) NOT NULL DEFAULT "straight_line",
                accumulated_depreciation DECIMAL(18,2) NOT NULL DEFAULT 0,
                net_book_value DECIMAL(18,2) NOT NULL DEFAULT 0,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                status VARCHAR(30) NOT NULL DEFAULT "active",
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_asset_code_farm (farm_id, asset_code)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_depreciation_schedules (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                asset_id INT NOT NULL,
                period_start DATE NOT NULL,
                period_end DATE NOT NULL,
                depreciation_amount DECIMAL(18,2) NOT NULL,
                accumulated_depreciation DECIMAL(18,2) NOT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_depr_asset (asset_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_credit_notes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                customer_name VARCHAR(180) NOT NULL,
                reference_no VARCHAR(80) NULL,
                amount DECIMAL(18,2) NOT NULL,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                status VARCHAR(30) NOT NULL DEFAULT "issued",
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_credit_farm (farm_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_refunds (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                party_name VARCHAR(180) NOT NULL,
                reference_no VARCHAR(80) NULL,
                amount DECIMAL(18,2) NOT NULL,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                refund_date DATE NOT NULL,
                status VARCHAR(30) NOT NULL DEFAULT "completed",
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_refund_farm (farm_id, refund_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_recurring_invoices (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                customer_name VARCHAR(180) NOT NULL,
                frequency VARCHAR(50) NOT NULL,
                next_run_date DATE NOT NULL,
                items JSON NULL,
                amount DECIMAL(18,2) NOT NULL,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                status VARCHAR(30) NOT NULL DEFAULT "active",
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_recurring_farm (farm_id, next_run_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_payments (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                receivable_id INT NULL,
                payable_id INT NULL,
                amount DECIMAL(18,2) NOT NULL,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                exchange_rate DECIMAL(18,6) NOT NULL DEFAULT 1.000000,
                payment_method VARCHAR(80) NOT NULL DEFAULT "bank_transfer",
                paid_at DATE NOT NULL,
                status VARCHAR(30) NOT NULL DEFAULT "completed",
                created_by INT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_payment_farm (farm_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_journal_approvals (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                entry_id INT NOT NULL,
                approved_by INT NOT NULL,
                action VARCHAR(30) NOT NULL,
                comment TEXT NULL,
                approved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_approval_entry (entry_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_audit_log (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                user_id INT NULL,
                action VARCHAR(120) NOT NULL,
                entity VARCHAR(120) NOT NULL,
                entity_id INT NULL,
                data JSON NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_audit_farm (farm_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_inventory_costing (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                method VARCHAR(40) NOT NULL DEFAULT "fifo",
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_costing_farm (farm_id)
            )'
        );

        $this->safeAlter('ALTER TABLE accounting_accounts ADD COLUMN book_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_journal_entries ADD COLUMN entity_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_journal_entries ADD COLUMN book_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_journal_entries ADD COLUMN currency VARCHAR(10) NOT NULL DEFAULT "USD"');
        $this->safeAlter('ALTER TABLE accounting_journal_entries ADD COLUMN exchange_rate DECIMAL(18,6) NOT NULL DEFAULT 1.000000');
        $this->safeAlter('ALTER TABLE accounting_journal_entries ADD COLUMN period_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_journal_lines ADD COLUMN tax_code_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_journal_lines ADD COLUMN tax_amount DECIMAL(18,2) NOT NULL DEFAULT 0');
        $this->safeAlter('ALTER TABLE accounting_receivables ADD COLUMN entity_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_receivables ADD COLUMN book_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_receivables ADD COLUMN currency VARCHAR(10) NOT NULL DEFAULT "USD"');
        $this->safeAlter('ALTER TABLE accounting_receivables ADD COLUMN exchange_rate DECIMAL(18,6) NOT NULL DEFAULT 1.000000');
        $this->safeAlter('ALTER TABLE accounting_payables ADD COLUMN entity_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_payables ADD COLUMN book_id INT NULL');
        $this->safeAlter('ALTER TABLE accounting_payables ADD COLUMN currency VARCHAR(10) NOT NULL DEFAULT "USD"');
        $this->safeAlter('ALTER TABLE accounting_payables ADD COLUMN exchange_rate DECIMAL(18,6) NOT NULL DEFAULT 1.000000');
    }

    public function entities(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, code, name, type, is_active FROM accounting_entities WHERE farm_id = ? ORDER BY code ASC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $code = trim((string) ($input['code'] ?? ''));
            $name = trim((string) ($input['name'] ?? ''));
            $type = strtolower(trim((string) ($input['type'] ?? '')));
            if ($code === '' || $name === '') {
                return Response::validationError(['entity' => 'Entity code and name are required']);
            }
            if (!Validation::validateEnum($type, ['legal', 'division', 'branch', 'project'])) {
                return Response::validationError(['type' => 'Invalid entity type']);
            }

            $this->db->execute(
                'INSERT INTO accounting_entities (farm_id, code, name, type) VALUES (?, ?, ?, ?)',
                [$farmId, Validation::sanitizeString($code), Validation::sanitizeString($name), $type]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_entity', 'entity', $id, $input);
            return Response::success(['id' => $id], 'Entity created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle accounting entities', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle entities', 'ACCOUNTING_ENTITIES_ERROR', 500);
        }
    }

    public function books(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, entity_id, name, currency, base_currency, is_primary, is_active
                     FROM accounting_books
                     WHERE farm_id = ?
                     ORDER BY name ASC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $entityId = isset($input['entity_id']) ? (int) $input['entity_id'] : null;
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));
            $baseCurrency = strtoupper(trim((string) ($input['base_currency'] ?? 'USD')));
            $isPrimary = !empty($input['is_primary']) ? 1 : 0;

            if ($name === '') {
                return Response::validationError(['name' => 'Book name is required']);
            }
            if ($currency === '' || $baseCurrency === '') {
                return Response::validationError(['currency' => 'Currency codes are required']);
            }

            $this->db->execute(
                'INSERT INTO accounting_books (farm_id, entity_id, name, currency, base_currency, is_primary)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [$farmId, $entityId, Validation::sanitizeString($name), $currency, $baseCurrency, $isPrimary]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_book', 'book', $id, $input);
            return Response::success(['id' => $id], 'Accounting book created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle accounting books', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle books', 'ACCOUNTING_BOOKS_ERROR', 500);
        }
    }

    public function currencies(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query('SELECT code, name, rate, is_active FROM accounting_currencies ORDER BY code ASC');
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $code = strtoupper(trim((string) ($input['code'] ?? '')));
            $name = trim((string) ($input['name'] ?? ''));
            $rate = $input['rate'] ?? null;

            if ($code === '' || $name === '' || !is_numeric($rate) || (float) $rate <= 0) {
                return Response::validationError(['currency' => 'Valid code, name and rate are required']);
            }

            $this->db->execute(
                'REPLACE INTO accounting_currencies (code, name, rate, is_active) VALUES (?, ?, ?, 1)',
                [$code, Validation::sanitizeString($name), (float) $rate]
            );
            $this->logAudit('upsert_currency', 'currency', null, $input);
            return Response::success(['code' => $code], 'Currency saved', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle currencies', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle currencies', 'ACCOUNTING_CURRENCIES_ERROR', 500);
        }
    }

    public function bankAccounts(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, name, bank_name, account_number, currency, balance, is_active
                     FROM accounting_bank_accounts
                     WHERE farm_id = ?
                     ORDER BY name ASC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $bankName = trim((string) ($input['bank_name'] ?? ''));
            $accountNumber = trim((string) ($input['account_number'] ?? ''));
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));
            $balance = $input['balance'] ?? 0;

            if ($name === '' || $bankName === '') {
                return Response::validationError(['bank_account' => 'Bank account name and bank name are required']);
            }
            if (!is_numeric($balance)) {
                return Response::validationError(['balance' => 'Balance must be numeric']);
            }

            $this->db->execute(
                'INSERT INTO accounting_bank_accounts (farm_id, name, bank_name, account_number, currency, balance)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($name),
                    Validation::sanitizeString($bankName),
                    Validation::sanitizeString($accountNumber),
                    $currency,
                    (float) $balance,
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_bank_account', 'bank_account', $id, $input);
            return Response::success(['id' => $id], 'Bank account created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle bank accounts', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle bank accounts', 'ACCOUNTING_BANK_ACCOUNTS_ERROR', 500);
        }
    }

    public function bankStatements(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, bank_account_id, statement_date, total_amount, currency, status, imported_at
                     FROM accounting_bank_statements
                     WHERE farm_id = ?
                     ORDER BY statement_date DESC, id DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $bankAccountId = (int) ($input['bank_account_id'] ?? 0);
            $statementDate = (string) ($input['statement_date'] ?? '');
            $lines = $input['lines'] ?? [];
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));
            $totalAmount = $input['total_amount'] ?? null;

            if ($bankAccountId <= 0 || !Validation::validateDate($statementDate)) {
                return Response::validationError(['statement' => 'Bank account and valid statement date are required']);
            }
            if (!is_array($lines) || empty($lines)) {
                return Response::validationError(['lines' => 'Statement lines are required']);
            }
            if (!is_numeric($totalAmount) || (float) $totalAmount < 0) {
                return Response::validationError(['total_amount' => 'Total amount is required']);
            }

            $this->db->execute(
                'INSERT INTO accounting_bank_statements (farm_id, bank_account_id, statement_date, imported_by, lines, total_amount, currency)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $bankAccountId,
                    $statementDate,
                    $this->userId(),
                    json_encode($lines, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
                    (float) $totalAmount,
                    $currency,
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('import_bank_statement', 'bank_statement', $id, $input);
            return Response::success(['id' => $id], 'Bank statement imported', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle bank statements', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle bank statements', 'ACCOUNTING_BANK_STATEMENTS_ERROR', 500);
        }
    }

    public function bankReconcile(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.post');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $input = $this->request->getBody();
            $statementId = (int) ($input['statement_id'] ?? 0);
            $cashbookEntryId = isset($input['cashbook_entry_id']) ? (int) $input['cashbook_entry_id'] : null;
            $paymentId = isset($input['payment_id']) ? (int) $input['payment_id'] : null;
            $note = trim((string) ($input['note'] ?? ''));

            if ($statementId <= 0) {
                return Response::validationError(['statement_id' => 'Statement ID is required']);
            }

            $this->db->execute(
                'INSERT INTO accounting_bank_reconciliations (farm_id, statement_id, cashbook_entry_id, payment_id, reconciled_by, note)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [$farmId, $statementId, $cashbookEntryId, $paymentId, $this->userId(), $note !== '' ? $note : null]
            );
            $reconciliationId = (int) $this->db->lastInsertId();
            $this->db->execute(
                'UPDATE accounting_bank_statements SET status = ? WHERE id = ? AND farm_id = ?',
                ['reconciled', $statementId, $farmId]
            );
            $this->logAudit('reconcile_bank_statement', 'bank_reconciliation', $reconciliationId, $input);
            return Response::success(['id' => $reconciliationId], 'Bank statement reconciled', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to reconcile bank statement', ['error' => $e->getMessage()]);
            return Response::error('Failed to reconcile bank statement', 'ACCOUNTING_BANK_RECONCILE_ERROR', 500);
        }
    }

    public function cashbook(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, book_id, account_id, type, amount, currency, exchange_rate, transaction_date, description, created_at
                     FROM accounting_cashbook_entries
                     WHERE farm_id = ?
                     ORDER BY transaction_date DESC, id DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $type = strtolower(trim((string) ($input['type'] ?? '')));
            $amount = $input['amount'] ?? null;
            $transactionDate = (string) ($input['transaction_date'] ?? '');
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));
            $exchangeRate = $input['exchange_rate'] ?? 1.0;
            $bookId = isset($input['book_id']) ? (int) $input['book_id'] : null;
            $accountId = isset($input['account_id']) ? (int) $input['account_id'] : null;
            $description = trim((string) ($input['description'] ?? ''));

            if (!Validation::validateEnum($type, ['cash_in', 'cash_out'])) {
                return Response::validationError(['type' => 'Cashbook type must be cash_in or cash_out']);
            }
            if (!is_numeric($amount) || (float) $amount <= 0) {
                return Response::validationError(['amount' => 'Amount must be positive']);
            }
            if (!Validation::validateDate($transactionDate)) {
                return Response::validationError(['transaction_date' => 'Invalid transaction date']);
            }
            if (!is_numeric($exchangeRate) || (float) $exchangeRate <= 0) {
                return Response::validationError(['exchange_rate' => 'Exchange rate must be positive']);
            }

            $this->db->execute(
                'INSERT INTO accounting_cashbook_entries (farm_id, book_id, account_id, type, amount, currency, exchange_rate, transaction_date, description, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $bookId,
                    $accountId,
                    $type,
                    (float) $amount,
                    $currency,
                    (float) $exchangeRate,
                    $transactionDate,
                    $description !== '' ? Validation::sanitizeString($description) : null,
                    $this->userId(),
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_cashbook_entry', 'cashbook_entry', $id, $input);
            return Response::success(['id' => $id], 'Cashbook entry created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle cashbook', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle cashbook', 'ACCOUNTING_CASHBOOK_ERROR', 500);
        }
    }

    public function taxCodes(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, code, name, rate_percent, type, is_active FROM accounting_tax_codes WHERE farm_id = ? ORDER BY code ASC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $code = trim((string) ($input['code'] ?? ''));
            $name = trim((string) ($input['name'] ?? ''));
            $ratePercent = $input['rate_percent'] ?? null;
            $type = strtolower(trim((string) ($input['type'] ?? '')));

            if ($code === '' || $name === '' || !is_numeric($ratePercent)) {
                return Response::validationError(['tax_code' => 'Code, name and rate are required']);
            }
            if (!Validation::validateEnum($type, ['vat', 'gst', 'sales_tax', 'withholding'])) {
                return Response::validationError(['type' => 'Tax type must be vat, gst, sales_tax or withholding']);
            }

            $this->db->execute(
                'INSERT INTO accounting_tax_codes (farm_id, code, name, rate_percent, type)
                 VALUES (?, ?, ?, ?, ?)',
                [$farmId, Validation::sanitizeString($code), Validation::sanitizeString($name), (float) $ratePercent, $type]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_tax_code', 'tax_code', $id, $input);
            return Response::success(['id' => $id], 'Tax code created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle tax codes', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle tax codes', 'ACCOUNTING_TAX_CODES_ERROR', 500);
        }
    }

    public function fixedAssets(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, asset_code, name, purchase_date, purchase_amount, salvage_value, useful_life_months, depreciation_method, accumulated_depreciation, net_book_value, currency, status
                     FROM accounting_fixed_assets
                     WHERE farm_id = ?
                     ORDER BY purchase_date DESC, id DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $assetCode = trim((string) ($input['asset_code'] ?? ''));
            $name = trim((string) ($input['name'] ?? ''));
            $purchaseDate = (string) ($input['purchase_date'] ?? '');
            $purchaseAmount = $input['purchase_amount'] ?? null;
            $salvageValue = $input['salvage_value'] ?? 0;
            $usefulLife = isset($input['useful_life_months']) ? (int) $input['useful_life_months'] : 0;
            $method = strtolower(trim((string) ($input['depreciation_method'] ?? 'straight_line')));
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));

            if ($assetCode === '' || $name === '' || !Validation::validateDate($purchaseDate)) {
                return Response::validationError(['asset' => 'Asset code, name and purchase date are required']);
            }
            if (!is_numeric($purchaseAmount) || (float) $purchaseAmount <= 0 || $usefulLife <= 0) {
                return Response::validationError(['purchase_amount' => 'Purchase amount and useful life are required']);
            }
            if (!Validation::validateEnum($method, ['straight_line', 'declining_balance', 'sum_of_years'])) {
                return Response::validationError(['depreciation_method' => 'Invalid depreciation method']);
            }

            $netBookValue = (float) $purchaseAmount - (float) $salvageValue;
            if ($netBookValue < 0) {
                $netBookValue = 0.0;
            }

            $this->db->execute(
                'INSERT INTO accounting_fixed_assets (farm_id, asset_code, name, purchase_date, purchase_amount, salvage_value, useful_life_months, depreciation_method, accumulated_depreciation, net_book_value, currency)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($assetCode),
                    Validation::sanitizeString($name),
                    $purchaseDate,
                    (float) $purchaseAmount,
                    (float) $salvageValue,
                    $usefulLife,
                    $method,
                    0.0,
                    $netBookValue,
                    $currency,
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_fixed_asset', 'fixed_asset', $id, $input);
            return Response::success(['id' => $id], 'Fixed asset created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle fixed assets', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle fixed assets', 'ACCOUNTING_FIXED_ASSETS_ERROR', 500);
        }
    }

    public function depreciationSchedules(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, asset_id, period_start, period_end, depreciation_amount, accumulated_depreciation, created_at
                     FROM accounting_depreciation_schedules
                     WHERE farm_id = ?
                     ORDER BY period_start DESC, id DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $assetId = (int) ($input['asset_id'] ?? 0);
            $periodStart = (string) ($input['period_start'] ?? '');
            $periodEnd = (string) ($input['period_end'] ?? '');

            if ($assetId <= 0 || !Validation::validateDate($periodStart) || !Validation::validateDate($periodEnd)) {
                return Response::validationError(['schedule' => 'Asset and valid period dates are required']);
            }

            $asset = $this->db->queryOne('SELECT * FROM accounting_fixed_assets WHERE id = ? AND farm_id = ?', [$assetId, $farmId]);
            if (!$asset) {
                return Response::notFound('Fixed asset not found');
            }

            $purchaseAmount = (float) $asset['purchase_amount'];
            $salvageValue = (float) $asset['salvage_value'];
            $usefulLife = (int) $asset['useful_life_months'];
            $method = $asset['depreciation_method'];

            $remainingValue = max(0, $purchaseAmount - $salvageValue);
            $monthlyDepreciation = $usefulLife > 0 ? round($remainingValue / $usefulLife, 2) : 0.0;
            $deprAmount = $monthlyDepreciation;
            if ($method === 'declining_balance') {
                $bookValue = $remainingValue;
                $rate = 2 / $usefulLife;
                $deprAmount = round($bookValue * $rate, 2);
            } elseif ($method === 'sum_of_years') {
                $n = $usefulLife;
                $sum = ($n * ($n + 1)) / 2;
                $yearFraction = 1 / $sum;
                $deprAmount = round(($remainingValue - $salvageValue) * $yearFraction, 2);
            }

            $accumulated = (float) $asset['accumulated_depreciation'] + $deprAmount;
            $netBookValue = max(0, $purchaseAmount - $accumulated);

            $this->db->execute(
                'INSERT INTO accounting_depreciation_schedules (farm_id, asset_id, period_start, period_end, depreciation_amount, accumulated_depreciation)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [$farmId, $assetId, $periodStart, $periodEnd, $deprAmount, $accumulated]
            );
            $scheduleId = (int) $this->db->lastInsertId();
            $this->db->execute(
                'UPDATE accounting_fixed_assets SET accumulated_depreciation = ?, net_book_value = ? WHERE id = ? AND farm_id = ?',
                [$accumulated, $netBookValue, $assetId, $farmId]
            );
            $this->logAudit('create_depreciation_schedule', 'depreciation_schedule', $scheduleId, $input);
            return Response::success(['id' => $scheduleId], 'Depreciation schedule created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle depreciation schedules', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle depreciation schedules', 'ACCOUNTING_DEPRECIATION_ERROR', 500);
        }
    }

    public function creditNotes(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, customer_name, reference_no, amount, currency, status, created_at
                     FROM accounting_credit_notes
                     WHERE farm_id = ?
                     ORDER BY created_at DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $customerName = trim((string) ($input['customer_name'] ?? ''));
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $amount = $input['amount'] ?? null;
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));

            if ($customerName === '' || !is_numeric($amount) || (float) $amount <= 0) {
                return Response::validationError(['credit_note' => 'Customer name and positive amount are required']);
            }

            $this->db->execute(
                'INSERT INTO accounting_credit_notes (farm_id, customer_name, reference_no, amount, currency)
                 VALUES (?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($customerName),
                    $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                    (float) $amount,
                    $currency,
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_credit_note', 'credit_note', $id, $input);
            return Response::success(['id' => $id], 'Credit note created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle credit notes', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle credit notes', 'ACCOUNTING_CREDIT_NOTES_ERROR', 500);
        }
    }

    public function refunds(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, party_name, reference_no, amount, currency, refund_date, status, created_at
                     FROM accounting_refunds
                     WHERE farm_id = ?
                     ORDER BY refund_date DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $partyName = trim((string) ($input['party_name'] ?? ''));
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $amount = $input['amount'] ?? null;
            $refundDate = (string) ($input['refund_date'] ?? '');
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));

            if ($partyName === '' || !is_numeric($amount) || (float) $amount <= 0 || !Validation::validateDate($refundDate)) {
                return Response::validationError(['refund' => 'Party name, positive amount and valid refund date are required']);
            }

            $this->db->execute(
                'INSERT INTO accounting_refunds (farm_id, party_name, reference_no, amount, currency, refund_date)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($partyName),
                    $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                    (float) $amount,
                    $currency,
                    $refundDate,
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_refund', 'refund', $id, $input);
            return Response::success(['id' => $id], 'Refund recorded', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle refunds', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle refunds', 'ACCOUNTING_REFUNDS_ERROR', 500);
        }
    }

    public function recurringInvoices(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, customer_name, frequency, next_run_date, amount, currency, status, created_at
                     FROM accounting_recurring_invoices
                     WHERE farm_id = ?
                     ORDER BY next_run_date ASC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $customerName = trim((string) ($input['customer_name'] ?? ''));
            $frequency = strtolower(trim((string) ($input['frequency'] ?? 'monthly')));
            $nextRunDate = (string) ($input['next_run_date'] ?? '');
            $items = $input['items'] ?? [];
            $amount = $input['amount'] ?? null;
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));

            if ($customerName === '' || !Validation::validateDate($nextRunDate) || !is_numeric($amount) || (float) $amount <= 0) {
                return Response::validationError(['recurring_invoice' => 'Customer name, next run date and positive amount are required']);
            }
            if (!Validation::validateEnum($frequency, ['daily', 'weekly', 'monthly', 'quarterly', 'yearly'])) {
                return Response::validationError(['frequency' => 'Invalid frequency']);
            }

            $this->db->execute(
                'INSERT INTO accounting_recurring_invoices (farm_id, customer_name, frequency, next_run_date, items, amount, currency)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($customerName),
                    $frequency,
                    $nextRunDate,
                    json_encode($items, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
                    (float) $amount,
                    $currency,
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_recurring_invoice', 'recurring_invoice', $id, $input);
            return Response::success(['id' => $id], 'Recurring invoice created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle recurring invoices', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle recurring invoices', 'ACCOUNTING_RECURRING_INVOICES_ERROR', 500);
        }
    }

    public function payments(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, receivable_id, payable_id, amount, currency, exchange_rate, payment_method, paid_at, status, created_at
                     FROM accounting_payments
                     WHERE farm_id = ?
                     ORDER BY paid_at DESC, id DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $receivableId = isset($input['receivable_id']) ? (int) $input['receivable_id'] : null;
            $payableId = isset($input['payable_id']) ? (int) $input['payable_id'] : null;
            $amount = $input['amount'] ?? null;
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));
            $exchangeRate = $input['exchange_rate'] ?? 1.0;
            $paymentMethod = trim((string) ($input['payment_method'] ?? 'bank_transfer'));
            $paidAt = (string) ($input['paid_at'] ?? date('Y-m-d'));

            if (!is_numeric($amount) || (float) $amount <= 0 || !Validation::validateDate($paidAt)) {
                return Response::validationError(['payment' => 'Valid amount and paid date are required']);
            }
            if ($receivableId <= 0 && $payableId <= 0) {
                return Response::validationError(['payment_target' => 'Receivable or payable ID is required']);
            }
            if (!is_numeric($exchangeRate) || (float) $exchangeRate <= 0) {
                return Response::validationError(['exchange_rate' => 'Exchange rate must be positive']);
            }

            $this->db->execute(
                'INSERT INTO accounting_payments (farm_id, receivable_id, payable_id, amount, currency, exchange_rate, payment_method, paid_at, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $receivableId,
                    $payableId,
                    (float) $amount,
                    $currency,
                    (float) $exchangeRate,
                    Validation::sanitizeString($paymentMethod),
                    $paidAt,
                    $this->userId(),
                ]
            );
            $id = (int) $this->db->lastInsertId();

            if ($receivableId > 0) {
                $this->db->execute('UPDATE accounting_receivables SET status = ? WHERE id = ? AND farm_id = ?', ['paid', $receivableId, $farmId]);
            }
            if ($payableId > 0) {
                $this->db->execute('UPDATE accounting_payables SET status = ? WHERE id = ? AND farm_id = ?', ['paid', $payableId, $farmId]);
            }
            $this->logAudit('create_payment', 'payment', $id, $input);
            return Response::success(['id' => $id], 'Payment recorded', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle payments', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle payments', 'ACCOUNTING_PAYMENTS_ERROR', 500);
        }
    }

    public function journalApprovals(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.approve');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $input = $this->request->getBody();
            $entryId = (int) ($input['entry_id'] ?? 0);
            $action = strtolower(trim((string) ($input['action'] ?? '')));
            $comment = trim((string) ($input['comment'] ?? ''));

            if ($entryId <= 0 || !Validation::validateEnum($action, ['approve', 'reject'])) {
                return Response::validationError(['approval' => 'Entry ID and approve/reject action are required']);
            }

            $entry = $this->db->queryOne('SELECT id, status FROM accounting_journal_entries WHERE id = ? AND farm_id = ?', [$entryId, $farmId]);
            if (!$entry) {
                return Response::notFound('Journal entry not found');
            }

            $newStatus = $action === 'approve' ? 'approved' : 'rejected';
            $this->db->execute('UPDATE accounting_journal_entries SET status = ? WHERE id = ? AND farm_id = ?', [$newStatus, $entryId, $farmId]);
            $this->db->execute(
                'INSERT INTO accounting_journal_approvals (farm_id, entry_id, approved_by, action, comment)
                 VALUES (?, ?, ?, ?, ?)',
                [$farmId, $entryId, $this->userId(), $action, $comment !== '' ? $comment : null]
            );
            $this->logAudit('journal_approval', 'journal_entry', $entryId, $input);
            return Response::success(['entry_id' => $entryId, 'status' => $newStatus], 'Journal approval recorded', 200);
        } catch (\Exception $e) {
            Logger::error('Failed to handle journal approvals', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle journal approvals', 'ACCOUNTING_JOURNAL_APPROVAL_ERROR', 500);
        }
    }

    public function periods(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, entity_id, book_id, name, start_date, end_date, status, created_at
                     FROM accounting_periods
                     WHERE farm_id = ?
                     ORDER BY start_date DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $startDate = (string) ($input['start_date'] ?? '');
            $endDate = (string) ($input['end_date'] ?? '');
            $bookId = isset($input['book_id']) ? (int) $input['book_id'] : null;
            $entityId = isset($input['entity_id']) ? (int) $input['entity_id'] : null;

            if ($name === '' || !Validation::validateDate($startDate) || !Validation::validateDate($endDate)) {
                return Response::validationError(['period' => 'Name and valid start/end dates are required']);
            }
            if (strtotime($endDate) < strtotime($startDate)) {
                return Response::validationError(['period' => 'End date must be after start date']);
            }

            $this->db->execute(
                'INSERT INTO accounting_periods (farm_id, entity_id, book_id, name, start_date, end_date)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [$farmId, $entityId, $bookId, Validation::sanitizeString($name), $startDate, $endDate]
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('create_period', 'period', $id, $input);
            return Response::success(['id' => $id], 'Period created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle accounting periods', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle periods', 'ACCOUNTING_PERIODS_ERROR', 500);
        }
    }

    public function closePeriod(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.post');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $input = $this->request->getBody();
            $periodId = (int) ($input['period_id'] ?? 0);

            if ($periodId <= 0) {
                return Response::validationError(['period_id' => 'Period ID is required']);
            }

            $period = $this->db->queryOne('SELECT id, status FROM accounting_periods WHERE id = ? AND farm_id = ?', [$periodId, $farmId]);
            if (!$period) {
                return Response::notFound('Period not found');
            }
            if ($period['status'] === 'closed') {
                return Response::validationError(['period' => 'Period is already closed']);
            }

            $this->db->execute('UPDATE accounting_periods SET status = ? WHERE id = ? AND farm_id = ?', ['closed', $periodId, $farmId]);
            $this->logAudit('close_period', 'period', $periodId, $input);
            return Response::success(['id' => $periodId, 'status' => 'closed'], 'Period closed', 200);
        } catch (\Exception $e) {
            Logger::error('Failed to close accounting period', ['error' => $e->getMessage()]);
            return Response::error('Failed to close period', 'ACCOUNTING_CLOSE_PERIOD_ERROR', 500);
        }
    }

    public function openPeriod(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.post');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $startDate = (string) ($input['start_date'] ?? '');
            $endDate = (string) ($input['end_date'] ?? '');
            $bookId = isset($input['book_id']) ? (int) $input['book_id'] : null;
            $entityId = isset($input['entity_id']) ? (int) $input['entity_id'] : null;

            if ($name === '' || !Validation::validateDate($startDate) || !Validation::validateDate($endDate)) {
                return Response::validationError(['period' => 'Name and valid start/end dates are required']);
            }
            if (strtotime($endDate) < strtotime($startDate)) {
                return Response::validationError(['period' => 'End date must be after start date']);
            }

            $this->db->execute(
                'INSERT INTO accounting_periods (farm_id, entity_id, book_id, name, start_date, end_date, status)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [$farmId, $entityId, $bookId, Validation::sanitizeString($name), $startDate, $endDate, 'open']
            );
            $id = (int) $this->db->lastInsertId();
            $this->logAudit('open_period', 'period', $id, $input);
            return Response::success(['id' => $id], 'Period opened', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to open accounting period', ['error' => $e->getMessage()]);
            return Response::error('Failed to open period', 'ACCOUNTING_OPEN_PERIOD_ERROR', 500);
        }
    }

    public function inventoryCosting(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $row = $this->db->queryOne('SELECT method, updated_at FROM accounting_inventory_costing WHERE farm_id = ?', [$farmId]);
                return Response::success($row ? $row : ['method' => 'fifo']);
            }

            $input = $this->request->getBody();
            $method = strtolower(trim((string) ($input['method'] ?? 'fifo')));
            if (!Validation::validateEnum($method, ['fifo', 'lifo', 'weighted_average'])) {
                return Response::validationError(['method' => 'Inventory costing method must be fifo, lifo or weighted_average']);
            }

            $this->db->execute(
                'REPLACE INTO accounting_inventory_costing (farm_id, method) VALUES (?, ?)',
                [$farmId, $method]
            );
            $this->logAudit('set_inventory_costing', 'inventory_costing', null, $input);
            return Response::success(['method' => $method], 'Inventory costing method saved', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle inventory costing', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle inventory costing', 'ACCOUNTING_INVENTORY_COSTING_ERROR', 500);
        }
    }
}
