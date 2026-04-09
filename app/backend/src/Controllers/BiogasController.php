<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class BiogasController
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
        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS biogas_system_status (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                system_name VARCHAR(150) NOT NULL,
                alert_level VARCHAR(20) NOT NULL DEFAULT "OPERATIONAL",
                current_pressure_bar DECIMAL(10,2) NOT NULL DEFAULT 0,
                pressure_percentage INT NOT NULL DEFAULT 0,
                net_flow_rate_m3h DECIMAL(10,2) NOT NULL DEFAULT 0,
                gas_production_rate_m3h DECIMAL(10,2) NOT NULL DEFAULT 0,
                gas_consumption_rate_m3h DECIMAL(10,2) NOT NULL DEFAULT 0,
                last_maintenance_date DATETIME NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_biogas_status_farm (farm_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS biogas_zone_status (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                zone_name VARCHAR(120) NOT NULL,
                zone_type VARCHAR(40) NOT NULL,
                current_pressure DECIMAL(10,2) NOT NULL DEFAULT 0,
                pressure_status VARCHAR(30) NOT NULL DEFAULT "STABLE",
                risk_level VARCHAR(30) NOT NULL DEFAULT "NORMAL",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_biogas_zone_farm (farm_id, created_at)
            )'
        );
    }

    public function status(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT system_name, alert_level, current_pressure_bar, pressure_percentage,
                        net_flow_rate_m3h, gas_production_rate_m3h, gas_consumption_rate_m3h, last_maintenance_date
                 FROM biogas_system_status
                 WHERE farm_id = ?
                 ORDER BY created_at DESC, id DESC
                 LIMIT 50',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch biogas status', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch biogas status', 'BIOGAS_STATUS_ERROR', 500);
        }
    }

    public function zones(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT id AS zone_id, zone_name, zone_type, current_pressure, pressure_status, risk_level
                 FROM biogas_zone_status
                 WHERE farm_id = ?
                 ORDER BY created_at DESC, id DESC
                 LIMIT 100',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch biogas zones', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch biogas zones', 'BIOGAS_ZONES_ERROR', 500);
        }
    }
}
