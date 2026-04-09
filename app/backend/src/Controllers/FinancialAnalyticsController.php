<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};
use FarmOS\Middleware\PermissionMiddleware;

class FinancialAnalyticsController
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

    private function getUserId(): ?int
    {
        $user = $this->request->getUser();
        if (!$user || empty($user['user_id'])) {
            return null;
        }

        return (int) $user['user_id'];
    }

    private function getFarmId(): int
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
            'CREATE TABLE IF NOT EXISTS financial_analytics_forecast (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                period VARCHAR(20) NOT NULL,
                projected_revenue DECIMAL(12,2) NOT NULL DEFAULT 0,
                projected_expenses DECIMAL(12,2) NOT NULL DEFAULT 0,
                net_cash_flow DECIMAL(12,2) NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_fin_forecast_farm (farm_id, period)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_assets (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                asset_name VARCHAR(180) NOT NULL,
                type VARCHAR(80) NOT NULL,
                purchase_cost DECIMAL(12,2) NOT NULL DEFAULT 0,
                current_value DECIMAL(12,2) NOT NULL DEFAULT 0,
                annual_depreciation DECIMAL(12,2) NOT NULL DEFAULT 0,
                purchase_date DATE NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_fin_assets_farm (farm_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS financial_roi_projects (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                project_name VARCHAR(180) NOT NULL,
                investment DECIMAL(12,2) NOT NULL DEFAULT 0,
                roi_percentage DECIMAL(8,2) NOT NULL DEFAULT 0,
                payback_months INT NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_fin_roi_farm (farm_id, created_at)
            )'
        );
    }

    public function forecast(): Response
    {
        try {
            $auth = $this->authorizePermission('analytics.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();

            $rows = $this->db->query(
                'SELECT period, projected_revenue, projected_expenses, net_cash_flow
                 FROM financial_analytics_forecast
                 WHERE farm_id = ?
                 ORDER BY period ASC, id ASC',
                [$farmId]
            );

            $currentCashPosition = 0.0;
            $burnRate = 0.0;
            $months = count($rows);

            foreach ($rows as $row) {
                $currentCashPosition += (float) ($row['net_cash_flow'] ?? 0);
                $net = (float) ($row['net_cash_flow'] ?? 0);
                if ($net < 0) {
                    $burnRate += abs($net);
                }
            }

            $avgBurn = $months > 0 ? round($burnRate / $months, 2) : 0.0;
            $runwayMonths = $avgBurn > 0 ? (int) floor(max(0, $currentCashPosition) / $avgBurn) : 0;

            return Response::success([
                'current_cash_position' => round($currentCashPosition, 2),
                'burn_rate' => $avgBurn,
                'runway_months' => $runwayMonths,
                'forecast_scenarios' => [
                    'Realistic' => $rows,
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch financial analytics forecast', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch financial analytics forecast', 'FINANCIAL_ANALYTICS_FORECAST_ERROR', 500);
        }
    }

    public function assets(): Response
    {
        try {
            $auth = $this->authorizePermission('analytics.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT asset_name, type, purchase_cost, current_value, annual_depreciation, purchase_date
                 FROM financial_assets
                 WHERE farm_id = ?
                 ORDER BY id DESC
                 LIMIT 200',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch financial assets', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch financial assets', 'FINANCIAL_ANALYTICS_ASSETS_ERROR', 500);
        }
    }

    public function roi(): Response
    {
        try {
            $auth = $this->authorizePermission('analytics.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT project_name, investment, roi_percentage, payback_months
                 FROM financial_roi_projects
                 WHERE farm_id = ?
                 ORDER BY roi_percentage DESC, id DESC
                 LIMIT 200',
                [$farmId]
            );

            $payload = [];
            foreach ($rows as $row) {
                $payload[] = [
                    'project_name' => $row['project_name'],
                    'investment' => (float) ($row['investment'] ?? 0),
                    'roi_percentage' => (float) ($row['roi_percentage'] ?? 0),
                    'payback_months' => (int) ($row['payback_months'] ?? 0),
                ];
            }

            return Response::success($payload);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch financial ROI projects', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch ROI projects', 'FINANCIAL_ANALYTICS_ROI_ERROR', 500);
        }
    }
}
