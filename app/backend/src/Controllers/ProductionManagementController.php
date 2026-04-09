<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger};
use FarmOS\Middleware\PermissionMiddleware;

class ProductionManagementController
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
            'CREATE TABLE IF NOT EXISTS fields (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NULL,
                name VARCHAR(100) NOT NULL,
                area_size DECIMAL(10,2) DEFAULT 0,
                current_crop VARCHAR(100) NULL,
                status VARCHAR(20) DEFAULT "fallow",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS crop_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                field_id INT NOT NULL,
                crop_name VARCHAR(100) NOT NULL,
                planting_date DATE NULL,
                harvest_date DATE NULL,
                yield_amount DECIMAL(10,2) NULL,
                yield_unit VARCHAR(20) NULL,
                notes TEXT NULL,
                recorded_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_crop_history_field (field_id),
                INDEX idx_crop_history_dates (planting_date, harvest_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS pest_disease_reports (
                id INT AUTO_INCREMENT PRIMARY KEY,
                field_id INT NULL,
                field_name VARCHAR(100) NOT NULL,
                crop_name VARCHAR(100) NOT NULL,
                pest_disease_type VARCHAR(150) NOT NULL,
                severity_level VARCHAR(20) NOT NULL DEFAULT "medium",
                affected_area_percentage INT NOT NULL DEFAULT 0,
                treatment_recommendation TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_pest_reports_created_at (created_at),
                INDEX idx_pest_reports_field (field_id)
            )'
        );
    }

    public function pestDisease(): Response
    {
        try {
            $auth = $this->authorizePermission('reports.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT field_name, crop_name, pest_disease_type, severity_level, affected_area_percentage, treatment_recommendation
                 FROM pest_disease_reports
                 ORDER BY created_at DESC, id DESC
                 LIMIT 20'
            );

            $reports = array_map(static function (array $row): array {
                $severity = strtolower((string) ($row['severity_level'] ?? 'medium'));
                return [
                    'field_name' => $row['field_name'] ?? 'Unknown Field',
                    'crop_name' => $row['crop_name'] ?? 'Unknown Crop',
                    'pest_disease_type' => $row['pest_disease_type'] ?? 'Pest / Disease',
                    'severity_level' => $severity,
                    'severity_display' => strtoupper($severity),
                    'affected_area_percentage' => (int) ($row['affected_area_percentage'] ?? 0),
                    'treatment_recommendation' => $row['treatment_recommendation'] ?? 'No recommendation available',
                ];
            }, $rows);

            return Response::success($reports);
        } catch (\Exception $e) {
            Logger::error('Failed to list pest and disease reports', ['error' => $e->getMessage()]);
            return Response::error('Failed to list pest and disease reports', 'PRODUCTION_PEST_ERROR', 500);
        }
    }

    public function cropRotation(): Response
    {
        try {
            $auth = $this->authorizePermission('reports.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $fields = $this->db->query(
                'SELECT id, name, area_size, current_crop
                 FROM fields
                 ORDER BY name ASC, id ASC'
            );

            $analysis = [];
            foreach ($fields as $field) {
                $history = $this->db->query(
                    'SELECT crop_name, planting_date
                     FROM crop_history
                     WHERE field_id = ?
                     ORDER BY planting_date DESC, id DESC
                     LIMIT 3',
                    [(int) $field['id']]
                );

                $recentCrops = [];
                $families = [];
                foreach ($history as $entry) {
                    $crop = (string) ($entry['crop_name'] ?? 'Crop');
                    $family = $this->inferCropFamily($crop);
                    $recentCrops[] = [
                        'crop' => $crop,
                        'family' => $family,
                    ];
                    $families[] = $family;
                }

                if (empty($recentCrops) && !empty($field['current_crop'])) {
                    $currentCrop = (string) $field['current_crop'];
                    $recentCrops[] = [
                        'crop' => $currentCrop,
                        'family' => $this->inferCropFamily($currentCrop),
                    ];
                    $families[] = $this->inferCropFamily($currentCrop);
                }

                $rotationCompliance = count(array_unique($families)) === count($families);
                $recommendation = $rotationCompliance
                    ? 'Maintain crop diversity and monitor soil health.'
                    : 'Avoid repeating the same crop family next cycle; switch to a contrasting crop family.';

                $analysis[] = [
                    'field_name' => $field['name'] ?? 'Field',
                    'area_hectares' => (float) ($field['area_size'] ?? 0),
                    'recent_crops' => $recentCrops,
                    'rotation_compliance' => $rotationCompliance,
                    'recommendation' => $recommendation,
                ];
            }

            return Response::success($analysis);
        } catch (\Exception $e) {
            Logger::error('Failed to analyze crop rotation', ['error' => $e->getMessage()]);
            return Response::error('Failed to analyze crop rotation', 'PRODUCTION_ROTATION_ERROR', 500);
        }
    }

    private function inferCropFamily(string $cropName): string
    {
        $crop = strtolower(trim($cropName));
        if ($crop === '') {
            return 'Unknown';
        }

        $families = [
            'Maize' => ['maize', 'corn', 'sorghum', 'millet'],
            'Legume' => ['soybean', 'beans', 'pea', 'groundnut', 'cowpea'],
            'Brassica' => ['cabbage', 'kale', 'broccoli', 'canola'],
            'Root' => ['potato', 'cassava', 'sweet potato', 'beet'],
            'Cucurbit' => ['pumpkin', 'cucumber', 'melon'],
            'Solanaceae' => ['tomato', 'pepper', 'eggplant'],
        ];

        foreach ($families as $family => $crops) {
            foreach ($crops as $candidate) {
                if (strpos($crop, $candidate) !== false) {
                    return $family;
                }
            }
        }

        return ucfirst($crop);
    }
}
