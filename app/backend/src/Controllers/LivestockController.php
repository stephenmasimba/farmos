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

            if ($date && !Validation::validateDate($date, 'Y-m-d H:i:s')) {
                if (!Validation::validateDate($date, 'Y-m-d')) {
                    return Response::validationError(['date' => 'Invalid date format']);
                }
                $date = $date . ' 00:00:00';
            }

            $livestock->addEvent($this->db, $eventType, $description, $date);

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
}
