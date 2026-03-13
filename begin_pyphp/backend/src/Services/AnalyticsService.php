<?php

namespace FarmOS\Services;

use FarmOS\Database;
use FarmOS\Repositories\ApiRequestLogRepository;
use FarmOS\Models\{FinancialRecord, Inventory, Task};

final class AnalyticsService
{
    private Database $db;
    private ApiRequestLogRepository $apiLogs;

    public function __construct(Database $db)
    {
        $this->db = $db;
        $this->apiLogs = new ApiRequestLogRepository($db);
    }

    public function getDashboard(int $farmId): array
    {
        $tasks = $this->db->queryOne(
            "SELECT
                SUM(CASE WHEN status IN ('pending','in_progress') THEN 1 ELSE 0 END) AS active_tasks
             FROM " . Task::table() . "
             WHERE farm_id = ?",
            [$farmId]
        );

        $criticalTasks = $this->db->queryOne(
            "SELECT COUNT(*) AS c
             FROM " . Task::table() . "
             WHERE farm_id = ? AND priority = 'critical' AND status != 'completed'",
            [$farmId]
        );

        $lowStock = $this->db->queryOne(
            'SELECT COUNT(*) AS c
             FROM ' . Inventory::table() . '
             WHERE farm_id = ? AND min_level IS NOT NULL AND quantity < min_level',
            [$farmId]
        );

        $criticalAlerts = (int) (($criticalTasks['c'] ?? 0) + ($lowStock['c'] ?? 0));

        $dailyRevenue = [];
        for ($i = 6; $i >= 0; $i--) {
            $d = date('Y-m-d', strtotime("-$i days"));
            $row = $this->db->queryOne(
                'SELECT SUM(amount) AS total
                 FROM ' . FinancialRecord::table() . '
                 WHERE farm_id = ? AND type = "income" AND DATE(date) = ?',
                [$farmId, $d]
            );
            $dailyRevenue[] = (int) round((float) ($row['total'] ?? 0));
        }

        $api = $this->getApiAnalytics();

        return [
            'active_tasks' => (int) ($tasks['active_tasks'] ?? 0),
            'critical_alerts' => $criticalAlerts,
            'daily_revenue' => $dailyRevenue,
            'api' => $api,
        ];
    }

    private function getApiAnalytics(): ?array
    {
        try {
            return [
                'last_hour' => [
                    ...$this->apiLogs->getLastHourStats(),
                ],
            ];
        } catch (\Exception $e) {
            return null;
        }
    }
}
