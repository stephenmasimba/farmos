<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation
};
use FarmOS\Models\{Livestock, Inventory, FinancialRecord, Task, Farm};

/**
 * DashboardController - Aggregated farm dashboard and reporting
 */
class DashboardController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
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

            return Response::success([
                'scores' => $scores,
                'overall_health_score' => round($overallScore, 2),
                'status' => match(true) {
                    $overallScore >= 80 => 'excellent',
                    $overallScore >= 60 => 'good',
                    $overallScore >= 40 => 'fair',
                    default => 'needs_attention'
                },
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
}
