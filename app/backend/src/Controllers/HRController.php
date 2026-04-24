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

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_payroll_entries (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                employee_id INT NOT NULL,
                period_start DATE NOT NULL,
                period_end DATE NOT NULL,
                pay_date DATE NOT NULL,
                gross_amount DECIMAL(12,2) NOT NULL,
                net_amount DECIMAL(12,2) NOT NULL,
                status ENUM("scheduled", "processed", "paid") NOT NULL DEFAULT "scheduled",
                notes TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_hr_payroll_farm (farm_id),
                INDEX idx_hr_payroll_employee (employee_id),
                INDEX idx_hr_payroll_status (status)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_benefits (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(255) NOT NULL,
                benefit_type VARCHAR(100) NOT NULL,
                coverage TEXT NULL,
                active TINYINT(1) NOT NULL DEFAULT 1,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_hr_benefits_farm (farm_id),
                INDEX idx_hr_benefits_active (active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_certifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                employee_id INT NULL,
                title VARCHAR(255) NOT NULL,
                awarded_on DATE NOT NULL,
                expiry_date DATE NULL,
                status VARCHAR(20) NOT NULL DEFAULT "active",
                notes TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_hr_certifications_farm (farm_id),
                INDEX idx_hr_certifications_status (status)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_contractors (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(255) NOT NULL,
                service_area VARCHAR(100) NOT NULL,
                hourly_rate DECIMAL(10,2) NOT NULL,
                active TINYINT(1) NOT NULL DEFAULT 1,
                notes TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_hr_contractors_farm (farm_id),
                INDEX idx_hr_contractors_active (active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_attendance (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                user_id INT NOT NULL,
                schedule_id INT NULL,
                clock_in DATETIME NOT NULL,
                clock_out DATETIME NULL,
                source VARCHAR(30) NOT NULL DEFAULT "manual",
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_hr_attendance_farm_date (farm_id, clock_in),
                INDEX idx_hr_attendance_user (user_id, clock_in)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_employee_compensation (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                employee_id INT NOT NULL,
                pay_type ENUM("hourly","salary") NOT NULL DEFAULT "hourly",
                hourly_rate DECIMAL(12,2) NOT NULL DEFAULT 0,
                salary_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
                currency VARCHAR(10) NOT NULL DEFAULT "USD",
                effective_from DATE NOT NULL,
                active TINYINT(1) NOT NULL DEFAULT 1,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_hr_comp (farm_id, employee_id, effective_from),
                INDEX idx_hr_comp_farm_emp (farm_id, employee_id, active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_benefit_enrollments (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                benefit_id INT NOT NULL,
                employee_id INT NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NULL,
                employee_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
                employer_contribution DECIMAL(12,2) NOT NULL DEFAULT 0,
                status VARCHAR(20) NOT NULL DEFAULT "active",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_hr_ben_enroll_farm (farm_id, employee_id, status)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_payroll_runs (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                period_start DATE NOT NULL,
                period_end DATE NOT NULL,
                pay_date DATE NOT NULL,
                status ENUM("draft","processed","paid") NOT NULL DEFAULT "processed",
                tax_rate DECIMAL(6,4) NOT NULL DEFAULT 0,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_hr_payroll_runs_farm (farm_id, period_start, period_end)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_contractor_logs (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                contractor_id INT NOT NULL,
                work_date DATE NOT NULL,
                hours DECIMAL(10,2) NOT NULL,
                hourly_rate DECIMAL(10,2) NOT NULL,
                description VARCHAR(255) NULL,
                status VARCHAR(20) NOT NULL DEFAULT "unbilled",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_hr_contractor_logs_farm (farm_id, work_date),
                INDEX idx_hr_contractor_logs_contractor (contractor_id, work_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_training_courses (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                title VARCHAR(255) NOT NULL,
                description TEXT NULL,
                competency_area VARCHAR(120) NULL,
                recurrence_days INT NOT NULL DEFAULT 0,
                active TINYINT(1) NOT NULL DEFAULT 1,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_hr_courses_farm (farm_id, active)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS hr_training_records (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                course_id INT NOT NULL,
                employee_id INT NOT NULL,
                completed_on DATE NOT NULL,
                expiry_date DATE NULL,
                status VARCHAR(20) NOT NULL DEFAULT "valid",
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_hr_training_farm_emp (farm_id, employee_id, status),
                INDEX idx_hr_training_expiry (farm_id, expiry_date)
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

    public function listPayroll(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $rows = $this->db->query(
                'SELECT id, farm_id, employee_id, period_start, period_end, pay_date, gross_amount, net_amount, status, notes, created_at
                 FROM hr_payroll_entries
                 WHERE farm_id = ?
                 ORDER BY pay_date DESC, id DESC',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list payroll entries', ['error' => $e->getMessage()]);
            return Response::error('Failed to list payroll entries', 'HR_PAYROLL_LIST_ERROR', 500);
        }
    }

    public function createPayroll(): Response
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
            $farmId = isset($input['farm_id']) ? (int) $input['farm_id'] : 0;
            $employeeId = isset($input['employee_id']) ? (int) $input['employee_id'] : 0;
            $periodStart = (string) ($input['period_start'] ?? '');
            $periodEnd = (string) ($input['period_end'] ?? '');
            $payDate = (string) ($input['pay_date'] ?? '');
            $grossAmount = isset($input['gross_amount']) ? (float) $input['gross_amount'] : null;
            $netAmount = isset($input['net_amount']) ? (float) $input['net_amount'] : null;
            $status = strtolower(trim((string) ($input['status'] ?? 'scheduled')));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($farmId <= 0) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if ($employeeId <= 0) {
                $errors['employee_id'] = 'Employee ID is required';
            }
            if (!Validation::validateDate($periodStart, 'Y-m-d')) {
                $errors['period_start'] = 'Valid period start date is required';
            }
            if (!Validation::validateDate($periodEnd, 'Y-m-d')) {
                $errors['period_end'] = 'Valid period end date is required';
            }
            if (!Validation::validateDate($payDate, 'Y-m-d')) {
                $errors['pay_date'] = 'Valid pay date is required';
            }
            if ($grossAmount === null || $grossAmount < 0) {
                $errors['gross_amount'] = 'Gross amount must be a positive number';
            }
            if ($netAmount === null || $netAmount < 0) {
                $errors['net_amount'] = 'Net amount must be a positive number';
            }
            if (!in_array($status, ['scheduled', 'processed', 'paid'], true)) {
                $errors['status'] = 'Status must be scheduled, processed, or paid';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO hr_payroll_entries (farm_id, employee_id, period_start, period_end, pay_date, gross_amount, net_amount, status, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $employeeId,
                    $periodStart,
                    $periodEnd,
                    $payDate,
                    round($grossAmount, 2),
                    round($netAmount, 2),
                    $status,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Payroll entry created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create payroll entry', ['error' => $e->getMessage()]);
            return Response::error('Failed to create payroll entry', 'HR_PAYROLL_CREATE_ERROR', 500);
        }
    }

    public function listBenefits(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $rows = $this->db->query(
                'SELECT id, farm_id, name, benefit_type, coverage, active, created_at
                 FROM hr_benefits
                 WHERE farm_id = ?
                 ORDER BY active DESC, name ASC',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list benefits', ['error' => $e->getMessage()]);
            return Response::error('Failed to list benefits', 'HR_BENEFITS_LIST_ERROR', 500);
        }
    }

    public function createBenefit(): Response
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
            $farmId = isset($input['farm_id']) ? (int) $input['farm_id'] : 0;
            $name = trim((string) ($input['name'] ?? ''));
            $benefitType = trim((string) ($input['benefit_type'] ?? ''));
            $coverage = trim((string) ($input['coverage'] ?? ''));
            $active = isset($input['active']) && ((int) $input['active'] === 1);

            $errors = [];
            if ($farmId <= 0) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if ($name === '') {
                $errors['name'] = 'Benefit name is required';
            }
            if ($benefitType === '') {
                $errors['benefit_type'] = 'Benefit type is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO hr_benefits (farm_id, name, benefit_type, coverage, active, created_by)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($name),
                    Validation::sanitizeString($benefitType),
                    $coverage !== '' ? Validation::sanitizeString($coverage) : null,
                    $active ? 1 : 0,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Benefit created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create benefit', ['error' => $e->getMessage()]);
            return Response::error('Failed to create benefit', 'HR_BENEFIT_CREATE_ERROR', 500);
        }
    }

    public function listCertifications(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $rows = $this->db->query(
                'SELECT id, farm_id, employee_id, title, awarded_on, expiry_date, status, notes, created_at
                 FROM hr_certifications
                 WHERE farm_id = ?
                 ORDER BY awarded_on DESC, id DESC',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list certifications', ['error' => $e->getMessage()]);
            return Response::error('Failed to list certifications', 'HR_CERTIFICATIONS_LIST_ERROR', 500);
        }
    }

    public function createCertification(): Response
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
            $farmId = isset($input['farm_id']) ? (int) $input['farm_id'] : 0;
            $employeeId = isset($input['employee_id']) ? (int) $input['employee_id'] : null;
            $title = trim((string) ($input['title'] ?? ''));
            $awardedOn = (string) ($input['awarded_on'] ?? '');
            $expiryDate = (string) ($input['expiry_date'] ?? '');
            $status = strtolower(trim((string) ($input['status'] ?? 'active')));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($farmId <= 0) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if ($title === '') {
                $errors['title'] = 'Certification title is required';
            }
            if (!Validation::validateDate($awardedOn, 'Y-m-d')) {
                $errors['awarded_on'] = 'Valid awarded on date is required';
            }
            if ($expiryDate !== '' && !Validation::validateDate($expiryDate, 'Y-m-d')) {
                $errors['expiry_date'] = 'Expiry date must be a valid date';
            }
            if (!in_array($status, ['active', 'expired', 'pending'], true)) {
                $errors['status'] = 'Status must be active, expired, or pending';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO hr_certifications (farm_id, employee_id, title, awarded_on, expiry_date, status, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $employeeId,
                    Validation::sanitizeString($title),
                    $awardedOn,
                    $expiryDate !== '' ? $expiryDate : null,
                    $status,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Certification created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create certification', ['error' => $e->getMessage()]);
            return Response::error('Failed to create certification', 'HR_CERTIFICATION_CREATE_ERROR', 500);
        }
    }

    public function listContractors(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $rows = $this->db->query(
                'SELECT id, farm_id, name, service_area, hourly_rate, active, notes, created_at
                 FROM hr_contractors
                 WHERE farm_id = ?
                 ORDER BY active DESC, name ASC',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list contractors', ['error' => $e->getMessage()]);
            return Response::error('Failed to list contractors', 'HR_CONTRACTORS_LIST_ERROR', 500);
        }
    }

    public function createContractor(): Response
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
            $farmId = isset($input['farm_id']) ? (int) $input['farm_id'] : 0;
            $name = trim((string) ($input['name'] ?? ''));
            $serviceArea = trim((string) ($input['service_area'] ?? ''));
            $hourlyRate = isset($input['hourly_rate']) ? (float) $input['hourly_rate'] : null;
            $active = isset($input['active']) && ((int) $input['active'] === 1);
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($farmId <= 0) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if ($name === '') {
                $errors['name'] = 'Contractor name is required';
            }
            if ($serviceArea === '') {
                $errors['service_area'] = 'Service area is required';
            }
            if ($hourlyRate === null || $hourlyRate < 0) {
                $errors['hourly_rate'] = 'Hourly rate must be a positive number';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO hr_contractors (farm_id, name, service_area, hourly_rate, active, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($name),
                    Validation::sanitizeString($serviceArea),
                    round($hourlyRate, 2),
                    $active ? 1 : 0,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Contractor created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create contractor', ['error' => $e->getMessage()]);
            return Response::error('Failed to create contractor', 'HR_CONTRACTOR_CREATE_ERROR', 500);
        }
    }

    public function listAttendance(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $q = $this->request->getQuery();
            $userId = isset($q['user_id']) && is_numeric($q['user_id']) ? (int) $q['user_id'] : 0;
            $from = trim((string) ($q['from'] ?? ''));
            $to = trim((string) ($q['to'] ?? ''));
            $where = 'farm_id = ?';
            $params = [$farmId];
            if ($userId > 0) {
                $where .= ' AND user_id = ?';
                $params[] = $userId;
            }
            if ($from !== '' && Validation::validateDate($from, 'Y-m-d')) {
                $where .= ' AND clock_in >= ?';
                $params[] = $from . ' 00:00:00';
            }
            if ($to !== '' && Validation::validateDate($to, 'Y-m-d')) {
                $where .= ' AND clock_in <= ?';
                $params[] = $to . ' 23:59:59';
            }
            $rows = $this->db->query(
                'SELECT id, user_id, schedule_id, clock_in, clock_out, source, notes, created_at
                 FROM hr_attendance
                 WHERE ' . $where . '
                 ORDER BY clock_in DESC, id DESC
                 LIMIT 2000',
                $params
            );
            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list attendance', ['error' => $e->getMessage()]);
            return Response::error('Failed to list attendance', 'HR_ATTENDANCE_LIST_ERROR', 500);
        }
    }

    public function clockIn(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.create');
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $userId = (int) ($input['user_id'] ?? $actorId);
            $scheduleId = isset($input['schedule_id']) && is_numeric($input['schedule_id']) ? (int) $input['schedule_id'] : null;
            $clockIn = trim((string) ($input['clock_in'] ?? date('Y-m-d H:i:s')));
            $source = trim((string) ($input['source'] ?? 'manual'));
            $notes = trim((string) ($input['notes'] ?? ''));
            if ($farmId <= 0) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            if ($userId <= 0) {
                return Response::validationError(['user_id' => 'user_id is required']);
            }
            if (!Validation::validateDate($clockIn, 'Y-m-d H:i:s')) {
                return Response::validationError(['clock_in' => 'Invalid clock_in']);
            }
            $open = $this->db->queryOne(
                'SELECT id FROM hr_attendance WHERE farm_id = ? AND user_id = ? AND clock_out IS NULL ORDER BY clock_in DESC LIMIT 1',
                [$farmId, $userId]
            );
            if ($open) {
                return Response::validationError(['attendance' => 'User already clocked in']);
            }
            $this->db->execute(
                'INSERT INTO hr_attendance (farm_id, user_id, schedule_id, clock_in, source, notes, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $userId,
                    $scheduleId,
                    $clockIn,
                    Validation::sanitizeString($source),
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $actorId,
                    date('Y-m-d H:i:s'),
                ]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Clock-in recorded', 201);
        } catch (\Exception $e) {
            Logger::error('Failed clock in', ['error' => $e->getMessage()]);
            return Response::error('Failed clock in', 'HR_CLOCK_IN_ERROR', 500);
        }
    }

    public function clockOut(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.create');
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $userId = (int) ($input['user_id'] ?? $actorId);
            $clockOut = trim((string) ($input['clock_out'] ?? date('Y-m-d H:i:s')));
            if ($farmId <= 0) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            if ($userId <= 0) {
                return Response::validationError(['user_id' => 'user_id is required']);
            }
            if (!Validation::validateDate($clockOut, 'Y-m-d H:i:s')) {
                return Response::validationError(['clock_out' => 'Invalid clock_out']);
            }
            $open = $this->db->queryOne(
                'SELECT id, clock_in FROM hr_attendance WHERE farm_id = ? AND user_id = ? AND clock_out IS NULL ORDER BY clock_in DESC LIMIT 1',
                [$farmId, $userId]
            );
            if (!$open) {
                return Response::validationError(['attendance' => 'No open clock-in found']);
            }
            $this->db->execute('UPDATE hr_attendance SET clock_out = ?, updated_at = ? WHERE id = ?', [$clockOut, date('Y-m-d H:i:s'), (int) $open['id']]);
            return Response::success(['id' => (int) $open['id']], 'Clock-out recorded');
        } catch (\Exception $e) {
            Logger::error('Failed clock out', ['error' => $e->getMessage()]);
            return Response::error('Failed clock out', 'HR_CLOCK_OUT_ERROR', 500);
        }
    }

    public function compensation(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'tasks.read' : 'tasks.create';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            if ($this->request->getMethod() === 'GET') {
                $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
                if (!$farmId) {
                    return Response::validationError(['farm_id' => 'Farm ID is required']);
                }
                $rows = $this->db->query(
                    'SELECT id, employee_id, pay_type, hourly_rate, salary_amount, currency, effective_from, active
                     FROM hr_employee_compensation
                     WHERE farm_id = ?
                     ORDER BY employee_id ASC, effective_from DESC',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $employeeId = (int) ($input['employee_id'] ?? 0);
            $payType = strtolower(trim((string) ($input['pay_type'] ?? 'hourly')));
            $hourlyRate = isset($input['hourly_rate']) && is_numeric($input['hourly_rate']) ? (float) $input['hourly_rate'] : 0.0;
            $salaryAmount = isset($input['salary_amount']) && is_numeric($input['salary_amount']) ? (float) $input['salary_amount'] : 0.0;
            $currency = strtoupper(trim((string) ($input['currency'] ?? 'USD')));
            $effectiveFrom = trim((string) ($input['effective_from'] ?? date('Y-m-d')));
            $active = isset($input['active']) ? ((int) $input['active'] === 1) : true;
            $errors = [];
            if ($farmId <= 0) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if ($employeeId <= 0) {
                $errors['employee_id'] = 'Employee ID is required';
            }
            if (!in_array($payType, ['hourly', 'salary'], true)) {
                $errors['pay_type'] = 'pay_type must be hourly or salary';
            }
            if (!Validation::validateDate($effectiveFrom, 'Y-m-d')) {
                $errors['effective_from'] = 'effective_from is invalid';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }
            $this->db->execute(
                'INSERT INTO hr_employee_compensation (farm_id, employee_id, pay_type, hourly_rate, salary_amount, currency, effective_from, active, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $employeeId,
                    $payType,
                    round($hourlyRate, 2),
                    round($salaryAmount, 2),
                    Validation::sanitizeString($currency),
                    $effectiveFrom,
                    $active ? 1 : 0,
                    $actorId,
                ]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Compensation saved', 201);
        } catch (\Exception $e) {
            Logger::error('Failed compensation', ['error' => $e->getMessage()]);
            return Response::error('Failed compensation', 'HR_COMP_ERROR', 500);
        }
    }

    public function enrollBenefit(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.create');
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $benefitId = (int) ($input['benefit_id'] ?? 0);
            $employeeId = (int) ($input['employee_id'] ?? 0);
            $startDate = trim((string) ($input['start_date'] ?? date('Y-m-d')));
            $endDate = trim((string) ($input['end_date'] ?? ''));
            $employeeDeduction = isset($input['employee_deduction']) && is_numeric($input['employee_deduction']) ? (float) $input['employee_deduction'] : 0.0;
            $employerContribution = isset($input['employer_contribution']) && is_numeric($input['employer_contribution']) ? (float) $input['employer_contribution'] : 0.0;
            if ($farmId <= 0 || $benefitId <= 0 || $employeeId <= 0) {
                return Response::validationError(['enrollment' => 'farm_id, benefit_id, employee_id are required']);
            }
            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'Invalid start_date']);
            }
            if ($endDate !== '' && !Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'Invalid end_date']);
            }
            $this->db->execute(
                'INSERT INTO hr_benefit_enrollments (farm_id, benefit_id, employee_id, start_date, end_date, employee_deduction, employer_contribution, status, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, "active", ?, ?)',
                [$farmId, $benefitId, $employeeId, $startDate, $endDate !== '' ? $endDate : null, round($employeeDeduction, 2), round($employerContribution, 2), $actorId, date('Y-m-d H:i:s')]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Benefit enrollment created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to enroll benefit', ['error' => $e->getMessage()]);
            return Response::error('Failed to enroll benefit', 'HR_BEN_ENROLL_ERROR', 500);
        }
    }

    public function listBenefitEnrollments(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            $rows = $this->db->query(
                'SELECT id, benefit_id, employee_id, start_date, end_date, employee_deduction, employer_contribution, status
                 FROM hr_benefit_enrollments
                 WHERE farm_id = ?
                 ORDER BY created_at DESC, id DESC',
                [$farmId]
            );
            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list benefit enrollments', ['error' => $e->getMessage()]);
            return Response::error('Failed to list benefit enrollments', 'HR_BEN_ENROLL_LIST_ERROR', 500);
        }
    }

    public function runPayroll(): Response
    {
        try {
            $auth = $this->authorizePermission('tasks.create');
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $periodStart = trim((string) ($input['period_start'] ?? ''));
            $periodEnd = trim((string) ($input['period_end'] ?? ''));
            $payDate = trim((string) ($input['pay_date'] ?? $periodEnd));
            $taxRate = isset($input['tax_rate']) && is_numeric($input['tax_rate']) ? (float) $input['tax_rate'] : 0.0;
            $maxHoursPerDay = isset($input['max_hours_per_day']) && is_numeric($input['max_hours_per_day']) ? (float) $input['max_hours_per_day'] : 12.0;
            if ($farmId <= 0) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }
            if (!Validation::validateDate($periodStart, 'Y-m-d') || !Validation::validateDate($periodEnd, 'Y-m-d')) {
                return Response::validationError(['period' => 'period_start and period_end are required']);
            }
            if (!Validation::validateDate($payDate, 'Y-m-d')) {
                return Response::validationError(['pay_date' => 'Invalid pay_date']);
            }

            $this->db->execute(
                'INSERT INTO hr_payroll_runs (farm_id, period_start, period_end, pay_date, status, tax_rate, created_by)
                 VALUES (?, ?, ?, ?, "processed", ?, ?)',
                [$farmId, $periodStart, $periodEnd, $payDate, $taxRate, $actorId]
            );
            $runId = (int) $this->db->lastInsertId();

            $comp = $this->db->query(
                'SELECT employee_id, pay_type, hourly_rate, salary_amount, currency
                 FROM hr_employee_compensation
                 WHERE farm_id = ? AND active = 1
                 ORDER BY employee_id ASC, effective_from DESC',
                [$farmId]
            );
            $latest = [];
            foreach ($comp as $c) {
                $eid = (int) ($c['employee_id'] ?? 0);
                if ($eid > 0 && !isset($latest[$eid])) {
                    $latest[$eid] = $c;
                }
            }

            $violations = [];
            $createdEntries = [];
            foreach ($latest as $eid => $c) {
                $payType = (string) ($c['pay_type'] ?? 'hourly');
                $currency = (string) ($c['currency'] ?? 'USD');
                $gross = 0.0;
                if ($payType === 'salary') {
                    $gross = (float) ($c['salary_amount'] ?? 0);
                } else {
                    $hoursRow = $this->db->queryOne(
                        'SELECT COALESCE(SUM(TIMESTAMPDIFF(MINUTE, clock_in, clock_out)) / 60, 0) AS hours
                         FROM hr_attendance
                         WHERE farm_id = ? AND user_id = ? AND clock_out IS NOT NULL AND clock_in >= ? AND clock_in <= ?',
                        [$farmId, $eid, $periodStart . ' 00:00:00', $periodEnd . ' 23:59:59']
                    );
                    $hours = (float) ($hoursRow['hours'] ?? 0);
                    $gross = $hours * (float) ($c['hourly_rate'] ?? 0);

                    $daily = $this->db->query(
                        'SELECT DATE(clock_in) AS d, COALESCE(SUM(TIMESTAMPDIFF(MINUTE, clock_in, clock_out)) / 60, 0) AS hours
                         FROM hr_attendance
                         WHERE farm_id = ? AND user_id = ? AND clock_out IS NOT NULL AND clock_in >= ? AND clock_in <= ?
                         GROUP BY DATE(clock_in)',
                        [$farmId, $eid, $periodStart . ' 00:00:00', $periodEnd . ' 23:59:59']
                    );
                    foreach ($daily as $dr) {
                        $h = (float) ($dr['hours'] ?? 0);
                        if ($h > $maxHoursPerDay) {
                            $violations[] = ['employee_id' => $eid, 'date' => (string) ($dr['d'] ?? ''), 'hours' => $h, 'rule' => 'max_hours_per_day'];
                        }
                    }
                }

                $dedRow = $this->db->queryOne(
                    'SELECT COALESCE(SUM(employee_deduction),0) AS deductions
                     FROM hr_benefit_enrollments
                     WHERE farm_id = ? AND employee_id = ? AND status = "active" AND start_date <= ? AND (end_date IS NULL OR end_date >= ?)',
                    [$farmId, $eid, $periodEnd, $periodStart]
                );
                $deductions = (float) ($dedRow['deductions'] ?? 0);
                $tax = $gross * $taxRate;
                $net = max(0, $gross - $tax - $deductions);

                $this->db->execute(
                    'INSERT INTO hr_payroll_entries (farm_id, employee_id, period_start, period_end, pay_date, gross_amount, net_amount, status, notes, created_by)
                     VALUES (?, ?, ?, ?, ?, ?, ?, "processed", ?, ?)',
                    [
                        $farmId,
                        $eid,
                        $periodStart,
                        $periodEnd,
                        $payDate,
                        round($gross, 2),
                        round($net, 2),
                        'run_id=' . $runId . '; currency=' . $currency . '; tax=' . round($tax, 2) . '; deductions=' . round($deductions, 2),
                        $actorId,
                    ]
                );
                $createdEntries[] = (int) $this->db->lastInsertId();
            }

            return Response::success(['run_id' => $runId, 'entry_ids' => $createdEntries, 'compliance_violations' => $violations], 'Payroll run processed', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to run payroll', ['error' => $e->getMessage()]);
            return Response::error('Failed to run payroll', 'HR_PAYROLL_RUN_ERROR', 500);
        }
    }

    public function contractorLogs(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'tasks.read' : 'tasks.create';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();

            if ($this->request->getMethod() === 'GET') {
                $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
                if ($farmId <= 0) {
                    return Response::validationError(['farm_id' => 'Farm ID is required']);
                }
                $rows = $this->db->query(
                    'SELECT id, contractor_id, work_date, hours, hourly_rate, description, status, created_at
                     FROM hr_contractor_logs
                     WHERE farm_id = ?
                     ORDER BY work_date DESC, id DESC
                     LIMIT 2000',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $contractorId = (int) ($input['contractor_id'] ?? 0);
            $workDate = trim((string) ($input['work_date'] ?? date('Y-m-d')));
            $hours = isset($input['hours']) && is_numeric($input['hours']) ? (float) $input['hours'] : null;
            $hourlyRate = isset($input['hourly_rate']) && is_numeric($input['hourly_rate']) ? (float) $input['hourly_rate'] : null;
            $description = trim((string) ($input['description'] ?? ''));
            if ($farmId <= 0 || $contractorId <= 0) {
                return Response::validationError(['log' => 'farm_id and contractor_id are required']);
            }
            if (!Validation::validateDate($workDate, 'Y-m-d')) {
                return Response::validationError(['work_date' => 'Invalid work_date']);
            }
            if ($hours === null || $hours <= 0) {
                return Response::validationError(['hours' => 'hours must be positive']);
            }
            if ($hourlyRate === null || $hourlyRate < 0) {
                return Response::validationError(['hourly_rate' => 'hourly_rate must be non-negative']);
            }
            $this->db->execute(
                'INSERT INTO hr_contractor_logs (farm_id, contractor_id, work_date, hours, hourly_rate, description, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, "unbilled", ?)',
                [$farmId, $contractorId, $workDate, round($hours, 2), round($hourlyRate, 2), $description !== '' ? Validation::sanitizeString($description) : null, $actorId]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Contractor log created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed contractor logs', ['error' => $e->getMessage()]);
            return Response::error('Failed contractor logs', 'HR_CONTRACTOR_LOGS_ERROR', 500);
        }
    }

    public function trainingCourses(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'tasks.read' : 'tasks.create';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            if ($this->request->getMethod() === 'GET') {
                $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
                if ($farmId <= 0) {
                    return Response::validationError(['farm_id' => 'Farm ID is required']);
                }
                $rows = $this->db->query(
                    'SELECT id, title, description, competency_area, recurrence_days, active, created_at
                     FROM hr_training_courses
                     WHERE farm_id = ?
                     ORDER BY active DESC, title ASC',
                    [$farmId]
                );
                return Response::success($rows);
            }
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $title = trim((string) ($input['title'] ?? ''));
            $description = trim((string) ($input['description'] ?? ''));
            $competency = trim((string) ($input['competency_area'] ?? ''));
            $recurrenceDays = isset($input['recurrence_days']) && is_numeric($input['recurrence_days']) ? (int) $input['recurrence_days'] : 0;
            $active = isset($input['active']) ? ((int) $input['active'] === 1) : true;
            if ($farmId <= 0 || $title === '') {
                return Response::validationError(['course' => 'farm_id and title are required']);
            }
            $this->db->execute(
                'INSERT INTO hr_training_courses (farm_id, title, description, competency_area, recurrence_days, active, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [$farmId, Validation::sanitizeString($title), $description !== '' ? Validation::sanitizeString($description) : null, $competency !== '' ? Validation::sanitizeString($competency) : null, $recurrenceDays, $active ? 1 : 0, $actorId]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Training course created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed training courses', ['error' => $e->getMessage()]);
            return Response::error('Failed training courses', 'HR_TRAINING_COURSES_ERROR', 500);
        }
    }

    public function trainingRecords(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'tasks.read' : 'tasks.create';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }
            $actorId = $this->getUserId();
            if (!$actorId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            if ($this->request->getMethod() === 'GET') {
                $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
                if ($farmId <= 0) {
                    return Response::validationError(['farm_id' => 'Farm ID is required']);
                }
                $q = $this->request->getQuery();
                $employeeId = isset($q['employee_id']) && is_numeric($q['employee_id']) ? (int) $q['employee_id'] : 0;
                $days = isset($q['expiring_days']) && is_numeric($q['expiring_days']) ? (int) $q['expiring_days'] : 0;
                $where = 'farm_id = ?';
                $params = [$farmId];
                if ($employeeId > 0) {
                    $where .= ' AND employee_id = ?';
                    $params[] = $employeeId;
                }
                if ($days > 0) {
                    $where .= ' AND expiry_date IS NOT NULL AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)';
                    $params[] = $days;
                }
                $rows = $this->db->query(
                    'SELECT id, course_id, employee_id, completed_on, expiry_date, status, notes
                     FROM hr_training_records
                     WHERE ' . $where . '
                     ORDER BY completed_on DESC, id DESC
                     LIMIT 2000',
                    $params
                );
                return Response::success($rows);
            }
            $input = $this->request->getBody();
            $farmId = (int) ($input['farm_id'] ?? 0);
            $courseId = (int) ($input['course_id'] ?? 0);
            $employeeId = (int) ($input['employee_id'] ?? 0);
            $completedOn = trim((string) ($input['completed_on'] ?? date('Y-m-d')));
            $expiryDate = trim((string) ($input['expiry_date'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));
            if ($farmId <= 0 || $courseId <= 0 || $employeeId <= 0) {
                return Response::validationError(['record' => 'farm_id, course_id, employee_id are required']);
            }
            if (!Validation::validateDate($completedOn, 'Y-m-d')) {
                return Response::validationError(['completed_on' => 'Invalid completed_on']);
            }
            if ($expiryDate !== '' && !Validation::validateDate($expiryDate, 'Y-m-d')) {
                return Response::validationError(['expiry_date' => 'Invalid expiry_date']);
            }
            $this->db->execute(
                'INSERT INTO hr_training_records (farm_id, course_id, employee_id, completed_on, expiry_date, status, notes, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [$farmId, $courseId, $employeeId, $completedOn, $expiryDate !== '' ? $expiryDate : null, 'valid', $notes !== '' ? Validation::sanitizeString($notes) : null, $actorId, date('Y-m-d H:i:s')]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Training record created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed training records', ['error' => $e->getMessage()]);
            return Response::error('Failed training records', 'HR_TRAINING_RECORDS_ERROR', 500);
        }
    }
}
