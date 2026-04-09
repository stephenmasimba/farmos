<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class BreedingController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
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
        $input = $this->request->getBody();
        if (!empty($input['farm_id'])) {
            return (int) $input['farm_id'];
        }

        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS breeding_records (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                animal_id VARCHAR(100) NOT NULL,
                breeding_date DATE NOT NULL,
                expected_birth_date DATE NOT NULL,
                status VARCHAR(30) NOT NULL DEFAULT "Pregnant",
                notes TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_breeding_farm (farm_id, breeding_date)
            )'
        );
    }

    public function index(): Response
    {
        try {
            if (!$this->getUserId()) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $farmId = $this->getFarmId();
            $rows = $this->db->query(
                'SELECT animal_id, breeding_date, expected_birth_date, status, notes
                 FROM breeding_records
                 WHERE farm_id = ?
                 ORDER BY breeding_date DESC, id DESC
                 LIMIT 200',
                [$farmId]
            );

            return Response::success($rows);
        } catch (\Exception $e) {
            Logger::error('Failed to list breeding records', ['error' => $e->getMessage()]);
            return Response::error('Failed to fetch breeding records', 'BREEDING_LIST_ERROR', 500);
        }
    }

    public function store(): Response
    {
        try {
            $userId = $this->getUserId();
            if (!$userId) {
                return Response::unauthorized();
            }

            $this->ensureTable();
            $input = $this->request->getBody();
            $farmId = $this->getFarmId();

            $animalId = trim((string) ($input['animal_id'] ?? ''));
            $breedingDate = (string) ($input['breeding_date'] ?? '');
            $expectedBirthDate = (string) ($input['expected_birth_date'] ?? '');
            $status = trim((string) ($input['status'] ?? 'Pregnant'));
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($animalId === '') {
                $errors['animal_id'] = 'Animal ID is required';
            }
            if (!Validation::validateDate($breedingDate, 'Y-m-d')) {
                $errors['breeding_date'] = 'Breeding date is required';
            }
            if (!Validation::validateDate($expectedBirthDate, 'Y-m-d')) {
                $errors['expected_birth_date'] = 'Expected birth date is required';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO breeding_records (farm_id, animal_id, breeding_date, expected_birth_date, status, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    Validation::sanitizeString($animalId),
                    $breedingDate,
                    $expectedBirthDate,
                    Validation::sanitizeString($status),
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    $userId,
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Breeding record created successfully', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create breeding record', ['error' => $e->getMessage()]);
            return Response::error('Failed to create breeding record', 'BREEDING_CREATE_ERROR', 500);
        }
    }
}
