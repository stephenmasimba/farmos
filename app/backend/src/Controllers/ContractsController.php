<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class ContractsController
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

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS contracts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                grower_name VARCHAR(255) NOT NULL,
                crop VARCHAR(100) NOT NULL,
                acreage DECIMAL(10,2) NOT NULL,
                agreed_price_per_kg DECIMAL(10,2) NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                status VARCHAR(20) DEFAULT "draft",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_contracts_status (status),
                INDEX idx_contracts_dates (start_date, end_date)
            )'
        );
    }

    private function toDisplayStatus(?string $status): string
    {
        $normalized = strtolower((string) $status);
        if ($normalized === 'active') {
            return 'Active';
        }
        if ($normalized === 'completed') {
            return 'Completed';
        }

        return 'Draft';
    }

    private function toStorageStatus(string $status): string
    {
        $normalized = strtolower(trim($status));
        if (in_array($normalized, ['draft', 'active', 'completed'], true)) {
            return $normalized;
        }

        return 'draft';
    }

    public function index(): Response
    {
        try {
            $auth = $this->authorizePermission('marketplace.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTable();
            $rows = $this->db->query(
                'SELECT id, grower_name, crop, acreage, agreed_price_per_kg, start_date, end_date, status
                 FROM contracts
                 ORDER BY created_at DESC, id DESC'
            );

            $contracts = array_map(function (array $row): array {
                return [
                    'id' => (int) $row['id'],
                    'grower_name' => $row['grower_name'] ?? '',
                    'crop' => $row['crop'] ?? '',
                    'acreage' => (float) ($row['acreage'] ?? 0),
                    'agreed_price_per_kg' => (float) ($row['agreed_price_per_kg'] ?? 0),
                    'start_date' => $row['start_date'] ?? '',
                    'end_date' => $row['end_date'] ?? '',
                    'status' => $this->toDisplayStatus($row['status'] ?? null),
                ];
            }, $rows);

            return Response::success($contracts);
        } catch (\Exception $e) {
            Logger::error('Failed to list contracts', ['error' => $e->getMessage()]);
            return Response::error('Failed to list contracts', 'CONTRACTS_LIST_ERROR', 500);
        }
    }

    public function store(): Response
    {
        try {
            $auth = $this->authorizePermission('marketplace.manage');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $input = $this->request->getBody();
            $growerName = trim((string) ($input['grower_name'] ?? ''));
            $crop = trim((string) ($input['crop'] ?? ''));
            $acreage = $input['acreage'] ?? null;
            $price = $input['agreed_price_per_kg'] ?? null;
            $startDate = (string) ($input['start_date'] ?? '');
            $endDate = (string) ($input['end_date'] ?? '');

            $errors = [];
            if ($growerName === '') {
                $errors['grower_name'] = 'Grower name is required';
            }
            if ($crop === '') {
                $errors['crop'] = 'Crop is required';
            }
            if (!is_numeric($acreage) || (float) $acreage <= 0) {
                $errors['acreage'] = 'Acreage must be greater than zero';
            }
            if (!is_numeric($price) || (float) $price < 0) {
                $errors['agreed_price_per_kg'] = 'Price per kg must be numeric';
            }
            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                $errors['start_date'] = 'Valid start date is required';
            }
            if (!Validation::validateDate($endDate, 'Y-m-d')) {
                $errors['end_date'] = 'Valid end date is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO contracts (grower_name, crop, acreage, agreed_price_per_kg, start_date, end_date, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    Validation::sanitizeString($growerName),
                    Validation::sanitizeString($crop),
                    (float) $acreage,
                    (float) $price,
                    $startDate,
                    $endDate,
                    $this->toStorageStatus((string) ($input['status'] ?? 'Draft')),
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Contract created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create contract', ['error' => $e->getMessage()]);
            return Response::error('Failed to create contract', 'CONTRACT_CREATE_ERROR', 500);
        }
    }
}
