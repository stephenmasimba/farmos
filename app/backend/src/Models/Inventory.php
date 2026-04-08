<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * Inventory Model - Represents farm inventory/supplies
 */
class Inventory extends Model
{
    protected static string $table = 'inventory';

    protected static array $fillable = [
        'farm_id',
        'name',
        'category',
        'description',
        'quantity',
        'unit',
        'min_level',
        'max_level',
        'cost_per_unit',
        'supplier',
        'location',
        'expiry_date',
        'batch_number',
        'notes',
    ];

    protected static array $casts = [
        'id' => 'int',
        'farm_id' => 'int',
        'quantity' => 'float',
        'min_level' => 'float',
        'max_level' => 'float',
        'cost_per_unit' => 'float',
        'expiry_date' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected static array $hidden = [];

    /**
     * Get all inventory for a farm
     */
    public static function byFarm(int $farmId, Database $db, int $limit = 100, int $offset = 0): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? ORDER BY category ASC, name ASC LIMIT ? OFFSET ?',
            [$farmId, $limit, $offset]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get inventory by category
     */
    public static function byCategory(int $farmId, string $category, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND category = ? ORDER BY name ASC',
            [$farmId, $category]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get low stock items (below min_level)
     */
    public static function lowStock(int $farmId, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE farm_id = ? AND quantity < min_level ORDER BY name ASC',
            [$farmId]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get expiring items (within 30 days)
     */
    public static function expiringSoon(int $farmId, Database $db, int $days = 30): array
    {
        $sql = 'SELECT * FROM ' . self::$table . ' 
                WHERE farm_id = ? 
                AND expiry_date IS NOT NULL 
                AND expiry_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL ? DAY)
                ORDER BY expiry_date ASC';

        $results = $db->query($sql, [$farmId, $days]);
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get all categories
     */
    public static function categories(int $farmId, Database $db): array
    {
        $results = $db->query(
            'SELECT DISTINCT category FROM ' . self::$table . ' WHERE farm_id = ? ORDER BY category ASC',
            [$farmId]
        );
        return array_map(fn($row) => $row['category'], $results);
    }

    /**
     * Count inventory items
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
     * Get total inventory value
     */
    public static function totalValue(int $farmId, Database $db): float
    {
        $result = $db->queryOne(
            'SELECT SUM(quantity * cost_per_unit) as total FROM ' . self::$table . ' WHERE farm_id = ?',
            [$farmId]
        );
        return $result['total'] ? (float) $result['total'] : 0.0;
    }

    /**
     * Adjust quantity
     */
    public function adjustQuantity(Database $db, float $amount, ?string $reason = null): bool
    {
        $this->quantity = ($this->attributes['quantity'] ?? 0) + $amount;

        // Log the adjustment
        if ($reason) {
            $this->notes = ($this->attributes['notes'] ?? '') . "\n[" . date('Y-m-d H:i:s') . "] Adjustment: $amount ($reason)";
        }

        $this->updated_at = date('Y-m-d H:i:s');
        return (bool) $this->save();
    }

    /**
     * Check if low stock
     */
    public function isLowStock(): bool
    {
        return ($this->attributes['quantity'] ?? 0) < ($this->attributes['min_level'] ?? 0);
    }

    /**
     * Check if expired
     */
    public function isExpired(): bool
    {
        if (!isset($this->attributes['expiry_date'])) {
            return false;
        }

        $expiry = new \DateTime($this->attributes['expiry_date']);
        $now = new \DateTime();

        return $now > $expiry;
    }

    /**
     * Get inventory value
     */
    public function getValue(): float
    {
        $qty = $this->attributes['quantity'] ?? 0;
        $cost = $this->attributes['cost_per_unit'] ?? 0;
        return $qty * $cost;
    }

    /**
     * Get inventory reference
     */
    public function reference(): string
    {
        return "[Inventory #{$this->attributes['id']} {$this->attributes['name']} ({$this->attributes['category']})]";
    }

    /**
     * Get full profile with status indicators
     */
    public function getFullProfile(): array
    {
        $profile = $this->toArray();
        $profile['is_low_stock'] = $this->isLowStock();
        $profile['is_expired'] = $this->isExpired();
        $profile['total_value'] = $this->getValue();
        $profile['status'] = $this->isExpired() ? 'expired' : ($this->isLowStock() ? 'low_stock' : 'ok');

        return $profile;
    }
}
