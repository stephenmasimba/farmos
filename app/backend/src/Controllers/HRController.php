<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class HRController
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
            'CREATE TABLE IF NOT EXISTS hr_sops (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                role VARCHAR(100) NOT NULL,
                content TEXT NOT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_hr_sops_created_at (created_at)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_tasks (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                assigned_to INT NULL,
                due_date DATE NOT NULL,
                status VARCHAR(20) DEFAULT "pending",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_hr_tasks_due_date (due_date),
                INDEX idx_hr_tasks_status (status)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_schedules (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                role VARCHAR(100) NOT NULL,
                start_time DATETIME NOT NULL,
                end_time DATETIME NOT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_hr_schedules_user (user_id),
                INDEX idx_hr_schedules_start (start_time)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_sop_executions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                sop_id INT NOT NULL,
                status VARCHAR(20) NOT NULL,
                notes TEXT NULL,
                executed_by INT NULL,
                executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_hr_sop_exec_sop (sop_id),
                INDEX idx_hr_sop_exec_time (executed_at)
            )'
        );
    }

    public function listSops(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT id, title, role, content, created_at
                 FROM hr_sops
                 ORDER BY created_at DESC, id DESC'
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list HR SOPs', ['error' => $e->getMessage()]);
            return Response::error('Failed to list SOPs', 'HR_SOPS_LIST_ERROR', 500);
        }
    }

    public function createSop(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.create');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $title = trim((string) ($input['title'] ?? ''));
            $role = trim((string) ($input['role'] ?? ''));
            $content = trim((string) ($input['content'] ?? ''));

            $errors = [];
            if ($title === '') {
                $errors['title'] = 'Title is required';
            }
            if ($role === '') {
                $errors['role'] = 'Role is required';
            }
            if ($content === '') {
                $errors['content'] = 'Content is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO hr_sops (title, role, content, created_by) VALUES (?, ?, ?, ?)',
                [
                    Validation::sanitizeString($title),
                    Validation::sanitizeString($role),
                    Validation::sanitizeString($content),
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'SOP created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create HR SOP', ['error' => $e->getMessage()]);
            return Response::error('Failed to create SOP', 'HR_SOP_CREATE_ERROR', 500);
        }
    }

    public function listTasks(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT id, title, assigned_to, due_date, status
                 FROM hr_tasks
                 ORDER BY due_date ASC, id DESC'
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list HR tasks', ['error' => $e->getMessage()]);
            return Response::error('Failed to list tasks', 'HR_TASKS_LIST_ERROR', 500);
        }
    }

    public function createTask(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.create');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $title = trim((string) ($input['title'] ?? ''));
            $dueDate = (string) ($input['due_date'] ?? '');
            $assignedTo = isset($input['assigned_to']) && is_numeric($input['assigned_to']) ? (int) $input['assigned_to'] : null;

            $errors = [];
            if ($title === '') {
                $errors['title'] = 'Title is required';
            }
            if (!Validation::validateDate($dueDate, 'Y-m-d')) {
                $errors['due_date'] = 'Valid due date is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO hr_tasks (title, assigned_to, due_date, status, created_by) VALUES (?, ?, ?, ?, ?)',
                [
                    Validation::sanitizeString($title),
                    $assignedTo,
                    $dueDate,
                    'pending',
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Task created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create HR task', ['error' => $e->getMessage()]);
            return Response::error('Failed to create task', 'HR_TASK_CREATE_ERROR', 500);
        }
    }

    public function listSchedules(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT id, user_id, role, start_time, end_time
                 FROM hr_schedules
                 ORDER BY start_time DESC, id DESC'
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list HR schedules', ['error' => $e->getMessage()]);
            return Response::error('Failed to list schedules', 'HR_SCHEDULES_LIST_ERROR', 500);
        }
    }

    public function createSchedule(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.create');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $scheduledUserId = isset($input['user_id']) && is_numeric($input['user_id']) ? (int) $input['user_id'] : 0;
            $role = trim((string) ($input['role'] ?? ''));
            $startTime = (string) ($input['start_time'] ?? '');
            $endTime = (string) ($input['end_time'] ?? '');

            $errors = [];
            if ($scheduledUserId <= 0) {
                $errors['user_id'] = 'Valid user ID is required';
            }
            if ($role === '') {
                $errors['role'] = 'Role is required';
            }
            if ($startTime === '') {
                $errors['start_time'] = 'Start time is required';
            }
            if ($endTime === '') {
                $errors['end_time'] = 'End time is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO hr_schedules (user_id, role, start_time, end_time, created_by) VALUES (?, ?, ?, ?, ?)',
                [
                    $scheduledUserId,
                    Validation::sanitizeString($role),
                    str_replace('T', ' ', $startTime),
                    str_replace('T', ' ', $endTime),
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Schedule created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create HR schedule', ['error' => $e->getMessage()]);
            return Response::error('Failed to create schedule', 'HR_SCHEDULE_CREATE_ERROR', 500);
        }
    }

    public function listExecutions(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $rows = $this->db->query(
                'SELECT sop_id, status, executed_at, notes
                 FROM hr_sop_executions
                 ORDER BY executed_at DESC, id DESC
                 LIMIT 25'
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list SOP executions', ['error' => $e->getMessage()]);
            return Response::error('Failed to list SOP executions', 'HR_EXECUTIONS_LIST_ERROR', 500);
        }
    }

    public function runSop(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.complete');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $input = $this->request->getBody();
            $sopId = isset($input['sop_id']) && is_numeric($input['sop_id']) ? (int) $input['sop_id'] : 0;
            $status = strtolower(trim((string) ($input['status'] ?? '')));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($sopId <= 0) {
                $errors['sop_id'] = 'Valid SOP ID is required';
            }
            if (!in_array($status, ['completed', 'failed'], true)) {
                $errors['status'] = 'Status must be completed or failed';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $existing = $this->db->query('SELECT id FROM hr_sops WHERE id = ? LIMIT 1', [$sopId]);
            if (empty($existing)) {
                return Response::notFound('SOP not found');
            }

            $this->db->execute(
                'INSERT INTO hr_sop_executions (sop_id, status, notes, executed_by) VALUES (?, ?, ?, ?)',
                [$sopId, $status, Validation::sanitizeString($notes), $userId]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'SOP execution recorded successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to record SOP execution', ['error' => $e->getMessage()]);
            return Response::error('Failed to record SOP execution', 'HR_EXECUTION_CREATE_ERROR', 500);
        }
    }
}
