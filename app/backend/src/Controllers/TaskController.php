<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation
};
use FarmOS\Models\Task;

/**
 * TaskController - Manages farm tasks and todos
 */
class TaskController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    /**
     * List tasks
     * GET /api/tasks?farm_id={id}&status={status}&priority={priority}&page={page}
     */
    public function index(): Response
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

            // Pagination
            $page = (int) ($this->request->getQuery()['page'] ?? 1);
            $perPage = (int) ($this->request->getQuery()['per_page'] ?? 15);
            $page = max(1, $page);
            $perPage = min($perPage, 100);

            // Filters
            $status = $this->request->getQuery()['status'] ?? null;
            $priority = $this->request->getQuery()['priority'] ?? null;
            $assigned = $this->request->getQuery()['assigned_to'] ?? null;

            $query = Task::query($this->db)
                ->where('farm_id', $farmId);

            if ($status) {
                if (!Validation::validateEnum($status, ['pending', 'in_progress', 'completed', 'cancelled'])) {
                    return Response::validationError(['status' => 'Invalid status']);
                }
                $query->where('status', $status);
            } else {
                // Default: exclude completed and cancelled
                $query->where('status !=', 'completed');
                $query->where('status !=', 'cancelled');
            }

            if ($priority) {
                if (!Validation::validateEnum($priority, ['low', 'medium', 'high', 'critical'])) {
                    return Response::validationError(['priority' => 'Invalid priority']);
                }
                $query->where('priority', $priority);
            }

            if ($assigned) {
                $assigned = (int) $assigned;
                if ($assigned > 0) {
                    $query->where('assigned_to', $assigned);
                }
            }

            $result = $query
                ->orderBy('priority', 'DESC')
                ->orderBy('due_date', 'ASC')
                ->paginate($page, $perPage);

            Logger::info('Listed tasks', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'count' => count($result['data']),
            ]);

            return Response::success([
                'tasks' => array_map(fn($m) => $m->getFullProfile(), $result['data']),
                'pagination' => [
                    'page' => $result['page'],
                    'per_page' => $result['per_page'],
                    'total' => $result['total'],
                    'last_page' => $result['last_page'],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to list tasks', ['error' => $e->getMessage()]);
            return Response::error('Failed to list tasks', 'LIST_ERROR', 500);
        }
    }

    /**
     * Create task
     * POST /api/tasks
     */
    public function store(): Response
    {
        try {
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
            if (empty($input['title'])) {
                $errors['title'] = 'Title is required';
            }
            if (empty($input['priority'])) {
                $errors['priority'] = 'Priority is required';
            }

            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            // Validate and sanitize
            if (!Validation::validateEnum($input['priority'], ['low', 'medium', 'high', 'critical'])) {
                return Response::validationError(['priority' => 'Invalid priority']);
            }

            $input['title'] = Validation::sanitizeString($input['title']);
            $input['description'] = Validation::sanitizeString($input['description'] ?? '');
            $input['status'] = 'pending';
            $input['created_by'] = $user['user_id'];

            // Validate due date if provided
            if (!empty($input['due_date'])) {
                if (!Validation::validateDate($input['due_date'], 'Y-m-d')) {
                    if (!Validation::validateDate($input['due_date'], 'Y-m-d H:i:s')) {
                        return Response::validationError(['due_date' => 'Invalid date format']);
                    }
                } else {
                    $input['due_date'] = $input['due_date'] . ' 23:59:59';
                }
            }

            // Validate assigned_to if provided
            if (!empty($input['assigned_to'])) {
                $input['assigned_to'] = (int) $input['assigned_to'];
                if ($input['assigned_to'] <= 0) {
                    unset($input['assigned_to']);
                }
            }

            // Create task
            $task = new Task($this->db, array_filter($input, fn($k) => in_array($k, Task::fillable()), ARRAY_FILTER_USE_KEY));
            $taskId = $task->save();

            Logger::info('Created task', [
                'user_id' => $user['user_id'],
                'task_id' => $taskId,
                'farm_id' => $input['farm_id'],
                'title' => $input['title'],
            ]);

            return Response::success(
                array_merge($task->toArray(), ['id' => $taskId]),
                'Task created successfully',
                201
            );
        } catch (\Exception $e) {
            Logger::error('Failed to create task', ['error' => $e->getMessage()]);
            return Response::error('Failed to create task', 'CREATE_ERROR', 500);
        }
    }

    /**
     * Get task details
     * GET /api/tasks/{id}
     */
    public function show(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $task = Task::find($id, $this->db);
            if (!$task) {
                return Response::notFound('Task not found');
            }

            Logger::info('Retrieved task', [
                'user_id' => $user['user_id'],
                'task_id' => $id,
            ]);

            return Response::success($task->getFullProfile());
        } catch (\Exception $e) {
            Logger::error('Failed to retrieve task', ['error' => $e->getMessage()]);
            return Response::error('Failed to retrieve task', 'RETRIEVE_ERROR', 500);
        }
    }

    /**
     * Update task
     * PUT /api/tasks/{id}
     */
    public function update(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $task = Task::find($id, $this->db);
            if (!$task) {
                return Response::notFound('Task not found');
            }

            $input = $this->request->getBody();

            // Update allowed fields
            if (!empty($input['title'])) {
                $task->title = Validation::sanitizeString($input['title']);
            }
            if (!empty($input['description'])) {
                $task->description = Validation::sanitizeString($input['description']);
            }
            if (!empty($input['priority'])) {
                if (!Validation::validateEnum($input['priority'], ['low', 'medium', 'high', 'critical'])) {
                    return Response::validationError(['priority' => 'Invalid priority']);
                }
                $task->priority = $input['priority'];
            }
            if (isset($input['status'])) {
                if (!Validation::validateEnum($input['status'], ['pending', 'in_progress', 'completed', 'cancelled'])) {
                    return Response::validationError(['status' => 'Invalid status']);
                }
                $task->status = $input['status'];

                if ($input['status'] === 'completed') {
                    $task->completed_at = date('Y-m-d H:i:s');
                } elseif ($input['status'] !== 'completed' && $task->completed_at) {
                    $task->completed_at = null;
                }
            }
            if (!empty($input['due_date'])) {
                if (!Validation::validateDate($input['due_date'], 'Y-m-d')) {
                    if (!Validation::validateDate($input['due_date'], 'Y-m-d H:i:s')) {
                        return Response::validationError(['due_date' => 'Invalid date format']);
                    }
                } else {
                    $input['due_date'] = $input['due_date'] . ' 23:59:59';
                }
                $task->due_date = $input['due_date'];
            }
            if (isset($input['assigned_to'])) {
                $input['assigned_to'] = empty($input['assigned_to']) ? null : (int) $input['assigned_to'];
                $task->assigned_to = $input['assigned_to'];
            }

            $task->updated_at = date('Y-m-d H:i:s');
            $task->save();

            Logger::info('Updated task', [
                'user_id' => $user['user_id'],
                'task_id' => $id,
                'status' => $input['status'] ?? null,
            ]);

            return Response::success($task->getFullProfile(), 'Task updated successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to update task', ['error' => $e->getMessage()]);
            return Response::error('Failed to update task', 'UPDATE_ERROR', 500);
        }
    }

    /**
     * Delete task
     * DELETE /api/tasks/{id}
     */
    public function destroy(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $affected = Task::destroy($id, $this->db);
            if (!$affected) {
                return Response::notFound('Task not found');
            }

            Logger::info('Deleted task', [
                'user_id' => $user['user_id'],
                'task_id' => $id,
            ]);

            return Response::success(['id' => $id], 'Task deleted successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to delete task', ['error' => $e->getMessage()]);
            return Response::error('Failed to delete task', 'DELETE_ERROR', 500);
        }
    }

    /**
     * Assign task to user
     * POST /api/tasks/{id}/assign
     */
    public function assign(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $task = Task::find($id, $this->db);
            if (!$task) {
                return Response::notFound('Task not found');
            }

            $input = $this->request->getBody();

            if (!isset($input['assigned_to'])) {
                return Response::validationError(['assigned_to' => 'User ID is required']);
            }

            $userId = empty($input['assigned_to']) ? null : (int) $input['assigned_to'];
            $task->assigned_to = $userId;
            $task->save();

            Logger::info('Assigned task', [
                'user_id' => $user['user_id'],
                'task_id' => $id,
                'assigned_to' => $userId,
            ]);

            return Response::success($task->getFullProfile(), 'Task assigned successfully');
        } catch (\Exception $e) {
            Logger::error('Failed to assign task', ['error' => $e->getMessage()]);
            return Response::error('Failed to assign task', 'ASSIGN_ERROR', 500);
        }
    }

    /**
     * Complete task
     * POST /api/tasks/{id}/complete
     */
    public function complete(int $id): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $task = Task::find($id, $this->db);
            if (!$task) {
                return Response::notFound('Task not found');
            }

            if ($task->status === 'completed') {
                return Response::error('Task is already completed', 'ALREADY_COMPLETED', 400);
            }

            $task->complete();

            Logger::info('Completed task', [
                'user_id' => $user['user_id'],
                'task_id' => $id,
            ]);

            return Response::success($task->getFullProfile(), 'Task marked as completed');
        } catch (\Exception $e) {
            Logger::error('Failed to complete task', ['error' => $e->getMessage()]);
            return Response::error('Failed to complete task', 'COMPLETE_ERROR', 500);
        }
    }

    /**
     * Get task statistics
     * GET /api/tasks/stats?farm_id={id}
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

            $stats = Task::getStats($farmId, $this->db);
            $byPriority = Task::byPriorityCount($farmId, $this->db);
            $overdue = Task::overdue($farmId, $this->db);
            $dueSoon = Task::dueWithin($farmId, 3, $this->db);

            Logger::info('Retrieved task statistics', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success([
                'summary' => $stats,
                'by_priority' => $byPriority,
                'overdue_count' => count($overdue),
                'due_soon_count' => count($dueSoon),
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get task statistics', ['error' => $e->getMessage()]);
            return Response::error('Failed to get statistics', 'STATS_ERROR', 500);
        }
    }
}
