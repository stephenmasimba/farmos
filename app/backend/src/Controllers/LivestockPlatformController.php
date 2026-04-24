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
                cost_total DECIMAL(14,2) NOT NULL DEFAULT 0,
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
                series_id BIGINT NOT NULL DEFAULT 0,
                recurrence_days INT NOT NULL DEFAULT 0,
                reminder_days_before INT NOT NULL DEFAULT 0,
                cost_total DECIMAL(14,2) NOT NULL DEFAULT 0,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_vax_farm_date (farm_id, scheduled_date),
                INDEX idx_livestock_vax_livestock (livestock_id)
            )'
        );

        try {
            $this->db->execute('ALTER TABLE livestock_vaccination_schedule ADD COLUMN series_id BIGINT NOT NULL DEFAULT 0');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE livestock_vaccination_schedule ADD COLUMN recurrence_days INT NOT NULL DEFAULT 0');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE livestock_vaccination_schedule ADD COLUMN reminder_days_before INT NOT NULL DEFAULT 0');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE livestock_vaccination_schedule ADD COLUMN cost_total DECIMAL(14,2) NOT NULL DEFAULT 0');
        } catch (\Throwable $e) {
        }

        try {
            $this->db->execute('ALTER TABLE livestock_health_records ADD COLUMN cost_total DECIMAL(14,2) NOT NULL DEFAULT 0');
        } catch (\Throwable $e) {
        }

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_feed_logs (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                livestock_id INT NOT NULL,
                feed_item VARCHAR(191) NOT NULL,
                feed_qty DECIMAL(14,3) NOT NULL,
                unit VARCHAR(20) NOT NULL DEFAULT "kg",
                cost_total DECIMAL(14,2) NOT NULL DEFAULT 0,
                log_date DATE NOT NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_feed_farm_date (farm_id, log_date),
                INDEX idx_livestock_feed_livestock (livestock_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_trace_events (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                livestock_id INT NOT NULL,
                event_type VARCHAR(60) NOT NULL,
                event_date DATETIME NOT NULL,
                location VARCHAR(191) NULL,
                latitude DECIMAL(10,7) NULL,
                longitude DECIMAL(10,7) NULL,
                reference_type VARCHAR(60) NULL,
                reference_id VARCHAR(80) NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_trace_farm_date (farm_id, event_date),
                INDEX idx_livestock_trace_animal (livestock_id, event_date)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_pedigree (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                livestock_id INT NOT NULL,
                sire_id INT NULL,
                dam_id INT NULL,
                herdbook_id VARCHAR(120) NULL,
                genetic_line VARCHAR(120) NULL,
                pedigree_json LONGTEXT NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                UNIQUE KEY uniq_livestock_pedigree (farm_id, livestock_id),
                INDEX idx_livestock_pedigree_farm (farm_id),
                INDEX idx_livestock_pedigree_parents (farm_id, sire_id, dam_id)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_genetic_traits (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                livestock_id INT NOT NULL,
                trait_name VARCHAR(120) NOT NULL,
                trait_value VARCHAR(191) NOT NULL,
                measured_on DATE NULL,
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_traits_farm_animal (farm_id, livestock_id, trait_name),
                INDEX idx_livestock_traits_farm_date (farm_id, measured_on)
            )'
        );

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_breeding_plans (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                dam_id INT NOT NULL,
                sire_id INT NULL,
                planned_breeding_date DATE NOT NULL,
                method VARCHAR(40) NOT NULL DEFAULT "natural",
                expected_birth_date DATE NULL,
                status VARCHAR(20) NOT NULL DEFAULT "planned",
                notes VARCHAR(255) NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NULL,
                INDEX idx_livestock_breeding_plans_farm_date (farm_id, planned_breeding_date),
                INDEX idx_livestock_breeding_plans_farm_status (farm_id, status)
            )'
        );
    }

    private static ?array $financialRecordColumns = null;

    private function financialRecordColumns(): array
    {
        if (self::$financialRecordColumns !== null) {
            return self::$financialRecordColumns;
        }
        try {
            $rows = $this->db->query('SHOW COLUMNS FROM financial_records');
            $cols = [];
            foreach ($rows as $r) {
                $name = strtolower((string) ($r['Field'] ?? ''));
                if ($name !== '') {
                    $cols[$name] = true;
                }
            }
            self::$financialRecordColumns = $cols;
            return $cols;
        } catch (\Throwable $e) {
            self::$financialRecordColumns = [];
            return [];
        }
    }

    private function postFinanceRecord(
        int $farmId,
        string $type,
        string $category,
        string $description,
        float $amount,
        string $recordDate,
        ?string $referenceNumber,
        ?string $notes,
        ?int $createdBy
    ): void {
        $cols = $this->financialRecordColumns();
        if (empty($cols)) {
            return;
        }

        $dateTime = trim($recordDate);
        if ($dateTime !== '' && strlen($dateTime) === 10) {
            $dateTime .= ' 00:00:00';
        }
        if ($dateTime === '') {
            $dateTime = date('Y-m-d H:i:s');
        }

        $fields = ['farm_id', 'type', 'category', 'description', 'amount', 'date'];
        $values = [
            $farmId,
            $type,
            $category !== '' ? Validation::sanitizeString($category) : null,
            $description !== '' ? Validation::sanitizeString($description) : null,
            round($amount, 2),
            $dateTime,
        ];

        if (isset($cols['reference_number'])) {
            $fields[] = 'reference_number';
            $values[] = $referenceNumber !== null && $referenceNumber !== '' ? Validation::sanitizeString($referenceNumber) : null;
        }
        if (isset($cols['payment_method'])) {
            $fields[] = 'payment_method';
            $values[] = null;
        }
        if (isset($cols['notes'])) {
            $fields[] = 'notes';
            $values[] = $notes !== null && $notes !== '' ? Validation::sanitizeString($notes) : null;
        }
        if (isset($cols['status'])) {
            $fields[] = 'status';
            $values[] = 'completed';
        }
        if (isset($cols['currency'])) {
            $fields[] = 'currency';
            $values[] = 'USD';
        }
        if (isset($cols['category_source'])) {
            $fields[] = 'category_source';
            $values[] = 'system';
        }
        if (isset($cols['created_by'])) {
            $fields[] = 'created_by';
            $values[] = $createdBy;
        }
        if (isset($cols['updated_by'])) {
            $fields[] = 'updated_by';
            $values[] = $createdBy;
        }

        $placeholders = implode(',', array_fill(0, count($fields), '?'));
        $sql = 'INSERT INTO financial_records (' . implode(', ', $fields) . ') VALUES (' . $placeholders . ')';
        $this->db->execute($sql, $values);
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
            $postToFinance = !empty($input['post_to_finance']);
            $financeType = strtolower(trim((string) ($input['finance_type'] ?? 'income')));
            $financeAmount = isset($input['finance_amount']) && is_numeric($input['finance_amount']) ? (float) $input['finance_amount'] : null;
            $financeCategory = trim((string) ($input['finance_category'] ?? 'Livestock Production'));

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
            $id = (int) $this->db->lastInsertId();

            if ($postToFinance && $financeAmount !== null && $financeAmount > 0 && Validation::validateEnum($financeType, ['income', 'expense'])) {
                $this->postFinanceRecord(
                    $farmId,
                    $financeType,
                    $financeCategory !== '' ? $financeCategory : 'Livestock Production',
                    'Production: ' . $metric . ' (animal #' . $livestockId . ')',
                    $financeAmount,
                    $logDate,
                    'livestock_production_log:' . $id,
                    $notes !== '' ? $notes : null,
                    $userId
                );
            }

            return Response::success(['id' => $id], 'Production log created', 201);
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
                    'SELECT id, livestock_id, vaccine_name, scheduled_date, administered_date, status, batch_no, notes, series_id, recurrence_days, reminder_days_before
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
            $recurrenceDays = isset($input['recurrence_days']) && is_numeric($input['recurrence_days']) ? (int) $input['recurrence_days'] : 0;
            $occurrences = isset($input['occurrences']) && is_numeric($input['occurrences']) ? (int) $input['occurrences'] : 1;
            $reminderDays = isset($input['reminder_days_before']) && is_numeric($input['reminder_days_before']) ? (int) $input['reminder_days_before'] : 0;
            $costTotal = isset($input['cost_total']) && is_numeric($input['cost_total']) ? (float) $input['cost_total'] : 0.0;
            $postToFinance = !empty($input['post_to_finance']);
            $financeCategory = trim((string) ($input['finance_category'] ?? 'Livestock Vaccinations'));

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
            if ($recurrenceDays < 0 || $recurrenceDays > 3650) {
                $errors['recurrence_days'] = 'Invalid recurrence_days';
            }
            if ($occurrences < 1 || $occurrences > 60) {
                $errors['occurrences'] = 'Invalid occurrences';
            }
            if ($reminderDays < 0 || $reminderDays > 365) {
                $errors['reminder_days_before'] = 'Invalid reminder_days_before';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $seriesId = random_int(100000000, 999999999);
            $createdIds = [];
            $base = strtotime($scheduledDate);
            $count = max(1, $occurrences);
            for ($i = 0; $i < $count; $i++) {
                $dt = $base;
                if ($i > 0 && $recurrenceDays > 0) {
                    $dt = strtotime('+' . ($i * $recurrenceDays) . ' days', $base);
                }
                $sd = date('Y-m-d', $dt);
                $this->db->execute(
                    'INSERT INTO livestock_vaccination_schedule
                     (farm_id, livestock_id, vaccine_name, scheduled_date, administered_date, status, batch_no, notes, series_id, recurrence_days, reminder_days_before, cost_total, created_by)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    [
                        $farmId,
                        $livestockId,
                        Validation::sanitizeString($vaccineName),
                        $sd,
                        $administeredDate !== '' ? $administeredDate : null,
                        $status,
                        $batchNo !== '' ? Validation::sanitizeString($batchNo) : null,
                        $notes !== '' ? Validation::sanitizeString($notes) : null,
                        $seriesId,
                        $recurrenceDays,
                        $reminderDays,
                        $costTotal,
                        $userId,
                    ]
                );
                $createdIds[] = (int) $this->db->lastInsertId();

                if ($postToFinance && $costTotal > 0) {
                    $this->postFinanceRecord(
                        $farmId,
                        'expense',
                        $financeCategory !== '' ? $financeCategory : 'Livestock Vaccinations',
                        'Vaccine: ' . $vaccineName . ' (animal #' . $livestockId . ')',
                        $costTotal,
                        $sd,
                        'livestock_vaccination:' . (string) end($createdIds),
                        null,
                        $userId
                    );
                }
            }

            return Response::success(['ids' => $createdIds, 'series_id' => $seriesId], 'Vaccination schedule created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle livestock vaccinations', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle vaccinations', 'LIVESTOCK_VACCINATIONS_ERROR', 500);
        }
    }

    public function alerts(): Response
    {
        try {
            $auth = $this->authorizePermission('livestock.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $days = isset($q['days']) && is_numeric($q['days']) ? (int) $q['days'] : 14;
            $days = max(1, min(365, $days));
            $today = date('Y-m-d');
            $cutoff = date('Y-m-d', strtotime('+' . $days . ' days'));

            $dueVaccines = $this->db->query(
                'SELECT id, livestock_id, vaccine_name, scheduled_date, status, reminder_days_before
                 FROM livestock_vaccination_schedule
                 WHERE farm_id = ? AND status = "scheduled" AND scheduled_date <= ?
                 ORDER BY scheduled_date ASC, id ASC
                 LIMIT 500',
                [$farmId, $cutoff]
            );

            $overdueVaccines = $this->db->query(
                'SELECT id, livestock_id, vaccine_name, scheduled_date, status
                 FROM livestock_vaccination_schedule
                 WHERE farm_id = ? AND status = "scheduled" AND scheduled_date < ?
                 ORDER BY scheduled_date ASC, id ASC
                 LIMIT 500',
                [$farmId, $today]
            );

            $followups = $this->db->query(
                'SELECT id, livestock_id, condition_name, next_followup_date, status
                 FROM livestock_health_records
                 WHERE farm_id = ? AND status = "open" AND next_followup_date IS NOT NULL AND next_followup_date <= ?
                 ORDER BY next_followup_date ASC, id ASC
                 LIMIT 500',
                [$farmId, $cutoff]
            );

            $reproPregChecks = $this->db->query(
                'SELECT id, dam_id, sire_id, pregnancy_check_date, expected_calving_date, outcome
                 FROM livestock_reproduction_cycles
                 WHERE farm_id = ? AND outcome = "pending" AND pregnancy_check_date IS NOT NULL AND pregnancy_check_date <= ?
                 ORDER BY pregnancy_check_date ASC, id ASC
                 LIMIT 300',
                [$farmId, $cutoff]
            );

            $reproDueBirths = $this->db->query(
                'SELECT id, dam_id, sire_id, expected_calving_date, outcome
                 FROM livestock_reproduction_cycles
                 WHERE farm_id = ? AND outcome IN ("pregnant","pending") AND expected_calving_date IS NOT NULL AND expected_calving_date <= ? AND actual_calving_date IS NULL
                 ORDER BY expected_calving_date ASC, id ASC
                 LIMIT 300',
                [$farmId, $cutoff]
            );

            return Response::success([
                'days' => $days,
                'due_vaccinations' => $dueVaccines,
                'overdue_vaccinations' => $overdueVaccines,
                'health_followups' => $followups,
                'pregnancy_checks_due' => $reproPregChecks,
                'births_due' => $reproDueBirths,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to fetch livestock alerts', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch alerts', 'LIVESTOCK_ALERTS_ERROR', 500);
        }
    }

    public function feedLogs(): Response
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
                $q = $this->request->getQuery();
                $livestockId = isset($q['livestock_id']) && is_numeric($q['livestock_id']) ? (int) $q['livestock_id'] : 0;
                $sql = 'SELECT id, livestock_id, feed_item, feed_qty, unit, cost_total, log_date, notes
                        FROM livestock_feed_logs
                        WHERE farm_id = ?';
                $params = [$farmId];
                if ($livestockId > 0) {
                    $sql .= ' AND livestock_id = ?';
                    $params[] = $livestockId;
                }
                $sql .= ' ORDER BY log_date DESC, id DESC LIMIT 500';
                return Response::success($this->db->query($sql, $params));
            }

            $input = $this->request->getBody();
            $livestockId = (int) ($input['livestock_id'] ?? 0);
            $feedItem = trim((string) ($input['feed_item'] ?? ''));
            $qty = $input['feed_qty'] ?? null;
            $unit = trim((string) ($input['unit'] ?? 'kg'));
            $cost = isset($input['cost_total']) && is_numeric($input['cost_total']) ? (float) $input['cost_total'] : 0.0;
            $logDate = (string) ($input['log_date'] ?? date('Y-m-d'));
            $notes = trim((string) ($input['notes'] ?? ''));
            $postToFinance = !empty($input['post_to_finance']);
            $financeCategory = trim((string) ($input['finance_category'] ?? 'Livestock Feed'));

            $errors = [];
            if ($livestockId <= 0) {
                $errors['livestock_id'] = 'Livestock ID is required';
            }
            if ($feedItem === '') {
                $errors['feed_item'] = 'Feed item is required';
            }
            if (!is_numeric($qty) || (float) $qty <= 0) {
                $errors['feed_qty'] = 'feed_qty must be positive';
            }
            if (!Validation::validateDate($logDate, 'Y-m-d')) {
                $errors['log_date'] = 'Invalid log_date';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO livestock_feed_logs (farm_id, livestock_id, feed_item, feed_qty, unit, cost_total, log_date, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $livestockId,
                    Validation::sanitizeString($feedItem),
                    (float) $qty,
                    Validation::sanitizeString($unit),
                    $cost,
                    $logDate,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );
            $id = (int) $this->db->lastInsertId();

            if ($postToFinance && $cost > 0) {
                $this->postFinanceRecord(
                    $farmId,
                    'expense',
                    $financeCategory !== '' ? $financeCategory : 'Livestock Feed',
                    'Feed: ' . $feedItem . ' (animal #' . $livestockId . ')',
                    $cost,
                    $logDate,
                    'livestock_feed_log:' . $id,
                    $notes !== '' ? $notes : null,
                    $userId
                );
            }

            return Response::success(['id' => $id], 'Feed log created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle feed logs', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle feed logs', 'LIVESTOCK_FEED_LOGS_ERROR', 500);
        }
    }

    public function breedingPlans(): Response
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
                $q = $this->request->getQuery();
                $status = strtolower(trim((string) ($q['status'] ?? '')));
                $damId = isset($q['dam_id']) && is_numeric($q['dam_id']) ? (int) $q['dam_id'] : 0;
                $sql = 'SELECT id, dam_id, sire_id, planned_breeding_date, method, expected_birth_date, status, notes
                        FROM livestock_breeding_plans
                        WHERE farm_id = ?';
                $params = [$farmId];
                if ($status !== '') {
                    $sql .= ' AND status = ?';
                    $params[] = $status;
                }
                if ($damId > 0) {
                    $sql .= ' AND dam_id = ?';
                    $params[] = $damId;
                }
                $sql .= ' ORDER BY planned_breeding_date ASC, id DESC LIMIT 500';
                return Response::success($this->db->query($sql, $params));
            }

            $input = $this->request->getBody();
            $damId = (int) ($input['dam_id'] ?? 0);
            $sireId = isset($input['sire_id']) && is_numeric($input['sire_id']) ? (int) $input['sire_id'] : null;
            $plannedDate = trim((string) ($input['planned_breeding_date'] ?? ''));
            $method = strtolower(trim((string) ($input['method'] ?? 'natural')));
            $expectedBirth = trim((string) ($input['expected_birth_date'] ?? ''));
            $status = strtolower(trim((string) ($input['status'] ?? 'planned')));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($damId <= 0) {
                $errors['dam_id'] = 'Dam ID is required';
            }
            if (!Validation::validateDate($plannedDate, 'Y-m-d')) {
                $errors['planned_breeding_date'] = 'planned_breeding_date is invalid';
            }
            if ($expectedBirth !== '' && !Validation::validateDate($expectedBirth, 'Y-m-d')) {
                $errors['expected_birth_date'] = 'expected_birth_date is invalid';
            }
            if (!Validation::validateEnum($method, ['natural', 'ai', 'embryo_transfer'])) {
                $errors['method'] = 'Invalid method';
            }
            if (!Validation::validateEnum($status, ['planned', 'completed', 'cancelled'])) {
                $errors['status'] = 'Invalid status';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO livestock_breeding_plans (farm_id, dam_id, sire_id, planned_breeding_date, method, expected_birth_date, status, notes, created_by, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $damId,
                    $sireId,
                    $plannedDate,
                    Validation::sanitizeString($method),
                    $expectedBirth !== '' ? $expectedBirth : null,
                    Validation::sanitizeString($status),
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                    date('Y-m-d H:i:s'),
                ]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Breeding plan created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle breeding plans', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle breeding plans', 'LIVESTOCK_BREEDING_PLANS_ERROR', 500);
        }
    }

    public function pedigree(): Response
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

            if ($this->request->getMethod() === 'POST') {
                $input = $this->request->getBody();
                $livestockId = (int) ($input['livestock_id'] ?? 0);
                $sireId = isset($input['sire_id']) && is_numeric($input['sire_id']) ? (int) $input['sire_id'] : null;
                $damId = isset($input['dam_id']) && is_numeric($input['dam_id']) ? (int) $input['dam_id'] : null;
                $herdbookId = trim((string) ($input['herdbook_id'] ?? ''));
                $geneticLine = trim((string) ($input['genetic_line'] ?? ''));
                $pedigreeJson = $input['pedigree'] ?? null;
                $notes = trim((string) ($input['notes'] ?? ''));

                $errors = [];
                if ($livestockId <= 0) {
                    $errors['livestock_id'] = 'Livestock ID is required';
                }
                if ($sireId !== null && $sireId === $livestockId) {
                    $errors['sire_id'] = 'sire_id cannot equal livestock_id';
                }
                if ($damId !== null && $damId === $livestockId) {
                    $errors['dam_id'] = 'dam_id cannot equal livestock_id';
                }
                if (!empty($errors)) {
                    return Response::validationError($errors);
                }

                $exists = $this->db->queryOne('SELECT id FROM livestock WHERE id = ? AND farm_id = ? LIMIT 1', [$livestockId, $farmId]);
                if (!$exists) {
                    return Response::notFound('Livestock not found');
                }
                if ($sireId !== null) {
                    $sire = $this->db->queryOne('SELECT id FROM livestock WHERE id = ? AND farm_id = ? LIMIT 1', [$sireId, $farmId]);
                    if (!$sire) {
                        return Response::validationError(['sire_id' => 'Sire not found']);
                    }
                }
                if ($damId !== null) {
                    $dam = $this->db->queryOne('SELECT id FROM livestock WHERE id = ? AND farm_id = ? LIMIT 1', [$damId, $farmId]);
                    if (!$dam) {
                        return Response::validationError(['dam_id' => 'Dam not found']);
                    }
                }

                $pedJson = null;
                if ($pedigreeJson !== null) {
                    $pedJson = json_encode($pedigreeJson);
                }

                $this->db->execute(
                    'INSERT INTO livestock_pedigree (farm_id, livestock_id, sire_id, dam_id, herdbook_id, genetic_line, pedigree_json, notes, created_by, updated_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                     ON DUPLICATE KEY UPDATE
                        sire_id = VALUES(sire_id),
                        dam_id = VALUES(dam_id),
                        herdbook_id = VALUES(herdbook_id),
                        genetic_line = VALUES(genetic_line),
                        pedigree_json = VALUES(pedigree_json),
                        notes = VALUES(notes),
                        updated_at = VALUES(updated_at)',
                    [
                        $farmId,
                        $livestockId,
                        $sireId,
                        $damId,
                        $herdbookId !== '' ? Validation::sanitizeString($herdbookId) : null,
                        $geneticLine !== '' ? Validation::sanitizeString($geneticLine) : null,
                        $pedJson,
                        $notes !== '' ? Validation::sanitizeString($notes) : null,
                        $userId,
                        date('Y-m-d H:i:s'),
                    ]
                );

                return Response::success(['livestock_id' => $livestockId], 'Pedigree saved', 201);
            }

            $q = $this->request->getQuery();
            $livestockId = isset($q['livestock_id']) && is_numeric($q['livestock_id']) ? (int) $q['livestock_id'] : 0;
            $generations = isset($q['generations']) && is_numeric($q['generations']) ? (int) $q['generations'] : 3;
            $generations = max(1, min(6, $generations));
            if ($livestockId <= 0) {
                return Response::validationError(['livestock_id' => 'Livestock ID is required']);
            }

            $root = $this->db->queryOne('SELECT id, name, species, breed, gender, birth_date, status, tag_number, microchip_id FROM livestock WHERE id = ? AND farm_id = ? LIMIT 1', [$livestockId, $farmId]);
            if (!$root) {
                return Response::notFound('Livestock not found');
            }

            $pedRows = $this->db->query(
                'SELECT livestock_id, sire_id, dam_id, herdbook_id, genetic_line, pedigree_json, notes
                 FROM livestock_pedigree
                 WHERE farm_id = ?',
                [$farmId]
            );
            $map = [];
            foreach ($pedRows as $r) {
                $map[(int) $r['livestock_id']] = $r;
            }

            $build = function (int $id, int $depth) use (&$build, $map, $farmId): array {
                $row = $this->db->queryOne('SELECT id, name, species, breed, gender, birth_date, status, tag_number, microchip_id FROM livestock WHERE id = ? AND farm_id = ? LIMIT 1', [$id, $farmId]) ?: ['id' => $id];
                $node = [
                    'animal' => $row,
                    'pedigree' => null,
                    'sire' => null,
                    'dam' => null,
                ];
                if (!isset($map[$id])) {
                    return $node;
                }
                $p = $map[$id];
                $node['pedigree'] = [
                    'sire_id' => isset($p['sire_id']) ? (int) $p['sire_id'] : null,
                    'dam_id' => isset($p['dam_id']) ? (int) $p['dam_id'] : null,
                    'herdbook_id' => $p['herdbook_id'] ?? null,
                    'genetic_line' => $p['genetic_line'] ?? null,
                    'notes' => $p['notes'] ?? null,
                ];
                if ($depth <= 1) {
                    return $node;
                }
                $sireId = isset($p['sire_id']) && is_numeric($p['sire_id']) ? (int) $p['sire_id'] : 0;
                $damId = isset($p['dam_id']) && is_numeric($p['dam_id']) ? (int) $p['dam_id'] : 0;
                if ($sireId > 0) {
                    $node['sire'] = $build($sireId, $depth - 1);
                }
                if ($damId > 0) {
                    $node['dam'] = $build($damId, $depth - 1);
                }
                return $node;
            };

            $tree = $build($livestockId, $generations);
            return Response::success([
                'farm_id' => $farmId,
                'livestock_id' => $livestockId,
                'generations' => $generations,
                'tree' => $tree,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to handle pedigree', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle pedigree', 'LIVESTOCK_PEDIGREE_ERROR', 500);
        }
    }

    public function genetics(): Response
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
                $q = $this->request->getQuery();
                $livestockId = isset($q['livestock_id']) && is_numeric($q['livestock_id']) ? (int) $q['livestock_id'] : 0;
                $sql = 'SELECT id, livestock_id, trait_name, trait_value, measured_on, notes, created_at
                        FROM livestock_genetic_traits
                        WHERE farm_id = ?';
                $params = [$farmId];
                if ($livestockId > 0) {
                    $sql .= ' AND livestock_id = ?';
                    $params[] = $livestockId;
                }
                $sql .= ' ORDER BY measured_on DESC, id DESC LIMIT 2000';
                return Response::success($this->db->query($sql, $params));
            }

            $input = $this->request->getBody();
            $livestockId = (int) ($input['livestock_id'] ?? 0);
            $traitName = trim((string) ($input['trait_name'] ?? ''));
            $traitValue = trim((string) ($input['trait_value'] ?? ''));
            $measuredOn = trim((string) ($input['measured_on'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($livestockId <= 0) {
                $errors['livestock_id'] = 'Livestock ID is required';
            }
            if ($traitName === '') {
                $errors['trait_name'] = 'trait_name is required';
            }
            if ($traitValue === '') {
                $errors['trait_value'] = 'trait_value is required';
            }
            if ($measuredOn !== '' && !Validation::validateDate($measuredOn, 'Y-m-d')) {
                $errors['measured_on'] = 'measured_on is invalid';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $exists = $this->db->queryOne('SELECT id FROM livestock WHERE id = ? AND farm_id = ? LIMIT 1', [$livestockId, $farmId]);
            if (!$exists) {
                return Response::notFound('Livestock not found');
            }

            $this->db->execute(
                'INSERT INTO livestock_genetic_traits (farm_id, livestock_id, trait_name, trait_value, measured_on, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $livestockId,
                    Validation::sanitizeString($traitName),
                    Validation::sanitizeString($traitValue),
                    $measuredOn !== '' ? $measuredOn : null,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Genetic trait recorded', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle genetics', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle genetics', 'LIVESTOCK_GENETICS_ERROR', 500);
        }
    }

    public function lifecycleAnalytics(): Response
    {
        try {
            $auth = $this->authorizePermission('livestock.read');
            if ($auth !== true) {
                return $auth;
            }
            $this->ensureTables();
            $farmId = $this->farmId();
            $q = $this->request->getQuery();
            $livestockId = isset($q['livestock_id']) && is_numeric($q['livestock_id']) ? (int) $q['livestock_id'] : 0;
            $from = trim((string) ($q['from'] ?? ''));
            $to = trim((string) ($q['to'] ?? ''));
            $whereDates = '';
            $paramsDates = [];
            if ($from !== '' && Validation::validateDate($from, 'Y-m-d')) {
                $whereDates .= ' AND %s >= ?';
                $paramsDates[] = $from;
            }
            if ($to !== '' && Validation::validateDate($to, 'Y-m-d')) {
                $whereDates .= ' AND %s <= ?';
                $paramsDates[] = $to;
            }

            $animalClause = $livestockId > 0 ? ' AND livestock_id = ?' : '';
            $animalParams = $livestockId > 0 ? [$livestockId] : [];

            $feed = $this->db->queryOne(
                'SELECT COALESCE(SUM(cost_total), 0) AS cost_total, COUNT(*) AS cnt
                 FROM livestock_feed_logs
                 WHERE farm_id = ?' . $animalClause,
                array_merge([$farmId], $animalParams)
            ) ?: ['cost_total' => 0, 'cnt' => 0];

            $health = $this->db->queryOne(
                'SELECT COALESCE(SUM(cost_total), 0) AS cost_total, COUNT(*) AS cnt
                 FROM livestock_health_records
                 WHERE farm_id = ?' . $animalClause,
                array_merge([$farmId], $animalParams)
            ) ?: ['cost_total' => 0, 'cnt' => 0];

            $vax = $this->db->queryOne(
                'SELECT COALESCE(SUM(cost_total), 0) AS cost_total, COUNT(*) AS cnt
                 FROM livestock_vaccination_schedule
                 WHERE farm_id = ?' . $animalClause,
                array_merge([$farmId], $animalParams)
            ) ?: ['cost_total' => 0, 'cnt' => 0];

            $prodRows = $this->db->query(
                'SELECT metric, COALESCE(SUM(value), 0) AS total_value, COUNT(*) AS cnt
                 FROM livestock_production_logs
                 WHERE farm_id = ?' . $animalClause . '
                 GROUP BY metric
                 ORDER BY metric ASC',
                array_merge([$farmId], $animalParams)
            );

            $repro = $this->db->query(
                'SELECT outcome, COUNT(*) AS cnt
                 FROM livestock_reproduction_cycles
                 WHERE farm_id = ?' . ($livestockId > 0 ? ' AND dam_id = ?' : '') . '
                 GROUP BY outcome',
                $livestockId > 0 ? [$farmId, $livestockId] : [$farmId]
            );

            $trace = $this->db->query(
                'SELECT event_type, COUNT(*) AS cnt
                 FROM livestock_trace_events
                 WHERE farm_id = ?' . $animalClause . '
                 GROUP BY event_type
                 ORDER BY cnt DESC',
                array_merge([$farmId], $animalParams)
            );

            return Response::success([
                'farm_id' => $farmId,
                'livestock_id' => $livestockId > 0 ? $livestockId : null,
                'feed' => ['count' => (int) ($feed['cnt'] ?? 0), 'cost_total' => (float) ($feed['cost_total'] ?? 0)],
                'health' => ['count' => (int) ($health['cnt'] ?? 0), 'cost_total' => (float) ($health['cost_total'] ?? 0)],
                'vaccinations' => ['count' => (int) ($vax['cnt'] ?? 0), 'cost_total' => (float) ($vax['cost_total'] ?? 0)],
                'production' => $prodRows,
                'reproduction_outcomes' => $repro,
                'traceability' => $trace,
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to compute lifecycle analytics', ['error' => $e->getMessage()]);
            return Response::error('Failed to compute lifecycle analytics', 'LIVESTOCK_LIFECYCLE_ANALYTICS_ERROR', 500);
        }
    }

    public function trace(): Response
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
                $q = $this->request->getQuery();
                $livestockId = isset($q['livestock_id']) && is_numeric($q['livestock_id']) ? (int) $q['livestock_id'] : 0;
                $sql = 'SELECT id, livestock_id, event_type, event_date, location, latitude, longitude, reference_type, reference_id, notes
                        FROM livestock_trace_events
                        WHERE farm_id = ?';
                $params = [$farmId];
                if ($livestockId > 0) {
                    $sql .= ' AND livestock_id = ?';
                    $params[] = $livestockId;
                }
                $sql .= ' ORDER BY event_date DESC, id DESC LIMIT 1000';
                return Response::success($this->db->query($sql, $params));
            }

            $input = $this->request->getBody();
            $livestockId = (int) ($input['livestock_id'] ?? 0);
            $eventType = trim((string) ($input['event_type'] ?? ''));
            $eventDate = trim((string) ($input['event_date'] ?? date('Y-m-d H:i:s')));
            $location = trim((string) ($input['location'] ?? ''));
            $lat = isset($input['latitude']) && is_numeric($input['latitude']) ? (float) $input['latitude'] : null;
            $lng = isset($input['longitude']) && is_numeric($input['longitude']) ? (float) $input['longitude'] : null;
            $refType = trim((string) ($input['reference_type'] ?? ''));
            $refId = trim((string) ($input['reference_id'] ?? ''));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($livestockId <= 0) {
                $errors['livestock_id'] = 'Livestock ID is required';
            }
            if ($eventType === '') {
                $errors['event_type'] = 'event_type is required';
            }
            if (!Validation::validateDate($eventDate, 'Y-m-d H:i:s')) {
                $errors['event_date'] = 'Invalid event_date (YYYY-MM-DD HH:MM:SS)';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO livestock_trace_events (farm_id, livestock_id, event_type, event_date, location, latitude, longitude, reference_type, reference_id, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $livestockId,
                    Validation::sanitizeString($eventType),
                    $eventDate,
                    $location !== '' ? Validation::sanitizeString($location) : null,
                    $lat,
                    $lng,
                    $refType !== '' ? Validation::sanitizeString($refType) : null,
                    $refId !== '' ? Validation::sanitizeString($refId) : null,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );
            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Trace event created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle trace events', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle trace events', 'LIVESTOCK_TRACE_ERROR', 500);
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
            $costTotal = isset($input['cost_total']) && is_numeric($input['cost_total']) ? (float) $input['cost_total'] : 0.0;
            $postToFinance = !empty($input['post_to_finance']);
            $financeCategory = trim((string) ($input['finance_category'] ?? 'Livestock Health'));
            $notes = trim((string) ($input['notes'] ?? ''));

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
                 (farm_id, livestock_id, record_date, condition_name, treatment, medicine, dosage, veterinarian, next_followup_date, status, cost_total, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
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
                    $costTotal,
                    $userId,
                ]
            );

            $id = (int) $this->db->lastInsertId();
            if ($postToFinance && $costTotal > 0) {
                $this->postFinanceRecord(
                    $farmId,
                    'expense',
                    $financeCategory !== '' ? $financeCategory : 'Livestock Health',
                    'Health: ' . $conditionName . ' (animal #' . $livestockId . ')',
                    $costTotal,
                    $recordDate,
                    'livestock_health_record:' . $id,
                    $notes !== '' ? $notes : null,
                    $userId
                );
            }

            return Response::success(['id' => $id], 'Health record created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle livestock health records', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle health records', 'LIVESTOCK_HEALTH_ERROR', 500);
        }
    }
}
