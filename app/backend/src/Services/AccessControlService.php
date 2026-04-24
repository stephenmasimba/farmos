<?php

namespace FarmOS\Services;

use FarmOS\Database;
use FarmOS\Logger;

class AccessControlService
{
    private Database $db;
    private static bool $tablesEnsured = false;
    private static bool $seeded = false;

    public function __construct(Database $db)
    {
        $this->db = $db;
        $this->boot();
    }

    private function boot(): void
    {
        if (!self::$tablesEnsured) {
            $this->ensureTables();
            self::$tablesEnsured = true;
        }

        if (!self::$seeded) {
            $this->seedRolesAndPermissions();
            self::$seeded = true;
        }
    }

    public function getPermissionCatalog(): array
    {
        return [
            'users.view',
            'users.create',
            'users.update',
            'users.delete',
            'users.permissions.manage',
            'settings.read',
            'settings.update',
            'reports.read',
            'reports.generate',
            'analytics.read',
            'tasks.read',
            'tasks.create',
            'tasks.update',
            'tasks.complete',
            'inventory.read',
            'inventory.create',
            'inventory.update',
            'inventory.adjust',
            'inventory.transfer',
            'financial.read',
            'financial.create',
            'financial.update',
            'accounting.read',
            'accounting.post',
            'livestock.read',
            'livestock.create',
            'livestock.update',
            'livestock.platform',
            'iot.read',
            'iot.manage',
            'compliance.read',
            'compliance.manage',
            'marketplace.read',
            'marketplace.manage',
            'admin.access',
        ];
    }

    public function getRoleTemplates(): array
    {
        return [
            'super_admin' => ['*'],
            'admin' => [
                'users.view', 'users.create', 'users.update', 'users.delete', 'users.permissions.manage',
                'settings.read', 'settings.update',
                'reports.read', 'reports.generate', 'analytics.read',
                'tasks.read', 'tasks.create', 'tasks.update', 'tasks.complete',
                'inventory.read', 'inventory.create', 'inventory.update', 'inventory.adjust', 'inventory.transfer',
                'financial.read', 'financial.create', 'financial.update', 'accounting.read', 'accounting.post',
                'livestock.read', 'livestock.create', 'livestock.update', 'livestock.platform',
                'iot.read', 'iot.manage',
                'compliance.read', 'compliance.manage',
                'marketplace.read', 'marketplace.manage',
                'admin.access',
            ],
            'manager' => [
                'users.view',
                'reports.read', 'reports.generate', 'analytics.read',
                'tasks.read', 'tasks.create', 'tasks.update', 'tasks.complete',
                'inventory.read', 'inventory.create', 'inventory.update', 'inventory.adjust', 'inventory.transfer',
                'financial.read', 'financial.create', 'financial.update', 'accounting.read',
                'livestock.read', 'livestock.create', 'livestock.update', 'livestock.platform',
                'iot.read',
                'compliance.read',
                'marketplace.read',
            ],
            'finance_manager' => [
                'financial.read', 'financial.create', 'financial.update',
                'accounting.read', 'accounting.post',
                'reports.read', 'reports.generate', 'analytics.read',
            ],
            'inventory_manager' => [
                'inventory.read', 'inventory.create', 'inventory.update', 'inventory.adjust', 'inventory.transfer',
                'reports.read', 'analytics.read',
            ],
            'livestock_manager' => [
                'livestock.read', 'livestock.create', 'livestock.update', 'livestock.platform',
                'reports.read', 'analytics.read',
            ],
            'auditor' => [
                'users.view', 'settings.read',
                'reports.read', 'analytics.read',
                'inventory.read', 'financial.read', 'accounting.read',
                'livestock.read', 'compliance.read',
            ],
            'field_worker' => [
                'tasks.read', 'tasks.complete',
                'inventory.read',
                'livestock.read',
                'iot.read',
            ],
            'worker' => [
                'tasks.read', 'tasks.complete',
                'inventory.read',
                'livestock.read',
            ],
            'user' => [
                'tasks.read',
                'inventory.read',
                'livestock.read',
            ],
        ];
    }

    public function getEffectivePermissions(int $userId, string $role, int $farmId = 1): array
    {
        $rolePermissions = $this->getRolePermissions($role);

        $overrides = $this->db->query(
            'SELECT permission, effect
             FROM user_permissions
             WHERE user_id = ? AND (farm_id IS NULL OR farm_id = ?)',
            [$userId, $farmId]
        );

        $allowed = array_fill_keys($rolePermissions, true);
        foreach ($overrides as $row) {
            $permission = (string) ($row['permission'] ?? '');
            $effect = (string) ($row['effect'] ?? 'allow');
            if ($permission === '') {
                continue;
            }

            if ($effect === 'deny') {
                unset($allowed[$permission]);
            } else {
                $allowed[$permission] = true;
            }
        }

        return array_values(array_keys($allowed));
    }

    public function userHasPermission(array $claims, string $permission, int $farmId = 1): bool
    {
        $userId = (int) ($claims['user_id'] ?? 0);
        $role = (string) ($claims['role'] ?? 'user');

        if ($userId <= 0 || $permission === '') {
            return false;
        }

        $effective = $this->getEffectivePermissions($userId, $role, $farmId);

        if (in_array('*', $effective, true)) {
            return true;
        }

        if (in_array($permission, $effective, true)) {
            return true;
        }

        $segments = explode('.', $permission);
        if (count($segments) === 2) {
            $wildcard = $segments[0] . '.*';
            if (in_array($wildcard, $effective, true)) {
                return true;
            }
        }

        return false;
    }

    public function syncUserRole(int $userId, string $role, ?int $actorUserId = null, ?int $farmId = null): void
    {
        $before = $this->db->queryOne('SELECT role FROM users WHERE id = ?', [$userId]);
        $this->db->execute('UPDATE users SET role = ?, updated_at = NOW() WHERE id = ?', [$role, $userId]);

        $this->logAccessEvent(
            'user.role.updated',
            $userId,
            [
                'before_role' => $before['role'] ?? null,
                'after_role' => $role,
            ],
            $actorUserId,
            $farmId
        );
    }

    public function replaceUserPermissions(int $userId, array $permissions, int $farmId = 0, ?int $actorUserId = null): void
    {
        $normalizedFarmId = $farmId > 0 ? $farmId : null;

        $this->db->beginTransaction();
        try {
            if ($normalizedFarmId === null) {
                $this->db->execute('DELETE FROM user_permissions WHERE user_id = ? AND farm_id IS NULL', [$userId]);
            } else {
                $this->db->execute('DELETE FROM user_permissions WHERE user_id = ? AND farm_id = ?', [$userId, $normalizedFarmId]);
            }

            foreach ($permissions as $permission) {
                if (!is_array($permission)) {
                    continue;
                }

                $name = trim((string) ($permission['permission'] ?? ''));
                $effect = strtolower(trim((string) ($permission['effect'] ?? 'allow')));

                if ($name === '' || !in_array($effect, ['allow', 'deny'], true)) {
                    continue;
                }

                $this->db->execute(
                    'INSERT INTO user_permissions (user_id, permission, effect, farm_id, created_at)
                     VALUES (?, ?, ?, ?, NOW())',
                    [$userId, $name, $effect, $normalizedFarmId]
                );
            }

            $this->db->commit();

            $this->logAccessEvent(
                'user.permissions.replaced',
                $userId,
                [
                    'farm_id' => $normalizedFarmId,
                    'permission_count' => count($permissions),
                ],
                $actorUserId,
                $normalizedFarmId
            );
        } catch (\Throwable $e) {
            $this->db->rollback();
            throw $e;
        }
    }

    public function listAuditEvents(int $limit = 100): array
    {
        $safeLimit = $limit > 0 ? min($limit, 500) : 100;
        return $this->db->query(
            'SELECT id, event_type, target_user_id, actor_user_id, farm_id, metadata_json, created_at
             FROM access_audit_log
             ORDER BY id DESC
             LIMIT ' . (int) $safeLimit
        );
    }

    public function getUserAccessProfile(int $userId, int $farmId = 1): array
    {
        $user = $this->db->queryOne('SELECT id, email, role, status FROM users WHERE id = ?', [$userId]);
        if (!$user) {
            return [];
        }

        $role = (string) ($user['role'] ?? 'user');
        $rolePermissions = $this->getRolePermissions($role);
        $effective = $this->getEffectivePermissions($userId, $role, $farmId);

        return [
            'user' => $user,
            'farm_id' => $farmId,
            'role_permissions' => $rolePermissions,
            'effective_permissions' => $effective,
            'catalog' => $this->getPermissionCatalog(),
        ];
    }

    private function getRolePermissions(string $role): array
    {
        $rows = $this->db->query(
            'SELECT permission
             FROM role_permissions
             WHERE role_name = ?
             ORDER BY permission ASC',
            [$role]
        );

        if (empty($rows)) {
            $templates = $this->getRoleTemplates();
            return $templates[$role] ?? $templates['user'];
        }

        $permissions = [];
        foreach ($rows as $row) {
            $permissions[] = (string) $row['permission'];
        }

        return array_values(array_unique($permissions));
    }

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS roles (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(80) NOT NULL UNIQUE,
                description VARCHAR(255) NULL,
                is_system TINYINT(1) NOT NULL DEFAULT 1,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
            )'
        );

        try {
            $this->db->execute('ALTER TABLE roles ADD COLUMN description VARCHAR(255) NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE roles ADD COLUMN is_system TINYINT(1) NOT NULL DEFAULT 1');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE roles ADD COLUMN created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP');
        } catch (\Throwable $e) {
        }

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS role_permissions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                role_name VARCHAR(80) NOT NULL,
                permission VARCHAR(120) NOT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_role_permission (role_name, permission),
                INDEX idx_role_permissions_role (role_name)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS user_permissions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                permission VARCHAR(120) NOT NULL,
                effect VARCHAR(10) NOT NULL DEFAULT "allow",
                farm_id INT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_permissions_user (user_id),
                INDEX idx_user_permissions_farm (farm_id),
                INDEX idx_user_permissions_effect (effect)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS access_audit_log (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                event_type VARCHAR(120) NOT NULL,
                target_user_id INT NULL,
                actor_user_id INT NULL,
                farm_id INT NULL,
                metadata_json TEXT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_access_audit_event (event_type),
                INDEX idx_access_audit_target (target_user_id),
                INDEX idx_access_audit_actor (actor_user_id),
                INDEX idx_access_audit_created (created_at)
            )'
        );
    }

    private function seedRolesAndPermissions(): void
    {
        $templates = $this->getRoleTemplates();

        foreach ($templates as $roleName => $permissions) {
            $this->db->execute(
                'INSERT IGNORE INTO roles (name, description, is_system) VALUES (?, ?, 1)',
                [$roleName, ucfirst(str_replace('_', ' ', $roleName)) . ' role']
            );

            foreach ($permissions as $permission) {
                $this->db->execute(
                    'INSERT IGNORE INTO role_permissions (role_name, permission) VALUES (?, ?)',
                    [$roleName, $permission]
                );
            }
        }

        Logger::info('Access control role templates initialized', ['roles' => array_keys($templates)]);
    }

    public function logAccessEvent(string $eventType, ?int $targetUserId, array $meta = [], ?int $actorUserId = null, ?int $farmId = null): void
    {
        try {
            $metaJson = !empty($meta) ? json_encode($meta) : null;
            $this->db->execute(
                'INSERT INTO access_audit_log (event_type, target_user_id, actor_user_id, farm_id, metadata_json, created_at)
                 VALUES (?, ?, ?, ?, ?, NOW())',
                [$eventType, $targetUserId, $actorUserId, $farmId, $metaJson]
            );
        } catch (\Throwable $e) {
            Logger::warning('Failed to log access audit event', [
                'event' => $eventType,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
