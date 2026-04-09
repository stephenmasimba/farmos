<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class WasteController
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

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS waste_biogas_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                log_date DATE NOT NULL,
                feedstock_input_kg DECIMAL(10,2) NOT NULL,
                estimated_gas_output_m3 DECIMAL(10,2) NOT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_waste_biogas_date (log_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS waste_compost_piles (
                id INT AUTO_INCREMENT PRIMARY KEY,
                location VARCHAR(150) NOT NULL,
                start_date DATE NOT NULL,
                status VARCHAR(30) NOT NULL DEFAULT "Active",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_waste_compost_date (start_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS waste_manure_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                log_date DATE NOT NULL,
                source VARCHAR(100) NOT NULL,
                quantity_kg DECIMAL(10,2) NOT NULL,
                destination VARCHAR(100) NOT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_waste_manure_date (log_date)
            )'
        );
    }

    public function biogas(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'compliance.read' : 'compliance.manage';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT log_date AS date, feedstock_input_kg, estimated_gas_output_m3
                     FROM waste_biogas_logs
                     ORDER BY log_date DESC, id DESC
                     LIMIT 50'
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $date = (string) ($input['date'] ?? '');
            $inputKg = $input['feedstock_input_kg'] ?? null;
            $outputM3 = $input['estimated_gas_output_m3'] ?? null;

            $errors = [];
            if (!Validation::validateDate($date, 'Y-m-d')) {
                $errors['date'] = 'Valid date is required';
            }
            if (!is_numeric($inputKg) || (float) $inputKg < 0) {
                $errors['feedstock_input_kg'] = 'Feedstock input must be numeric';
            }
            if (!is_numeric($outputM3) || (float) $outputM3 < 0) {
                $errors['estimated_gas_output_m3'] = 'Gas output must be numeric';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO waste_biogas_logs (log_date, feedstock_input_kg, estimated_gas_output_m3, created_by) VALUES (?, ?, ?, ?)',
                [$date, (float) $inputKg, (float) $outputM3, $this->getUserId()]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Biogas log created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle biogas logs', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle biogas logs', 'WASTE_BIOGAS_ERROR', 500);
        }
    }

    public function compost(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'compliance.read' : 'compliance.manage';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT location, start_date, status
                     FROM waste_compost_piles
                     ORDER BY start_date DESC, id DESC
                     LIMIT 50'
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $location = trim((string) ($input['location'] ?? ''));
            $startDate = (string) ($input['start_date'] ?? '');
            $errors = [];
            if ($location === '') {
                $errors['location'] = 'Location is required';
            }
            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                $errors['start_date'] = 'Valid start date is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO waste_compost_piles (location, start_date, status, created_by) VALUES (?, ?, ?, ?)',
                [Validation::sanitizeString($location), $startDate, 'Active', $this->getUserId()]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Compost pile created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle compost piles', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle compost piles', 'WASTE_COMPOST_ERROR', 500);
        }
    }

    public function manure(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'compliance.read' : 'compliance.manage';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT log_date AS date, source, quantity_kg, destination
                     FROM waste_manure_logs
                     ORDER BY log_date DESC, id DESC
                     LIMIT 50'
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $date = (string) ($input['date'] ?? '');
            $source = trim((string) ($input['source'] ?? ''));
            $quantityKg = $input['quantity_kg'] ?? null;
            $destination = trim((string) ($input['destination'] ?? ''));

            $errors = [];
            if (!Validation::validateDate($date, 'Y-m-d')) {
                $errors['date'] = 'Valid date is required';
            }
            if ($source === '') {
                $errors['source'] = 'Source is required';
            }
            if (!is_numeric($quantityKg) || (float) $quantityKg < 0) {
                $errors['quantity_kg'] = 'Quantity must be numeric';
            }
            if ($destination === '') {
                $errors['destination'] = 'Destination is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO waste_manure_logs (log_date, source, quantity_kg, destination, created_by) VALUES (?, ?, ?, ?, ?)',
                [$date, Validation::sanitizeString($source), (float) $quantityKg, Validation::sanitizeString($destination), $this->getUserId()]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Manure log created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle manure logs', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle manure logs', 'WASTE_MANURE_ERROR', 500);
        }
    }
}
