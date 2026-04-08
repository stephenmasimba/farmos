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

            $input = $this->request->getBody();

            // Validate required fields
            $errors = [];
            if (empty($input['farm_id'])) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if (empty($input['type'])) {
                $errors['type'] = 'Type (income/expense) is required';
            }
            if (empty($input['category'])) {
                $errors['category'] = 'Category is required';
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

            // Create record
            $record = new FinancialRecord($this->db, array_filter($input, fn($k) => in_array($k, FinancialRecord::fillable()), ARRAY_FILTER_USE_KEY));
            $recordId = $record->save();

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

            $record = FinancialRecord::find($id, $this->db);
            if (!$record) {
                return Response::notFound('Financial record not found');
            }

            $input = $this->request->getBody();

            // Update allowed fields
            if (!empty($input['description'])) {
                $record->description = Validation::sanitizeString($input['description']);
            }
            if (!empty($input['category'])) {
                $record->category = Validation::sanitizeString($input['category']);
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
            $record->save();

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

            $affected = FinancialRecord::destroy($id, $this->db);
            if (!$affected) {
                return Response::notFound('Financial record not found');
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
                 WHERE farm_id = ? AND type = \'income\' AND date >= ? AND date <= ? 
                 GROUP BY category',
                [$farmId, $startDate, $endDate]
            );

            $expenseByCategory = $this->db->query(
                'SELECT category, SUM(amount) as total, COUNT(*) as count 
                 FROM ' . FinancialRecord::table() . ' 
                 WHERE farm_id = ? AND type = \'expense\' AND date >= ? AND date <= ? 
                 GROUP BY category',
                [$farmId, $startDate, $endDate]
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
}
