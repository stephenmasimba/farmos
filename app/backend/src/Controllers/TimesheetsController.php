<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class TimesheetsController
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

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS timesheets (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                work_date DATE NOT NULL,
                hours_worked DECIMAL(5, 2) NOT NULL,
                task_description TEXT NULL,
                status VARCHAR(20) DEFAULT "pending",
                approved_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_timesheets_user_date (user_id, work_date),
                INDEX idx_timesheets_status (status)
            )'
        );
    }

    private function toDisplayStatus(?string $status): string
    {
        $normalized = strtolower((string) $status);
        if ($normalized === 'approved') {
            return 'Approved';
        }
        if ($normalized === 'rejected') {
            return 'Rejected';
        }

        return 'Pending';
    }

    private function toStorageStatus(string $status): ?string
    {
        $normalized = strtolower(trim($status));
        if (in_array($normalized, ['pending', 'approved', 'rejected'], true)) {
            return $normalized;
        }

        return null;
    }

    public function index(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTable();
            $rows = $this->db->query(
                'SELECT t.id, t.work_date, t.hours_worked, t.task_description, t.status,
                        u.first_name, u.last_name, u.email
                 FROM timesheets t
                 LEFT JOIN users u ON u.id = t.user_id
                 ORDER BY t.work_date DESC, t.id DESC'
            );

            $timesheets = array_map([$this, 'mapTimesheetRow'], $rows);
            return Response::success($timesheets);
        } catch (\Exception $e) {
            Logger::error('Failed to list timesheets', ['error' => $e->getMessage()]);
            return Response::error('Failed to list timesheets', 'TIMESHEETS_LIST_ERROR', 500);
        }
    }

    public function stats(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTable();
            $row = $this->db->query(
                'SELECT COALESCE(SUM(hours_worked), 0) AS total_hours,
                        SUM(CASE WHEN status = "pending" THEN 1 ELSE 0 END) AS pending_approvals
                 FROM timesheets'
            );
            $stats = $row[0] ?? ['total_hours' => 0, 'pending_approvals' => 0];

            return Response::success([
                'total_hours' => (float) ($stats['total_hours'] ?? 0),
                'pending_approvals' => (int) ($stats['pending_approvals'] ?? 0),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve timesheet stats', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve timesheet stats', 'TIMESHEETS_STATS_ERROR', 500);
        }
    }

    public function logHours(): Response
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

            $this->ensureTable();
            $input = $this->request->getBody();
            $date = (string) ($input['date'] ?? '');
            $hoursWorked = $input['hours_worked'] ?? null;
            $taskDescription = trim((string) ($input['task_description'] ?? ''));

            $errors = [];
            if (!Validation::validateDate($date, 'Y-m-d')) {
                $errors['date'] = 'Valid work date is required';
            }
            if (!is_numeric($hoursWorked) || (float) $hoursWorked <= 0) {
                $errors['hours_worked'] = 'Hours worked must be greater than zero';
            }
            if ($taskDescription === '') {
                $errors['task_description'] = 'Task description is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO timesheets (user_id, work_date, hours_worked, task_description, status)
                 VALUES (?, ?, ?, ?, ?)',
                [
                    $userId,
                    $date,
                    (float) $hoursWorked,
                    Validation::sanitizeString($taskDescription),
                    'pending',
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Timesheet logged successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to log hours', ['error' => $e->getMessage()]);
            return Response::error('Failed to log hours', 'TIMESHEET_CREATE_ERROR', 500);
        }
    }

    public function updateStatus(int $timesheetId): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.update');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $input = $this->request->getBody();
            $status = $this->toStorageStatus((string) ($input['status'] ?? ''));
            if ($status === null) {
                return Response::validationError(['status' => 'Invalid status']);
            }

            $existing = $this->db->query('SELECT id FROM timesheets WHERE id = ? LIMIT 1', [$timesheetId]);
            if (empty($existing)) {
                return Response::notFound('Timesheet not found');
            }

            $approvedBy = $status === 'pending' ? null : $userId;
            $this->db->execute(
                'UPDATE timesheets SET status = ?, approved_by = ? WHERE id = ?',
                [$status, $approvedBy, $timesheetId]
            );

            return Response::success(['id' => $timesheetId, 'status' => $this->toDisplayStatus($status)], 'Timesheet status updated');
        } catch (\Exception $e) {
            Logger::error('Failed to update timesheet status', ['id' => $timesheetId, 'error' => $e->getMessage()]);
            return Response::error('Failed to update timesheet', 'TIMESHEET_STATUS_ERROR', 500);
        }
    }

    private function mapTimesheetRow(array $row): array
    {
        $employeeName = trim(((string) ($row['first_name'] ?? '')) . ' ' . ((string) ($row['last_name'] ?? '')));
        if ($employeeName === '') {
            $employeeName = $row['email'] ?? 'Employee';
        }

        return [
            'id' => (int) $row['id'],
            'employee_name' => $employeeName,
            'date' => $row['work_date'] ?? '',
            'hours_worked' => (float) ($row['hours_worked'] ?? 0),
            'task_description' => $row['task_description'] ?? '',
            'status' => $this->toDisplayStatus($row['status'] ?? null),
        ];
    }
}
