<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};
use FarmOS\Middleware\PermissionMiddleware;

class VeterinaryController
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

    private function getFarmId(): int
    {
        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureTables(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS veterinary_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL DEFAULT 1,
                animal_id VARCHAR(100) NOT NULL,
                animal_type VARCHAR(100) NULL,
                treatment_date DATE NULL,
                treatment_type VARCHAR(100) NOT NULL,
                medication VARCHAR(150) NULL,
                dosage VARCHAR(100) NULL,
                withdrawal_period_days INT DEFAULT 0,
                withdrawal_end_date DATE NULL,
                notes TEXT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "ACTIVE",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_veterinary_logs_farm (farm_id, created_at),
                INDEX idx_veterinary_logs_animal (animal_id),
                INDEX idx_veterinary_logs_created_at (created_at)
            )'
        );
        try {
            $this->db->execute('ALTER TABLE veterinary_logs ADD COLUMN farm_id INT NOT NULL DEFAULT 1');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE veterinary_logs ADD COLUMN treatment_date DATE NULL');
        } catch (\Throwable $e) {
        }
        try {
            $this->db->execute('ALTER TABLE veterinary_logs ADD COLUMN notes TEXT NULL');
        } catch (\Throwable $e) {
        }

        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS veterinary_vaccinations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL DEFAULT 1,
                vaccine_name VARCHAR(150) NOT NULL,
                batch_id VARCHAR(100) NOT NULL,
                target_age_days INT NOT NULL DEFAULT 0,
                scheduled_date DATE NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT "scheduled",
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_veterinary_vax_schedule (scheduled_date),
                INDEX idx_veterinary_vax_status (status)
            )'
        );
        try {
            $this->db->execute('ALTER TABLE veterinary_vaccinations ADD COLUMN farm_id INT NOT NULL DEFAULT 1');
        } catch (\Throwable $e) {
        }
    }

    public function logs(): Response
    {
        try {
            $auth = $this->authorizePermission($this->request->getMethod() === 'GET' ? 'livestock.read' : 'livestock.update');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();

            if ($this->request->getMethod() === 'POST') {
                $userId = $this->getUserId();
                if (!$userId) {
                    return Response::unauthorized();
                }

                $input = $this->request->getBody();
                $animalId = trim((string) ($input['animal_id'] ?? ''));
                $animalType = trim((string) ($input['animal_type'] ?? ''));
                $treatmentType = trim((string) ($input['treatment_type'] ?? ''));
                $medication = trim((string) ($input['medication'] ?? ''));
                $dosage = trim((string) ($input['dosage'] ?? ''));
                $withdrawalDays = $input['withdrawal_period_days'] ?? 0;
                $treatmentDate = trim((string) ($input['treatment_date'] ?? date('Y-m-d')));
                $notes = trim((string) ($input['notes'] ?? ''));

                $errors = [];
                if ($animalId === '') {
                    $errors['animal_id'] = 'Animal ID is required';
                }
                if ($treatmentType === '') {
                    $errors['treatment_type'] = 'Treatment type is required';
                }
                if (!Validation::validateDate($treatmentDate, 'Y-m-d')) {
                    $errors['treatment_date'] = 'Valid treatment date is required';
                }
                if (!is_numeric($withdrawalDays) || (int) $withdrawalDays < 0) {
                    $errors['withdrawal_period_days'] = 'Withdrawal period days must be 0 or greater';
                }
                if (!empty($errors)) {
                    return Response::validationError($errors);
                }

                $wd = (int) $withdrawalDays;
                $withdrawalEndDate = null;
                if ($wd > 0) {
                    $ts = strtotime($treatmentDate);
                    if ($ts !== false) {
                        $withdrawalEndDate = date('Y-m-d', $ts + ($wd * 86400));
                    }
                }

                $this->db->execute(
                    'INSERT INTO veterinary_logs (farm_id, animal_id, animal_type, treatment_date, treatment_type, medication, dosage, withdrawal_period_days, withdrawal_end_date, notes, status, created_by)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    [
                        $farmId,
                        Validation::sanitizeString($animalId),
                        $animalType !== '' ? Validation::sanitizeString($animalType) : null,
                        $treatmentDate,
                        Validation::sanitizeString($treatmentType),
                        $medication !== '' ? Validation::sanitizeString($medication) : null,
                        $dosage !== '' ? Validation::sanitizeString($dosage) : null,
                        $wd,
                        $withdrawalEndDate,
                        $notes !== '' ? Validation::sanitizeString($notes) : null,
                        'ACTIVE',
                        $userId,
                    ]
                );

                return Response::success(['id' => (int) $this->db->lastInsertId()], 'Treatment logged successfully', 201);
            }

            $rows = $this->db->query(
                'SELECT id, animal_id, animal_type, treatment_type, medication, dosage,
                        withdrawal_period_days, withdrawal_end_date, status, treatment_date, notes
                 FROM veterinary_logs
                 WHERE farm_id = ?
                 ORDER BY created_at DESC, id DESC
                 LIMIT 50',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list veterinary logs', ['error' => $e->getMessage()]);
            return Response::error('Failed to list veterinary logs', 'VETERINARY_LOGS_ERROR', 500);
        }
    }

    public function vaccinations(): Response
    {
        try {
            $auth = $this->authorizePermission($this->request->getMethod() === 'GET' ? 'livestock.read' : 'livestock.update');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();

            if ($this->request->getMethod() === 'POST') {
                $userId = $this->getUserId();
                if (!$userId) {
                    return Response::unauthorized();
                }

                $input = $this->request->getBody();
                $vaccineName = trim((string) ($input['vaccine_name'] ?? ''));
                $batchId = trim((string) ($input['batch_id'] ?? ''));
                $targetAgeDays = $input['target_age_days'] ?? 0;
                $scheduledDate = trim((string) ($input['scheduled_date'] ?? ''));
                $status = trim((string) ($input['status'] ?? 'scheduled'));

                $errors = [];
                if ($vaccineName === '') {
                    $errors['vaccine_name'] = 'Vaccine name is required';
                }
                if ($batchId === '') {
                    $errors['batch_id'] = 'Batch ID is required';
                }
                if (!is_numeric($targetAgeDays) || (int) $targetAgeDays < 0) {
                    $errors['target_age_days'] = 'Target age days must be 0 or greater';
                }
                if (!Validation::validateDate($scheduledDate, 'Y-m-d')) {
                    $errors['scheduled_date'] = 'Valid scheduled date is required';
                }
                $statusNorm = strtolower($status);
                if (!Validation::validateEnum($statusNorm, ['scheduled', 'completed', 'missed', 'cancelled'])) {
                    $errors['status'] = 'Status must be scheduled, completed, missed, or cancelled';
                }
                if (!empty($errors)) {
                    return Response::validationError($errors);
                }

                $this->db->execute(
                    'INSERT INTO veterinary_vaccinations (farm_id, vaccine_name, batch_id, target_age_days, scheduled_date, status, created_by)
                     VALUES (?, ?, ?, ?, ?, ?, ?)',
                    [
                        $farmId,
                        Validation::sanitizeString($vaccineName),
                        Validation::sanitizeString($batchId),
                        (int) $targetAgeDays,
                        $scheduledDate,
                        $statusNorm,
                        $userId,
                    ]
                );

                return Response::success(['id' => (int) $this->db->lastInsertId()], 'Vaccination scheduled successfully', 201);
            }

            $rows = $this->db->query(
                'SELECT id, vaccine_name, batch_id, target_age_days, scheduled_date, status
                 FROM veterinary_vaccinations
                 WHERE farm_id = ?
                 ORDER BY scheduled_date ASC, id ASC
                 LIMIT 50',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list veterinary vaccinations', ['error' => $e->getMessage()]);
            return Response::error('Failed to list veterinary vaccinations', 'VETERINARY_VACCINATIONS_ERROR', 500);
        }
    }

    public function updateLogStatus(int $id): Response
    {
        try {
            $auth = $this->authorizePermission('livestock.update');
            if ($auth !== true) {
                return $auth;
            }

            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $input = $this->request->getBody();
            $status = strtoupper(trim((string) ($input['status'] ?? '')));

            if (!Validation::validateEnum($status, ['ACTIVE', 'CLEARED', 'CANCELLED'])) {
                return Response::validationError(['status' => 'Status must be ACTIVE, CLEARED, or CANCELLED']);
            }

            $row = $this->db->queryOne('SELECT id FROM veterinary_logs WHERE id = ? AND farm_id = ? LIMIT 1', [$id, $farmId]);
            if (!$row) {
                return Response::notFound('Log not found');
            }

            $this->db->execute('UPDATE veterinary_logs SET status = ? WHERE id = ?', [$status, $id]);
            return Response::success(['ok' => true]);
        } catch (\Exception $e) {
            Logger::error('Failed to update veterinary log status', ['error' => $e->getMessage()]);
            return Response::error('Failed to update log status', 'VETERINARY_LOG_STATUS_ERROR', 500);
        }
    }

    public function withdrawals(): Response
    {
        try {
            $auth = $this->authorizePermission('livestock.read');
            if ($auth !== true) {
                return $auth;
            }

            $this->ensureTables();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT animal_id, withdrawal_end_date AS end_date,
                        DATEDIFF(withdrawal_end_date, CURDATE()) AS days_remaining
                 FROM veterinary_logs
                 WHERE farm_id = ?
                   AND withdrawal_end_date IS NOT NULL
                   AND withdrawal_end_date >= CURDATE()
                 ORDER BY withdrawal_end_date ASC, id ASC',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list veterinary withdrawals', ['error' => $e->getMessage()]);
            return Response::error('Failed to list veterinary withdrawals', 'VETERINARY_WITHDRAWALS_ERROR', 500);
        }
    }
}
