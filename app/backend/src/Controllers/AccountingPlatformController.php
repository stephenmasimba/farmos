<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class AccountingPlatformController
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

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_accounts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                code VARCHAR(20) NOT NULL,
                name VARCHAR(150) NOT NULL,
                type VARCHAR(20) NOT NULL,
                subtype VARCHAR(50) NULL,
                parent_id INT NULL,
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_account_code_farm (farm_id, code),
                INDEX idx_accounts_farm_type (farm_id, type)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_journal_entries (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                journal_date DATE NOT NULL,
                reference_no VARCHAR(60) NULL,
                memo VARCHAR(255) NULL,
                status VARCHAR(20) NOT NULL DEFAULT "posted",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_journal_farm_date (farm_id, journal_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_journal_lines (
                id INT AUTO_INCREMENT PRIMARY KEY,
                entry_id INT NOT NULL,
                account_id INT NOT NULL,
                description VARCHAR(255) NULL,
                debit DECIMAL(14,2) NOT NULL DEFAULT 0,
                credit DECIMAL(14,2) NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_journal_lines_entry (entry_id),
                INDEX idx_journal_lines_account (account_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_receivables (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                customer_name VARCHAR(180) NOT NULL,
                reference_no VARCHAR(80) NULL,
                amount DECIMAL(14,2) NOT NULL,
                due_date DATE NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_receivables_farm_due (farm_id, due_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS accounting_payables (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                vendor_name VARCHAR(180) NOT NULL,
                reference_no VARCHAR(80) NULL,
                amount DECIMAL(14,2) NOT NULL,
                due_date DATE NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_payables_farm_due (farm_id, due_date)
            )'
        );
    }

    public function accounts(): Response
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
                    'SELECT id, code, name, type, subtype, parent_id, is_active
                     FROM accounting_accounts
                     WHERE farm_id = ?
                     ORDER BY code ASC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $code = trim((string) ($input['code'] ?? ''));
            $name = trim((string) ($input['name'] ?? ''));
            $type = strtolower(trim((string) ($input['type'] ?? '')));
            $subtype = trim((string) ($input['subtype'] ?? ''));
            $parentId = isset($input['parent_id']) ? (int) $input['parent_id'] : null;

            $errors = [];
            if ($code === '') {
                $errors['code'] = 'Account code is required';
            }
            if ($name === '') {
                $errors['name'] = 'Account name is required';
            }
            if (!Validation::validateEnum($type, ['asset', 'liability', 'equity', 'income', 'expense'])) {
                $errors['type'] = 'Invalid account type';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO accounting_accounts (farm_id, code, name, type, subtype, parent_id, is_active)
                 VALUES (?, ?, ?, ?, ?, ?, 1)',
                [
                    $farmId,
                    Validation::sanitizeString($code),
                    Validation::sanitizeString($name),
                    $type,
                    $subtype !== '' ? Validation::sanitizeString($subtype) : null,
                    $parentId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Account created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle accounting accounts', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle accounts', 'ACCOUNTING_ACCOUNTS_ERROR', 500);
        }
    }

    public function journalEntries(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'accounting.read' : 'accounting.post';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, journal_date, reference_no, memo, status
                     FROM accounting_journal_entries
                     WHERE farm_id = ?
                     ORDER BY journal_date DESC, id DESC
                     LIMIT 300',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $journalDate = (string) ($input['journal_date'] ?? date('Y-m-d'));
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $memo = trim((string) ($input['memo'] ?? ''));
            $lines = $input['lines'] ?? [];

            if (!Validation::validateDate($journalDate, 'Y-m-d')) {
                return Response::validationError(['journal_date' => 'Journal date is invalid']);
            }
            if (!is_array($lines) || count($lines) < 2) {
                return Response::validationError(['lines' => 'At least two journal lines are required']);
            }

            $totalDebit = 0.0;
            $totalCredit = 0.0;
            foreach ($lines as $idx => $line) {
                if (!is_array($line)) {
                    return Response::validationError(['lines' => 'Invalid journal lines payload']);
                }
                $accountId = (int) ($line['account_id'] ?? 0);
                $debit = (float) ($line['debit'] ?? 0);
                $credit = (float) ($line['credit'] ?? 0);
                if ($accountId <= 0) {
                    return Response::validationError(['lines' => 'Line ' . ($idx + 1) . ' missing account_id']);
                }
                if ($debit < 0 || $credit < 0) {
                    return Response::validationError(['lines' => 'Debit/credit cannot be negative']);
                }
                $totalDebit += $debit;
                $totalCredit += $credit;
            }
            if (round($totalDebit, 2) !== round($totalCredit, 2)) {
                return Response::validationError(['lines' => 'Debits and credits must balance']);
            }

            $this->db->execute(
                'INSERT INTO accounting_journal_entries (farm_id, journal_date, reference_no, memo, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $journalDate,
                    $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                    $memo !== '' ? Validation::sanitizeString($memo) : null,
                    'posted',
                    $userId,
                ]
            );
            $entryId = (int) $this->db->lastInsertId();

            foreach ($lines as $line) {
                $this->db->execute(
                    'INSERT INTO accounting_journal_lines (entry_id, account_id, description, debit, credit)
                     VALUES (?, ?, ?, ?, ?)',
                    [
                        $entryId,
                        (int) $line['account_id'],
                        !empty($line['description']) ? Validation::sanitizeString((string) $line['description']) : null,
                        (float) ($line['debit'] ?? 0),
                        (float) ($line['credit'] ?? 0),
                    ]
                );
            }

            return Response::success(['id' => $entryId], 'Journal entry posted', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle journal entries', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle journal entries', 'ACCOUNTING_JOURNAL_ERROR', 500);
        }
    }

    public function seedChartOfAccounts(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.post');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            $input = $this->request->getBody();
            $force = !empty($input['force']);
            $existingCountRow = $this->db->queryOne('SELECT COUNT(*) AS c FROM accounting_accounts WHERE farm_id = ?', [$farmId]);
            $existingCount = (int) ($existingCountRow['c'] ?? 0);
            if ($existingCount > 0 && !$force) {
                return Response::validationError(['force' => 'Chart of accounts already exists. Pass force=1 to seed anyway.']);
            }

            $accounts = [
                ['1000', 'Cash on Hand', 'asset', 'cash'],
                ['1100', 'Bank Accounts', 'asset', 'bank'],
                ['1200', 'Accounts Receivable', 'asset', 'ar'],
                ['1300', 'Inventory', 'asset', 'inventory'],
                ['1500', 'Equipment', 'asset', 'fixed_asset'],
                ['1600', 'Accumulated Depreciation', 'asset', 'contra_asset'],
                ['2000', 'Accounts Payable', 'liability', 'ap'],
                ['2100', 'Taxes Payable', 'liability', 'tax'],
                ['2200', 'Payroll Liabilities', 'liability', 'payroll'],
                ['3000', "Owner's Equity", 'equity', 'capital'],
                ['3100', 'Retained Earnings', 'equity', 'retained_earnings'],
                ['4000', 'Sales Revenue', 'income', 'sales'],
                ['4100', 'Livestock Sales', 'income', 'livestock'],
                ['4200', 'Crop Sales', 'income', 'crops'],
                ['4300', 'Service Income', 'income', 'services'],
                ['5000', 'Cost of Goods Sold', 'expense', 'cogs'],
                ['5100', 'Feed Expense', 'expense', 'feed'],
                ['5200', 'Veterinary Expense', 'expense', 'vet'],
                ['5300', 'Labor Expense', 'expense', 'labor'],
                ['5400', 'Utilities Expense', 'expense', 'utilities'],
                ['5500', 'Repairs & Maintenance', 'expense', 'repairs'],
                ['5600', 'Supplies Expense', 'expense', 'supplies'],
                ['5700', 'Fuel & Transport', 'expense', 'fuel'],
                ['5800', 'Depreciation Expense', 'expense', 'depreciation'],
            ];

            $inserted = 0;
            foreach ($accounts as $a) {
                $code = $a[0];
                $name = $a[1];
                $type = $a[2];
                $subtype = $a[3];
                try {
                    $this->db->execute(
                        'INSERT INTO accounting_accounts (farm_id, code, name, type, subtype, parent_id, is_active)
                         VALUES (?, ?, ?, ?, ?, NULL, 1)',
                        [$farmId, $code, Validation::sanitizeString($name), $type, $subtype]
                    );
                    $inserted++;
                } catch (\Throwable $e) {
                }
            }

            return Response::success(['inserted' => $inserted], 'Chart of accounts seeded', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to seed chart of accounts', ['error' => $e->getMessage()]);
            return Response::error('Failed to seed chart of accounts', 'ACCOUNTING_SEED_COA_ERROR', 500);
        }
    }

    public function journalEntryDetails(int $entryId): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            $entry = $this->db->queryOne(
                'SELECT id, journal_date, reference_no, memo, status, created_at
                 FROM accounting_journal_entries
                 WHERE id = ? AND farm_id = ?',
                [$entryId, $farmId]
            );
            if (!$entry) {
                return Response::notFound('Journal entry not found');
            }

            $lines = $this->db->query(
                'SELECT l.id, l.account_id, a.code AS account_code, a.name AS account_name, l.description, l.debit, l.credit
                 FROM accounting_journal_lines l
                 INNER JOIN accounting_accounts a ON a.id = l.account_id AND a.farm_id = ?
                 WHERE l.entry_id = ?
                 ORDER BY l.id ASC',
                [$farmId, $entryId]
            );

            return Response::success([
                'entry' => $entry,
                'lines' => $lines,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch journal entry details', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch journal entry details', 'ACCOUNTING_JOURNAL_DETAIL_ERROR', 500);
        }
    }

    public function reverseJournalEntry(int $entryId): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.post');
            if ($auth !== true) {
                return $auth;
            }
            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            $entry = $this->db->queryOne(
                'SELECT id, journal_date, reference_no, memo, status
                 FROM accounting_journal_entries
                 WHERE id = ? AND farm_id = ?',
                [$entryId, $farmId]
            );
            if (!$entry) {
                return Response::notFound('Journal entry not found');
            }

            $input = $this->request->getBody();
            $reverseDate = trim((string) ($input['reverse_date'] ?? date('Y-m-d')));
            if (!Validation::validateDate($reverseDate, 'Y-m-d')) {
                return Response::validationError(['reverse_date' => 'reverse_date is invalid']);
            }

            $lines = $this->db->query(
                'SELECT account_id, description, debit, credit
                 FROM accounting_journal_lines
                 WHERE entry_id = ?
                 ORDER BY id ASC',
                [$entryId]
            );
            if (count($lines) < 2) {
                return Response::validationError(['lines' => 'Journal entry has no lines to reverse']);
            }

            $ref = 'REV-' . (string) $entryId;
            $memo = 'Reversal of entry #' . (string) $entryId . (isset($entry['memo']) && (string) $entry['memo'] !== '' ? (': ' . (string) $entry['memo']) : '');
            $this->db->execute(
                'INSERT INTO accounting_journal_entries (farm_id, journal_date, reference_no, memo, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $reverseDate,
                    $ref,
                    Validation::sanitizeString($memo),
                    'posted',
                    $userId,
                ]
            );
            $newEntryId = (int) $this->db->lastInsertId();

            foreach ($lines as $line) {
                $this->db->execute(
                    'INSERT INTO accounting_journal_lines (entry_id, account_id, description, debit, credit)
                     VALUES (?, ?, ?, ?, ?)',
                    [
                        $newEntryId,
                        (int) ($line['account_id'] ?? 0),
                        !empty($line['description']) ? Validation::sanitizeString((string) $line['description']) : null,
                        (float) ($line['credit'] ?? 0),
                        (float) ($line['debit'] ?? 0),
                    ]
                );
            }

            return Response::success(['id' => $newEntryId], 'Journal entry reversed', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to reverse journal entry', ['error' => $e->getMessage()]);
            return Response::error('Failed to reverse journal entry', 'ACCOUNTING_JOURNAL_REVERSE_ERROR', 500);
        }
    }

    public function trialBalance(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $startDate = isset($q['start_date']) ? trim((string) $q['start_date']) : '';
            $endDate = isset($q['end_date']) ? trim((string) $q['end_date']) : '';
            if ($startDate !== '' && !Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'start_date is invalid']);
            }
            if ($endDate !== '' && !Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'end_date is invalid']);
            }

            $rows = $this->getAccountSums($farmId, $startDate !== '' ? $startDate : null, $endDate !== '' ? $endDate : null);

            $debits = 0.0;
            $credits = 0.0;
            foreach ($rows as $row) {
                $debits += (float) ($row['total_debit'] ?? 0);
                $credits += (float) ($row['total_credit'] ?? 0);
            }

            return Response::success([
                'start_date' => $startDate !== '' ? $startDate : null,
                'end_date' => $endDate !== '' ? $endDate : null,
                'accounts' => $rows,
                'total_debits' => round($debits, 2),
                'total_credits' => round($credits, 2),
                'is_balanced' => round($debits, 2) === round($credits, 2),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to generate trial balance', ['error' => $e->getMessage()]);
            return Response::error('Failed to generate trial balance', 'ACCOUNTING_TRIAL_BALANCE_ERROR', 500);
        }
    }

    public function profitAndLoss(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $startDate = isset($q['start_date']) ? trim((string) $q['start_date']) : '';
            $endDate = isset($q['end_date']) ? trim((string) $q['end_date']) : '';
            if ($startDate === '' || $endDate === '') {
                return Response::validationError(['date_range' => 'start_date and end_date are required']);
            }
            if (!Validation::validateDate($startDate, 'Y-m-d') || !Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['date_range' => 'start_date/end_date are invalid']);
            }

            $rows = $this->getAccountSums($farmId, $startDate, $endDate);
            $income = [];
            $expenses = [];
            $incomeTotal = 0.0;
            $expenseTotal = 0.0;
            foreach ($rows as $r) {
                $type = (string) ($r['type'] ?? '');
                $debit = (float) ($r['total_debit'] ?? 0);
                $credit = (float) ($r['total_credit'] ?? 0);
                if ($type === 'income') {
                    $amt = round($credit - $debit, 2);
                    if ($amt != 0.0) {
                        $income[] = $r + ['amount' => $amt];
                        $incomeTotal += $amt;
                    }
                } elseif ($type === 'expense') {
                    $amt = round($debit - $credit, 2);
                    if ($amt != 0.0) {
                        $expenses[] = $r + ['amount' => $amt];
                        $expenseTotal += $amt;
                    }
                }
            }

            usort($income, static fn($a, $b) => (float) ($b['amount'] ?? 0) <=> (float) ($a['amount'] ?? 0));
            usort($expenses, static fn($a, $b) => (float) ($b['amount'] ?? 0) <=> (float) ($a['amount'] ?? 0));
            $net = round($incomeTotal - $expenseTotal, 2);

            return Response::success([
                'start_date' => $startDate,
                'end_date' => $endDate,
                'income_total' => round($incomeTotal, 2),
                'expense_total' => round($expenseTotal, 2),
                'net_profit' => $net,
                'income' => $income,
                'expenses' => $expenses,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to generate profit & loss', ['error' => $e->getMessage()]);
            return Response::error('Failed to generate profit & loss', 'ACCOUNTING_PL_ERROR', 500);
        }
    }

    public function balanceSheet(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $asOf = isset($q['as_of']) ? trim((string) $q['as_of']) : '';
            if ($asOf === '' || !Validation::validateDate($asOf, 'Y-m-d')) {
                return Response::validationError(['as_of' => 'as_of (YYYY-MM-DD) is required']);
            }

            $rows = $this->getAccountSums($farmId, null, $asOf);
            $assets = [];
            $liabilities = [];
            $equity = [];
            $assetTotal = 0.0;
            $liabilityTotal = 0.0;
            $equityTotal = 0.0;

            foreach ($rows as $r) {
                $type = (string) ($r['type'] ?? '');
                $debit = (float) ($r['total_debit'] ?? 0);
                $credit = (float) ($r['total_credit'] ?? 0);
                if ($type === 'asset') {
                    $amt = round($debit - $credit, 2);
                    if ($amt != 0.0) {
                        $assets[] = $r + ['amount' => $amt];
                        $assetTotal += $amt;
                    }
                } elseif ($type === 'liability') {
                    $amt = round($credit - $debit, 2);
                    if ($amt != 0.0) {
                        $liabilities[] = $r + ['amount' => $amt];
                        $liabilityTotal += $amt;
                    }
                } elseif ($type === 'equity') {
                    $amt = round($credit - $debit, 2);
                    if ($amt != 0.0) {
                        $equity[] = $r + ['amount' => $amt];
                        $equityTotal += $amt;
                    }
                }
            }

            usort($assets, static fn($a, $b) => (float) ($b['amount'] ?? 0) <=> (float) ($a['amount'] ?? 0));
            usort($liabilities, static fn($a, $b) => (float) ($b['amount'] ?? 0) <=> (float) ($a['amount'] ?? 0));
            usort($equity, static fn($a, $b) => (float) ($b['amount'] ?? 0) <=> (float) ($a['amount'] ?? 0));

            return Response::success([
                'as_of' => $asOf,
                'assets_total' => round($assetTotal, 2),
                'liabilities_total' => round($liabilityTotal, 2),
                'equity_total' => round($equityTotal, 2),
                'assets' => $assets,
                'liabilities' => $liabilities,
                'equity' => $equity,
                'is_balanced' => round($assetTotal, 2) === round($liabilityTotal + $equityTotal, 2),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to generate balance sheet', ['error' => $e->getMessage()]);
            return Response::error('Failed to generate balance sheet', 'ACCOUNTING_BS_ERROR', 500);
        }
    }

    public function cashFlow(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $startDate = isset($q['start_date']) ? trim((string) $q['start_date']) : '';
            $endDate = isset($q['end_date']) ? trim((string) $q['end_date']) : '';
            if ($startDate === '' || $endDate === '') {
                return Response::validationError(['date_range' => 'start_date and end_date are required']);
            }
            if (!Validation::validateDate($startDate, 'Y-m-d') || !Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['date_range' => 'start_date/end_date are invalid']);
            }
            $cashAccountIds = [];
            if (isset($q['cash_account_ids'])) {
                $raw = (string) $q['cash_account_ids'];
                $parts = array_values(array_filter(array_map('trim', explode(',', $raw))));
                foreach ($parts as $p) {
                    if (is_numeric($p)) {
                        $cashAccountIds[] = (int) $p;
                    }
                }
            }
            if (empty($cashAccountIds)) {
                $rows = $this->db->query(
                    'SELECT id FROM accounting_accounts WHERE farm_id = ? AND type = "asset" AND (LOWER(name) LIKE "%cash%" OR LOWER(name) LIKE "%bank%" OR LOWER(COALESCE(subtype,"")) = "cash")',
                    [$farmId]
                );
                foreach ($rows as $r) {
                    $cashAccountIds[] = (int) ($r['id'] ?? 0);
                }
                $cashAccountIds = array_values(array_filter(array_unique($cashAccountIds)));
            }

            if (empty($cashAccountIds)) {
                return Response::success([
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                    'cash_account_ids' => [],
                    'net_cash_change' => 0.0,
                    'by_account_type' => [],
                ]);
            }

            $placeholders = implode(',', array_fill(0, count($cashAccountIds), '?'));
            $entryRows = $this->db->query(
                'SELECT DISTINCT e.id
                 FROM accounting_journal_entries e
                 INNER JOIN accounting_journal_lines l ON l.entry_id = e.id
                 WHERE e.farm_id = ?
                   AND e.status = "posted"
                   AND e.journal_date >= ?
                   AND e.journal_date <= ?
                   AND l.account_id IN (' . $placeholders . ')',
                array_merge([$farmId, $startDate, $endDate], $cashAccountIds)
            );
            $entryIds = array_values(array_filter(array_map(static fn($r) => (int) ($r['id'] ?? 0), $entryRows)));

            $netCash = 0.0;
            $byType = [];
            foreach ($entryIds as $entryId) {
                $lines = $this->db->query(
                    'SELECT a.type, l.account_id, l.debit, l.credit
                     FROM accounting_journal_lines l
                     INNER JOIN accounting_accounts a ON a.id = l.account_id
                     WHERE l.entry_id = ? AND a.farm_id = ?',
                    [$entryId, $farmId]
                );
                $cashDebit = 0.0;
                $cashCredit = 0.0;
                foreach ($lines as $ln) {
                    $aid = (int) ($ln['account_id'] ?? 0);
                    if (in_array($aid, $cashAccountIds, true)) {
                        $cashDebit += (float) ($ln['debit'] ?? 0);
                        $cashCredit += (float) ($ln['credit'] ?? 0);
                    }
                }
                $delta = $cashDebit - $cashCredit;
                if (round($delta, 2) === 0.0) {
                    continue;
                }
                $netCash += $delta;

                if ($delta > 0) {
                    foreach ($lines as $ln) {
                        $aid = (int) ($ln['account_id'] ?? 0);
                        if (in_array($aid, $cashAccountIds, true)) {
                            continue;
                        }
                        $t = (string) ($ln['type'] ?? 'other');
                        $amt = (float) ($ln['credit'] ?? 0);
                        if ($amt <= 0) {
                            continue;
                        }
                        if (!isset($byType[$t])) {
                            $byType[$t] = 0.0;
                        }
                        $byType[$t] += $amt;
                    }
                } else {
                    foreach ($lines as $ln) {
                        $aid = (int) ($ln['account_id'] ?? 0);
                        if (in_array($aid, $cashAccountIds, true)) {
                            continue;
                        }
                        $t = (string) ($ln['type'] ?? 'other');
                        $amt = (float) ($ln['debit'] ?? 0);
                        if ($amt <= 0) {
                            continue;
                        }
                        if (!isset($byType[$t])) {
                            $byType[$t] = 0.0;
                        }
                        $byType[$t] -= $amt;
                    }
                }
            }

            return Response::success([
                'start_date' => $startDate,
                'end_date' => $endDate,
                'cash_account_ids' => $cashAccountIds,
                'net_cash_change' => round($netCash, 2),
                'by_account_type' => array_map(static fn($v) => round((float) $v, 2), $byType),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to generate cash flow', ['error' => $e->getMessage()]);
            return Response::error('Failed to generate cash flow', 'ACCOUNTING_CF_ERROR', 500);
        }
    }

    public function receivables(): Response
    {
        return $this->handleLedgerAging('accounting_receivables', 'customer_name');
    }

    public function payables(): Response
    {
        return $this->handleLedgerAging('accounting_payables', 'vendor_name');
    }

    private function handleLedgerAging(string $table, string $nameField): Response
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
                    "SELECT id, {$nameField} AS party_name, reference_no, amount, due_date, status
                     FROM {$table}
                     WHERE farm_id = ?
                     ORDER BY due_date ASC, id DESC",
                    [$farmId]
                );

                $today = strtotime(date('Y-m-d'));
                $aging = ['current' => 0.0, '1_30' => 0.0, '31_60' => 0.0, '61_90' => 0.0, '90_plus' => 0.0];
                foreach ($rows as &$row) {
                    $due = strtotime((string) ($row['due_date'] ?? date('Y-m-d')));
                    $daysPast = $due !== false ? max(0, (int) floor(($today - $due) / 86400)) : 0;
                    $row['days_past_due'] = $daysPast;
                    $amount = (float) ($row['amount'] ?? 0);
                    if ($daysPast === 0) {
                        $aging['current'] += $amount;
                    } elseif ($daysPast <= 30) {
                        $aging['1_30'] += $amount;
                    } elseif ($daysPast <= 60) {
                        $aging['31_60'] += $amount;
                    } elseif ($daysPast <= 90) {
                        $aging['61_90'] += $amount;
                    } else {
                        $aging['90_plus'] += $amount;
                    }
                }

                return Response::success(['items' => $rows, 'aging' => $aging]);
            }

            $input = $this->request->getBody();
            $partyName = trim((string) ($input['party_name'] ?? ''));
            $referenceNo = trim((string) ($input['reference_no'] ?? ''));
            $amount = $input['amount'] ?? null;
            $dueDate = (string) ($input['due_date'] ?? '');

            $errors = [];
            if ($partyName === '') {
                $errors['party_name'] = 'Party name is required';
            }
            if (!is_numeric($amount) || (float) $amount <= 0) {
                $errors['amount'] = 'Amount must be positive';
            }
            if (!Validation::validateDate($dueDate, 'Y-m-d')) {
                $errors['due_date'] = 'Due date is invalid';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                "INSERT INTO {$table} (farm_id, {$nameField}, reference_no, amount, due_date, status)
                 VALUES (?, ?, ?, ?, ?, ?)",
                [
                    $farmId,
                    Validation::sanitizeString($partyName),
                    $referenceNo !== '' ? Validation::sanitizeString($referenceNo) : null,
                    (float) $amount,
                    $dueDate,
                    'open',
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Ledger item created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle ledger aging', ['error' => $e->getMessage(), 'table' => $table]);
            return Response::error('Failed to handle ledger item', 'ACCOUNTING_LEDGER_ERROR', 500);
        }
    }

    private function getAccountSums(int $farmId, ?string $startDate, ?string $endDate): array
    {
        $where = 'a.farm_id = ?';
        $params = [$farmId];
        $entryJoin = 'LEFT JOIN accounting_journal_entries e ON e.id = l.entry_id AND e.farm_id = a.farm_id AND e.status = "posted"';
        if ($startDate !== null) {
            $entryJoin .= ' AND e.journal_date >= ?';
            $params[] = $startDate;
        }
        if ($endDate !== null) {
            $entryJoin .= ' AND e.journal_date <= ?';
            $params[] = $endDate;
        }

        return $this->db->query(
            'SELECT a.id, a.code, a.name, a.type, a.subtype,
                    COALESCE(SUM(CASE WHEN e.id IS NOT NULL THEN l.debit ELSE 0 END), 0) AS total_debit,
                    COALESCE(SUM(CASE WHEN e.id IS NOT NULL THEN l.credit ELSE 0 END), 0) AS total_credit
             FROM accounting_accounts a
             LEFT JOIN accounting_journal_lines l ON l.account_id = a.id
             ' . $entryJoin . '
             WHERE ' . $where . '
             GROUP BY a.id, a.code, a.name, a.type, a.subtype
             ORDER BY a.code ASC',
            $params
        );
    }
}
