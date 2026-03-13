<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * Livestock Model - Represents an animal in the farming system
 */
class Livestock extends Model
{
    protected static string $table = 'livestock';

    protected static array $fillable = [
        'farm_id',
        'name',
        'species',
        'breed',
        'birth_date',
        'gender',
        'weight',
        'weight_unit',
        'status',
        'acquisition_date',
        'acquisition_cost',
        'notes',
        'photo_url',
        'tag_number',
        'microchip_id',
    ];

    protected static array $casts = [
        'id' => 'int',
        'farm_id' => 'int',
        'birth_date' => 'datetime',
        'acquisition_date' => 'datetime',
        'weight' => 'float',
        'acquisition_cost' => 'float',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected static array $hidden = [];

    /**
     * Get all livestock for a farm
     */
    public static function byFarm(int $farmId, Database $db, int $limit = 100, int $offset = 0): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? ORDER BY name ASC LIMIT ? OFFSET ?',
            [$farmId, $limit, $offset]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get livestock by status
     */
    public static function byStatus(int $farmId, string $status, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND status = ? ORDER BY name ASC',
            [$farmId, $status]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get livestock by species
     */
    public static function bySpecies(int $farmId, string $species, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND species = ? ORDER BY name ASC',
            [$farmId, $species]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get all active livestock for a farm
     */
    public static function activeFarm(int $farmId, Database $db): array
    {
        return self::byStatus($farmId, 'active', $db);
    }

    /**
     * Count livestock by farm
     */
    public static function countByFarm(int $farmId, Database $db): int
    {
        $result = $db->queryOne(
            'SELECT COUNT(*) as count FROM ' . self::$table . ' WHERE farm_id = ?',
            [$farmId]
        );
        return $result['count'] ?? 0;
    }

    /**
     * Count by status
     */
    public static function countByStatus(int $farmId, string $status, Database $db): int
    {
        $result = $db->queryOne(
            'SELECT COUNT(*) as count FROM ' . self::$table . ' WHERE farm_id = ? AND status = ?',
            [$farmId, $status]
        );
        return $result['count'] ?? 0;
    }

    /**
     * Get livestock events
     */
    public function getEvents(Database $db): array
    {
        $events = $db->query(
            'SELECT * FROM animal_events WHERE livestock_id = ? ORDER BY date DESC',
            [$this->attributes['id'] ?? null]
        );
        return $events;
    }

    /**
     * Add event to livestock
     */
    public function addEvent(Database $db, string $eventType, string $description, string $date = null): bool
    {
        $date = $date ?: date('Y-m-d H:i:s');

        return (bool) $db->execute(
            'INSERT INTO animal_events (livestock_id, event_type, description, date) VALUES (?, ?, ?, ?)',
            [$this->attributes['id'], $eventType, $description, $date]
        );
    }

    /**
     * Get livestock age in years
     */
    public function getAge(): ?float
    {
        $birthDate = $this->attributes['birth_date'] ?? null;
        if (!$birthDate) {
            return null;
        }

        $now = new \DateTime();
        $birth = new \DateTime($birthDate);
        $interval = $now->diff($birth);

        return $interval->y + ($interval->m / 12);
    }

    /**
     * Get livestock reference for logging
     */
    public function reference(): string
    {
        return "[Livestock #{$this->attributes['id']} {$this->attributes['name']} ({$this->attributes['species']})]";
    }

    /**
     * Check if livestock is active
     */
    public function isActive(): bool
    {
        return $this->attributes['status'] === 'active';
    }

    /**
     * Update status
     */
    public function updateStatus(string $newStatus): void
    {
        $this->attributes['status'] = $newStatus;
        $this->attributes['updated_at'] = date('Y-m-d H:i:s');
        $this->update();
    }

    /**
     * Get full profile with events
     */
    public function getFullProfile(Database $db): array
    {
        $profile = $this->toArray();
        $profile['age_years'] = $this->getAge();
        $profile['events'] = $this->getEvents($db);
        $profile['total_events'] = count($profile['events']);

        return $profile;
    }
}
