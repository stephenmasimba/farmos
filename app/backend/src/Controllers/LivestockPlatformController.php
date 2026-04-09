<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class LivestockPlatformController
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

    private function userId(): ?int
    {
        $user = $this->request->getUser();
        if (!$user || empty($user['user_id'])) {
            return null;
        }
        return (int) $user['user_id'];
    }

    private function farmId(): int
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
            'CREATE TABLE IF NOT EXISTS livestock_health_records (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                livestock_id INT NOT NULL,
                record_date DATE NOT NULL,
                condition_name VARCHAR(120) NOT NULL,
                treatment VARCHAR(255) NULL,
                medicine VARCHAR(120) NULL,
                dosage VARCHAR(80) NULL,
                veterinarian VARCHAR(120) NULL,
                next_followup_date DATE NULL,
                status VARCHAR(20) NOT NULL DEFAULT "open",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_health_farm_date (farm_id, record_date),
                INDEX idx_livestock_health_livestock (livestock_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_reproduction_cycles (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                dam_id INT NOT NULL,
                sire_id INT NULL,
                heat_date DATE NULL,
                insemination_date DATE NULL,
                pregnancy_check_date DATE NULL,
                expected_calving_date DATE NULL,
                actual_calving_date DATE NULL,
                outcome VARCHAR(30) NOT NULL DEFAULT "pending",
                notes TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_repro_farm (farm_id, dam_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_production_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                livestock_id INT NOT NULL,
                log_date DATE NOT NULL,
                metric VARCHAR(60) NOT NULL,
                value DECIMAL(14,3) NOT NULL,
                unit VARCHAR(20) NOT NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_prod_farm_date (farm_id, log_date),
                INDEX idx_livestock_prod_livestock (livestock_id, metric)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_vaccination_schedule (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                livestock_id INT NOT NULL,
                vaccine_name VARCHAR(120) NOT NULL,
                scheduled_date DATE NOT NULL,
                administered_date DATE NULL,
                status VARCHAR(20) NOT NULL DEFAULT "scheduled",
                batch_no VARCHAR(80) NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_vax_farm_date (farm_id, scheduled_date),
                INDEX idx_livestock_vax_livestock (livestock_id)
            )'
        );
    }

    public function health(): Response
    {
        return $this->handleHealthRecords();
    }

    public function reproduction(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'livestock.read' : 'livestock.platform';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, dam_id, sire_id, heat_date, insemination_date, pregnancy_check_date,
                            expected_calving_date, actual_calving_date, outcome, notes
                     FROM livestock_reproduction_cycles
                     WHERE farm_id = ?
                     ORDER BY created_at DESC, id DESC
                     LIMIT 300',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $damId = (int) ($input['dam_id'] ?? 0);
            $sireId = isset($input['sire_id']) ? (int) $input['sire_id'] : null;
            $outcome = strtolower(trim((string) ($input['outcome'] ?? 'pending')));
            $notes = trim((string) ($input['notes'] ?? ''));

            if ($damId <= 0) {
                return Response::validationError(['dam_id' => 'Dam ID is required']);
            }
            if (!Validation::validateEnum($outcome, ['pending', 'pregnant', 'calved', 'failed'])) {
                return Response::validationError(['outcome' => 'Invalid outcome']);
            }

            $dateFields = ['heat_date', 'insemination_date', 'pregnancy_check_date', 'expected_calving_date', 'actual_calving_date'];
            $payloadDates = [];
            foreach ($dateFields as $field) {
                $value = (string) ($input[$field] ?? '');
                if ($value !== '' && !Validation::validateDate($value, 'Y-m-d')) {
                    return Response::validationError([$field => 'Invalid date']);
                }
                $payloadDates[$field] = $value !== '' ? $value : null;
            }

            $this->db->execute(
                'INSERT INTO livestock_reproduction_cycles
                 (farm_id, dam_id, sire_id, heat_date, insemination_date, pregnancy_check_date, expected_calving_date, actual_calving_date, outcome, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $damId,
                    $sireId,
                    $payloadDates['heat_date'],
                    $payloadDates['insemination_date'],
                    $payloadDates['pregnancy_check_date'],
                    $payloadDates['expected_calving_date'],
                    $payloadDates['actual_calving_date'],
                    $outcome,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Reproduction cycle recorded', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle livestock reproduction', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle reproduction', 'LIVESTOCK_REPRODUCTION_ERROR', 500);
        }
    }

    public function production(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'livestock.read' : 'livestock.platform';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT livestock_id, log_date, metric, value, unit, notes
                     FROM livestock_production_logs
                     WHERE farm_id = ?
                     ORDER BY log_date DESC, id DESC
                     LIMIT 500',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $livestockId = (int) ($input['livestock_id'] ?? 0);
            $logDate = (string) ($input['log_date'] ?? date('Y-m-d'));
            $metric = strtolower(trim((string) ($input['metric'] ?? '')));
            $value = $input['value'] ?? null;
            $unit = trim((string) ($input['unit'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($livestockId <= 0) {
                $errors['livestock_id'] = 'Livestock ID is required';
            }
            if (!Validation::validateDate($logDate, 'Y-m-d')) {
                $errors['log_date'] = 'Log date is invalid';
            }
            if ($metric === '') {
                $errors['metric'] = 'Metric is required';
            }
            if (!is_numeric($value)) {
                $errors['value'] = 'Value must be numeric';
            }
            if ($unit === '') {
                $errors['unit'] = 'Unit is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO livestock_production_logs (farm_id, livestock_id, log_date, metric, value, unit, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $livestockId,
                    $logDate,
                    Validation::sanitizeString($metric),
                    (float) $value,
                    Validation::sanitizeString($unit),
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Production log created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle livestock production', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle production logs', 'LIVESTOCK_PRODUCTION_ERROR', 500);
        }
    }

    public function vaccinations(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'livestock.read' : 'livestock.platform';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, livestock_id, vaccine_name, scheduled_date, administered_date, status, batch_no, notes
                     FROM livestock_vaccination_schedule
                     WHERE farm_id = ?
                     ORDER BY scheduled_date ASC, id DESC
                     LIMIT 500',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $livestockId = (int) ($input['livestock_id'] ?? 0);
            $vaccineName = trim((string) ($input['vaccine_name'] ?? ''));
            $scheduledDate = (string) ($input['scheduled_date'] ?? '');
            $administeredDate = (string) ($input['administered_date'] ?? '');
            $status = strtolower(trim((string) ($input['status'] ?? 'scheduled')));
            $batchNo = trim((string) ($input['batch_no'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($livestockId <= 0) {
                $errors['livestock_id'] = 'Livestock ID is required';
            }
            if ($vaccineName === '') {
                $errors['vaccine_name'] = 'Vaccine name is required';
            }
            if (!Validation::validateDate($scheduledDate, 'Y-m-d')) {
                $errors['scheduled_date'] = 'Scheduled date is invalid';
            }
            if ($administeredDate !== '' && !Validation::validateDate($administeredDate, 'Y-m-d')) {
                $errors['administered_date'] = 'Administered date is invalid';
            }
            if (!Validation::validateEnum($status, ['scheduled', 'completed', 'overdue', 'cancelled'])) {
                $errors['status'] = 'Invalid status';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO livestock_vaccination_schedule
                 (farm_id, livestock_id, vaccine_name, scheduled_date, administered_date, status, batch_no, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $livestockId,
                    Validation::sanitizeString($vaccineName),
                    $scheduledDate,
                    $administeredDate !== '' ? $administeredDate : null,
                    $status,
                    $batchNo !== '' ? Validation::sanitizeString($batchNo) : null,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Vaccination schedule record created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle livestock vaccinations', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle vaccinations', 'LIVESTOCK_VACCINATIONS_ERROR', 500);
        }
    }

    private function handleHealthRecords(): Response
    {
        try {
            $permission = $this->request->getMethod() === 'GET' ? 'livestock.read' : 'livestock.platform';
            $auth = $this->authorizePermission($permission);
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->userId();
            if (!$userId) {
                return Response::unauthorized();
            }
            $this->ensureTables();
            $farmId = $this->farmId();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT id, livestock_id, record_date, condition_name, treatment, medicine, dosage, veterinarian, next_followup_date, status
                     FROM livestock_health_records
                     WHERE farm_id = ?
                     ORDER BY record_date DESC, id DESC
                     LIMIT 500',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $livestockId = (int) ($input['livestock_id'] ?? 0);
            $recordDate = (string) ($input['record_date'] ?? date('Y-m-d'));
            $conditionName = trim((string) ($input['condition_name'] ?? ''));
            $treatment = trim((string) ($input['treatment'] ?? ''));
            $medicine = trim((string) ($input['medicine'] ?? ''));
            $dosage = trim((string) ($input['dosage'] ?? ''));
            $veterinarian = trim((string) ($input['veterinarian'] ?? ''));
            $nextFollowup = (string) ($input['next_followup_date'] ?? '');
            $status = strtolower(trim((string) ($input['status'] ?? 'open')));

            $errors = [];
            if ($livestockId <= 0) {
                $errors['livestock_id'] = 'Livestock ID is required';
            }
            if (!Validation::validateDate($recordDate, 'Y-m-d')) {
                $errors['record_date'] = 'Record date is invalid';
            }
            if ($conditionName === '') {
                $errors['condition_name'] = 'Condition name is required';
            }
            if ($nextFollowup !== '' && !Validation::validateDate($nextFollowup, 'Y-m-d')) {
                $errors['next_followup_date'] = 'Follow-up date is invalid';
            }
            if (!Validation::validateEnum($status, ['open', 'resolved', 'chronic'])) {
                $errors['status'] = 'Invalid status';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO livestock_health_records
                 (farm_id, livestock_id, record_date, condition_name, treatment, medicine, dosage, veterinarian, next_followup_date, status, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $livestockId,
                    $recordDate,
                    Validation::sanitizeString($conditionName),
                    $treatment !== '' ? Validation::sanitizeString($treatment) : null,
                    $medicine !== '' ? Validation::sanitizeString($medicine) : null,
                    $dosage !== '' ? Validation::sanitizeString($dosage) : null,
                    $veterinarian !== '' ? Validation::sanitizeString($veterinarian) : null,
                    $nextFollowup !== '' ? $nextFollowup : null,
                    $status,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Health record created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle livestock health records', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle health records', 'LIVESTOCK_HEALTH_ERROR', 500);
        }
    }
}
