<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * Weather Model - Farm weather tracking and observations
 */
class Weather extends Model
{
    protected static string $table = 'weather';
    protected static array $fillable = [
        'farm_id', 'observation_date', 'temperature', 'temperature_min', 'temperature_max',
        'humidity', 'pressure', 'wind_speed', 'wind_direction', 'precipitation', 
        'condition', 'visibility', 'uv_index', 'source', 'notes'
    ];

    public function __construct(Database $db, array $attributes = [])
    {
        parent::__construct($db, $attributes);
    }

    /**
     * Get weather by farm
     */
    public static function byFarm(int $farmId, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->orderBy('observation_date', 'DESC')
            ->get();
    }

    /**
     * Get weather by date range
     */
    public static function byDateRange(int $farmId, string $startDate, string $endDate, Database $db): array
    {
        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('observation_date >=', $startDate . ' 00:00:00')
            ->where('observation_date <=', $endDate . ' 23:59:59')
            ->orderBy('observation_date', 'DESC')
            ->get();
    }

    /**
     * Get current weather for farm
     */
    public static function currentWeather(int $farmId, Database $db): ?array
    {
        $result = static::query($db)
            ->where('farm_id', $farmId)
            ->orderBy('observation_date', 'DESC')
            ->limit(1)
            ->get();

        return !empty($result) ? $result[0] : null;
    }

    /**
     * Get today's weather
     */
    public static function today(int $farmId, Database $db): array
    {
        $today = date('Y-m-d');
        
        return static::query($db)
            ->where('farm_id', $farmId)
            ->where('observation_date >=', $today . ' 00:00:00')
            ->where('observation_date <=', $today . ' 23:59:59')
            ->orderBy('observation_date', 'DESC')
            ->get();
    }

    /**
     * Get weather statistics for date range
     */
    public static function getStats(int $farmId, string $startDate, string $endDate, Database $db): ?array
    {
        $result = static::query($db)->getConnection()->query(
            'SELECT 
                COUNT(*) as observations,
                AVG(temperature) as avg_temperature,
                MIN(temperature_min) as min_temperature,
                MAX(temperature_max) as max_temperature,
                AVG(humidity) as avg_humidity,
                AVG(pressure) as avg_pressure,
                AVG(wind_speed) as avg_wind_speed,
                SUM(precipitation) as total_precipitation,
                MAX(uv_index) as max_uv_index
            FROM ' . static::table() . '
            WHERE farm_id = ? AND observation_date >= ? AND observation_date <= ?',
            [$farmId, $startDate . ' 00:00:00', $endDate . ' 23:59:59']
        );

        return !empty($result) ? $result[0] : null;
    }

    /**
     * Get condition distribution
     */
    public static function getConditionStats(int $farmId, string $startDate, string $endDate, Database $db): array
    {
        return static::query($db)->getConnection()->query(
            'SELECT `condition`, COUNT(*) as count 
             FROM ' . static::table() . '
             WHERE farm_id = ? AND observation_date >= ? AND observation_date <= ?
             GROUP BY `condition`',
            [$farmId, $startDate . ' 00:00:00', $endDate . ' 23:59:59']
        );
    }

    /**
     * Get rainy days count
     */
    public static function rainyDays(int $farmId, string $startDate, string $endDate, Database $db): int
    {
        $result = static::query($db)->getConnection()->query(
            'SELECT COUNT(DISTINCT DATE(observation_date)) as rainy_days 
             FROM ' . static::table() . '
             WHERE farm_id = ? AND observation_date >= ? AND observation_date <= ?
             AND (precipitation > 0 OR `condition` IN ("rainy", "thunderstorm"))',
            [$farmId, $startDate . ' 00:00:00', $endDate . ' 23:59:59']
        );

        return $result[0]['rainy_days'] ?? 0;
    }

    /**
     * Get frost risk days
     */
    public static function frostRiskDays(int $farmId, string $startDate, string $endDate, Database $db): int
    {
        $result = static::query($db)->getConnection()->query(
            'SELECT COUNT(DISTINCT DATE(observation_date)) as frost_days 
             FROM ' . static::table() . '
             WHERE farm_id = ? AND observation_date >= ? AND observation_date <= ?
             AND temperature_min < 0',
            [$farmId, $startDate . ' 00:00:00', $endDate . ' 23:59:59']
        );

        return $result[0]['frost_days'] ?? 0;
    }

    /**
     * Check if severe weather (high wind, extreme temps, etc.)
     */
    public function hasSevereWeather(): bool
    {
        return ($this->wind_speed > 40) ||
               ($this->temperature > 40) ||
               ($this->temperature_min < -10) ||
               ($this->uv_index > 10) ||
               in_array($this->condition, ['thunderstorm', 'severe_storm', 'tornado-warning']);
    }

    /**
     * Get full profile with weather indicator
     */
    public function getFullProfile(): array
    {
        return [
            'id' => $this->id,
            'farm_id' => $this->farm_id,
            'observation_date' => $this->observation_date,
            'temperature' => (float) $this->temperature,
            'temperature_min' => (float) $this->temperature_min,
            'temperature_max' => (float) $this->temperature_max,
            'humidity' => (int) $this->humidity,
            'pressure' => (float) $this->pressure,
            'wind_speed' => (float) $this->wind_speed,
            'wind_direction' => $this->wind_direction,
            'precipitation' => (float) $this->precipitation,
            'condition' => $this->condition,
            'visibility' => (float) $this->visibility,
            'uv_index' => (int) $this->uv_index,
            'source' => $this->source,
            'notes' => $this->notes,
            'indicators' => [
                'has_severe_weather' => $this->hasSevereWeather(),
                'is_rainy' => $this->precipitation > 0 || in_array($this->condition, ['rainy', 'thunderstorm']),
                'is_freezing' => $this->temperature_min < 0,
                'is_hot' => $this->temperature_max > 35,
                'high_humidity' => $this->humidity > 80,
            ],
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
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
