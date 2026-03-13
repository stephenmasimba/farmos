<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation
};
use FarmOS\Models\{Livestock, Inventory, FinancialRecord, Task, Farm};
use FarmOS\Services\{AnalyticsService, ReportService};

/**
 * DashboardController - Aggregated farm dashboard and reporting
 */
class DashboardController
{
    protected Database $db;
    protected Request $request;
    private ReportService $reportService;
    private AnalyticsService $analyticsService;
    private static bool $reportExportsTableEnsured = false;
    private static bool $apiRequestLogsTableEnsured = false;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
        $this->reportService = new ReportService($db);
        $this->analyticsService = new AnalyticsService($db);
    }

    /**
     * Get dashboard overview
     * GET /api/dashboard/overview?farm_id={id}
     */
    public function overview(): Response
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

            // Get farm
            $farm = Farm::find($farmId, $this->db);
            if (!$farm) {
                return Response::notFound('Farm not found');
            }

            // Get livestock statistics
            $livestockStats = $this->db->query(
                'SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status = "active" THEN 1 ELSE 0 END) as active,
                    species,
                    COUNT(*) as count
                FROM ' . Livestock::table() . '
                WHERE farm_id = ?
                GROUP BY species
                ORDER BY count DESC',
                [$farmId]
            );

            $livestockTotalCount = array_sum(array_map(fn($s) => $s['count'] ?? 0, $livestockStats));
            $livestockActiveCount = array_sum(array_map(fn($s) => $s['active'] ?? 0, $livestockStats));

            // Get inventory statistics
            $inventoryStats = $this->db->query(
                'SELECT 
                    COUNT(*) as total_items,
                    SUM(quantity) as total_quantity,
                    SUM(quantity * cost_per_unit) as total_value,
                    SUM(CASE WHEN quantity < min_level THEN 1 ELSE 0 END) as low_stock_count
                FROM ' . Inventory::table() . '
                WHERE farm_id = ?',
                [$farmId]
            );

            $inventory = $inventoryStats[0] ?? [
                'total_items' => 0,
                'total_quantity' => 0,
                'total_value' => 0,
                'low_stock_count' => 0,
            ];

            // Get financial statistics
            $financialStats = $this->db->query(
                'SELECT 
                    SUM(CASE WHEN type = "income" THEN amount ELSE 0 END) as total_income,
                    SUM(CASE WHEN type = "expense" THEN amount ELSE 0 END) as total_expense,
                    (SUM(CASE WHEN type = "income" THEN amount ELSE 0 END) - 
                     SUM(CASE WHEN type = "expense" THEN amount ELSE 0 END)) as net_profit
                FROM ' . FinancialRecord::table() . '
                WHERE farm_id = ?',
                [$farmId]
            );

            $financial = $financialStats[0] ?? [
                'total_income' => 0,
                'total_expense' => 0,
                'net_profit' => 0,
            ];

            // Get task statistics
            $taskStats = Task::getStats($farmId, $this->db);

            // Get month-to-date financial
            $monthStart = date('Y-m-01');
            $monthFinancials = $this->db->query(
                'SELECT 
                    SUM(CASE WHEN type = "income" THEN amount ELSE 0 END) as monthly_income,
                    SUM(CASE WHEN type = "expense" THEN amount ELSE 0 END) as monthly_expense
                FROM ' . FinancialRecord::table() . '
                WHERE farm_id = ? AND date >= ?',
                [$farmId, $monthStart]
            );

            $monthFinancial = $monthFinancials[0] ?? [
                'monthly_income' => 0,
                'monthly_expense' => 0,
            ];

            Logger::info('Retrieved dashboard overview', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'farm' => [
                    'id' => $farm->id,
                    'name' => $farm->name,
                    'type' => $farm->type,
                    'location' => $farm->location,
                    'size' => $farm->size,
                ],
                'livestock' => [
                    'total' => $livestockTotalCount,
                    'active' => $livestockActiveCount,
                    'by_species' => $livestockStats,
                ],
                'inventory' => [
                    'total_items' => (int) $inventory['total_items'],
                    'total_quantity' => (float) $inventory['total_quantity'],
                    'total_value' => round((float) $inventory['total_value'], 2),
                    'low_stock_count' => (int) $inventory['low_stock_count'],
                ],
                'financial' => [
                    'total_income' => round((float) $financial['total_income'], 2),
                    'total_expense' => round((float) $financial['total_expense'], 2),
                    'net_profit' => round((float) $financial['net_profit'], 2),
                    'monthly_income' => round((float) $monthFinancial['monthly_income'], 2),
                    'monthly_expense' => round((float) $monthFinancial['monthly_expense'], 2),
                ],
                'tasks' => [
                    'total' => (int) $taskStats['total'],
                    'completed' => (int) $taskStats['completed'],
                    'in_progress' => (int) $taskStats['in_progress'],
                    'pending' => (int) $taskStats['pending'],
                    'overdue' => (int) $taskStats['overdue'],
                    'critical_pending' => (int) $taskStats['critical_pending'],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get dashboard overview', ['error' => $e->getMessage()]);
            return Response::error('Failed to get overview', 'OVERVIEW_ERROR', 500);
        }
    }

    /**
     * Get health/productivity metrics
     * GET /api/dashboard/health?farm_id={id}
     */
    public function health(): Response
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

            // Overall farm health score based on multiple factors
            $scores = [];

            // Livestock health (portion of animals in good status)
            $livestockStatusResult = $this->db->query(
                'SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status = "active" THEN 1 ELSE 0 END) as healthy,
                    SUM(CASE WHEN status = "quarantine" THEN 1 ELSE 0 END) as quarantined
                FROM ' . Livestock::table() . '
                WHERE farm_id = ?',
                [$farmId]
            );

            $livestockStatus = $livestockStatusResult[0] ?? ['total' => 0, 'healthy' => 0, 'quarantined' => 0];

            if ($livestockStatus['total'] > 0) {
                $livestockScore = ($livestockStatus['healthy'] / $livestockStatus['total']) * 100;
                $scores['livestock_health'] = round($livestockScore, 2);
            } else {
                $scores['livestock_health'] = 0;
            }

            // Inventory health (portion of items not low stock)
            $inventoryResult = $this->db->query(
                'SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN quantity >= min_level THEN 1 ELSE 0 END) as adequate
                FROM ' . Inventory::table() . '
                WHERE farm_id = ?',
                [$farmId]
            );

            $inventory = $inventoryResult[0] ?? ['total' => 0, 'adequate' => 0];

            if ($inventory['total'] > 0) {
                $inventoryScore = ($inventory['adequate'] / $inventory['total']) * 100;
                $scores['inventory_health'] = round($inventoryScore, 2);
            } else {
                $scores['inventory_health'] = 0;
            }

            // Task completion rate
            $taskStats = Task::getStats($farmId, $this->db);

            if ($taskStats['total'] > 0) {
                $taskScore = ($taskStats['completed'] / $taskStats['total']) * 100;
                $scores['task_completion_rate'] = round($taskScore, 2);
            } else {
                $scores['task_completion_rate'] = 0;
            }

            // Financial health (profitability)
            $financialResult = $this->db->query(
                'SELECT 
                    SUM(CASE WHEN type = "income" THEN amount ELSE 0 END) as income,
                    SUM(CASE WHEN type = "expense" THEN amount ELSE 0 END) as expense
                FROM ' . FinancialRecord::table() . '
                WHERE farm_id = ?',
                [$farmId]
            );

            $financial = $financialResult[0] ?? ['income' => 0, 'expense' => 0];

            if ($financial['income'] > 0) {
                $profitMargin = (($financial['income'] - $financial['expense']) / $financial['income']) * 100;
                $scores['profit_margin'] = round($profitMargin, 2);
            } else {
                $scores['profit_margin'] = 0;
            }

            // Overall health score (average of all metrics)
            $overallScore = array_sum($scores) / count($scores);

            Logger::info('Retrieved farm health metrics', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            $status = 'needs_attention';
            if ($overallScore >= 80) {
                $status = 'excellent';
            } elseif ($overallScore >= 60) {
                $status = 'good';
            } elseif ($overallScore >= 40) {
                $status = 'fair';
            }

            return Response::success([
                'scores' => $scores,
                'overall_health_score' => round($overallScore, 2),
                'status' => $status,
                'metrics' => [
                    'livestock' => $livestockStatus,
                    'inventory' => $inventory,
                    'tasks' => [
                        'total' => $taskStats['total'],
                        'completed' => $taskStats['completed'],
                    ],
                    'financial' => [
                        'income' => round((float) $financial['income'], 2),
                        'expense' => round((float) $financial['expense'], 2),
                    ],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get farm health', ['error' => $e->getMessage()]);
            return Response::error('Failed to get health metrics', 'HEALTH_ERROR', 500);
        }
    }

    /**
     * Get combined alerts
     * GET /api/dashboard/alerts?farm_id={id}
     */
    public function alerts(): Response
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

            // Low stock alerts
            $lowStock = $this->db->query(
                'SELECT id, name, category, quantity, min_level 
                 FROM ' . Inventory::table() . '
                 WHERE farm_id = ? AND quantity < min_level
                 ORDER BY quantity ASC',
                [$farmId]
            );

            // Expiring items
            $expiring = $this->db->query(
                'SELECT id, name, category, expiry_date, quantity 
                 FROM ' . Inventory::table() . '
                 WHERE farm_id = ? AND expiry_date IS NOT NULL 
                 AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
                 AND expiry_date >= CURDATE()
                 ORDER BY expiry_date ASC',
                [$farmId]
            );

            // Overdue tasks
            $overdue = Task::overdue($farmId, $this->db);

            // Critical tasks
            $critical = $this->db->query(
                'SELECT id, title, due_date, assigned_to 
                 FROM ' . Task::table() . '
                 WHERE farm_id = ? AND priority = "critical" AND status != "completed"
                 ORDER BY due_date ASC',
                [$farmId]
            );

            // Quarantined animals
            $quarantined = $this->db->query(
                'SELECT id, name, species, status 
                 FROM ' . Livestock::table() . '
                 WHERE farm_id = ? AND status = "quarantine"',
                [$farmId]
            );

            Logger::info('Retrieved farm alerts', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'alerts' => [
                    'low_stock' => [
                        'count' => count($lowStock),
                        'items' => $lowStock,
                    ],
                    'expiring_inventory' => [
                        'count' => count($expiring),
                        'items' => $expiring,
                    ],
                    'overdue_tasks' => [
                        'count' => count($overdue),
                        'items' => array_map(fn($t) => $t->getFullProfile(), $overdue),
                    ],
                    'critical_tasks' => [
                        'count' => count($critical),
                        'items' => $critical,
                    ],
                    'quarantined_animals' => [
                        'count' => count($quarantined),
                        'items' => $quarantined,
                    ],
                ],
                'total_alert_count' => count($lowStock) + count($expiring) + count($overdue) + count($critical) + count($quarantined),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get farm alerts', ['error' => $e->getMessage()]);
            return Response::error('Failed to get alerts', 'ALERTS_ERROR', 500);
        }
    }

    /**
     * Get activity timeline
     * GET /api/dashboard/timeline?farm_id={id}&days={7}
     */
    public function timeline(): Response
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

            $days = (int) ($this->request->getQuery()['days'] ?? 7);
            $days = min(max($days, 1), 90); // Clamp between 1 and 90

            $since = date('Y-m-d H:i:s', strtotime("-$days days"));

            // Recent livestock additions
            $livestockAdded = $this->db->query(
                'SELECT id, name, species, created_at 
                 FROM ' . Livestock::table() . '
                 WHERE farm_id = ? AND created_at >= ?
                 ORDER BY created_at DESC
                 LIMIT 10',
                [$farmId, $since]
            );

            // Recent financial transactions
            $transactions = $this->db->query(
                'SELECT id, type, category, amount, date, description 
                 FROM ' . FinancialRecord::table() . '
                 WHERE farm_id = ? AND date >= ?
                 ORDER BY date DESC
                 LIMIT 10',
                [$farmId, $since]
            );

            // Completed tasks
            $completedTasks = $this->db->query(
                'SELECT id, title, status, updated_at 
                 FROM ' . Task::table() . '
                 WHERE farm_id = ? AND status = "completed" AND updated_at >= ?
                 ORDER BY updated_at DESC
                 LIMIT 10',
                [$farmId, $since]
            );

            // Inventory adjustments (via quantity changes - would need adjustment log table in real system)
            // For now, just show recent inventory items
            $inventoryUpdated = $this->db->query(
                'SELECT id, name, category, quantity, updated_at 
                 FROM ' . Inventory::table() . '
                 WHERE farm_id = ? AND updated_at >= ?
                 ORDER BY updated_at DESC
                 LIMIT 10',
                [$farmId, $since]
            );

            Logger::info('Retrieved activity timeline', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'days' => $days,
            ]);

            return Response::success([
                'timeline' => [
                    'livestock_added' => [
                        'count' => count($livestockAdded),
                        'items' => $livestockAdded,
                    ],
                    'transactions' => [
                        'count' => count($transactions),
                        'items' => $transactions,
                    ],
                    'tasks_completed' => [
                        'count' => count($completedTasks),
                        'items' => $completedTasks,
                    ],
                    'inventory_updated' => [
                        'count' => count($inventoryUpdated),
                        'items' => $inventoryUpdated,
                    ],
                ],
                'period' => [
                    'days' => $days,
                    'since' => $since,
                    'until' => date('Y-m-d H:i:s'),
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get activity timeline', ['error' => $e->getMessage()]);
            return Response::error('Failed to get timeline', 'TIMELINE_ERROR', 500);
        }
    }

    /**
     * Get forecast/predictions
     * GET /api/dashboard/forecast?farm_id={id}
     */
    public function forecast(): Response
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

            // Forecast livestock based on current numbers
            $livestockForecast = $this->db->query(
                'SELECT species, COUNT(*) as current_count 
                 FROM ' . Livestock::table() . '
                 WHERE farm_id = ? AND status = "active"
                 GROUP BY species',
                [$farmId]
            );

            // Inventory forecast (items that need reordering soon based on usage rate)
            // Simple forecast: if min_level not reached in 30 days, safe; otherwise warn
            $inventoryForecast = $this->db->query(
                'SELECT name, category, quantity, min_level, cost_per_unit,
                        CASE 
                            WHEN quantity < min_level THEN "critical"
                            WHEN quantity < (min_level * 1.5) THEN "warning"
                            ELSE "adequate"
                        END as status
                 FROM ' . Inventory::table() . '
                 WHERE farm_id = ?
                 ORDER BY status DESC',
                [$farmId]
            );

            // Financial forecast (revenue vs expense trend)
            $monthlyTrend = [];
            for ($i = 11; $i >= 0; $i--) {
                $date = date('Y-m', strtotime("-$i months"));
                $monthStart = "$date-01";
                $monthEnd = date('Y-m-t', strtotime($monthStart));

                $result = $this->db->query(
                    'SELECT 
                        SUM(CASE WHEN type = "income" THEN amount ELSE 0 END) as income,
                        SUM(CASE WHEN type = "expense" THEN amount ELSE 0 END) as expense
                    FROM ' . FinancialRecord::table() . '
                    WHERE farm_id = ? AND date >= ? AND date <= ?',
                    [$farmId, $monthStart, $monthEnd]
                );

                if ($result) {
                    $monthlyTrend[] = array_merge(['month' => $date], $result[0]);
                }
            }

            // Calculate trend (simple average of last 3 months for next month prediction)
            $lastThree = array_slice($monthlyTrend, -3);
            $avgIncome = count($lastThree) > 0 ? array_sum(array_map(fn($m) => $m['income'] ?? 0, $lastThree)) / count($lastThree) : 0;
            $avgExpense = count($lastThree) > 0 ? array_sum(array_map(fn($m) => $m['expense'] ?? 0, $lastThree)) / count($lastThree) : 0;

            Logger::info('Retrieved farm forecast', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'livestock_forecast' => $livestockForecast,
                'inventory_forecast' => [
                    'critical' => count(array_filter($inventoryForecast, fn($i) => $i['status'] === 'critical')),
                    'warning' => count(array_filter($inventoryForecast, fn($i) => $i['status'] === 'warning')),
                    'adequate' => count(array_filter($inventoryForecast, fn($i) => $i['status'] === 'adequate')),
                    'items' => $inventoryForecast,
                ],
                'financial_forecast' => [
                    'trend' => $monthlyTrend,
                    'predicted_next_month' => [
                        'income' => round($avgIncome, 2),
                        'expense' => round($avgExpense, 2),
                        'profit' => round($avgIncome - $avgExpense, 2),
                    ],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get farm forecast', ['error' => $e->getMessage()]);
            return Response::error('Failed to get forecast', 'FORECAST_ERROR', 500);
        }
    }

    private function resolveFarmId(?array $user): int
    {
        $farmId = (int) ($this->request->getQuery('farm_id', 0));
        if ($farmId > 0) {
            return $farmId;
        }

        $farmId = (int) ($this->request->getInput('farm_id', 0));
        if ($farmId > 0) {
            return $farmId;
        }

        if ($user && !empty($user['user_id'])) {
            try {
                $row = $this->db->queryOne('SELECT id FROM ' . Farm::table() . ' WHERE owner_id = ? ORDER BY id ASC LIMIT 1', [(int) $user['user_id']]);
                if ($row && isset($row['id'])) {
                    return (int) $row['id'];
                }
            } catch (\Exception $e) {
            }
        }

        return 1;
    }

    private function ensureReportExportsTable(): void
    {
        if (self::$reportExportsTableEnsured) {
            return;
        }
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS report_exports (
                token VARCHAR(64) PRIMARY KEY,
                content_type VARCHAR(100) NOT NULL,
                filename VARCHAR(255) NOT NULL,
                body MEDIUMTEXT NOT NULL,
                expires_at DATETIME NOT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            )'
        );
        self::$reportExportsTableEnsured = true;
    }

    private function ensureApiRequestLogsTable(): void
    {
        if (self::$apiRequestLogsTableEnsured) {
            return;
        }
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS api_request_logs (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                method VARCHAR(10) NOT NULL,
                path VARCHAR(255) NOT NULL,
                status_code INT NOT NULL,
                duration_ms INT NOT NULL,
                ip VARCHAR(64) NULL,
                user_id INT NULL,
                user_agent VARCHAR(255) NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_created_at (created_at),
                INDEX idx_path (path),
                INDEX idx_status_code (status_code),
                INDEX idx_user_id (user_id)
            )'
        );
        self::$apiRequestLogsTableEnsured = true;
    }

    public function reportTypes(): Response
    {
        $user = $this->request->getUser();
        if (!$user) {
            return Response::unauthorized();
        }

        return Response::success($this->reportService->getTypes());
    }

    public function generateReport(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $payload = $this->request->getBody();
            $typeRaw = Validation::sanitizeString((string) ($payload['type'] ?? ''));
            $format = strtolower(Validation::sanitizeString((string) ($payload['format'] ?? 'csv')));
            $type = strtolower($typeRaw);

            if ($type === '') {
                return Response::validationError(['type' => 'Required']);
            }
            if (!in_array($format, ['csv', 'pdf'], true)) {
                return Response::validationError(['format' => 'Invalid']);
            }

            $farmId = $this->resolveFarmId($user);
            $startDate = Validation::sanitizeString((string) ($payload['start_date'] ?? ''));
            $endDate = Validation::sanitizeString((string) ($payload['end_date'] ?? ''));

            if ($endDate === '') {
                $endDate = date('Y-m-d');
            }
            if ($startDate === '') {
                $startDate = date('Y-m-d', strtotime('-30 days'));
            }

            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'Invalid date format']);
            }
            if (!Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'Invalid date format']);
            }

            return Response::success(
                $this->reportService->generate($farmId, $type, $format, $startDate, $endDate)
            );
        } catch (\Exception $e) {
            Logger::error('Failed to generate report', ['error' => $e->getMessage()]);
            return Response::error('Failed to generate report', 'REPORT_GENERATE_ERROR', 500);
        }
    }

    private function buildReport(string $type, int $farmId, string $startDate, string $endDate, string $format): array
    {
        if ($type === 'financial') {
            return $this->buildFinancialReport($farmId, $startDate, $endDate, $format);
        }
        if ($type === 'inventory') {
            return $this->buildInventoryReport($farmId, $format);
        }
        if ($type === 'livestock') {
            return $this->buildLivestockReport($farmId, $format);
        }
        if ($type === 'tasks') {
            return $this->buildTasksReport($farmId, $startDate, $endDate, $format);
        }

        throw new \InvalidArgumentException('Unknown report type');
    }

    private function buildFinancialReport(int $farmId, string $startDate, string $endDate, string $format): array
    {
        $rows = $this->db->query(
            'SELECT type, category, amount, currency, date, status, description
             FROM ' . FinancialRecord::table() . '
             WHERE farm_id = ? AND DATE(date) >= ? AND DATE(date) <= ?
             ORDER BY date DESC',
            [$farmId, $startDate, $endDate]
        );

        $income = 0.0;
        $expense = 0.0;
        foreach ($rows as $r) {
            $amt = isset($r['amount']) ? (float) $r['amount'] : 0.0;
            if (($r['type'] ?? '') === 'income') {
                $income += $amt;
            } else {
                $expense += $amt;
            }
        }

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['date', 'type', 'category', 'amount', 'currency', 'status', 'description']);
            foreach ($rows as $r) {
                fputcsv($out, [
                    (string) ($r['date'] ?? ''),
                    (string) ($r['type'] ?? ''),
                    (string) ($r['category'] ?? ''),
                    (string) ($r['amount'] ?? ''),
                    (string) ($r['currency'] ?? ''),
                    (string) ($r['status'] ?? ''),
                    (string) ($r['description'] ?? ''),
                ]);
            }
            fputcsv($out, []);
            fputcsv($out, ['total_income', number_format($income, 2, '.', '')]);
            fputcsv($out, ['total_expense', number_format($expense, 2, '.', '')]);
            fputcsv($out, ['net_profit', number_format($income - $expense, 2, '.', '')]);
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'financial_report_' . $startDate . '_to_' . $endDate . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Financial Report</title></head><body>';
        $html .= '<h1>Financial Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<p>Period: ' . $escape($startDate) . ' to ' . $escape($endDate) . '</p>';
        $html .= '<p>Total income: ' . $escape(number_format($income, 2)) . '</p>';
        $html .= '<p>Total expense: ' . $escape(number_format($expense, 2)) . '</p>';
        $html .= '<p>Net profit: ' . $escape(number_format($income - $expense, 2)) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['Date', 'Type', 'Category', 'Amount', 'Currency', 'Status', 'Description'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['date'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['type'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['category'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['amount'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['currency'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['status'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['description'] ?? '')) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'financial_report_' . $startDate . '_to_' . $endDate . '.html',
            'body' => $html,
        ];
    }

    private function buildInventoryReport(int $farmId, string $format): array
    {
        $rows = $this->db->query(
            'SELECT name, category, quantity, unit, min_level, max_level, cost_per_unit, supplier, location, expiry_date
             FROM ' . Inventory::table() . '
             WHERE farm_id = ?
             ORDER BY category ASC, name ASC',
            [$farmId]
        );

        $totalValue = 0.0;
        $lowStock = 0;
        foreach ($rows as $r) {
            $qty = isset($r['quantity']) ? (float) $r['quantity'] : 0.0;
            $cpu = isset($r['cost_per_unit']) ? (float) $r['cost_per_unit'] : 0.0;
            $totalValue += $qty * $cpu;
            $min = isset($r['min_level']) ? (float) $r['min_level'] : 0.0;
            if ($min > 0 && $qty < $min) {
                $lowStock++;
            }
        }

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['name', 'category', 'quantity', 'unit', 'min_level', 'max_level', 'cost_per_unit', 'supplier', 'location', 'expiry_date', 'low_stock']);
            foreach ($rows as $r) {
                $qty = isset($r['quantity']) ? (float) $r['quantity'] : 0.0;
                $min = isset($r['min_level']) ? (float) $r['min_level'] : 0.0;
                $isLow = ($min > 0 && $qty < $min) ? 'yes' : 'no';
                fputcsv($out, [
                    (string) ($r['name'] ?? ''),
                    (string) ($r['category'] ?? ''),
                    (string) ($r['quantity'] ?? ''),
                    (string) ($r['unit'] ?? ''),
                    (string) ($r['min_level'] ?? ''),
                    (string) ($r['max_level'] ?? ''),
                    (string) ($r['cost_per_unit'] ?? ''),
                    (string) ($r['supplier'] ?? ''),
                    (string) ($r['location'] ?? ''),
                    (string) ($r['expiry_date'] ?? ''),
                    $isLow,
                ]);
            }
            fputcsv($out, []);
            fputcsv($out, ['low_stock_count', (string) $lowStock]);
            fputcsv($out, ['total_inventory_value', number_format($totalValue, 2, '.', '')]);
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'inventory_report_' . date('Y-m-d') . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Inventory Report</title></head><body>';
        $html .= '<h1>Inventory Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<p>Low stock items: ' . $escape((string) $lowStock) . '</p>';
        $html .= '<p>Total value: ' . $escape(number_format($totalValue, 2)) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['Name', 'Category', 'Quantity', 'Unit', 'Min', 'Max', 'Cost/Unit', 'Supplier', 'Location', 'Expiry', 'Low Stock'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $qty = isset($r['quantity']) ? (float) $r['quantity'] : 0.0;
            $min = isset($r['min_level']) ? (float) $r['min_level'] : 0.0;
            $isLow = ($min > 0 && $qty < $min) ? 'yes' : 'no';
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['name'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['category'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['quantity'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['unit'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['min_level'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['max_level'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['cost_per_unit'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['supplier'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['location'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['expiry_date'] ?? '')) . '</td>';
            $html .= '<td>' . $escape($isLow) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'inventory_report_' . date('Y-m-d') . '.html',
            'body' => $html,
        ];
    }

    private function buildLivestockReport(int $farmId, string $format): array
    {
        $rows = $this->db->query(
            'SELECT name, species, breed, gender, weight, status, birth_date, acquisition_date
             FROM ' . Livestock::table() . '
             WHERE farm_id = ?
             ORDER BY species ASC, status ASC, name ASC',
            [$farmId]
        );

        $active = 0;
        foreach ($rows as $r) {
            if (($r['status'] ?? '') === 'active') {
                $active++;
            }
        }

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['name', 'species', 'breed', 'gender', 'weight', 'status', 'birth_date', 'acquisition_date']);
            foreach ($rows as $r) {
                fputcsv($out, [
                    (string) ($r['name'] ?? ''),
                    (string) ($r['species'] ?? ''),
                    (string) ($r['breed'] ?? ''),
                    (string) ($r['gender'] ?? ''),
                    (string) ($r['weight'] ?? ''),
                    (string) ($r['status'] ?? ''),
                    (string) ($r['birth_date'] ?? ''),
                    (string) ($r['acquisition_date'] ?? ''),
                ]);
            }
            fputcsv($out, []);
            fputcsv($out, ['total', (string) count($rows)]);
            fputcsv($out, ['active', (string) $active]);
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'livestock_report_' . date('Y-m-d') . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Livestock Report</title></head><body>';
        $html .= '<h1>Livestock Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<p>Total: ' . $escape((string) count($rows)) . ' Active: ' . $escape((string) $active) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['Name', 'Species', 'Breed', 'Gender', 'Weight', 'Status', 'Birth Date', 'Acquisition Date'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['name'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['species'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['breed'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['gender'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['weight'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['status'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['birth_date'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['acquisition_date'] ?? '')) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'livestock_report_' . date('Y-m-d') . '.html',
            'body' => $html,
        ];
    }

    private function buildTasksReport(int $farmId, string $startDate, string $endDate, string $format): array
    {
        $rows = $this->db->query(
            'SELECT title, status, priority, due_date, created_at, updated_at
             FROM ' . Task::table() . '
             WHERE farm_id = ? AND DATE(created_at) >= ? AND DATE(created_at) <= ?
             ORDER BY created_at DESC',
            [$farmId, $startDate, $endDate]
        );

        $pending = 0;
        $inProgress = 0;
        $completed = 0;
        foreach ($rows as $r) {
            $s = (string) ($r['status'] ?? '');
            if ($s === 'completed') {
                $completed++;
            } elseif ($s === 'in_progress') {
                $inProgress++;
            } else {
                $pending++;
            }
        }

        if ($format === 'csv') {
            $out = fopen('php://temp', 'r+');
            fputcsv($out, ['title', 'status', 'priority', 'due_date', 'created_at', 'updated_at']);
            foreach ($rows as $r) {
                fputcsv($out, [
                    (string) ($r['title'] ?? ''),
                    (string) ($r['status'] ?? ''),
                    (string) ($r['priority'] ?? ''),
                    (string) ($r['due_date'] ?? ''),
                    (string) ($r['created_at'] ?? ''),
                    (string) ($r['updated_at'] ?? ''),
                ]);
            }
            fputcsv($out, []);
            fputcsv($out, ['pending', (string) $pending]);
            fputcsv($out, ['in_progress', (string) $inProgress]);
            fputcsv($out, ['completed', (string) $completed]);
            rewind($out);
            $csv = stream_get_contents($out);
            fclose($out);

            return [
                'content_type' => 'text/csv; charset=utf-8',
                'filename' => 'tasks_report_' . $startDate . '_to_' . $endDate . '.csv',
                'body' => $csv ?: '',
            ];
        }

        $escape = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<!doctype html><html><head><meta charset="utf-8"><title>Tasks Report</title></head><body>';
        $html .= '<h1>Tasks Report</h1>';
        $html .= '<p>Farm ID: ' . $escape((string) $farmId) . '</p>';
        $html .= '<p>Period: ' . $escape($startDate) . ' to ' . $escape($endDate) . '</p>';
        $html .= '<p>Pending: ' . $escape((string) $pending) . ' In progress: ' . $escape((string) $inProgress) . ' Completed: ' . $escape((string) $completed) . '</p>';
        $html .= '<table border="1" cellpadding="6" cellspacing="0"><thead><tr>';
        foreach (['Title', 'Status', 'Priority', 'Due Date', 'Created', 'Updated'] as $h) {
            $html .= '<th>' . $escape($h) . '</th>';
        }
        $html .= '</tr></thead><tbody>';
        foreach ($rows as $r) {
            $html .= '<tr>';
            $html .= '<td>' . $escape((string) ($r['title'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['status'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['priority'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['due_date'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['created_at'] ?? '')) . '</td>';
            $html .= '<td>' . $escape((string) ($r['updated_at'] ?? '')) . '</td>';
            $html .= '</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return [
            'content_type' => 'text/html; charset=utf-8',
            'filename' => 'tasks_report_' . $startDate . '_to_' . $endDate . '.html',
            'body' => $html,
        ];
    }

    public function getReportExportByToken(string $token): ?array
    {
        return $this->reportService->getExportByToken($token);
    }

    public function analyticsDashboard(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = $this->resolveFarmId($user);
            return Response::success($this->analyticsService->getDashboard($farmId));
        } catch (\Exception $e) {
            Logger::error('Failed to get analytics dashboard', ['error' => $e->getMessage()]);
            return Response::error('Failed to get analytics dashboard', 'ANALYTICS_ERROR', 500);
        }
    }
}
