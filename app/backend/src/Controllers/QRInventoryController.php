<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class QRInventoryController
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

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS qr_scan_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                item_type VARCHAR(60) NOT NULL,
                item_id INT NULL,
                scan_type VARCHAR(40) NOT NULL,
                quantity DECIMAL(12,2) NULL,
                unit VARCHAR(20) NULL,
                status VARCHAR(30) NULL,
                user_id INT NULL,
                scan_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_qr_farm_scan (farm_id, scan_time)
            )'
        );
    }

    public function history(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT item_type, item_id, scan_type, quantity, unit, status, user_id, scan_time
                 FROM qr_scan_history
                 WHERE farm_id = ?
                 ORDER BY scan_time DESC, id DESC
                 LIMIT 200',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch QR scan history', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch QR history', 'QR_HISTORY_ERROR', 500);
        }
    }
}
