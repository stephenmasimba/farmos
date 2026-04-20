<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation, RateLimiter
};
use FarmOS\Models\Livestock;

/**
 * LivestockController - Manages farm animal records
 * Handles CRUD operations and related queries
 */
class LivestockController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    private function ensureAnimalEventsTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS animal_events (
                id INT AUTO_INCREMENT PRIMARY KEY,
                livestock_id INT NOT NULL,
                event_type VARCHAR(100) NOT NULL,
                description TEXT NOT NULL,
                date DATETIME NOT NULL,
                cost DECIMAL(10,2) NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_animal_events_livestock (livestock_id, date),
                INDEX idx_animal_events_type (event_type)
            )'
        );

        try {
            $this->db->execute('ALTER TABLE animal_events ADD COLUMN cost DECIMAL(10,2) NULL DEFAULT 0');
        } catch (\Throwable $e) {
        }
    }

    /**
     * List livestock for a farm
     * GET /api/livestock?farm_id={id}&page={page}&per_page={per_page}&status={status}&species={species}
     */
    public function index(): Response
    {
        try {
            // Get current user
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            // Get farm_id from query
            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            // Pagination
            $page = (int) ($this->request->getQuery()['page'] ?? 1);
            $perPage = (int) ($this->request->getQuery()['per_page'] ?? 15);
            $page = max(1, $page);
            $perPage = min($perPage, 100); // Max 100 per page

            // Filters
            $status = $this->request->getQuery()['status'] ?? null;
            $species = $this->request->getQuery()['species'] ?? null;

            // Get livestock
            $query = Livestock::query($this->db)
                ->where('farm_id', $farmId);

            if ($status) {
                if (!Validation::validateEnum($status, ['active', 'sold', 'deceased', 'quarantine'])) {
                    return Response::validationError(['status' => 'Invalid status']);
                }
                $query->where('status', $status);
            }

            if ($species) {
                $species = Validation::sanitizeString($species);
                $query->where('species', $species);
            }

            // Paginate
            $result = $query
                ->orderBy('created_at', 'DESC')
                ->paginate($page, $perPage);

            Logger::info('Listed livestock', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'count' => count($result['data']),
                'page' => $page,
            ]);

            return Response::success([
                'livestock' => array_map(fn($m) => $m->toArray(), $result['data']),
                'pagination' => [
                    'page' => $result['page'],
                    'per_page' => $result['per_page'],
                    'total' => $result['total'],
                    'last_page' => $result['last_page'],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to list livestock', ['error' => $e->getMessage()]);
            return Response::error('Failed to list livestock', 'LIST_ERROR', 500);
        }
    }

    /**
     * Create new livestock
     * POST /api/livestock
     */
    public function store(): Response
    {
        try {
            // Get current user
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $input = $this->request->getBody();

            // Validate required fields
            $errors = [];
            if (empty($input['farm_id'])) {
                $errors['farm_id'] = 'Farm ID is required';
            }
            if (empty($input['name'])) {
                $errors['name'] = 'Animal name is required';
            }
            if (empty($input['species'])) {
                $errors['species'] = 'Species is required';
            }

            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            // Validate data
            $input['name'] = Validation::sanitizeString($input['name']);
            $input['species'] = Validation::sanitizeString($input['species']);
            $input['breed'] = Validation::sanitizeString($input['breed'] ?? '');

            if (!empty($input['birth_date'])) {
                if (!Validation::validateDate($input['birth_date'], 'Y-m-d')) {
                    return Response::validationError(['birth_date' => 'Invalid date format (YYYY-MM-DD)']);
                }
            }

            if (!empty($input['acquisition_date'])) {
                if (!Validation::validateDate($input['acquisition_date'], 'Y-m-d')) {
                    return Response::validationError(['acquisition_date' => 'Invalid date format (YYYY-MM-DD)']);
                }
            }

            if (!empty($input['weight'])) {
                if (!is_numeric($input['weight']) || $input['weight'] < 0) {
                    return Response::validationError(['weight' => 'Weight must be a positive number']);
                }
            }

            if (!empty($input['acquisition_cost'])) {
                if (!is_numeric($input['acquisition_cost']) || $input['acquisition_cost'] < 0) {
                    return Response::validationError(['acquisition_cost' => 'Cost must be a positive number']);
                }
            }

            // Validate status if provided
            $input['status'] = $input['status'] ?? 'active';
            if (!Validation::validateEnum($input['status'], ['active', 'sold', 'deceased', 'quarantine'])) {
                return Response::validationError(['status' => 'Invalid status']);
            }

            // Create livestock
            $livestock = new Livestock($this->db, array_filter($input, fn($k) => in_array($k, Livestock::fillable()), ARRAY_FILTER_USE_KEY));
            $livestockId = $livestock->save();

            Logger::info('Created livestock', [
                'user_id' => $user['user_id'],
                'livestock_id' => $livestockId,
                'farm_id' => $input['farm_id'],
                'name' => $input['name'],
            ]);

            return Response::success(
                array_merge($livestock->toArray(), ['id' => $livestockId]),
                'Livestock created successfully',
                201
            );
        } catch (\Exception $e) {
            Logger::error('Failed to create livestock', ['error' => $e->getMessage()]);
            return Response::error('Failed to create livestock', 'CREATE_ERROR', 500);
        }
    }

    /**
     * Get livestock details
     * GET /api/livestock/{id}
     */
    public function show(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $livestock = Livestock::find($id, $this->db);
            if (!$livestock) {
                return Response::notFound('Livestock not found');
            }

            Logger::info('Retrieved livestock', [
                'user_id' => $user['user_id'],
                'livestock_id' => $id,
            ]);

            return Response::success($livestock->getFullProfile($this->db));
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve livestock', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve livestock', 'RETRIEVE_ERROR', 500);
        }
    }

    /**
     * Update livestock
     * PUT /api/livestock/{id}
     */
    public function update(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $livestock = Livestock::find($id, $this->db);
            if (!$livestock) {
                return Response::notFound('Livestock not found');
            }

            $input = $this->request->getBody();

            // Validate and sanitize input
            if (!empty($input['name'])) {
                $livestock->name = Validation::sanitizeString($input['name']);
            }
            if (!empty($input['breed'])) {
                $livestock->breed = Validation::sanitizeString($input['breed']);
            }
            if (isset($input['status'])) {
                if (!Validation::validateEnum($input['status'], ['active', 'sold', 'deceased', 'quarantine'])) {
                    return Response::validationError(['status' => 'Invalid status']);
                }
                $livestock->status = $input['status'];
            }
            if (isset($input['weight'])) {
                if (!is_numeric($input['weight']) || $input['weight'] < 0) {
                    return Response::validationError(['weight' => 'Weight must be a positive number']);
                }
                $livestock->weight = (float) $input['weight'];
            }
            if (!empty($input['notes'])) {
                $livestock->notes = Validation::sanitizeString($input['notes']);
            }

            $livestock->updated_at = date('Y-m-d H:i:s');
            $livestock->save();

            Logger::info('Updated livestock', [
                'user_id' => $user['user_id'],
                'livestock_id' => $id,
                'fields' => array_keys($input),
            ]);

            return Response::success($livestock->toArray(), 'Livestock updated successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to update livestock', ['error' => $e->getMessage()]);
            return Response::error('Failed to update livestock', 'UPDATE_ERROR', 500);
        }
    }

    /**
     * Delete livestock
     * DELETE /api/livestock/{id}
     */
    public function destroy(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $livestock = Livestock::find($id, $this->db);
            if (!$livestock) {
                return Response::notFound('Livestock not found');
            }

            Livestock::destroy($id, $this->db);
            Logger::info('Deleted livestock', [
                'user_id' => $user['user_id'],
                'livestock_id' => $id,
            ]);

            return Response::success(['id' => $id], 'Livestock deleted successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to delete livestock', ['error' => $e->getMessage()]);
            return Response::error('Failed to delete livestock', 'DELETE_ERROR', 500);
        }
    }

    /**
     * Get livestock events
     * GET /api/livestock/{id}/events
     */
    public function getEvents(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $livestock = Livestock::find($id, $this->db);
            if (!$livestock) {
                return Response::notFound('Livestock not found');
            }

            $this->ensureAnimalEventsTable();
            $events = $livestock->getEvents($this->db);

            Logger::info('Retrieved livestock events', [
                'user_id' => $user['user_id'],
                'livestock_id' => $id,
                'event_count' => count($events),
            ]);

            return Response::success(['events' => $events]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve livestock events', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve livestock events', 'RETRIEVE_ERROR', 500);
        }
    }

    /**
     * Add event to livestock
     * POST /api/livestock/{id}/events
     */
    public function addEvent(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $livestock = Livestock::find($id, $this->db);
            if (!$livestock) {
                return Response::notFound('Livestock not found');
            }

            $input = $this->request->getBody();

            // Validate
            if (empty($input['event_type'])) {
                return Response::validationError(['event_type' => 'Event type is required']);
            }
            if (empty($input['description'])) {
                return Response::validationError(['description' => 'Description is required']);
            }

            $eventType = Validation::sanitizeString($input['event_type']);
            $description = Validation::sanitizeString($input['description']);
            $date = $input['date'] ?? null;
            $cost = null;
            if (isset($input['cost']) && $input['cost'] !== '') {
                if (!is_numeric($input['cost']) || (float) $input['cost'] < 0) {
                    return Response::validationError(['cost' => 'Cost must be a positive number']);
                }
                $cost = (float) $input['cost'];
            }

            if ($date && !Validation::validateDate($date, 'Y-m-d H:i:s')) {
                if (!Validation::validateDate($date, 'Y-m-d')) {
                    return Response::validationError(['date' => 'Invalid date format']);
                }
                $date = $date . ' 00:00:00';
            }

            $this->ensureAnimalEventsTable();
            $livestock->addEvent($this->db, $eventType, $description, $date, $cost);

            Logger::info('Added livestock event', [
                'user_id' => $user['user_id'],
                'livestock_id' => $id,
                'event_type' => $eventType,
            ]);

            return Response::success(['message' => 'Event added successfully'], 'Event added', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to add livestock event', ['error' => $e->getMessage()]);
            return Response::error('Failed to add livestock event', 'CREATE_ERROR', 500);
        }
    }

    /**
     * Get livestock statistics
     * GET /api/livestock/stats?farm_id={id}
     */
    public function getStats(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $total = Livestock::countByFarm($farmId, $this->db);
            $active = Livestock::countByStatus($farmId, 'active', $this->db);
            $sold = Livestock::countByStatus($farmId, 'sold', $this->db);
            $deceased = Livestock::countByStatus($farmId, 'deceased', $this->db);
            $quarantine = Livestock::countByStatus($farmId, 'quarantine', $this->db);

            Logger::info('Retrieved livestock statistics', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'total' => $total,
                'active' => $active,
                'sold' => $sold,
                'deceased' => $deceased,
                'quarantine' => $quarantine,
                'by_status' => [
                    'active' => $active,
                    'sold' => $sold,
                    'deceased' => $deceased,
                    'quarantine' => $quarantine,
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve livestock statistics', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve statistics', 'STATS_ERROR', 500);
        }
    }

    /**
     * Get livestock cost analysis
     * GET /api/livestock/cost-analysis?farm_id={id}&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD
     */
    public function costAnalysis(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $query = $this->request->getQuery();
            $farmId = (int) ($query['farm_id'] ?? 0);
            if ($farmId <= 0) {
                return Response::validationError(['farm_id' => 'Farm ID is required']);
            }

            $startDate = Validation::sanitizeString((string) ($query['start_date'] ?? date('Y-m-d', strtotime('-30 days'))));
            $endDate = Validation::sanitizeString((string) ($query['end_date'] ?? date('Y-m-d')));

            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'Invalid date format']);
            }
            if (!Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'Invalid date format']);
            }

            $this->ensureAnimalEventsTable();

            $acquisition = $this->db->queryOne(
                'SELECT
                    COUNT(*) AS livestock_count,
                    COALESCE(SUM(COALESCE(acquisition_cost, 0)), 0) AS acquisition_total
                 FROM ' . Livestock::table() . '
                 WHERE farm_id = ?',
                [$farmId]
            ) ?: [];

            $eventRows = $this->db->query(
                'SELECT
                    ae.event_type,
                    COUNT(*) AS event_count,
                    COALESCE(SUM(COALESCE(ae.cost, 0)), 0) AS total_cost
                 FROM animal_events ae
                 INNER JOIN ' . Livestock::table() . ' l ON l.id = ae.livestock_id
                 WHERE l.farm_id = ?
                   AND DATE(ae.date) >= ?
                   AND DATE(ae.date) <= ?
                 GROUP BY ae.event_type
                 ORDER BY total_cost DESC, event_count DESC',
                [$farmId, $startDate, $endDate]
            );

            $livestockRows = $this->db->query(
                'SELECT
                    l.id,
                    l.name,
                    l.species,
                    COUNT(ae.id) AS event_count,
                    COALESCE(SUM(COALESCE(ae.cost, 0)), 0) AS event_cost_total
                 FROM ' . Livestock::table() . ' l
                 LEFT JOIN animal_events ae
                    ON ae.livestock_id = l.id
                    AND DATE(ae.date) >= ?
                    AND DATE(ae.date) <= ?
                 WHERE l.farm_id = ?
                 GROUP BY l.id, l.name, l.species
                 ORDER BY event_cost_total DESC, event_count DESC
                 LIMIT 20',
                [$startDate, $endDate, $farmId]
            );

            $eventTotalCost = 0.0;
            $eventTotalCount = 0;
            foreach ($eventRows as $row) {
                $eventTotalCost += (float) ($row['total_cost'] ?? 0);
                $eventTotalCount += (int) ($row['event_count'] ?? 0);
            }

            $acquisitionTotal = (float) ($acquisition['acquisition_total'] ?? 0);

            return Response::success([
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ],
                'summary' => [
                    'livestock_count' => (int) ($acquisition['livestock_count'] ?? 0),
                    'acquisition_total' => $acquisitionTotal,
                    'event_cost_total' => $eventTotalCost,
                    'event_count' => $eventTotalCount,
                    'total_cost' => $acquisitionTotal + $eventTotalCost,
                ],
                'event_breakdown' => array_map(static function (array $row): array {
                    return [
                        'event_type' => (string) ($row['event_type'] ?? 'unknown'),
                        'event_count' => (int) ($row['event_count'] ?? 0),
                        'total_cost' => (float) ($row['total_cost'] ?? 0),
                    ];
                }, $eventRows),
                'livestock_breakdown' => array_map(static function (array $row): array {
                    return [
                        'id' => (int) ($row['id'] ?? 0),
                        'name' => (string) ($row['name'] ?? ''),
                        'species' => (string) ($row['species'] ?? ''),
                        'event_count' => (int) ($row['event_count'] ?? 0),
                        'event_cost_total' => (float) ($row['event_cost_total'] ?? 0),
                    ];
                }, $livestockRows),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve livestock cost analysis', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve livestock cost analysis', 'LIVESTOCK_COST_ANALYSIS_ERROR', 500);
        }
    }

    private function getFarmIdFromRequest(): int
    {
        $input = $this->request->getBody();
        if (!empty($input['farm_id'])) {
            return (int) $input['farm_id'];
        }

        $query = $this->request->getQuery();
        return (int) ($query['farm_id'] ?? 1);
    }

    private function ensureBreedingTable(): void
    {
        $this->db->execute(
            'CREATE TABLE IF NOT EXISTS livestock_breeding_records (
                id INT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                dam_batch_id INT NOT NULL,
                sire_batch_id INT NOT NULL,
                breeding_date DATE NOT NULL,
                expected_birth_date DATE NULL,
                notes TEXT NULL,
                created_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_livestock_breeding_farm (farm_id, breeding_date)
            )'
        );
    }

    public function breeding(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $this->ensureBreedingTable();
            $farmId = $this->getFarmIdFromRequest();

            if ($this->request->getMethod() === 'GET') {
                $rows = $this->db->query(
                    'SELECT dam_batch_id, sire_batch_id, breeding_date, expected_birth_date, notes
                     FROM livestock_breeding_records
                     WHERE farm_id = ?
                     ORDER BY breeding_date DESC, id DESC
                     LIMIT 200',
                    [$farmId]
                );
                return Response::success($rows);
            }

            $input = $this->request->getBody();
            $damBatchId = (int) ($input['dam_batch_id'] ?? 0);
            $sireBatchId = (int) ($input['sire_batch_id'] ?? 0);
            $breedingDate = (string) ($input['breeding_date'] ?? '');
            $expectedBirthDate = (string) ($input['expected_birth_date'] ?? '');
            $notes = trim((string) ($input['notes'] ?? ''));

            $errors = [];
            if ($damBatchId <= 0) {
                $errors['dam_batch_id'] = 'Dam batch ID is required';
            }
            if ($sireBatchId <= 0) {
                $errors['sire_batch_id'] = 'Sire batch ID is required';
            }
            if (!Validation::validateDate($breedingDate, 'Y-m-d')) {
                $errors['breeding_date'] = 'Breeding date is required';
            }
            if ($expectedBirthDate !== '' && !Validation::validateDate($expectedBirthDate, 'Y-m-d')) {
                $errors['expected_birth_date'] = 'Expected birth date is invalid';
            }
            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            $this->db->execute(
                'INSERT INTO livestock_breeding_records (farm_id, dam_batch_id, sire_batch_id, breeding_date, expected_birth_date, notes, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    $farmId,
                    $damBatchId,
                    $sireBatchId,
                    $breedingDate,
                    $expectedBirthDate !== '' ? $expectedBirthDate : null,
                    $notes !== '' ? Validation::sanitizeString($notes) : null,
                    (int) $user['user_id'],
                ]
            );

            return Response::success(['id' => (int) $this->db->lastInsertId()], 'Breeding record created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to handle livestock breeding', ['error' => $e->getMessage()]);
            return Response::error('Failed to handle breeding records', 'LIVESTOCK_BREEDING_ERROR', 500);
        }
    }

    public function addEventByBatch(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $input = $this->request->getBody();
            $batchId = (int) ($input['batch_id'] ?? 0);
            if ($batchId <= 0) {
                return Response::validationError(['batch_id' => 'Batch ID is required']);
            }

            return $this->addEvent($batchId);
        } catch (\Exception $e) {
            Logger::error('Failed to log livestock event by batch', ['error' => $e->getMessage()]);
            return Response::error('Failed to log livestock event', 'LIVESTOCK_EVENT_LOG_ERROR', 500);
        }
    }
}
