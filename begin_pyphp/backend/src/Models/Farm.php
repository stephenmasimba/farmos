<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * Farm Model - Represents a farm in the system
 */
class Farm extends Model
{
    protected static string $table = 'farms';
    
    protected static array $fillable = [
        'owner_id',
        'name',
        'location',
        'city',
        'state',
        'country',
        'zip_code',
        'latitude',
        'longitude',
        'size',
        'size_unit',
        'type',
        'established_year',
        'description',
        'logo_url',
        'phone',
        'email',
    ];

    protected static array $casts = [
        'id' => 'int',
        'owner_id' => 'int',
        'size' => 'float',
        'established_year' => 'int',
        'latitude' => 'float',
        'longitude' => 'float',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected static array $hidden = [];

    /**
     * Find farm by owner
     */
    public static function byOwner(int $ownerId, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE owner_id = ? ORDER BY name ASC',
            [$ownerId]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Find farms by type
     */
    public static function byType(string $type, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE type = ? ORDER BY name ASC',
            [$type]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get all livestock on farm
     */
    public function getLivestock(Database $db, string $status = null): array
    {
        if ($status) {
            return Livestock::byStatus($this->attributes['id'], $status, $db);
        }
        return Livestock::byFarm($this->attributes['id'], $db);
    }

    /**
     * Get livestock count
     */
    public function livestockCount(Database $db): int
    {
        return Livestock::countByFarm($this->attributes['id'], $db);
    }

    /**
     * Get farm reference for logging
     */
    public function reference(): string
    {
        return "[Farm #{$this->attributes['id']} {$this->attributes['name']}]";
    }

    /**
     * Get full profile with statistics
     */
    public function getFullProfile(Database $db): array
    {
        $profile = $this->toArray();
        $profile['livestock_count'] = $this->livestockCount($db);
        $profile['livestock_active'] = Livestock::countByStatus($this->attributes['id'], 'active', $db);
        
        return $profile;
    }
}
