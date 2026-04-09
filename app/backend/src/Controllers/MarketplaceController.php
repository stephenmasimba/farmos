<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class MarketplaceController
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

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS marketplace_listings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                title VARCHAR(255) NOT NULL,
                description TEXT NOT NULL,
                category VARCHAR(100) NOT NULL,
                location VARCHAR(150) NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                unit VARCHAR(20) NOT NULL,
                quantity DECIMAL(10,2) NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "active",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_marketplace_listings_farm (farm_id, created_at),
                INDEX idx_marketplace_listings_category (category),
                INDEX idx_marketplace_listings_created_at (created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS marketplace_customers (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(255) NOT NULL,
                email VARCHAR(150) NULL,
                phone VARCHAR(50) NULL,
                address VARCHAR(255) NULL,
                notes TEXT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "active",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_marketplace_customers_farm (farm_id, created_at),
                INDEX idx_marketplace_customers_name (name),
                INDEX idx_marketplace_customers_created_at (created_at)
            )'
        );

        try {
            $this->db->execute('ALTER TABLE marketplace_listings ADD COLUMN farm_id INT NOT NULL DEFAULT 1');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE marketplace_listings ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT "active"');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE marketplace_customers ADD COLUMN farm_id INT NOT NULL DEFAULT 1');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE marketplace_customers ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT "active"');
        } catch (\Throwable $e) {
        }
    }

    private function getFarmId(): int
    {
        $input = $this->request->getBody();
        $farmId = (int) ($input['farm_id'] ?? 0);
        if ($farmId > 0) {
            return $farmId;
        }

        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 0);
    }

    public function listListings(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $rows = $this->db->query(
                'SELECT id, title, description, category, location, price, unit, quantity
                 FROM marketplace_listings
                 WHERE farm_id = ? AND status = ?
                 ORDER BY created_at DESC, id DESC',
                [$farmId, 'active']
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list marketplace listings', ['error' => $e->getMessage()]);
            return Response::error('Failed to list marketplace listings', 'MARKETPLACE_LISTINGS_ERROR', 500);
        }
    }

    public function createListing(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $farmId = $this->getFarmId();
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $title = trim((string) ($input['title'] ?? ''));
            $description = trim((string) ($input['description'] ?? ''));
            $category = trim((string) ($input['category'] ?? ''));
            $location = trim((string) ($input['location'] ?? ''));
            $unit = trim((string) ($input['unit'] ?? ''));
            $price = $input['price'] ?? null;
            $quantity = $input['quantity'] ?? null;

            $errors = [];
            if ($title === '') {
                $errors['title'] = 'Title is required';
            }
            if ($description === '') {
                $errors['description'] = 'Description is required';
            }
            if ($category === '') {
                $errors['category'] = 'Category is required';
            }
            if ($location === '') {
                $errors['location'] = 'Location is required';
            }
            if ($unit === '') {
                $errors['unit'] = 'Unit is required';
            }
            if (!is_numeric($price) || (float) $price < 0) {
                $errors['price'] = 'Price must be numeric';
            }
            if (!is_numeric($quantity) || (float) $quantity <= 0) {
                $errors['quantity'] = 'Quantity must be greater than zero';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO marketplace_listings (farm_id, title, description, category, location, price, unit, quantity, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($title),
                    Validation::sanitizeString($description),
                    Validation::sanitizeString($category),
                    Validation::sanitizeString($location),
                    (float) $price,
                    Validation::sanitizeString($unit),
                    (float) $quantity,
                    'active',
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Listing created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create marketplace listing', ['error' => $e->getMessage()]);
            return Response::error('Failed to create marketplace listing', 'MARKETPLACE_LISTING_CREATE_ERROR', 500);
        }
    }

    public function listCustomers(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $rows = $this->db->query(
                'SELECT id, name, email, phone, address, notes
                 FROM marketplace_customers
                 WHERE farm_id = ? AND status = ?
                 ORDER BY created_at DESC, id DESC',
                [$farmId, 'active']
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list marketplace customers', ['error' => $e->getMessage()]);
            return Response::error('Failed to list marketplace customers', 'MARKETPLACE_CUSTOMERS_ERROR', 500);
        }
    }

    public function createCustomer(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $farmId = $this->getFarmId();
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

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
                'INSERT INTO marketplace_customers (farm_id, name, email, phone, address, notes, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($name),
                    $email !== '' ? $email : null,
                    Validation::sanitizeString((string) ($input['phone'] ?? '')),
                    Validation::sanitizeString((string) ($input['address'] ?? '')),
                    Validation::sanitizeString((string) ($input['notes'] ?? '')),
                    'active',
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Customer created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create marketplace customer', ['error' => $e->getMessage()]);
            return Response::error('Failed to create marketplace customer', 'MARKETPLACE_CUSTOMER_CREATE_ERROR', 500);
        }
    }
}
