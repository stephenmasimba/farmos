<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class PredictiveMaintenanceController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
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
            'CREATE TABLE IF NOT EXISTS predictive_maintenance_alerts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                equipment_name VARCHAR(150) NOT NULL,
                location VARCHAR(150) NULL,
                risk_level VARCHAR(20) NOT NULL DEFAULT "MEDIUM",
                risk_score INT NOT NULL DEFAULT 0,
                predicted_failure_date DATE NULL,
                vibration_mm_s DECIMAL(10,2) NULL,
                temperature_c DECIMAL(10,2) NULL,
                current_draw_a DECIMAL(10,2) NULL,
                recommended_action VARCHAR(255) NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_pm_alerts_farm (farm_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS predictive_maintenance_fleet (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                total_assets INT NOT NULL DEFAULT 0,
                fleet_availability DECIMAL(5,2) NOT NULL DEFAULT 0,
                critical INT NOT NULL DEFAULT 0,
                estimated_downtime_prevented_hrs DECIMAL(10,2) NOT NULL DEFAULT 0,
                maintenance_cost_savings_usd DECIMAL(12,2) NOT NULL DEFAULT 0,
                recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_pm_fleet_farm (farm_id, recorded_at)
            )'
        );
    }

    public function alerts(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();

            $rows = $this->db->query(
                'SELECT id, equipment_name, location, risk_level, risk_score, predicted_failure_date,
                        vibration_mm_s, temperature_c, current_draw_a, recommended_action
                 FROM predictive_maintenance_alerts
                 WHERE farm_id = ? AND status = ?
                 ORDER BY risk_score DESC, id DESC
                 LIMIT 100',
                [$farmId, 'open']
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list predictive maintenance alerts', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch predictive maintenance alerts', 'PREDICTIVE_MAINTENANCE_ALERTS_ERROR', 500);
        }
    }

    public function fleetHealth(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();

            $row = $this->db->queryOne(
                'SELECT total_assets, fleet_availability, critical, estimated_downtime_prevented_hrs, maintenance_cost_savings_usd
                 FROM predictive_maintenance_fleet
                 WHERE farm_id = ?
                 ORDER BY recorded_at DESC, id DESC
                 LIMIT 1',
                [$farmId]
            );

            if (!$row) {
                $row = [
                    'total_assets' => 0,
                    'fleet_availability' => 0,
                    'critical' => 0,
                    'estimated_downtime_prevented_hrs' => 0,
                    'maintenance_cost_savings_usd' => 0,
                ];
            }

            return Response::success($row);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch predictive maintenance fleet health', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch fleet health', 'PREDICTIVE_MAINTENANCE_FLEET_ERROR', 500);
        }
    }
}
