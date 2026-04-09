<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class WeatherIrrigationController
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
            'CREATE TABLE IF NOT EXISTS weather_irrigation_decisions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                forecast_rain_12h DECIMAL(8,2) NOT NULL DEFAULT 0,
                should_skip_irrigation TINYINT(1) NOT NULL DEFAULT 0,
                skip_reason VARCHAR(255) NULL,
                confidence_score INT NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_weather_decision_farm (farm_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS weather_irrigation_schedule (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                zone_name VARCHAR(120) NOT NULL,
                field_name VARCHAR(120) NULL,
                scheduled_time DATETIME NOT NULL,
                duration_min INT NOT NULL DEFAULT 0,
                status VARCHAR(20) NOT NULL DEFAULT "SCHEDULED",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_weather_schedule_farm (farm_id, scheduled_time)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS weather_irrigation_moisture (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                zone VARCHAR(120) NOT NULL,
                moisture_pct INT NOT NULL DEFAULT 0,
                threshold_pct INT NOT NULL DEFAULT 0,
                status VARCHAR(20) NOT NULL DEFAULT "OK",
                measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_weather_moisture_farm (farm_id, measured_at)
            )'
        );
    }

    public function decision(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $row = $this->db->queryOne(
                'SELECT forecast_rain_12h, should_skip_irrigation, skip_reason, confidence_score
                 FROM weather_irrigation_decisions
                 WHERE farm_id = ?
                 ORDER BY created_at DESC, id DESC
                 LIMIT 1',
                [$farmId]
            );

            if (!$row) {
                $row = [
                    'forecast_rain_12h' => 0,
                    'should_skip_irrigation' => 0,
                    'skip_reason' => 'No automated recommendation available yet',
                    'confidence_score' => 0,
                ];
            }

            return Response::success($row);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch irrigation decision', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch irrigation decision', 'WEATHER_IRRIGATION_DECISION_ERROR', 500);
        }
    }

    public function schedule(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT zone_name, field_name, scheduled_time, duration_min, status
                 FROM weather_irrigation_schedule
                 WHERE farm_id = ?
                 ORDER BY scheduled_time ASC, id ASC
                 LIMIT 100',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch irrigation schedule', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch irrigation schedule', 'WEATHER_IRRIGATION_SCHEDULE_ERROR', 500);
        }
    }

    public function moisture(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT zone, moisture_pct, threshold_pct, status
                 FROM weather_irrigation_moisture
                 WHERE farm_id = ?
                 ORDER BY measured_at DESC, id DESC
                 LIMIT 100',
                [$farmId]
            );

            $payload = [];
            foreach ($rows as $row) {
                $payload[] = [
                    'zone' => $row['zone'],
                    'moisture_pct' => (int) ($row['moisture_pct'] ?? 0),
                    'threshold' => (int) ($row['threshold_pct'] ?? 0),
                    'status' => $row['status'] ?? 'OK',
                ];
            }

            return Response::success($payload);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch irrigation moisture data', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch moisture data', 'WEATHER_IRRIGATION_MOISTURE_ERROR', 500);
        }
    }
}
