<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class SuppliersController
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

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS suppliers (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                contact_person VARCHAR(100) NULL,
                phone VARCHAR(20) NULL,
                email VARCHAR(100) NULL,
                address TEXT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )'
        );
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
                'SELECT id, name, contact_person, email, phone, address, created_at
                 FROM suppliers
                 ORDER BY created_at DESC, id DESC'
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list suppliers', ['error' => $e->getMessage()]);
            return Response::error('Failed to list suppliers', 'SUPPLIERS_LIST_ERROR', 500);
        }
    }

    public function store(): Response
    {
        try {
            $auth = $this->authorizePermission('marketplace.manage');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTable();
            $input = $this->request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            $email = trim((string) ($input['email'] ?? ''));

            $errors = [];
            if ($name === '') {
                $errors['name'] = 'Name is required';
            }
            if ($email !== '' && !Validation::validateEmail($email)) {
                $errors['email'] = 'Invalid email format';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO suppliers (name, contact_person, phone, email, address)
                 VALUES (?, ?, ?, ?, ?)',
                [
                    Validation::sanitizeString($name),
                    Validation::sanitizeString((string) ($input['contact_person'] ?? '')),
                    Validation::sanitizeString((string) ($input['phone'] ?? '')),
                    $email !== '' ? $email : null,
                    Validation::sanitizeString((string) ($input['address'] ?? '')),
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Supplier created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create supplier', ['error' => $e->getMessage()]);
            return Response::error('Failed to create supplier', 'SUPPLIER_CREATE_ERROR', 500);
        }
    }
}
