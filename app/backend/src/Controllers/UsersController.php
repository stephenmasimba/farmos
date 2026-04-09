<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Security, Validation};
use FarmOS\Models\User;
use FarmOS\Middleware\PermissionMiddleware;
use FarmOS\Services\AccessControlService;

class UsersController
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

    private function allowedRoles(): array
    {
        return [
            'super_admin',
            'admin',
            'manager',
            'finance_manager',
            'inventory_manager',
            'livestock_manager',
            'auditor',
            'worker',
            'field_worker',
            'user',
        ];
    }

    private function splitName(?string $name): array
    {
        $trimmed = trim((string) $name);
        if ($trimmed === '') {
            return ['', ''];
        }

        $parts = preg_split('/\s+/', $trimmed) ?: [];
        $firstName = array_shift($parts) ?: '';
        $lastName = trim(implode(' ', $parts));

        return [$firstName, $lastName];
    }

    private function currentUserId(): int
    {
        $claims = $this->request->getUser();
        return (int) ($claims['user_id'] ?? 0);
    }

    private function currentUserRole(): string
    {
        $claims = $this->request->getUser();
        return (string) ($claims['role'] ?? 'user');
    }

    private function isCurrentSuperAdmin(): bool
    {
        return $this->currentUserRole() === 'super_admin';
    }

    private function countSuperAdmins(): int
    {
        $row = $this->db->queryOne('SELECT COUNT(*) AS total FROM users WHERE role = ? AND status = ?', ['super_admin', 'active']);
        return (int) ($row['total'] ?? 0);
    }

    private function getUserRoleById(int $userId): ?string
    {
        $row = $this->db->queryOne('SELECT role FROM users WHERE id = ?', [$userId]);
        if (!$row) {
            return null;
        }
        return (string) ($row['role'] ?? 'user');
    }

    private function guardSuperAdminRoleChange(int $targetUserId, string $newRole): ?Response
    {
        $currentIsSuper = $this->isCurrentSuperAdmin();
        $targetCurrentRole = $this->getUserRoleById($targetUserId);
        if ($targetCurrentRole === null) {
            return Response::notFound('User not found');
        }

        if ($newRole === 'super_admin' && !$currentIsSuper) {
            return Response::forbidden('Only super administrators can assign super_admin role');
        }

        if ($targetCurrentRole === 'super_admin' && $newRole !== 'super_admin') {
            if (!$currentIsSuper) {
                return Response::forbidden('Only super administrators can modify a super_admin user');
            }

            if ($targetUserId === $this->currentUserId()) {
                return Response::forbidden('You cannot demote yourself from super_admin');
            }

            if ($this->countSuperAdmins() <= 1) {
                return Response::forbidden('Cannot remove the last active super_admin');
            }
        }

        return null;
    }

    public function index(): Response
    {
        try {
            $auth = $this->authorizePermission('users.view');
            if ($auth !== true) {
                return $auth;
            }

            $users = $this->db->query(
                'SELECT id, email, role, status, first_name, last_name, created_at, last_login
                 FROM users
                 ORDER BY created_at DESC'
            );

            $payload = array_map(static function (array $user): array {
                $fullName = trim(((string) ($user['first_name'] ?? '')) . ' ' . ((string) ($user['last_name'] ?? '')));
                return [
                    'id' => $user['id'],
                    'name' => $fullName !== '' ? $fullName : ($user['email'] ?? 'User'),
                    'email' => $user['email'] ?? '',
                    'role' => $user['role'] ?? 'user',
                    'status' => $user['status'] ?? 'active',
                    'created_at' => $user['created_at'] ?? null,
                    'last_login' => $user['last_login'] ?? null,
                ];
            }, $users);

            return Response::success($payload);
        } catch (\Exception $e) {
            Logger::error('Failed to list users', ['error' => $e->getMessage()]);
            return Response::error('Failed to list users', 'USERS_LIST_ERROR', 500);
        }
    }

    public function store(): Response
    {
        try {
            $auth = $this->authorizePermission('users.create');
            if ($auth !== true) {
                return $auth;
            }

            $input = $this->request->getBody();
            $email = trim((string) ($input['email'] ?? ''));
            $password = (string) ($input['password'] ?? '');
            $name = trim((string) ($input['name'] ?? ''));
            $role = trim((string) ($input['role'] ?? 'worker'));
            $status = trim((string) ($input['status'] ?? 'active'));

            $errors = [];
            if (!Validation::validateEmail($email)) {
                $errors['email'] = 'Invalid email format';
            }
            if ($name === '') {
                $errors['name'] = 'Name is required';
            }
            if (!Validation::validateEnum($role, $this->allowedRoles())) {
                $errors['role'] = 'Invalid role';
            }
            if ($role === 'super_admin' && !$this->isCurrentSuperAdmin()) {
                $errors['role'] = 'Only super administrators can create super_admin users';
            }
            if (!Validation::validateEnum($status, ['active', 'inactive', 'suspended'])) {
                $errors['status'] = 'Invalid status';
            }
            if ($password === '') {
                $errors['password'] = 'Password is required';
            }
            if (User::emailExists($email, $this->db)) {
                $errors['email'] = 'Email already registered';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            [$firstName, $lastName] = $this->splitName($name);
            $passwordHash = Security::hashPassword($password);

            $this->db->execute(
                'INSERT INTO users (email, password_hash, first_name, last_name, role, status)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [$email, $passwordHash, $firstName, $lastName, $role, $status]
            );

            $id = $this->db->lastInsertId();
            $access = new AccessControlService($this->db);
            $access->logAccessEvent('user.created', (int) $id, ['role' => $role, 'status' => $status], $this->currentUserId(), (int) ($this->request->getQuery('farm_id', 1) ?: 1));

            return Response::success([
                'id' => $id,
                'name' => trim($firstName . ' ' . $lastName),
                'email' => $email,
                'role' => $role,
                'status' => $status,
            ], 'User created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create user', ['error' => $e->getMessage()]);
            return Response::error($e->getMessage(), 'USER_CREATE_ERROR', 500);
        }
    }

    public function update(string $id): Response
    {
        try {
            $auth = $this->authorizePermission('users.update');
            if ($auth !== true) {
                return $auth;
            }

            $user = User::find($id, $this->db);
            if (!$user) {
                return Response::notFound('User not found');
            }

            $input = $this->request->getBody();
            $updates = [];
            $params = [];

            if (isset($input['name'])) {
                [$firstName, $lastName] = $this->splitName((string) $input['name']);
                $updates[] = 'first_name = ?';
                $updates[] = 'last_name = ?';
                $params[] = $firstName;
                $params[] = $lastName;
            }

            if (isset($input['email'])) {
                $email = trim((string) $input['email']);
                if (!Validation::validateEmail($email)) {
                    return Response::validationError(['email' => 'Invalid email format']);
                }
                $existing = User::findByEmail($email, $this->db);
                if ($existing && (string) $existing->id !== (string) $id) {
                    return Response::validationError(['email' => 'Email already registered']);
                }
                $updates[] = 'email = ?';
                $params[] = $email;
            }

            if (isset($input['role'])) {
                $role = trim((string) $input['role']);
                if (!Validation::validateEnum($role, $this->allowedRoles())) {
                    return Response::validationError(['role' => 'Invalid role']);
                }

                $superGuard = $this->guardSuperAdminRoleChange((int) $id, $role);
                if ($superGuard instanceof Response) {
                    return $superGuard;
                }

                $updates[] = 'role = ?';
                $params[] = $role;
            }

            if (isset($input['status'])) {
                $status = trim((string) $input['status']);
                if (!Validation::validateEnum($status, ['active', 'inactive', 'suspended'])) {
                    return Response::validationError(['status' => 'Invalid status']);
                }
                $updates[] = 'status = ?';
                $params[] = $status;
            }

            if (!empty($input['password'])) {
                $updates[] = 'password_hash = ?';
                $params[] = Security::hashPassword((string) $input['password']);
            }

            if (empty($updates)) {
                return Response::success(['id' => $id], 'No changes applied');
            }

            $updates[] = 'updated_at = NOW()';
            $params[] = $id;

            $this->db->execute(
                'UPDATE users SET ' . implode(', ', $updates) . ' WHERE id = ?',
                $params
            );

            $access = new AccessControlService($this->db);
            $access->logAccessEvent('user.updated', (int) $id, ['fields' => $updates], $this->currentUserId(), (int) ($this->request->getQuery('farm_id', 1) ?: 1));

            $updated = User::find($id, $this->db);
            $profile = $updated ? $updated->profile() : ['id' => $id];
            $profile['name'] = trim(((string) ($profile['first_name'] ?? '')) . ' ' . ((string) ($profile['last_name'] ?? '')));
            if ($profile['name'] === '') {
                $profile['name'] = $profile['email'] ?? 'User';
            }

            return Response::success($profile, 'User updated successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to update user', ['id' => $id, 'error' => $e->getMessage()]);
            return Response::error($e->getMessage(), 'USER_UPDATE_ERROR', 500);
        }
    }

    public function destroy(string $id): Response
    {
        try {
            $auth = $this->authorizePermission('users.delete');
            if ($auth !== true) {
                return $auth;
            }

            $currentUser = $this->request->getUser();
            if ($currentUser && (string) ($currentUser['user_id'] ?? '') === (string) $id) {
                return Response::forbidden('You cannot delete the current user');
            }

            $targetRole = $this->getUserRoleById((int) $id);
            if ($targetRole === 'super_admin') {
                if (!$this->isCurrentSuperAdmin()) {
                    return Response::forbidden('Only super administrators can delete super_admin users');
                }
                if ($this->countSuperAdmins() <= 1) {
                    return Response::forbidden('Cannot delete the last active super_admin');
                }
            }

            $deleted = User::destroy($id, $this->db);
            if (!$deleted) {
                return Response::notFound('User not found');
            }

            $access = new AccessControlService($this->db);
            $access->logAccessEvent('user.deleted', (int) $id, ['role' => $targetRole], $this->currentUserId(), (int) ($this->request->getQuery('farm_id', 1) ?: 1));

            return Response::success(['id' => $id], 'User deleted successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to delete user', ['id' => $id, 'error' => $e->getMessage()]);
            return Response::error('Failed to delete user', 'USER_DELETE_ERROR', 500);
        }
    }

    public function accessCatalog(): Response
    {
        try {
            $auth = $this->authorizePermission('users.permissions.manage');
            if ($auth !== true) {
                return $auth;
            }

            $access = new AccessControlService($this->db);
            return Response::success([
                'roles' => array_keys($access->getRoleTemplates()),
                'permissions' => $access->getPermissionCatalog(),
                'templates' => $access->getRoleTemplates(),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to load access catalog', ['error' => $e->getMessage()]);
            return Response::error('Failed to load access catalog', 'ACCESS_CATALOG_ERROR', 500);
        }
    }

    public function userAccessProfile(string $id): Response
    {
        try {
            $auth = $this->authorizePermission('users.permissions.manage');
            if ($auth !== true) {
                return $auth;
            }

            $userId = (int) $id;
            if ($userId <= 0) {
                return Response::validationError(['id' => 'Invalid user id']);
            }

            $farmId = (int) ($this->request->getQuery('farm_id', 1) ?: 1);
            $access = new AccessControlService($this->db);
            $profile = $access->getUserAccessProfile($userId, $farmId);

            if (empty($profile)) {
                return Response::notFound('User not found');
            }

            return Response::success($profile);
        } catch (\Exception $e) {
            Logger::error('Failed to load user access profile', ['id' => $id, 'error' => $e->getMessage()]);
            return Response::error('Failed to load access profile', 'ACCESS_PROFILE_ERROR', 500);
        }
    }

    public function assignRole(string $id): Response
    {
        try {
            $auth = $this->authorizePermission('users.permissions.manage');
            if ($auth !== true) {
                return $auth;
            }

            $userId = (int) $id;
            if ($userId <= 0) {
                return Response::validationError(['id' => 'Invalid user id']);
            }

            $input = $this->request->getBody();
            $role = trim((string) ($input['role'] ?? ''));
            if (!Validation::validateEnum($role, $this->allowedRoles())) {
                return Response::validationError(['role' => 'Invalid role']);
            }

            $superGuard = $this->guardSuperAdminRoleChange($userId, $role);
            if ($superGuard instanceof Response) {
                return $superGuard;
            }

            $access = new AccessControlService($this->db);
            $access->syncUserRole($userId, $role, $this->currentUserId(), (int) ($this->request->getQuery('farm_id', 1) ?: 1));

            return Response::success(['id' => $userId, 'role' => $role], 'Role updated');
        } catch (\Exception $e) {
            Logger::error('Failed to assign role', ['id' => $id, 'error' => $e->getMessage()]);
            return Response::error('Failed to assign role', 'ASSIGN_ROLE_ERROR', 500);
        }
    }

    public function replacePermissions(string $id): Response
    {
        try {
            $auth = $this->authorizePermission('users.permissions.manage');
            if ($auth !== true) {
                return $auth;
            }

            $userId = (int) $id;
            if ($userId <= 0) {
                return Response::validationError(['id' => 'Invalid user id']);
            }

            $input = $this->request->getBody();
            $permissions = $input['permissions'] ?? [];
            if (!is_array($permissions)) {
                return Response::validationError(['permissions' => 'Permissions must be an array']);
            }

            $farmId = isset($input['farm_id']) && is_numeric($input['farm_id']) ? (int) $input['farm_id'] : 0;
            $access = new AccessControlService($this->db);

            $targetRole = $this->getUserRoleById($userId);
            if ($targetRole === 'super_admin' && !$this->isCurrentSuperAdmin()) {
                return Response::forbidden('Only super administrators can modify super_admin permissions');
            }

            $access->replaceUserPermissions($userId, $permissions, $farmId, $this->currentUserId());

            return Response::success(['id' => $userId], 'Permissions replaced');
        } catch (\Exception $e) {
            Logger::error('Failed to replace user permissions', ['id' => $id, 'error' => $e->getMessage()]);
            return Response::error('Failed to replace permissions', 'REPLACE_PERMISSIONS_ERROR', 500);
        }
    }

    public function accessAudit(): Response
    {
        try {
            $auth = $this->authorizePermission('users.permissions.manage');
            if ($auth !== true) {
                return $auth;
            }

            $limit = (int) ($this->request->getQuery('limit', 100) ?: 100);
            $access = new AccessControlService($this->db);
            $rows = $access->listAuditEvents($limit);

            return Response::success(['events' => $rows]);
        } catch (\Exception $e) {
            Logger::error('Failed to load access audit', ['error' => $e->getMessage()]);
            return Response::error('Failed to load access audit', 'ACCESS_AUDIT_ERROR', 500);
        }
    }
}
