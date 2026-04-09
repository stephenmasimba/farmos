<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class CircularityController
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
            'CREATE TABLE IF NOT EXISTS circularity_compost (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                pile_name VARCHAR(150) NOT NULL,
                type VARCHAR(80) NOT NULL DEFAULT "Compost",
                days_active INT NOT NULL DEFAULT 0,
                status VARCHAR(30) NOT NULL DEFAULT "MONITOR",
                temperature_c DECIMAL(10,2) NULL,
                moisture_pct DECIMAL(10,2) NULL,
                ph DECIMAL(6,2) NULL,
                pathogen_kill VARCHAR(30) NOT NULL DEFAULT "IDLE",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_circularity_compost_farm (farm_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS circularity_carbon (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                monthly_co2e_avoided_tonnes DECIMAL(10,2) NOT NULL DEFAULT 0,
                yearly_projection DECIMAL(10,2) NOT NULL DEFAULT 0,
                potential_credit_value_usd DECIMAL(12,2) NOT NULL DEFAULT 0,
                biogas_methane_capture DECIMAL(10,2) NOT NULL DEFAULT 0,
                waste_diversion DECIMAL(10,2) NOT NULL DEFAULT 0,
                compost_soil_sequestration DECIMAL(10,2) NOT NULL DEFAULT 0,
                calculation_period VARCHAR(120) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_circularity_carbon_farm (farm_id, created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS circularity_bsf_cycles (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                cycle_name VARCHAR(150) NOT NULL,
                start_date DATE NOT NULL,
                waste_input_kg DECIMAL(12,2) NOT NULL,
                expected_yield_kg DECIMAL(12,2) NOT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_circularity_bsf_farm (farm_id, created_at)
            )'
        );
    }

    public function compost(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->getFarmId();

            $rows = $this->db->query(
                'SELECT pile_name, type, days_active, status, temperature_c, moisture_pct, ph, pathogen_kill
                 FROM circularity_compost
                 WHERE farm_id = ?
                 ORDER BY created_at DESC, id DESC
                 LIMIT 100',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch circularity compost data', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch compost circularity', 'CIRCULARITY_COMPOST_ERROR', 500);
        }
    }

    public function carbon(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->getFarmId();

            $row = $this->db->queryOne(
                'SELECT monthly_co2e_avoided_tonnes, yearly_projection, potential_credit_value_usd,
                        biogas_methane_capture, waste_diversion, compost_soil_sequestration, calculation_period
                 FROM circularity_carbon
                 WHERE farm_id = ?
                 ORDER BY created_at DESC, id DESC
                 LIMIT 1',
                [$farmId]
            );

            if (!$row) {
                return Response::success([]);
            }

            return Response::success([
                'monthly_co2e_avoided_tonnes' => (float) ($row['monthly_co2e_avoided_tonnes'] ?? 0),
                'yearly_projection' => (float) ($row['yearly_projection'] ?? 0),
                'potential_credit_value_usd' => (float) ($row['potential_credit_value_usd'] ?? 0),
                'breakdown' => [
                    'biogas_methane_capture' => (float) ($row['biogas_methane_capture'] ?? 0),
                    'waste_diversion' => (float) ($row['waste_diversion'] ?? 0),
                    'compost_soil_sequestration' => (float) ($row['compost_soil_sequestration'] ?? 0),
                ],
                'calculation_period' => (string) ($row['calculation_period'] ?? ''),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch circularity carbon data', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch carbon circularity', 'CIRCULARITY_CARBON_ERROR', 500);
        }
    }

    public function bsf(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->getFarmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT cycle_name, start_date, waste_input_kg, expected_yield_kg
                     FROM circularity_bsf_cycles
                     WHERE farm_id = ?
                     ORDER BY start_date DESC, id DESC
                     LIMIT 100',
                    [$farmId]
                );

                $result = [];
                $todayTs = strtotime(date('Y-m-d'));
                foreach ($rows as $row) {
                    $start = (string) ($row['start_date'] ?? date('Y-m-d'));
                    $daysElapsed = 0;
                    $startTs = strtotime($start);
                    if ($startTs !== false) {
                        $daysElapsed = max(0, (int) floor(($todayTs - $startTs) / 86400));
                    }
                    $daysRemaining = max(0, 14 - $daysElapsed);

                    $result[] = [
                        'cycle_name' => $row['cycle_name'],
                        'start_date' => $start,
                        'waste_input_kg' => (float) ($row['waste_input_kg'] ?? 0),
                        'expected_yield_kg' => (float) ($row['expected_yield_kg'] ?? 0),
                        'days_remaining' => $daysRemaining,
                    ];
                }

                return Response::success($result);
            }

            $input = $this->request->getBody();
            $cycleName = trim((string) ($input['cycle_name'] ?? ''));
            $wasteInputKg = $input['waste_input_kg'] ?? null;
            $expectedYieldKg = $input['expected_yield_kg'] ?? null;
            $startDate = (string) ($input['start_date'] ?? date('Y-m-d'));

            $errors = [];
            if ($cycleName === '') {
                $errors['cycle_name'] = 'Cycle name is required';
            }
            if (!is_numeric($wasteInputKg) || (float) $wasteInputKg <= 0) {
                $errors['waste_input_kg'] = 'Waste input must be numeric';
            }
            if (!is_numeric($expectedYieldKg) || (float) $expectedYieldKg <= 0) {
                $errors['expected_yield_kg'] = 'Expected yield must be numeric';
            }
            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                $errors['start_date'] = 'Start date is invalid';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO circularity_bsf_cycles (farm_id, cycle_name, start_date, waste_input_kg, expected_yield_kg, created_by)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($cycleName),
                    $startDate,
                    (float) $wasteInputKg,
                    (float) $expectedYieldKg,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'BSF cycle created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle circularity BSF cycle', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle BSF cycle', 'CIRCULARITY_BSF_ERROR', 500);
        }
    }
}
