<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class SystemController
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

    private function ensureSystemSettingsTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS system_settings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                setting_key VARCHAR(100) NOT NULL UNIQUE,
                setting_value TEXT NULL,
                setting_type VARCHAR(20) DEFAULT "string",
                category VARCHAR(50) DEFAULT "general",
                description TEXT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )'
        );

        $defaults = [
            ['app_name', 'FarmOS', 'string', 'general', 'Application name'],
            ['version', '1.0.0', 'string', 'general', 'Application version'],
            ['maintenance_mode', 'false', 'boolean', 'general', 'Maintenance mode flag'],
            ['backup_frequency', 'daily', 'string', 'backup', 'Backup schedule'],
        ];

        foreach ($defaults as $setting) {
            $this->db->execute(
                'INSERT IGNORE INTO system_settings (setting_key, setting_value, setting_type, category, description)
                 VALUES (?, ?, ?, ?, ?)',
                $setting
            );
        }
    }

    private function ensureTenantsTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS tenants (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                domain VARCHAR(255) NULL,
                subdomain VARCHAR(100) NULL,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )'
        );

        $this->db->execute(
            'INSERT IGNORE INTO tenants (id, name, domain, subdomain, is_active)
             VALUES (1, ?, ?, ?, TRUE)',
            ['Begin Masimba Farm', 'localhost', 'beginmasimba']
        );
    }

    public function getSettings(): Response
    {
        try {
            $auth = $this->authorizePermission('settings.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureSystemSettingsTable();
            $rows = $this->db->query('SELECT setting_key, setting_value FROM system_settings');

            $settings = [
                'app_name' => getenv('APP_NAME') ?: 'FarmOS',
                'version' => '1.0.0',
                'maintenance_mode' => false,
                'backup_frequency' => 'daily',
            ];

            foreach ($rows as $row) {
                $value = $row['setting_value'];
                if ($row['setting_key'] === 'maintenance_mode') {
                    $value = filter_var($value, FILTER_VALIDATE_BOOLEAN);
                }
                $settings[$row['setting_key']] = $value;
            }

            return Response::success($settings);
        } catch (\Exception $e) {
            Logger::error('Failed to get system settings', ['error' => $e->getMessage()]);
            return Response::error('Failed to get settings', 'SYSTEM_SETTINGS_ERROR', 500);
        }
    }

    public function updateSettings(): Response
    {
        try {
            $auth = $this->authorizePermission('settings.update');
            if ($auth !== true) {
                return $auth;
            }

            $input = $this->request->getBody();
            $this->ensureSystemSettingsTable();

            $appName = trim((string) ($input['app_name'] ?? ''));
            $version = trim((string) ($input['version'] ?? ''));
            $backupFrequency = trim((string) ($input['backup_frequency'] ?? 'daily'));
            $maintenanceMode = !empty($input['maintenance_mode']) ? 'true' : 'false';

            $errors = [];
            if ($appName === '') {
                $errors['app_name'] = 'App name is required';
            }
            if ($version === '') {
                $errors['version'] = 'Version is required';
            }
            if (!Validation::validateEnum($backupFrequency, ['daily', 'weekly', 'monthly'])) {
                $errors['backup_frequency'] = 'Invalid backup frequency';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $updates = [
                'app_name' => $appName,
                'version' => $version,
                'maintenance_mode' => $maintenanceMode,
                'backup_frequency' => $backupFrequency,
            ];

            foreach ($updates as $key => $value) {
                $this->db->execute(
                    'INSERT INTO system_settings (setting_key, setting_value)
                     VALUES (?, ?)
                     ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)',
                    [$key, $value]
                );
            }

            return Response::success([
                'app_name' => $appName,
                'version' => $version,
                'maintenance_mode' => $maintenanceMode === 'true',
                'backup_frequency' => $backupFrequency,
            ], 'Settings updated successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to update system settings', ['error' => $e->getMessage()]);
            return Response::error('Failed to update settings', 'SYSTEM_SETTINGS_UPDATE_ERROR', 500);
        }
    }

    public function listTenants(): Response
    {
        try {
            $auth = $this->authorizePermission('settings.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTenantsTable();
            $rows = $this->db->query(
                'SELECT id, name, domain, is_active FROM tenants ORDER BY id ASC'
            );

            $tenants = array_map(static function (array $tenant): array {
                return [
                    'id' => $tenant['id'],
                    'name' => $tenant['name'] ?? '',
                    'domain' => $tenant['domain'] ?? '',
                    'status' => !empty($tenant['is_active']) ? 'active' : 'inactive',
                ];
            }, $rows);

            return Response::success($tenants);
        } catch (\Exception $e) {
            Logger::error('Failed to list tenants', ['error' => $e->getMessage()]);
            return Response::error('Failed to list tenants', 'TENANTS_LIST_ERROR', 500);
        }
    }
}
