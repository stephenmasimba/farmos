<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class PaymentsController
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
            'CREATE TABLE IF NOT EXISTS payment_methods (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                brand VARCHAR(50) NOT NULL,
                last4 VARCHAR(4) NOT NULL,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_payment_methods_user (user_id, is_active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS payment_transactions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                currency VARCHAR(3) NOT NULL DEFAULT "USD",
                status VARCHAR(20) NOT NULL DEFAULT "completed",
                processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_payment_transactions_user (user_id),
                INDEX idx_payment_transactions_time (processed_at)
            )'
        );
    }

    public function listMethods(): Response
    {
        try {
            $auth = $this->authorizePermission('financial.read');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT id, brand, last4
                 FROM payment_methods
                 WHERE user_id = ? AND is_active = 1
                 ORDER BY created_at DESC, id DESC',
                [$userId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list payment methods', ['error' => $e->getMessage()]);
            return Response::error('Failed to list payment methods', 'PAYMENT_METHODS_LIST_ERROR', 500);
        }
    }

    public function process(): Response
    {
        try {
            $auth = $this->authorizePermission('financial.update');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $amount = $input['amount'] ?? null;
            if (!is_numeric($amount) || (float) $amount <= 0) {
                return Response::validationError(['amount' => 'Amount must be greater than zero']);
            }

            $this->db->execute(
                'INSERT INTO payment_transactions (user_id, amount, currency, status) VALUES (?, ?, ?, ?)',
                [$userId, (float) $amount, 'USD', 'completed']
            );

            return Response::success([
                'id' => (int) $this->db->lastInsertId(),
                'amount' => (float) $amount,
                'currency' => 'USD',
                'status' => 'completed',
            ], 'Payment processed successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to process payment', ['error' => $e->getMessage()]);
            return Response::error('Failed to process payment', 'PAYMENT_PROCESS_ERROR', 500);
        }
    }
}
