<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};

class ImportController
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
        $input = $this->request->getBody();
        if (!empty($input['farm_id'])) {
            return (int) $input['farm_id'];
        }

        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS imported_livestock_rows (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                row_data JSON NOT NULL,
                imported_by INT NULL,
                imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_import_livestock_farm (farm_id, imported_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS imported_inventory_rows (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                row_data JSON NOT NULL,
                imported_by INT NULL,
                imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_import_inventory_farm (farm_id, imported_at)
            )'
        );
    }

    public function templateCsv(string $type): string
    {
        $normalized = strtolower(trim($type));
        if ($normalized === 'livestock') {
            return "animal_tag,species,breed,sex,birth_date,status\n";
        }

        return "sku,name,category,unit,current_stock,reorder_level\n";
    }

    private function parseCsvRows(string $content): array
    {
        $lines = preg_split('/\r\n|\r|\n/', trim($content));
        if (!$lines || count($lines) < 2) {
            return [];
        }

        $headers = str_getcsv((string) array_shift($lines));
        $rows = [];
        foreach ($lines as $line) {
            $line = trim((string) $line);
            if ($line === '') {
                continue;
            }
            $values = str_getcsv($line);
            $row = [];
            foreach ($headers as $i => $key) {
                $cleanKey = trim((string) $key);
                if ($cleanKey === '') {
                    continue;
                }
                $row[$cleanKey] = $values[$i] ?? null;
            }
            if (!empty($row)) {
                $rows[] = $row;
            }
        }

        return $rows;
    }

    public function importRows(string $type): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $normalizedType = strtolower(trim($type));
            if (!in_array($normalizedType, ['livestock', 'inventory'], true)) {
                return Response::validationError(['type' => 'Unsupported import type']);
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = [];

            $input = $this->request->getBody();
            if (isset($input['rows']) && is_array($input['rows'])) {
                foreach ($input['rows'] as $row) {
                    if (is_array($row) && !empty($row)) {
                        $rows[] = $row;
                    }
                }
            } elseif (!empty($_FILES['file']['tmp_name']) && is_uploaded_file($_FILES['file']['tmp_name'])) {
                $content = (string) file_get_contents($_FILES['file']['tmp_name']);
                $rows = $this->parseCsvRows($content);
            }

            if (empty($rows)) {
                return Response::validationError(['file' => 'No import rows found']);
            }

            $table = $normalizedType === 'livestock' ? 'imported_livestock_rows' : 'imported_inventory_rows';
            $success = 0;
            $failed = 0;
            $errors = [];

            foreach ($rows as $idx => $row) {
                try {
                    $this->db->execute(
                        "INSERT INTO {$table} (farm_id, row_data, imported_by) VALUES (?, ?, ?)",
                        [$farmId, json_encode($row, JSON_UNESCAPED_UNICODE), $userId]
                    );
                    $success++;
                } catch (\Throwable $rowError) {
                    $failed++;
                    $errors[] = 'Row ' . ($idx + 1) . ': ' . $rowError->getMessage();
                }
            }

            return Response::success([
                'success' => $success,
                'failed' => $failed,
                'errors' => $errors,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to import data rows', ['error' => $e->getMessage()]);
            return Response::error('Failed to import data', 'DATA_IMPORT_ERROR', 500);
        }
    }
}
