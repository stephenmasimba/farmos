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

    public function trialBalance(): Response
    {
        try {
            $auth = $this->authorizePermission('accounting.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            $rows = $this->db->query(
                'SELECT a.id, a.code, a.name, a.type,
                        COALESCE(SUM(l.debit), 0) AS total_debit,
                        COALESCE(SUM(l.credit), 0) AS total_credit
                 FROM accounting_accounts a
                 LEFT JOIN accounting_journal_lines l ON l.account_id = a.id
                 LEFT JOIN accounting_journal_entries e ON e.id = l.entry_id AND e.farm_id = a.farm_id
                 WHERE a.farm_id = ?
                 GROUP BY a.id, a.code, a.name, a.type
                 ORDER BY a.code ASC',
                [$farmId]
            );

            $debits = 0.0;
            $credits = 0.0;
            foreach ($rows as $row) {
                $debits += (float) ($row['total_debit'] ?? 0);
                $credits += (float) ($row['total_credit'] ?? 0);
            }

            return Response::success([
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
}
