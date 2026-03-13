<?php

namespace FarmOS\Repositories;

use FarmOS\Database;

final class ReportExportRepository
{
    private Database $db;
    private static bool $tableEnsured = false;

    public function __construct(Database $db)
    {
        $this->db = $db;
    }

    public function save(string $token, string $contentType, string $filename, string $body, string $expiresAt): void
    {
        $this->ensureTable();
        $this->db->execute(
            'INSERT INTO report_exports (token, content_type, filename, body, expires_at) VALUES (?, ?, ?, ?, ?)',
            [$token, $contentType, $filename, $body, $expiresAt]
        );
    }

    public function findValidByToken(string $token): ?array
    {
        $this->ensureTable();
        $row = $this->db->queryOne(
            'SELECT content_type, filename, body, expires_at FROM report_exports WHERE token = ? LIMIT 1',
            [$token]
        );
        if (!$row) {
            return null;
        }

        $expiresAt = (string) ($row['expires_at'] ?? '');
        if ($expiresAt === '' || strtotime($expiresAt) === false || strtotime($expiresAt) < time()) {
            $this->deleteByToken($token);
            return null;
        }

        return [
            'content_type' => (string) ($row['content_type'] ?? 'application/octet-stream'),
            'filename' => (string) ($row['filename'] ?? 'report'),
            'body' => (string) ($row['body'] ?? ''),
        ];
    }

    public function deleteByToken(string $token): void
    {
        $this->ensureTable();
        $this->db->execute('DELETE FROM report_exports WHERE token = ?', [$token]);
    }

    private function ensureTable(): void
    {
        if (self::$tableEnsured) {
            return;
        }
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS report_exports (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                token VARCHAR(64) NOT NULL UNIQUE,
                content_type VARCHAR(100) NOT NULL,
                filename VARCHAR(255) NOT NULL,
                body MEDIUMTEXT NOT NULL,
                expires_at DATETIME NOT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_expires_at (expires_at)
            )'
        );
        self::$tableEnsured = true;
    }
}

