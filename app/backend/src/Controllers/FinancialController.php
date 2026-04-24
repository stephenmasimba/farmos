<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation
};
use FarmOS\Models\FinancialRecord;

/**
 * FinancialController - Manages farm financial records and reporting
 */
class FinancialController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function ensureAdvancedFinancialTables(): void
    {
        $this->ensureCategoryMappingsTable();
        $this->ensureFinancialPeriodsTable();
        $this->ensureBudgetsAndInvoicesTables();

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_categories (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(191) NOT NULL,
                type ENUM(\'income\', \'expense\', \'both\') NOT NULL DEFAULT \'both\',
                parent_id INT NULL,
                active TINYINT(1) NOT NULL DEFAULT 1,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                UNIQUE KEY uniq_fin_categories (farm_id, name),
                INDEX idx_fin_categories_farm (farm_id, active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_audit_events (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                event_type VARCHAR(80) NOT NULL,
                entity_type VARCHAR(80) NOT NULL,
                entity_id VARCHAR(80) NOT NULL,
                payload_json LONGTEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_fin_audit_farm_date (farm_id, created_at),
                INDEX idx_fin_audit_entity (entity_type, entity_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_close_checklist (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                period_id INT NOT NULL,
                check_key VARCHAR(80) NOT NULL,
                status ENUM(\'pending\', \'passed\', \'failed\') NOT NULL DEFAULT \'pending\',
                notes VARCHAR(255) NULL,
                updated_by INT NULL,
                updated_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_fin_close_check (farm_id, period_id, check_key),
                INDEX idx_fin_close_period (farm_id, period_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_budget_lines (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                category VARCHAR(191) NOT NULL,
                period ENUM(\'monthly\', \'yearly\') NOT NULL DEFAULT \'monthly\',
                year INT NOT NULL,
                month INT NULL,
                limit_amount DECIMAL(14,2) NOT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_budget_lines_farm_year (farm_id, year),
                INDEX idx_budget_lines_category (farm_id, category)
            )'
        );

        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN vendor VARCHAR(191) NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN tags_json TEXT NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN category_source VARCHAR(20) NOT NULL DEFAULT "manual"');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN mapped_rule_id INT NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN period_id INT NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN created_by INT NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN updated_by INT NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN currency VARCHAR(10) NOT NULL DEFAULT "USD"');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN reference_number VARCHAR(191) NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN payment_method VARCHAR(50) NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN status VARCHAR(30) NOT NULL DEFAULT "completed"');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN notes TEXT NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE ' . FinancialRecord::table() . ' ADD COLUMN updated_at TIMESTAMP NULL');
        } catch (\Throwable $e) {
        }
    }

    private function audit(int $farmId, string $eventType, string $entityType, string $entityId, array $payload = []): void
    {
        $user = $this->request->getUser();
        $userId = $user && isset($user['user_id']) ? (int) $user['user_id'] : null;
        $this->db->execute(
            'INSERT INTO financial_audit_events (farm_id, event_type, entity_type, entity_id, payload_json, created_by)
             VALUES (?, ?, ?, ?, ?, ?)',
            [
                $farmId,
                $eventType,
                $entityType,
                $entityId,
                json_encode($payload),
                $userId,
            ]
        );
    }

    private function closedPeriodForDate(int $farmId, string $dateTime): ?array
    {
        $date = substr($dateTime, 0, 10);
        $this->ensureFinancialPeriodsTable();
        return $this->db->queryOne(
            'SELECT id, name, start_date, end_date, status
             FROM financial_periods
             WHERE farm_id = ? AND status = \'closed\' AND start_date <= ? AND end_date >= ?
             LIMIT 1',
            [$farmId, $date, $date]
        );
    }

    private function canEditDate(int $farmId, string $dateTime): bool
    {
        return $this->closedPeriodForDate($farmId, $dateTime) === null;
    }

    /**
     * List financial records
     * GET /api/financial/records?farm_id={id}&type={income|expense}&page={page}
     */
    public function index(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            // Pagination
            $page = (int) ($this->request->getQuery()['page'] ?? 1);
            $perPage = (int) ($this->request->getQuery()['per_page'] ?? 15);
            $page = max(1, $page);
            $perPage = min($perPage, 100);

            // Filters
            $type = $this->request->getQuery()['type'] ?? null;
            $category = $this->request->getQuery()['category'] ?? null;
            $startDate = $this->request->getQuery()['start_date'] ?? null;
            $endDate = $this->request->getQuery()['end_date'] ?? null;

            $query = FinancialRecord::query($this->db)
                ->where('farm_id', $farmId);

            if ($type) {
                if (!Validation::validateEnum($type, ['income', 'expense'])) {
                    return Response::validationError(['type' => 'Invalid type']);
                }
                $query->where('type', $type);
            }

            if ($category) {
                $category = Validation::sanitizeString($category);
                $query->where('category', $category);
            }

            if ($startDate && Validation::validateDate($startDate, 'Y-m-d')) {
                $query->where('date >=', $startDate);
            }

            if ($endDate && Validation::validateDate($endDate, 'Y-m-d')) {
                $query->where('date <=', $endDate . ' 23:59:59');
            }

            $result = $query
                ->orderBy('date', 'DESC')
                ->paginate($page, $perPage);

            Logger::info('Listed financial records', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'count' => count($result['data']),
            ]);

            return Response::success([
                'records' => array_map(fn($m) => $m->getFullProfile(), $result['data']),
                'pagination' => [
                    'page' => $result['page'],
                    'per_page' => $result['per_page'],
                    'total' => $result['total'],
                    'last_page' => $result['last_page'],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to list financial records', ['error' => $e->getMessage()]);
            return Response::error('Failed to list records', 'LIST_ERROR', 500);
        }
    }

    /**
     * Create financial record
     * POST /api/financial/records
     */
    public function store(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $input = $this->request->getBody();

            // Validate required fields
            $errors = [];
            if (empty($input['farm_id'])) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if (empty($input['type'])) {
                $errors['type'] = 'Type (income/expense) is required';
            }
            if (empty($input['category']) && empty($input['description']) && empty($input['reference_number'])) {
                $errors['category'] = 'Category is required unless description or reference is available for auto-categorization';
            }
            if (!isset($input['amount'])) {
                $errors['amount'] = 'Amount is required';
            }
            if (empty($input['date'])) {
                $errors['date'] = 'Date is required';
            }

            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            // Validate and sanitize
            if (!Validation::validateEnum($input['type'], ['income', 'expense'])) {
                return Response::validationError(['type' => 'Type must be income or expense']);
            }

            $input['category'] = Validation::sanitizeString($input['category']);
            $input['description'] = Validation::sanitizeString($input['description'] ?? '');
            $input['reference_number'] = Validation::sanitizeString($input['reference_number'] ?? '');
            $input['payment_method'] = Validation::sanitizeString($input['payment_method'] ?? 'cash');
            $input['notes'] = Validation::sanitizeString($input['notes'] ?? '');
            $input['currency'] = $input['currency'] ?? 'USD';
            $input['status'] = $input['status'] ?? 'completed';

            $this->ensureCategoryMappingsTable();
            $mappingMeta = $this->resolveCategoryForRecord((int) $input['farm_id'], $input['category'], $input['description'], $input['reference_number'], (string) ($input['vendor'] ?? ''), (string) ($input['payment_method'] ?? ''));
            $resolvedCategory = $mappingMeta['category'];
            if ($resolvedCategory === '') {
                return Response::validationError(['category' => 'Category is required']);
            }
            $input['category'] = $resolvedCategory;
            $input['category_source'] = (string) ($mappingMeta['source'] ?? 'manual');
            $input['mapped_rule_id'] = isset($mappingMeta['rule_id']) ? (int) $mappingMeta['rule_id'] : null;
            $input['vendor'] = Validation::sanitizeString((string) ($input['vendor'] ?? ''));
            if (isset($input['tags']) && is_array($input['tags'])) {
                $input['tags_json'] = json_encode($input['tags']);
            }

            // Validate amount
            if (!is_numeric($input['amount']) || $input['amount'] <= 0) {
                return Response::validationError(['amount' => 'Amount must be a positive number']);
            }
            $input['amount'] = (float) $input['amount'];

            // Validate date
            if (!Validation::validateDate($input['date'], 'Y-m-d')) {
                if (!Validation::validateDate($input['date'], 'Y-m-d H:i:s')) {
                    return Response::validationError(['date' => 'Invalid date format']);
                }
            } else {
                $input['date'] = $input['date'] . ' 00:00:00';
            }

            if (!$this->canEditDate((int) $input['farm_id'], (string) $input['date'])) {
                $period = $this->closedPeriodForDate((int) $input['farm_id'], (string) $input['date']);
                $name = $period ? (string) ($period['name'] ?? 'closed period') : 'closed period';
                return Response::validationError(['date' => 'This date is in a closed period: ' . $name]);
            }

            $input['created_by'] = (int) $user['user_id'];
            $input['updated_by'] = (int) $user['user_id'];

            // Create record
            $record = new FinancialRecord($this->db, array_filter($input, fn($k) => in_array($k, FinancialRecord::fillable()), ARRAY_FILTER_USE_KEY));
            $recordId = $record->save();

            $this->audit((int) $input['farm_id'], 'record.created', 'financial_record', (string) $recordId, [
                'type' => $input['type'],
                'amount' => $input['amount'],
                'category' => $input['category'],
                'category_source' => $input['category_source'] ?? 'manual',
            ]);

            Logger::info('Created financial record', [
                'user_id' => $user['user_id'],
                'record_id' => $recordId,
                'farm_id' => $input['farm_id'],
                'type' => $input['type'],
                'amount' => $input['amount'],
            ]);

            return Response::success(
                array_merge($record->toArray(), ['id' => $recordId]),
                'Financial record created successfully',
                201
            );
        } catch (\Exception $e) {
            Logger::error('Failed to create financial record', ['error' => $e->getMessage()]);
            return Response::error('Failed to create record', 'CREATE_ERROR', 500);
        }
    }

    /**
     * Get financial record details
     * GET /api/financial/records/{id}
     */
    public function show(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $record = FinancialRecord::find($id, $this->db);
            if (!$record) {
                return Response::notFound('Financial record not found');
            }

            Logger::info('Retrieved financial record', [
                'user_id' => $user['user_id'],
                'record_id' => $id,
            ]);

            return Response::success($record->getFullProfile());
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve financial record', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve record', 'RETRIEVE_ERROR', 500);
        }
    }

    /**
     * Update financial record
     * PUT /api/financial/records/{id}
     */
    public function update(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $record = FinancialRecord::find($id, $this->db);
            if (!$record) {
                return Response::notFound('Financial record not found');
            }

            $farmId = $this->getFarmIdFromInputOrQuery() ?: 1;
            $recordDate = (string) ($record->attributes['date'] ?? '');
            if ($recordDate !== '' && !$this->canEditDate($farmId, $recordDate)) {
                $period = $this->closedPeriodForDate($farmId, $recordDate);
                $name = $period ? (string) ($period['name'] ?? 'closed period') : 'closed period';
                return Response::validationError(['record' => 'This record is in a closed period: ' . $name]);
            }

            $input = $this->request->getBody();

            // Update allowed fields
            if (!empty($input['description'])) {
                $record->description = Validation::sanitizeString($input['description']);
            }
            if (!empty($input['category'])) {
                $record->category = Validation::sanitizeString($input['category']);
                $record->category_source = 'manual';
                $record->mapped_rule_id = null;
            }
            if (isset($input['vendor'])) {
                $record->vendor = Validation::sanitizeString((string) $input['vendor']);
            }
            if (isset($input['tags']) && is_array($input['tags'])) {
                $record->tags_json = json_encode($input['tags']);
            }
            if (isset($input['amount'])) {
                if (!is_numeric($input['amount']) || $input['amount'] <= 0) {
                    return Response::validationError(['amount' => 'Amount must be positive']);
                }
                $record->amount = (float) $input['amount'];
            }
            if (isset($input['status'])) {
                if (!Validation::validateEnum($input['status'], ['completed', 'pending', 'cancelled'])) {
                    return Response::validationError(['status' => 'Invalid status']);
                }
                $record->status = $input['status'];
            }
            if (!empty($input['reference_number'])) {
                $record->reference_number = Validation::sanitizeString($input['reference_number']);
            }
            if (!empty($input['notes'])) {
                $record->notes = Validation::sanitizeString($input['notes']);
            }

            $record->updated_at = date('Y-m-d H:i:s');
            $record->updated_by = (int) $user['user_id'];
            $record->save();

            $this->audit($farmId, 'record.updated', 'financial_record', (string) $id, ['fields' => array_keys($input)]);

            Logger::info('Updated financial record', [
                'user_id' => $user['user_id'],
                'record_id' => $id,
            ]);

            return Response::success($record->getFullProfile(), 'Financial record updated successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to update financial record', ['error' => $e->getMessage()]);
            return Response::error('Failed to update record', 'UPDATE_ERROR', 500);
        }
    }

    /**
     * Delete financial record
     * DELETE /api/financial/records/{id}
     */
    public function destroy(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $record = FinancialRecord::find($id, $this->db);
            if ($record) {
                $farmId = $this->getFarmIdFromInputOrQuery() ?: 1;
                $recordDate = (string) ($record->attributes['date'] ?? '');
                if ($recordDate !== '' && !$this->canEditDate($farmId, $recordDate)) {
                    $period = $this->closedPeriodForDate($farmId, $recordDate);
                    $name = $period ? (string) ($period['name'] ?? 'closed period') : 'closed period';
                    return Response::validationError(['record' => 'This record is in a closed period: ' . $name]);
                }
            }

            $affected = FinancialRecord::destroy($id, $this->db);
            if (!$affected) {
                return Response::notFound('Financial record not found');
            }

            if ($record) {
                $farmId = $this->getFarmIdFromInputOrQuery() ?: 1;
                $this->audit($farmId, 'record.deleted', 'financial_record', (string) $id);
            }

            Logger::info('Deleted financial record', [
                'user_id' => $user['user_id'],
                'record_id' => $id,
            ]);

            return Response::success(['id' => $id], 'Financial record deleted successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to delete financial record', ['error' => $e->getMessage()]);
            return Response::error('Failed to delete record', 'DELETE_ERROR', 500);
        }
    }

    /**
     * Get financial summary
     * GET /api/financial/summary?farm_id={id}&start_date={date}&end_date={date}
     */
    public function getSummary(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $startDate = $this->request->getQuery()['start_date'] ?? null;
            $endDate = $this->request->getQuery()['end_date'] ?? null;

            $totalIncome = FinancialRecord::totalByType($farmId, 'income', $this->db);
            $totalExpense = FinancialRecord::totalByType($farmId, 'expense', $this->db);

            // Filter by date range if provided
            if ($startDate && $endDate) {
                if (!Validation::validateDate($startDate, 'Y-m-d') || !Validation::validateDate($endDate, 'Y-m-d')) {
                    return Response::validationError(['date' => 'Invalid date format']);
                }

                $records = FinancialRecord::byDateRange($farmId, $startDate, $endDate, $this->db);
                $totalIncome = array_sum(array_map(fn($r) => $r->isIncome() ? ($r->attributes['amount'] ?? 0) : 0, $records));
                $totalExpense = array_sum(array_map(fn($r) => !$r->isIncome() ? ($r->attributes['amount'] ?? 0) : 0, $records));
            }

            $netProfit = $totalIncome - $totalExpense;

            Logger::info('Retrieved financial summary', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'date_range' => [
                    'start' => $startDate,
                    'end' => $endDate,
                ],
                'summary' => [
                    'total_income' => round($totalIncome, 2),
                    'total_expense' => round($totalExpense, 2),
                    'net_profit' => round($netProfit, 2),
                    'profit_margin' => $totalIncome > 0 ? round(($netProfit / $totalIncome) * 100, 2) : 0,
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get financial summary', ['error' => $e->getMessage()]);
            return Response::error('Failed to get summary', 'SUMMARY_ERROR', 500);
        }
    }

    /**
     * Get monthly report
     * GET /api/financial/report/monthly?farm_id={id}&year={year}&month={month}
     */
    public function getMonthlyReport(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $year = $this->request->getQuery()['year'] ?? date('Y');
            $month = str_pad($this->request->getQuery()['month'] ?? date('m'), 2, '0', STR_PAD_LEFT);

            if (!Validation::validateDate("$year-$month-01", 'Y-m-d')) {
                return Response::validationError(['date' => 'Invalid year/month']);
            }

            $summary = FinancialRecord::monthlySummary($farmId, $year, $month, $this->db);

            // Get breakdown by category
            $startDate = "$year-$month-01";
            $endDate = date('Y-m-t', strtotime($startDate));

            $incomeByCategory = $this->db->query(
                'SELECT category, SUM(amount) as total, COUNT(*) as count 
                 FROM ' . FinancialRecord::table() . ' 
                 WHERE type = \'income\' AND date >= ? AND date <= ? 
                 GROUP BY category',
                [$startDate, $endDate]
            );

            $expenseByCategory = $this->db->query(
                'SELECT category, SUM(amount) as total, COUNT(*) as count 
                 FROM ' . FinancialRecord::table() . ' 
                 WHERE type = \'expense\' AND date >= ? AND date <= ? 
                 GROUP BY category',
                [$startDate, $endDate]
            );

            Logger::info('Retrieved monthly financial report', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'period' => "$year-$month",
            ]);

            return Response::success([
                'report' => $summary,
                'breakdown' => [
                    'income_by_category' => $incomeByCategory,
                    'expense_by_category' => $expenseByCategory,
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get monthly report', ['error' => $e->getMessage()]);
            return Response::error('Failed to get report', 'REPORT_ERROR', 500);
        }
    }

    /**
     * Get yearly report
     * GET /api/financial/report/yearly?farm_id={id}&year={year}
     */
    public function getYearlyReport(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $year = $this->request->getQuery()['year'] ?? date('Y');

            if (!Validation::validateInteger($year, 1900, 2100)) {
                return Response::validationError(['year' => 'Invalid year']);
            }

            $yearSummary = FinancialRecord::yearSummary($farmId, $year, $this->db);

            // Get monthly breakdown
            $monthlyData = [];
            for ($m = 1; $m <= 12; $m++) {
                $month = str_pad($m, 2, '0', STR_PAD_LEFT);
                $monthlyData[] = FinancialRecord::monthlySummary($farmId, $year, $month, $this->db);
            }

            Logger::info('Retrieved yearly financial report', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'year' => $year,
            ]);

            return Response::success([
                'yearly_summary' => $yearSummary,
                'monthly_breakdown' => $monthlyData,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get yearly report', ['error' => $e->getMessage()]);
            return Response::error('Failed to get report', 'REPORT_ERROR', 500);
        }
    }

    /**
     * Get categories
     * GET /api/financial/categories?farm_id={id}
     */
    public function getCategories(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $categories = FinancialRecord::categories($farmId, $this->db);

            Logger::info('Retrieved financial categories', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'count' => count($categories),
            ]);

            return Response::success(['categories' => $categories]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve categories', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve categories', 'RETRIEVE_ERROR', 500);
        }
    }

    private function buildBudgetReport(int $farmId, int $year, ?int $month = null): array
    {
        $budgets = $this->db->query(
            'SELECT id, category, period, year, month, limit_amount
             FROM financial_budget_lines
             WHERE farm_id = ? AND year = ?
             ORDER BY category ASC, period ASC, month ASC, id DESC',
            [$farmId, $year]
        );

        return array_map(function (array $budget) use ($farmId, $month): array {
            $period = (string) $budget['period'];
            $year = (int) $budget['year'];
            $budgetMonth = (int) ($budget['month'] ?? 0);
            $effectiveMonth = $period === 'monthly' ? ($budgetMonth ?: ($month ?: (int) date('n'))) : 0;

            if ($period === 'monthly') {
                $start = sprintf('%04d-%02d-01', $year, $effectiveMonth);
                $end = date('Y-m-t', strtotime($start));
            } else {
                $start = sprintf('%04d-01-01', $year);
                $end = sprintf('%04d-12-31', $year);
            }

            $spentRow = $this->db->queryOne(
                'SELECT COALESCE(SUM(amount), 0) AS spent
                 FROM ' . FinancialRecord::table() . '
                 WHERE type = ? AND category = ? AND date >= ? AND date <= ?',
                ['expense', (string) $budget['category'], $start, $end . ' 23:59:59']
            );

            $spent = isset($spentRow['spent']) ? (float) $spentRow['spent'] : 0.0;
            $limit = (float) $budget['limit_amount'];
            $variance = round($limit - $spent, 2);

            return [
                'id' => (int) $budget['id'],
                'category' => (string) $budget['category'],
                'period' => $period,
                'year' => $year,
                'month' => $period === 'monthly' ? $effectiveMonth : null,
                'limit' => $limit,
                'spent' => round($spent, 2),
                'variance' => $variance,
                'status' => $variance < 0 ? 'over_budget' : 'on_track',
            ];
        }, $budgets);
    }

    private function ensureCategoryMappingsTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_category_mappings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                keyword VARCHAR(191) NOT NULL,
                category VARCHAR(191) NOT NULL,
                active TINYINT(1) NOT NULL DEFAULT 1,
                match_field VARCHAR(40) NOT NULL DEFAULT "combined",
                match_type VARCHAR(20) NOT NULL DEFAULT "contains",
                priority INT NOT NULL DEFAULT 0,
                tags_json TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_financial_category_mappings_farm (farm_id),
                INDEX idx_financial_category_mappings_keyword (keyword)
            )'
        );

        try {
            $this->db->execute('ALTER TABLE financial_category_mappings ADD COLUMN match_field VARCHAR(40) NOT NULL DEFAULT "combined"');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE financial_category_mappings ADD COLUMN match_type VARCHAR(20) NOT NULL DEFAULT "contains"');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE financial_category_mappings ADD COLUMN priority INT NOT NULL DEFAULT 0');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE financial_category_mappings ADD COLUMN tags_json TEXT NULL');
        } catch (\Throwable $e) {
        }
    }

    private function ensureFinancialPeriodsTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_periods (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(64) NOT NULL,
                period_type ENUM(\'monthly\', \'yearly\') NOT NULL DEFAULT \'monthly\',
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                status ENUM(\'open\', \'closed\') NOT NULL DEFAULT \'open\',
                closed_at DATETIME NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_financial_periods_farm (farm_id),
                INDEX idx_financial_periods_dates (start_date, end_date)
            )'
        );
    }

    private function resolveCategoryForRecord(int $farmId, string $category, string $description, string $reference, string $vendor = '', string $paymentMethod = ''): array
    {
        $category = trim($category);
        $genericCategories = ['other', 'misc', 'uncategorized', 'general'];

        if ($category === '' || in_array(strtolower($category), $genericCategories, true)) {
            $mapped = $this->findCategoryMapping($farmId, $description, $reference, $vendor, $paymentMethod);
            $mappedCategory = $mapped['category'] ?? null;
            if ($mappedCategory !== null) {
                return [
                    'category' => (string) $mappedCategory,
                    'source' => 'mapped',
                    'rule_id' => isset($mapped['rule_id']) ? (int) $mapped['rule_id'] : null,
                    'tags' => $mapped['tags'] ?? [],
                ];
            }
        }

        return [
            'category' => $category,
            'source' => 'manual',
            'rule_id' => null,
            'tags' => [],
        ];
    }

    private function findCategoryMapping(int $farmId, string $description, string $reference, string $vendor = '', string $paymentMethod = ''): ?array
    {
        $this->ensureCategoryMappingsTable();
        $mappings = $this->db->query(
            'SELECT id, keyword, category, match_field, match_type, priority, tags_json
             FROM financial_category_mappings
             WHERE farm_id = ? AND active = 1
             ORDER BY priority DESC, CHAR_LENGTH(keyword) DESC, id ASC',
            [$farmId]
        );

        $description = strtolower(trim($description));
        $reference = strtolower(trim($reference));
        $vendor = strtolower(trim($vendor));
        $paymentMethod = strtolower(trim($paymentMethod));
        $combined = trim($description . ' ' . $reference . ' ' . $vendor . ' ' . $paymentMethod);

        foreach ($mappings as $mapping) {
            $needle = strtolower((string) ($mapping['keyword'] ?? ''));
            if ($needle === '') {
                continue;
            }
            $field = (string) ($mapping['match_field'] ?? 'combined');
            $haystack = $combined;
            if ($field === 'description') {
                $haystack = $description;
            } elseif ($field === 'reference_number') {
                $haystack = $reference;
            } elseif ($field === 'vendor') {
                $haystack = $vendor;
            } elseif ($field === 'payment_method') {
                $haystack = $paymentMethod;
            }

            $type = strtolower((string) ($mapping['match_type'] ?? 'contains'));
            $matched = false;
            if ($type === 'equals') {
                $matched = $haystack === $needle;
            } elseif ($type === 'starts_with') {
                $matched = str_starts_with($haystack, $needle);
            } elseif ($type === 'regex') {
                $matched = @preg_match('/' . str_replace('/', '\/', $needle) . '/i', $haystack) === 1;
            } else {
                $matched = stripos($haystack, $needle) !== false;
            }

            if ($matched) {
                $tags = [];
                $tagsJson = (string) ($mapping['tags_json'] ?? '');
                if ($tagsJson !== '') {
                    $decoded = json_decode($tagsJson, true);
                    if (is_array($decoded)) {
                        $tags = $decoded;
                    }
                }
                return [
                    'rule_id' => (int) ($mapping['id'] ?? 0),
                    'category' => (string) ($mapping['category'] ?? ''),
                    'tags' => $tags,
                ];
            }
        }

        return null;
    }

    public function getBudgetVariance(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureBudgetsAndInvoicesTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $year = (int) ($this->request->getQuery()['year'] ?? (int) date('Y'));
            $month = isset($this->request->getQuery()['month']) ? (int) $this->request->getQuery()['month'] : null;
            if (!Validation::validateInteger($year, 1900, 2100)) {
                return Response::validationError(['year' => 'Invalid year']);
            }
            if ($month !== null && !Validation::validateInteger($month, 1, 12)) {
                return Response::validationError(['month' => 'Invalid month']);
            }

            $budgetPerformance = $this->buildBudgetReport($farmId, $year, $month);
            $totals = ['budget' => 0.0, 'spent' => 0.0, 'variance' => 0.0, 'over_budget_count' => 0];
            foreach ($budgetPerformance as $budget) {
                $totals['budget'] += $budget['limit'];
                $totals['spent'] += $budget['spent'];
                $totals['variance'] += $budget['variance'];
                if ($budget['variance'] < 0) {
                    $totals['over_budget_count']++;
                }
            }

            return Response::success([
                'year' => $year,
                'month' => $month,
                'budgets' => $budgetPerformance,
                'totals' => [
                    'budget' => round($totals['budget'], 2),
                    'spent' => round($totals['spent'], 2),
                    'variance' => round($totals['variance'], 2),
                    'over_budget_count' => $totals['over_budget_count'],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve budget variance', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve budget variance', 'BUDGET_VARIANCE_ERROR', 500);
        }
    }

    public function getCostAllocation(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $startDate = Validation::sanitizeString((string) ($this->request->getQuery()['start_date'] ?? date('Y-m-d', strtotime('-30 days'))));
            $endDate = Validation::sanitizeString((string) ($this->request->getQuery()['end_date'] ?? date('Y-m-d')));
            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'Invalid start date']);
            }
            if (!Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'Invalid end date']);
            }

            $categories = $this->db->query(
                'SELECT category, SUM(amount) AS total_cost, COUNT(*) AS transactions
                 FROM ' . FinancialRecord::table() . '
                 WHERE type = ? AND date >= ? AND date <= ?
                 GROUP BY category
                 ORDER BY total_cost DESC',
                ['expense', $startDate, $endDate]
            );

            $totalExpense = 0.0;
            foreach ($categories as $row) {
                $totalExpense += (float) ($row['total_cost'] ?? 0);
            }

            return Response::success([
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ],
                'total_expense' => round($totalExpense, 2),
                'category_allocation' => array_map(static function (array $row): array {
                    return [
                        'category' => (string) ($row['category'] ?? 'Uncategorized'),
                        'total_cost' => round((float) ($row['total_cost'] ?? 0), 2),
                        'transactions' => (int) ($row['transactions'] ?? 0),
                    ];
                }, $categories),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve financial cost allocation', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve financial cost allocation', 'FINANCIAL_COST_ALLOCATION_ERROR', 500);
        }
    }

    public function getCategoryMappings(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureCategoryMappingsTable();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $mappings = $this->db->query(
                'SELECT id, keyword, category, active, match_field, match_type, priority, tags_json, created_at, updated_at
                 FROM financial_category_mappings
                 WHERE farm_id = ?
                 ORDER BY active DESC, priority DESC, keyword ASC',
                [$farmId]
            );

            return Response::success(['mappings' => $mappings]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve category mappings', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve category mappings', 'CATEGORY_MAPPINGS_ERROR', 500);
        }
    }

    public function saveCategoryMapping(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureCategoryMappingsTable();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = (int) ($this->request->getBody()['farm_id'] ?? 0);
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $input = $this->request->getBody();
            $keyword = Validation::sanitizeString((string) ($input['keyword'] ?? ''));
            $category = Validation::sanitizeString((string) ($input['category'] ?? ''));
            $active = isset($input['active']) && ((int) $input['active'] === 1);
            $matchField = Validation::sanitizeString((string) ($input['match_field'] ?? 'combined'));
            $matchType = strtolower(Validation::sanitizeString((string) ($input['match_type'] ?? 'contains')));
            $priority = isset($input['priority']) && is_numeric($input['priority']) ? (int) $input['priority'] : 0;
            $tagsJson = null;
            if (isset($input['tags']) && is_array($input['tags'])) {
                $tagsJson = json_encode($input['tags']);
            }

            $errors = [];
            if ($keyword === '') {
                $errors['keyword'] = 'Keyword is required';
            }
            if ($category === '') {
                $errors['category'] = 'Category is required';
            }
            if (!Validation::validateEnum($matchField, ['combined', 'description', 'reference_number', 'vendor', 'payment_method'])) {
                $errors['match_field'] = 'Invalid match_field';
            }
            if (!Validation::validateEnum($matchType, ['contains', 'starts_with', 'equals', 'regex'])) {
                $errors['match_type'] = 'Invalid match_type';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO financial_category_mappings (farm_id, keyword, category, active, match_field, match_type, priority, tags_json, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $keyword,
                    $category,
                    $active ? 1 : 0,
                    $matchField,
                    $matchType,
                    $priority,
                    $tagsJson,
                    (int) $user['user_id'],
                    date('Y-m-d H:i:s'),
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Category mapping saved', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to save category mapping', ['error' => $e->getMessage()]);
            return Response::error('Failed to save category mapping', 'CATEGORY_MAPPING_SAVE_ERROR', 500);
        }
    }

    public function deleteCategoryMapping(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            if ($id <= 0) {
                return Response::validationError(['id' => 'Invalid mapping ID']);
            }

            $record = $this->db->queryOne(
                'SELECT id FROM financial_category_mappings WHERE id = ? AND farm_id = ?',
                [$id, $farmId]
            );
            if (!$record) {
                return Response::notFound('Category mapping not found');
            }

            $this->db->execute('DELETE FROM financial_category_mappings WHERE id = ?', [$id]);

            return Response::success(['id' => $id], 'Category mapping deleted');
        } catch (\Exception $e) {
            Logger::error('Failed to delete category mapping', ['error' => $e->getMessage()]);
            return Response::error('Failed to delete category mapping', 'CATEGORY_MAPPING_DELETE_ERROR', 500);
        }
    }

    public function categories(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, name, type, parent_id, active, created_at, updated_at
                     FROM financial_categories
                     WHERE farm_id = ?
                     ORDER BY active DESC, parent_id ASC, name ASC',
                    [$farmId]
                );
                return Response::success(['categories' => $rows]);
            }

            $input = $this->request->getBody();
            $name = Validation::sanitizeString((string) ($input['name'] ?? ''));
            $type = (string) ($input['type'] ?? 'both');
            $parentId = isset($input['parent_id']) && is_numeric($input['parent_id']) ? (int) $input['parent_id'] : null;
            $active = isset($input['active']) ? ((int) $input['active'] === 1) : true;

            $errors = [];
            if ($name === '') {
                $errors['name'] = 'Name is required';
            }
            if (!Validation::validateEnum($type, ['income', 'expense', 'both'])) {
                $errors['type'] = 'Invalid type';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO financial_categories (farm_id, name, type, parent_id, active, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $name,
                    $type,
                    $parentId,
                    $active ? 1 : 0,
                    (int) $user['user_id'],
                    date('Y-m-d H:i:s'),
                ]
            );
            $id = (int) $this->db->lastInsertId();
            $this->audit($farmId, 'category.created', 'financial_category', (string) $id, ['name' => $name, 'type' => $type]);
            return Response::success(['id' => $id], 'Category created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle financial categories', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle categories', 'FIN_CATEGORIES_ERROR', 500);
        }
    }

    public function budgetVsActual(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $year = (int) ($this->request->getQuery()['year'] ?? (int) date('Y'));
            $month = isset($this->request->getQuery()['month']) ? (int) $this->request->getQuery()['month'] : null;
            $period = (string) ($this->request->getQuery()['period'] ?? '');
            if ($period !== '' && !Validation::validateEnum($period, ['monthly', 'yearly'])) {
                return Response::validationError(['period' => 'Invalid period']);
            }
            if ($month !== null && !Validation::validateInteger($month, 1, 12)) {
                return Response::validationError(['month' => 'Invalid month']);
            }

            $budgets = $this->buildBudgetReport($farmId, $year, $month);
            if ($period !== '') {
                $budgets = array_values(array_filter($budgets, fn($b) => ($b['period'] ?? '') === $period));
            }

            $totals = ['budget' => 0.0, 'actual' => 0.0, 'variance' => 0.0];
            foreach ($budgets as &$b) {
                $totals['budget'] += (float) ($b['limit'] ?? 0);
                $totals['actual'] += (float) ($b['spent'] ?? 0);
                $totals['variance'] += (float) ($b['variance'] ?? 0);
                $start = '';
                $end = '';
                if (($b['period'] ?? '') === 'monthly') {
                    $start = sprintf('%04d-%02d-01', (int) $b['year'], (int) ($b['month'] ?? 1));
                    $end = date('Y-m-t', strtotime($start));
                } else {
                    $start = sprintf('%04d-01-01', (int) $b['year']);
                    $end = sprintf('%04d-12-31', (int) $b['year']);
                }
                $b['drilldown'] = [
                    'url' => '/api/financial/budget-vs-actual/drilldown?farm_id=' . $farmId . '&category=' . urlencode((string) $b['category']) . '&start_date=' . $start . '&end_date=' . $end,
                    'start_date' => $start,
                    'end_date' => $end,
                ];
            }

            return Response::success([
                'year' => $year,
                'month' => $month,
                'period' => $period !== '' ? $period : null,
                'budgets' => $budgets,
                'totals' => [
                    'budget' => round($totals['budget'], 2),
                    'actual' => round($totals['actual'], 2),
                    'variance' => round($totals['variance'], 2),
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed budget vs actual', ['error' => $e->getMessage()]);
            return Response::error('Failed budget vs actual', 'BUDGET_VS_ACTUAL_ERROR', 500);
        }
    }

    public function budgetVsActualDrilldown(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $q = $this->request->getQuery();
            $farmId = (int) ($q['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $category = Validation::sanitizeString((string) ($q['category'] ?? ''));
            $startDate = Validation::sanitizeString((string) ($q['start_date'] ?? ''));
            $endDate = Validation::sanitizeString((string) ($q['end_date'] ?? ''));
            if ($category === '') {
                return Response::validationError(['category' => 'Category is required']);
            }
            if (!Validation::validateDate($startDate, 'Y-m-d') || !Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['date' => 'Invalid date format']);
            }

            $rows = $this->db->query(
                'SELECT id, type, category, vendor, description, amount, currency, date, status, reference_number, payment_method
                 FROM ' . FinancialRecord::table() . '
                 WHERE type = \'expense\' AND category = ? AND date >= ? AND date <= ?
                 ORDER BY date DESC, id DESC
                 LIMIT 1000',
                [$category, $startDate, $endDate . ' 23:59:59']
            );
            $total = 0.0;
            foreach ($rows as $r) {
                $total += (float) ($r['amount'] ?? 0);
            }
            return Response::success([
                'category' => $category,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'total' => round($total, 2),
                'records' => $rows,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed budget drilldown', ['error' => $e->getMessage()]);
            return Response::error('Failed drilldown', 'BUDGET_DRILLDOWN_ERROR', 500);
        }
    }

    public function reclassify(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $startDate = Validation::sanitizeString((string) ($input['start_date'] ?? ''));
            $endDate = Validation::sanitizeString((string) ($input['end_date'] ?? ''));
            $mode = (string) ($input['mode'] ?? 'unclassified');
            if (!Validation::validateEnum($mode, ['unclassified', 'mapped'])) {
                return Response::validationError(['mode' => 'Invalid mode']);
            }
            if ($startDate !== '' && !Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'Invalid date']);
            }
            if ($endDate !== '' && !Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'Invalid date']);
            }

            $where = '1=1';
            $params = [];
            if ($startDate !== '') {
                $where .= ' AND date >= ?';
                $params[] = $startDate;
            }
            if ($endDate !== '') {
                $where .= ' AND date <= ?';
                $params[] = $endDate . ' 23:59:59';
            }

            if ($mode === 'unclassified') {
                $where .= ' AND (category IS NULL OR category = \'\' OR LOWER(category) IN (\'other\',\'misc\',\'uncategorized\',\'general\'))';
            } else {
                $where .= ' AND category_source = \'mapped\'';
            }

            $rows = $this->db->query(
                'SELECT id, category, description, reference_number, vendor, payment_method, date
                 FROM ' . FinancialRecord::table() . '
                 WHERE ' . $where . '
                 ORDER BY date ASC, id ASC
                 LIMIT 5000',
                $params
            );

            $updated = 0;
            foreach ($rows as $r) {
                $recordId = (int) ($r['id'] ?? 0);
                $dateTime = (string) ($r['date'] ?? '');
                if ($recordId <= 0 || $dateTime === '') {
                    continue;
                }
                if (!$this->canEditDate($farmId, $dateTime)) {
                    continue;
                }
                $meta = $this->resolveCategoryForRecord(
                    $farmId,
                    (string) ($r['category'] ?? ''),
                    (string) ($r['description'] ?? ''),
                    (string) ($r['reference_number'] ?? ''),
                    (string) ($r['vendor'] ?? ''),
                    (string) ($r['payment_method'] ?? '')
                );
                $cat = (string) ($meta['category'] ?? '');
                if ($cat === '') {
                    continue;
                }
                $this->db->execute(
                    'UPDATE ' . FinancialRecord::table() . ' SET category = ?, category_source = ?, mapped_rule_id = ?, updated_by = ?, updated_at = ? WHERE id = ?',
                    [$cat, (string) ($meta['source'] ?? 'mapped'), $meta['rule_id'] ?? null, (int) $user['user_id'], date('Y-m-d H:i:s'), $recordId]
                );
                $updated++;
            }

            $this->audit($farmId, 'records.reclassified', 'financial_record', 'bulk', ['updated' => $updated, 'mode' => $mode]);
            return Response::success(['updated' => $updated], 'Reclassification complete');
        } catch (\Exception $e) {
            Logger::error('Failed to reclassify', ['error' => $e->getMessage()]);
            return Response::error('Failed to reclassify', 'RECLASSIFY_ERROR', 500);
        }
    }

    public function getCloseChecklist(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }
            $this->ensureAdvancedFinancialTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            $periodId = (int) ($this->request->getQuery()['period_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            if ($periodId <= 0) {
                return Response::validationError(['period_id' => 'period_id is required']);
            }
            $rows = $this->db->query(
                'SELECT check_key, status, notes, updated_at
                 FROM financial_close_checklist
                 WHERE farm_id = ? AND period_id = ?
                 ORDER BY check_key ASC',
                [$farmId, $periodId]
            );
            return Response::success(['period_id' => $periodId, 'checks' => $rows]);
        } catch (\Exception $e) {
            Logger::error('Failed to get close checklist', ['error' => $e->getMessage()]);
            return Response::error('Failed to get close checklist', 'CLOSE_CHECKLIST_ERROR', 500);
        }
    }

    public function updateCloseChecklist(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }
            $this->ensureAdvancedFinancialTables();
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            $periodId = (int) ($input['period_id'] ?? 0);
            $checkKey = Validation::sanitizeString((string) ($input['check_key'] ?? ''));
            $status = (string) ($input['status'] ?? 'pending');
            $notes = Validation::sanitizeString((string) ($input['notes'] ?? ''));
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            if ($periodId <= 0) {
                return Response::validationError(['period_id' => 'period_id is required']);
            }
            if ($checkKey === '') {
                return Response::validationError(['check_key' => 'check_key is required']);
            }
            if (!Validation::validateEnum($status, ['pending', 'passed', 'failed'])) {
                return Response::validationError(['status' => 'Invalid status']);
            }

            $this->db->execute(
                'INSERT INTO financial_close_checklist (farm_id, period_id, check_key, status, notes, updated_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE status = VALUES(status), notes = VALUES(notes), updated_by = VALUES(updated_by), updated_at = VALUES(updated_at)',
                [$farmId, $periodId, $checkKey, $status, $notes !== '' ? $notes : null, (int) $user['user_id'], date('Y-m-d H:i:s')]
            );
            $this->audit($farmId, 'close_check.updated', 'financial_period', (string) $periodId, ['check_key' => $checkKey, 'status' => $status]);
            return Response::success(['period_id' => $periodId, 'check_key' => $checkKey, 'status' => $status], 'Checklist updated');
        } catch (\Exception $e) {
            Logger::error('Failed to update close checklist', ['error' => $e->getMessage()]);
            return Response::error('Failed to update close checklist', 'CLOSE_CHECKLIST_UPDATE_ERROR', 500);
        }
    }

    public function reopenPeriod(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }
            $this->ensureAdvancedFinancialTables();
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            $periodId = (int) ($input['period_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            if ($periodId <= 0) {
                return Response::validationError(['period_id' => 'period_id is required']);
            }
            $period = $this->db->queryOne('SELECT id, status FROM financial_periods WHERE farm_id = ? AND id = ? LIMIT 1', [$farmId, $periodId]);
            if (!$period) {
                return Response::notFound('Period not found');
            }
            if (($period['status'] ?? 'open') !== 'closed') {
                return Response::validationError(['status' => 'Period is not closed']);
            }
            $this->db->execute('UPDATE financial_periods SET status = \'open\', updated_at = ? WHERE id = ?', [date('Y-m-d H:i:s'), $periodId]);
            $this->audit($farmId, 'period.reopened', 'financial_period', (string) $periodId);
            return Response::success(['period_id' => $periodId, 'status' => 'open'], 'Period reopened');
        } catch (\Exception $e) {
            Logger::error('Failed to reopen period', ['error' => $e->getMessage()]);
            return Response::error('Failed to reopen period', 'REOPEN_PERIOD_ERROR', 500);
        }
    }

    public function getPeriods(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureFinancialPeriodsTable();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $periods = $this->db->query(
                'SELECT id, name, period_type, start_date, end_date, status, closed_at, created_at
                 FROM financial_periods
                 WHERE farm_id = ?
                 ORDER BY start_date DESC',
                [$farmId]
            );

            return Response::success(['periods' => $periods]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve financial periods', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve financial periods', 'FINANCIAL_PERIODS_ERROR', 500);
        }
    }

    public function closePeriod(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureAdvancedFinancialTables();
            $farmId = (int) ($this->request->getBody()['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $input = $this->request->getBody();
            $periodType = (string) ($input['period_type'] ?? 'monthly');
            $year = (int) ($input['year'] ?? (int) date('Y'));
            $month = (int) ($input['month'] ?? (int) date('n'));
            $force = isset($input['force']) && ((int) $input['force'] === 1);

            if (!Validation::validateEnum($periodType, ['monthly', 'yearly'])) {
                return Response::validationError(['period_type' => 'Period type must be monthly or yearly']);
            }
            if (!Validation::validateInteger($year, 1900, 2100)) {
                return Response::validationError(['year' => 'Invalid year']);
            }
            if ($periodType === 'monthly' && !Validation::validateInteger($month, 1, 12)) {
                return Response::validationError(['month' => 'Invalid month']);
            }

            if ($periodType === 'monthly') {
                $startDate = sprintf('%04d-%02d-01', $year, $month);
                $endDate = date('Y-m-t', strtotime($startDate));
                $name = date('Y-m', strtotime($startDate));
            } else {
                $startDate = sprintf('%04d-01-01', $year);
                $endDate = sprintf('%04d-12-31', $year);
                $name = (string) $year;
            }

            $existing = $this->db->queryOne(
                'SELECT id, status FROM financial_periods WHERE farm_id = ? AND period_type = ? AND start_date = ? AND end_date = ?',
                [$farmId, $periodType, $startDate, $endDate]
            );

            $now = date('Y-m-d H:i:s');
            $pendingRow = $this->db->queryOne(
                'SELECT COUNT(*) AS c
                 FROM ' . FinancialRecord::table() . '
                 WHERE status = \'pending\' AND date >= ? AND date <= ?',
                [$startDate, $endDate . ' 23:59:59']
            );
            $pendingCount = (int) ($pendingRow['c'] ?? 0);

            $uncatRow = $this->db->queryOne(
                'SELECT COUNT(*) AS c
                 FROM ' . FinancialRecord::table() . '
                 WHERE date >= ? AND date <= ?
                   AND (category IS NULL OR category = \'\' OR LOWER(category) IN (\'other\',\'misc\',\'uncategorized\',\'general\'))',
                [$startDate, $endDate . ' 23:59:59']
            );
            $uncatCount = (int) ($uncatRow['c'] ?? 0);

            $checks = [
                'pending_transactions' => $pendingCount === 0 ? 'passed' : 'failed',
                'uncategorized_transactions' => $uncatCount === 0 ? 'passed' : 'failed',
            ];

            if ($existing) {
                if ($existing['status'] === 'closed') {
                    return Response::validationError(['period' => 'This period is already closed']);
                }

                $periodId = (int) $existing['id'];
            } else {
                $this->db->execute(
                    'INSERT INTO financial_periods (farm_id, name, period_type, start_date, end_date, status, closed_at, created_by, updated_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    [$farmId, $name, $periodType, $startDate, $endDate, 'open', null, (int) $user['user_id'], $now]
                );
                $periodId = (int) $this->db->lastInsertId();
            }

            foreach ($checks as $key => $status) {
                $notes = $key === 'pending_transactions' ? ('pending_count=' . $pendingCount) : ('uncategorized_count=' . $uncatCount);
                $this->db->execute(
                    'INSERT INTO financial_close_checklist (farm_id, period_id, check_key, status, notes, updated_by, updated_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?)
                     ON DUPLICATE KEY UPDATE status = VALUES(status), notes = VALUES(notes), updated_by = VALUES(updated_by), updated_at = VALUES(updated_at)',
                    [$farmId, $periodId, $key, $status, $notes, (int) $user['user_id'], $now]
                );
            }

            $hasFailures = in_array('failed', array_values($checks), true);
            if ($hasFailures && !$force) {
                return Response::validationError([
                    'close' => 'Close checks failed. Fix issues or pass force=1.',
                    'checklist' => [
                        'pending_transactions' => $pendingCount,
                        'uncategorized_transactions' => $uncatCount,
                    ],
                ]);
            }

            $this->db->execute(
                'UPDATE financial_periods SET status = ?, closed_at = ?, updated_at = ? WHERE id = ?',
                ['closed', $now, $now, (int) $periodId]
            );

            $this->db->execute(
                'UPDATE ' . FinancialRecord::table() . ' SET period_id = COALESCE(period_id, ?) WHERE date >= ? AND date <= ?',
                [$periodId, $startDate, $endDate . ' 23:59:59']
            );

            $summary = $this->db->queryOne(
                'SELECT
                    SUM(CASE WHEN type = \'income\' THEN amount ELSE 0 END) AS total_income,
                    SUM(CASE WHEN type = \'expense\' THEN amount ELSE 0 END) AS total_expense,
                    COUNT(*) AS total_transactions
                 FROM ' . FinancialRecord::table() . '
                 WHERE date >= ? AND date <= ?',
                [$startDate, $endDate]
            );

            $this->audit($farmId, 'period.closed', 'financial_period', (string) $periodId, [
                'period_type' => $periodType,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'force' => $force,
                'checklist' => [
                    'pending_transactions' => $pendingCount,
                    'uncategorized_transactions' => $uncatCount,
                ],
            ]);

            return Response::success([
                'period_id' => $periodId,
                'name' => $name,
                'period_type' => $periodType,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'status' => 'closed',
                'checklist' => [
                    'pending_transactions' => $pendingCount,
                    'uncategorized_transactions' => $uncatCount,
                ],
                'totals' => [
                    'income' => round((float) ($summary['total_income'] ?? 0), 2),
                    'expense' => round((float) ($summary['total_expense'] ?? 0), 2),
                    'net' => round(((float) ($summary['total_income'] ?? 0) - (float) ($summary['total_expense'] ?? 0)), 2),
                    'transactions' => (int) ($summary['total_transactions'] ?? 0),
                ],
            ], 'Financial period closed successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to close financial period', ['error' => $e->getMessage()]);
            return Response::error('Failed to close financial period', 'CLOSE_PERIOD_ERROR', 500);
        }
    }

    private function getFarmIdFromInputOrQuery(): int
    {
        $input = $this->request->getBody();
        if (!empty($input['farm_id'])) {
            return (int) $input['farm_id'];
        }

        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureBudgetsAndInvoicesTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_budgets (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                category VARCHAR(191) NOT NULL,
                period ENUM(\'monthly\', \'yearly\') NOT NULL,
                year INT NOT NULL,
                month TINYINT NULL,
                limit_amount DECIMAL(12,2) NOT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_financial_budgets_farm (farm_id, year, period, month),
                INDEX idx_financial_budgets_category (farm_id, category)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_invoices (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                invoice_number VARCHAR(64) NOT NULL,
                customer_name VARCHAR(255) NOT NULL,
                items TEXT NULL,
                amount DECIMAL(12,2) NOT NULL,
                due_date DATE NOT NULL,
                status ENUM(\'unpaid\', \'paid\', \'overdue\', \'cancelled\') NOT NULL DEFAULT \'unpaid\',
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_financial_invoices_farm (farm_id, created_at),
                INDEX idx_financial_invoices_status (farm_id, status),
                UNIQUE KEY uniq_financial_invoices_number (invoice_number)
            )'
        );
    }

    public function budgets(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureBudgetsAndInvoicesTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            if ($this->request->getMethod() === 'GET') {
                $year = (int) ($this->request->getQuery()['year'] ?? (int) date('Y'));
                $month = (int) ($this->request->getQuery()['month'] ?? (int) date('n'));
                $year = $year ?: (int) date('Y');
                $month = $month ?: (int) date('n');

                $budgets = $this->db->query(
                    'SELECT id, category, period, year, month, limit_amount
                     FROM financial_budget_lines
                     WHERE farm_id = ? AND year = ?
                     ORDER BY category ASC, period ASC, month ASC, id DESC',
                    [$farmId, $year]
                );

                $budgetsWithSpent = array_map(function (array $b) use ($farmId, $month): array {
                    $period = (string) $b['period'];
                    $year = (int) $b['year'];
                    $budgetMonth = (int) ($b['month'] ?? 0);
                    $effectiveMonth = $period === 'monthly' ? ($budgetMonth ?: $month) : 0;

                    if ($period === 'monthly') {
                        $start = sprintf('%04d-%02d-01', $year, $effectiveMonth);
                        $end = date('Y-m-t', strtotime($start));
                    } else {
                        $start = sprintf('%04d-01-01', $year);
                        $end = sprintf('%04d-12-31', $year);
                    }

                    $row = $this->db->query(
                        'SELECT COALESCE(SUM(amount), 0) AS spent
                         FROM ' . FinancialRecord::table() . '
                         WHERE type = \'expense\' AND category = ? AND date >= ? AND date <= ?',
                        [(string) $b['category'], $start, $end . ' 23:59:59']
                    );
                    $spent = isset($row[0]['spent']) ? (float) $row[0]['spent'] : 0.0;

                    return [
                        'id' => (int) $b['id'],
                        'category' => (string) $b['category'],
                        'period' => $period,
                        'year' => $year,
                        'month' => $period === 'monthly' ? $effectiveMonth : null,
                        'limit' => (float) $b['limit_amount'],
                        'spent' => round($spent, 2),
                    ];
                }, $budgets);

                return Response::success(['budgets' => $budgetsWithSpent]);
            }

            $input = $this->request->getBody();
            $category = Validation::sanitizeString((string) ($input['category'] ?? ''));
            $limit = $input['limit'] ?? null;
            $period = (string) ($input['period'] ?? 'monthly');
            $year = (int) ($input['year'] ?? (int) date('Y'));

            $errors = [];
            if ($category === '') {
                $errors['category'] = 'Category is required';
            }
            if (!is_numeric($limit) || (float) $limit <= 0) {
                $errors['limit'] = 'Limit must be a positive number';
            }
            if (!Validation::validateEnum($period, ['monthly', 'yearly'])) {
                $errors['period'] = 'Period must be monthly or yearly';
            }
            if ($year <= 1900 || $year >= 2100) {
                $errors['year'] = 'Invalid year';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $month = null;
            if ($period === 'monthly') {
                $month = isset($input['month']) && is_numeric($input['month']) ? (int) $input['month'] : (int) date('n');
            }

            $this->db->execute(
                'INSERT INTO financial_budget_lines (farm_id, category, period, year, month, limit_amount, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $category,
                    $period,
                    $year,
                    $month,
                    (float) $limit,
                    (int) $user['user_id'],
                    date('Y-m-d H:i:s'),
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Budget created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle budgets', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle budgets', 'BUDGETS_ERROR', 500);
        }
    }

    public function invoices(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureBudgetsAndInvoicesTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                $farmId = $this->getFarmIdFromInputOrQuery();
            }
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            if ($this->request->getMethod() === 'GET') {
                $invoices = $this->db->query(
                    'SELECT id, invoice_number, customer_name, items, amount, due_date, status, created_at
                     FROM financial_invoices
                     WHERE farm_id = ?
                     ORDER BY created_at DESC, id DESC
                     LIMIT 200',
                    [$farmId]
                );

                return Response::success(['invoices' => $invoices]);
            }

            $input = $this->request->getBody();
            $customerName = Validation::sanitizeString((string) ($input['customer_name'] ?? ''));
            $items = Validation::sanitizeString((string) ($input['items'] ?? ''));
            $amount = $input['amount'] ?? null;
            $dueDate = (string) ($input['due_date'] ?? '');
            $status = (string) ($input['status'] ?? 'unpaid');

            $errors = [];
            if ($customerName === '') {
                $errors['customer_name'] = 'Customer name is required';
            }
            if (!is_numeric($amount) || (float) $amount <= 0) {
                $errors['amount'] = 'Amount must be a positive number';
            }
            if (!Validation::validateDate($dueDate, 'Y-m-d')) {
                $errors['due_date'] = 'Due date is required (YYYY-MM-DD)';
            }
            if (!Validation::validateEnum($status, ['unpaid', 'paid', 'overdue', 'cancelled'])) {
                $errors['status'] = 'Invalid status';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $invoiceNumber = 'INV-' . date('Ymd') . '-' . strtoupper(bin2hex(random_bytes(4)));

            $this->db->execute(
                'INSERT INTO financial_invoices (farm_id, invoice_number, customer_name, items, amount, due_date, status, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $invoiceNumber,
                    $customerName,
                    $items !== '' ? $items : null,
                    (float) $amount,
                    $dueDate,
                    $status,
                    (int) $user['user_id'],
                    date('Y-m-d H:i:s'),
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId(), 'invoice_number' => $invoiceNumber], 'Invoice created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle invoices', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle invoices', 'INVOICES_ERROR', 500);
        }
    }
}
