<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class EquipmentController
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
        return $this->request->getUser() ?: null;
    }

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS equipment (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NULL,
                name VARCHAR(100) NOT NULL,
                type VARCHAR(100) NULL,
                serial_number VARCHAR(50) NULL,
                purchase_date DATE NULL,
                purchase_price DECIMAL(10,2) NULL,
                status VARCHAR(20) DEFAULT "active",
                last_maintenance_date DATE NULL,
                next_maintenance_date DATE NULL,
                notes TEXT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )'
        );
    }

    private function toStorageStatus(string $status): string
    {
        $normalized = strtolower(trim($status));
        if ($normalized === 'operational') {
            return 'active';
        }
        if ($normalized === 'maintenance' || $normalized === 'broken') {
            return 'maintenance';
        }
        if ($normalized === 'sold') {
            return 'retired';
        }

        return 'active';
    }

    private function toDisplayStatus(?string $status): string
    {
        $normalized = strtolower((string) $status);
        if ($normalized === 'maintenance') {
            return 'Maintenance';
        }
        if ($normalized === 'retired') {
            return 'Sold';
        }

        return 'Operational';
    }

    public function index(): Response
    {
        try {
            if (!$this->requireAuth()) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 1);
            $rows = $this->db->query(
                'SELECT id, name, type, purchase_date, status FROM equipment WHERE farm_id = ? OR farm_id IS NULL ORDER BY created_at DESC',
                [$farmId]
            );

            $equipment = array_map(fn(array $row) => [
                'id' => (int) $row['id'],
                'name' => $row['name'] ?? '',
                'type' => $row['type'] ?? 'Equipment',
                'purchase_date' => $row['purchase_date'] ?? '',
                'status' => $this->toDisplayStatus($row['status'] ?? null),
            ], $rows);

            return Response::success($equipment);
        } catch (\Exception $e) {
            Logger::error('Failed to list equipment', ['error' => $e->getMessage()]);
            return Response::error('Failed to list equipment', 'EQUIPMENT_LIST_ERROR', 500);
        }
    }

    public function store(): Response
    {
        try {
            if (!$this->requireAuth()) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            if ($name === '') {
                return Response::validationError(['name' => 'Name is required']);
            }

            $farmId = (int) ($input['farm_id'] ?? 1);
            $this->db->execute(
                'INSERT INTO equipment (farm_id, name, type, purchase_date, status) VALUES (?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($name),
                    Validation::sanitizeString((string) ($input['type'] ?? 'Equipment')),
                    !empty($input['purchase_date']) ? $input['purchase_date'] : null,
                    $this->toStorageStatus((string) ($input['status'] ?? 'Operational')),
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Equipment created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create equipment', ['error' => $e->getMessage()]);
            return Response::error('Failed to create equipment', 'EQUIPMENT_CREATE_ERROR', 500);
        }
    }
}
