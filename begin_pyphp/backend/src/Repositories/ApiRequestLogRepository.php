<?php

namespace FarmOS\Repositories;

use FarmOS\Database;

final class ApiRequestLogRepository
{
    private Database $db;
    private static bool $tableEnsured = false;

    public function __construct(Database $db)
    {
        $this->db = $db;
    }

    public function getLastHourStats(): array
    {
        $this->ensureTable();
        $lastHour = date('Y-m-d H:i:s', time() - 3600);
        $hits = $this->db->queryOne('SELECT COUNT(*) AS c FROM api_request_logs WHERE created_at >= ?', [$lastHour]);
        $errors = $this->db->queryOne('SELECT COUNT(*) AS c FROM api_request_logs WHERE created_at >= ? AND status_code >= 400', [$lastHour]);
        $top = $this->db->query(
            'SELECT path, COUNT(*) AS c
             FROM api_request_logs
             WHERE created_at >= ?
             GROUP BY path
             ORDER BY c DESC
             LIMIT 10',
            [$lastHour]
        );

        return [
            'requests' => (int) ($hits['c'] ?? 0),
            'errors' => (int) ($errors['c'] ?? 0),
            'top_paths' => array_map(fn($r) => ['path' => (string) ($r['path'] ?? ''), 'count' => (int) ($r['c'] ?? 0)], $top),
        ];
    }

    private function ensureTable(): void
    {
        if (self::$tableEnsured) {
            return;
        }
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS api_request_logs (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                method VARCHAR(10) NOT NULL,
                path VARCHAR(255) NOT NULL,
                status_code INT NOT NULL,
                duration_ms INT NOT NULL,
                ip VARCHAR(64) NULL,
                user_id INT NULL,
                user_agent VARCHAR(255) NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_created_at (created_at),
                INDEX idx_path (path),
                INDEX idx_status_code (status_code),
                INDEX idx_user_id (user_id)
            )'
        );
        self::$tableEnsured = true;
    }
}

