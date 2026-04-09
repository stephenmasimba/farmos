<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class FieldsController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function requireAuth()
    {
        $user = $this->request->getUser();
        return $user ?: null;
    }

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS fields (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NULL,
                name VARCHAR(100) NOT NULL,
                area_size DECIMAL(10,2) DEFAULT 0,
                location_coordinates VARCHAR(255) NULL,
                current_crop VARCHAR(100) NULL,
                planting_date DATE NULL,
                expected_harvest_date DATE NULL,
                status VARCHAR(20) DEFAULT "fallow",
                soil_type VARCHAR(100) NULL,
                notes TEXT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS field_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                field_id INT NOT NULL,
                event_date DATE NOT NULL,
                action VARCHAR(100) NOT NULL,
                details TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_field_history_field (field_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS field_soil_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                field_id INT NOT NULL,
                log_date DATE NOT NULL,
                organic_matter_percent DECIMAL(5,2) NOT NULL,
                ph DECIMAL(4,2) NOT NULL,
                notes TEXT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_field_soil_field (field_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS field_harvest_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                field_id INT NOT NULL,
                harvest_date DATE NOT NULL,
                crop VARCHAR(100) NOT NULL,
                yield_amount DECIMAL(10,2) NOT NULL,
                unit VARCHAR(20) NOT NULL,
                target_yield DECIMAL(10,2) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_field_harvest_field (field_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS field_rotation_plans (
                id INT AUTO_INCREMENT PRIMARY KEY,
                field_id INT NOT NULL,
                year INT NOT NULL,
                season VARCHAR(50) NOT NULL,
                planned_crop VARCHAR(100) NOT NULL,
                notes TEXT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_field_rotation_field (field_id)
            )'
        );
    }

    private function mapStatusForStorage(string $status): string
    {
        $normalized = strtolower(trim($status));
        if ($normalized === 'active') {
            return 'planted';
        }
        if ($normalized === 'inactive') {
            return 'harvested';
        }
        if ($normalized === 'fallow') {
            return 'fallow';
        }

        return 'prepared';
    }

    private function mapStatusForDisplay(?string $status): string
    {
        $normalized = strtolower((string) $status);
        if ($normalized === 'planted' || $normalized === 'prepared') {
            return 'Active';
        }
        if ($normalized === 'fallow') {
            return 'Fallow';
        }

        return 'Inactive';
    }

    public function index(): Response
    {
        try {
            if (!$this->requireAuth()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 1);
            $rows = $this->db->query(
                'SELECT id, name, area_size, current_crop, status FROM fields WHERE farm_id = ? OR farm_id IS NULL ORDER BY name ASC',
                [$farmId]
            );

            $fields = array_map(fn(array $row) => [
                'id' => (int) $row['id'],
                'name' => $row['name'] ?? '',
                'area' => (float) ($row['area_size'] ?? 0),
                'crop' => $row['current_crop'] ?? '',
                'status' => $this->mapStatusForDisplay($row['status'] ?? null),
            ], $rows);

            return Response::success($fields);
        } catch (\Exception $e) {
            Logger::error('Failed to list fields', ['error' => $e->getMessage()]);
            return Response::error('Failed to list fields', 'FIELDS_LIST_ERROR', 500);
        }
    }

    public function store(): Response
    {
        try {
            if (!$this->requireAuth()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $area = $input['area'] ?? null;
            if ($name === '' || !is_numeric($area)) {
                return Response::validationError([
                    'name' => $name === '' ? 'Name is required' : null,
                    'area' => !is_numeric($area) ? 'Area must be numeric' : null,
                ]);
            }

            $farmId = (int) ($input['farm_id'] ?? 1);
            $this->db->execute(
                'INSERT INTO fields (farm_id, name, area_size, current_crop, status, notes) VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($name),
                    (float) $area,
                    Validation::sanitizeString((string) ($input['crop'] ?? '')),
                    $this->mapStatusForStorage((string) ($input['status'] ?? 'Active')),
                    Validation::sanitizeString((string) ($input['notes'] ?? '')),
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Field created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create field', ['error' => $e->getMessage()]);
            return Response::error('Failed to create field', 'FIELD_CREATE_ERROR', 500);
        }
    }

    public function history(int $fieldId): Response
    {
        return $this->listChildRows('field_history', $fieldId, 'event_date', [
            'id',
            'field_id',
            'event_date AS date',
            'action',
            'details',
        ]);
    }

    public function soil(int $fieldId): Response
    {
        return $this->listChildRows('field_soil_logs', $fieldId, 'log_date', [
            'id',
            'field_id',
            'log_date AS date',
            'organic_matter_percent',
            'ph',
            'notes',
        ]);
    }

    public function harvest(int $fieldId): Response
    {
        return $this->listChildRows('field_harvest_logs', $fieldId, 'harvest_date', [
            'id',
            'field_id',
            'harvest_date AS date',
            'crop',
            'yield_amount',
            'unit',
            'target_yield',
        ]);
    }

    public function rotation(int $fieldId): Response
    {
        return $this->listChildRows('field_rotation_plans', $fieldId, 'year DESC, season', [
            'id',
            'field_id',
            'year',
            'season',
            'planned_crop',
            'notes',
        ]);
    }

    private function listChildRows(string $table, int $fieldId, string $orderBy, array $columns): Response
    {
        try {
            if (!$this->requireAuth()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT ' . implode(', ', $columns) . ' FROM ' . $table . ' WHERE field_id = ? ORDER BY ' . $orderBy,
                [$fieldId]
            );
            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list field detail rows', ['table' => $table, 'error' => $e->getMessage()]);
            return Response::error('Failed to retrieve field details', 'FIELD_DETAIL_ERROR', 500);
        }
    }

    public function addHistory(): Response
    {
        return $this->insertChildRow('field_history', [
            'field_id', 'date', 'action', 'details'
        ], static fn(array $input) => [
            (int) $input['field_id'],
            $input['date'],
            Validation::sanitizeString((string) $input['action']),
            Validation::sanitizeString((string) $input['details']),
        ], 'INSERT INTO field_history (field_id, event_date, action, details) VALUES (?, ?, ?, ?)');
    }

    public function addSoil(): Response
    {
        return $this->insertChildRow('field_soil_logs', [
            'field_id', 'date', 'organic_matter_percent', 'ph'
        ], static fn(array $input) => [
            (int) $input['field_id'],
            $input['date'],
            (float) $input['organic_matter_percent'],
            (float) $input['ph'],
            Validation::sanitizeString((string) ($input['notes'] ?? '')),
        ], 'INSERT INTO field_soil_logs (field_id, log_date, organic_matter_percent, ph, notes) VALUES (?, ?, ?, ?, ?)');
    }

    public function addHarvest(): Response
    {
        return $this->insertChildRow('field_harvest_logs', [
            'field_id', 'date', 'crop', 'yield_amount', 'unit'
        ], static fn(array $input) => [
            (int) $input['field_id'],
            $input['date'],
            Validation::sanitizeString((string) $input['crop']),
            (float) $input['yield_amount'],
            Validation::sanitizeString((string) $input['unit']),
            isset($input['target_yield']) ? (float) $input['target_yield'] : null,
        ], 'INSERT INTO field_harvest_logs (field_id, harvest_date, crop, yield_amount, unit, target_yield) VALUES (?, ?, ?, ?, ?, ?)');
    }

    public function addRotation(): Response
    {
        return $this->insertChildRow('field_rotation_plans', [
            'field_id', 'year', 'season', 'planned_crop'
        ], static fn(array $input) => [
            (int) $input['field_id'],
            (int) $input['year'],
            Validation::sanitizeString((string) $input['season']),
            Validation::sanitizeString((string) $input['planned_crop']),
            Validation::sanitizeString((string) ($input['notes'] ?? '')),
        ], 'INSERT INTO field_rotation_plans (field_id, year, season, planned_crop, notes) VALUES (?, ?, ?, ?, ?)');
    }

    private function insertChildRow(string $table, array $required, callable $mapper, string $sql): Response
    {
        try {
            if (!$this->requireAuth()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $errors = [];
            foreach ($required as $field) {
                if (!isset($input[$field]) || $input[$field] === '') {
                    $errors[$field] = 'Required';
                }
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute($sql, $mapper($input));
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Saved successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to insert field child row', ['table' => $table, 'error' => $e->getMessage()]);
            return Response::error('Failed to save field data', 'FIELD_SAVE_ERROR', 500);
        }
    }
}
