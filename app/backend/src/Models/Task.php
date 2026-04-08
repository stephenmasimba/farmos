<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * Task Model - Farm task/todo tracking
 */
class Task extends Model
{
    protected static string $table = 'tasks';
    protected static array $fillable = [
        'farm_id', 'title', 'description', 'assigned_to', 'status', 'priority',
        'due_date', 'completed_at', 'created_by'
    ];

    public function __construct(Database $db, array $attributes = [])
    {
        parent::__construct($db, $attributes);
    }

    /**
     * Get tasks by farm
     */
    public static function byFarm(int $farmId, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->get();
    }

    /**
     * Get tasks by status
     */
    public static function byStatus(int $farmId, string $status, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('status', $status)
            ->get();
    }

    /**
     * Get tasks by priority
     */
    public static function byPriority(int $farmId, string $priority, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('priority', $priority)
            ->get();
    }

    /**
     * Get tasks assigned to user
     */
    public static function byAssignedTo(int $farmId, int $userId, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('assigned_to', $userId)
            ->get();
    }

    /**
     * Get pending tasks for farm
     */
    public static function pending(int $farmId, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('status', 'pending')
            ->orderBy('priority', 'DESC')
            ->orderBy('due_date', 'ASC')
            ->get();
    }

    /**
     * Get overdue tasks
     */
    public static function overdue(int $farmId, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('status !=', 'completed')
            ->where('due_date <', date('Y-m-d'))
            ->orderBy('due_date', 'ASC')
            ->get();
    }

    /**
     * Get tasks due within days
     */
    public static function dueWithin(int $farmId, int $days, Database $db): array
    {
        $futureDate = date('Y-m-d', strtotime("+$days days"));

        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('status !=', 'completed')
            ->where('due_date <=', $futureDate)
            ->where('due_date >=', date('Y-m-d'))
            ->orderBy('due_date', 'ASC')
            ->get();
    }

    /**
     * Get task statistics for farm
     */
    public static function getStats(int $farmId, Database $db): array
    {
        $result = $db->query(
            'SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END) as completed,
                SUM(CASE WHEN status = "in_progress" THEN 1 ELSE 0 END) as in_progress,
                SUM(CASE WHEN status = "pending" THEN 1 ELSE 0 END) as pending,
                SUM(CASE WHEN status = "cancelled" THEN 1 ELSE 0 END) as cancelled,
                SUM(CASE WHEN status != "completed" AND due_date < CURDATE() THEN 1 ELSE 0 END) as overdue,
                SUM(CASE WHEN priority = "critical" AND status != "completed" THEN 1 ELSE 0 END) as critical_pending
            FROM ' . static::table() . '
            WHERE farm_id = ?',
            [$farmId]
        );

        return $result[0] ?? [
            'total' => 0,
            'completed' => 0,
            'in_progress' => 0,
            'pending' => 0,
            'cancelled' => 0,
            'overdue' => 0,
            'critical_pending' => 0,
        ];
    }

    /**
     * Get tasks by priority for farm
     */
    public static function byPriorityCount(int $farmId, Database $db): array
    {
        return $db->query(
            'SELECT priority, COUNT(*) as count 
             FROM ' . static::table() . ' 
             WHERE farm_id = ? AND status != "completed"
             GROUP BY priority',
            [$farmId]
        );
    }

    /**
     * Complete task
     */
    public function complete(): self
    {
        $this->status = 'completed';
        $this->completed_at = date('Y-m-d H:i:s');
        $this->save();
        return $this;
    }

    /**
     * Check if task is overdue
     */
    public function isOverdue(): bool
    {
        return $this->status !== 'completed' &&
               $this->due_date &&
               strtotime($this->due_date) < time();
    }

    /**
     * Check if task is due soon (within 3 days)
     */
    public function isDueSoon(): bool
    {
        if (!$this->due_date || $this->status === 'completed') {
            return false;
        }

        $dueTime = strtotime($this->due_date);
        $now = time();
        $threeAgo = strtotime('+3 days');

        return $dueTime >= $now && $dueTime <= $threeAgo;
    }

    /**
     * Get full profile with relationships
     */
    public function getFullProfile(): array
    {
        return [
            'id' => $this->id,
            'farm_id' => $this->farm_id,
            'title' => $this->title,
            'description' => $this->description,
            'assigned_to' => $this->assigned_to,
            'status' => $this->status,
            'priority' => $this->priority,
            'due_date' => $this->due_date,
            'completed_at' => $this->completed_at,
            'created_by' => $this->created_by,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'indicators' => [
                'is_overdue' => $this->isOverdue(),
                'is_due_soon' => $this->isDueSoon(),
                'is_completed' => $this->status === 'completed',
            ],
        ];
    }

    /**
     * Get table name
     */
    public static function table(): string
    {
        return static::$table;
    }

    /**
     * Get fillable fields
     */
    public static function fillable(): array
    {
        return static::$fillable;
    }
}
