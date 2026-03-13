<?php

namespace FarmOS\Controllers;

use FarmOS\{
    Request, Response, Database, Logger, Validation
};
use FarmOS\Models\Weather;

/**
 * WeatherController - Manages farm weather observations and data
 */
class WeatherController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    /**
     * Get current weather
     * GET /api/weather/current?farm_id={id}
     */
    public function current(): Response
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

            $weather = Weather::currentWeather($farmId, $this->db);
            if (!$weather) {
                return Response::success(
                    ['message' => 'No weather data available yet'],
                    'No observations recorded'
                );
            }

            Logger::info('Retrieved current weather', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success($weather->getFullProfile());
        } catch (\Exception $e) {
            Logger::error('Failed to get current weather', ['error' => $e->getMessage()]);
            return Response::error('Failed to get weather', 'WEATHER_ERROR', 500);
        }
    }

    /**
     * Get weather history
     * GET /api/weather/history?farm_id={id}&start_date={date}&end_date={date}&page={page}
     */
    public function history(): Response
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

            $startDate = $this->request->getQuery()['start_date'] ?? date('Y-m-d', strtotime('-30 days'));
            $endDate = $this->request->getQuery()['end_date'] ?? date('Y-m-d');

            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'Invalid date format']);
            }
            if (!Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'Invalid date format']);
            }

            // Pagination
            $page = (int) ($this->request->getQuery()['page'] ?? 1);
            $perPage = (int) ($this->request->getQuery()['per_page'] ?? 20);
            $page = max(1, $page);
            $perPage = min($perPage, 100);

            $result = Weather::query($this->db)
                ->where('farm_id', $farmId)
                ->where('observation_date >=', $startDate . ' 00:00:00')
                ->where('observation_date <=', $endDate . ' 23:59:59')
                ->orderBy('observation_date', 'DESC')
                ->paginate($page, $perPage);

            Logger::info('Retrieved weather history', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'days' => ceil((strtotime($endDate) - strtotime($startDate)) / 86400),
                'count' => count($result['data']),
            ]);

            return Response::success([
                'observations' => array_map(fn($m) => $m->getFullProfile(), $result['data']),
                'date_range' => [
                    'start' => $startDate,
                    'end' => $endDate,
                ],
                'pagination' => [
                    'page' => $result['page'],
                    'per_page' => $result['per_page'],
                    'total' => $result['total'],
                    'last_page' => $result['last_page'],
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get weather history', ['error' => $e->getMessage()]);
            return Response::error('Failed to get history', 'HISTORY_ERROR', 500);
        }
    }

    /**
     * Create weather observation
     * POST /api/weather/observation
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
            if (!isset($input['temperature'])) {
                $errors['temperature'] = 'Temperature is required';
            }

            if (!empty($errors)) {
                return Response::validationError($errors);
            }

            // Validate and sanitize
            if (!is_numeric($input['temperature'])) {
                return Response::validationError(['temperature' => 'Temperature must be numeric']);
            }

            $input['observation_date'] = $input['observation_date'] ?? date('Y-m-d H:i:s');

            if (!Validation::validateDate($input['observation_date'], 'Y-m-d H:i:s')) {
                if (!Validation::validateDate($input['observation_date'], 'Y-m-d')) {
                    return Response::validationError(['observation_date' => 'Invalid date format']);
                } else {
                    $input['observation_date'] = $input['observation_date'] . ' ' . date('H:i:s');
                }
            }

            // Sanitize and validate numeric fields
            $input['temperature'] = (float) $input['temperature'];
            $input['temperature_min'] = empty($input['temperature_min']) ? null : (float) $input['temperature_min'];
            $input['temperature_max'] = empty($input['temperature_max']) ? null : (float) $input['temperature_max'];
            $input['humidity'] = empty($input['humidity']) ? 50 : min(100, max(0, (int) $input['humidity']));
            $input['pressure'] = empty($input['pressure']) ? null : (float) $input['pressure'];
            $input['wind_speed'] = empty($input['wind_speed']) ? 0 : (float) $input['wind_speed'];
            $input['wind_direction'] = Validation::sanitizeString($input['wind_direction'] ?? 'N');
            $input['precipitation'] = empty($input['precipitation']) ? 0 : (float) $input['precipitation'];
            $input['condition'] = Validation::sanitizeString($input['condition'] ?? 'clear');
            $input['visibility'] = empty($input['visibility']) ? 10 : (float) $input['visibility'];
            $input['uv_index'] = empty($input['uv_index']) ? 0 : min(20, max(0, (int) $input['uv_index']));
            $input['source'] = Validation::sanitizeString($input['source'] ?? 'manual');
            $input['notes'] = Validation::sanitizeString($input['notes'] ?? '');

            // Create observation
            $weather = new Weather($this->db, array_filter($input, fn($k) => in_array($k, Weather::fillable()), ARRAY_FILTER_USE_KEY));
            $obsId = $weather->save();

            Logger::info('Created weather observation', [
                'user_id' => $user['user_id'],
                'observation_id' => $obsId,
                'farm_id' => $input['farm_id'],
                'temperature' => $input['temperature'],
                'condition' => $input['condition'],
            ]);

            return Response::success(
                array_merge($weather->toArray(), ['id' => $obsId]),
                'Weather observation recorded successfully',
                201
            );
        } catch (\Exception $e) {
            Logger::error('Failed to create weather observation', ['error' => $e->getMessage()]);
            return Response::error('Failed to record observation', 'CREATE_ERROR', 500);
        }
    }

    /**
     * Get weather statistics
     * GET /api/weather/stats?farm_id={id}&start_date={date}&end_date={date}
     */
    public function stats(): Response
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

            $startDate = $this->request->getQuery()['start_date'] ?? date('Y-m-d', strtotime('-30 days'));
            $endDate = $this->request->getQuery()['end_date'] ?? date('Y-m-d');

            if (!Validation::validateDate($startDate, 'Y-m-d')) {
                return Response::validationError(['start_date' => 'Invalid date format']);
            }
            if (!Validation::validateDate($endDate, 'Y-m-d')) {
                return Response::validationError(['end_date' => 'Invalid date format']);
            }

            $stats = Weather::getStats($farmId, $startDate, $endDate, $this->db);
            $conditions = Weather::getConditionStats($farmId, $startDate, $endDate, $this->db);
            $rainyDays = Weather::rainyDays($farmId, $startDate, $endDate, $this->db);
            $frostDays = Weather::frostRiskDays($farmId, $startDate, $endDate, $this->db);

            if (!$stats) {
                return Response::success(
                    ['message' => 'No weather data available for this period'],
                    'No observations found'
                );
            }

            Logger::info('Retrieved weather statistics', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'date_range' => "$startDate to $endDate",
            ]);

            return Response::success([
                'period' => [
                    'start' => $startDate,
                    'end' => $endDate,
                ],
                'statistics' => [
                    'observations' => (int) $stats['observations'],
                    'temperature' => [
                        'average' => round((float) $stats['avg_temperature'], 2),
                        'minimum' => round((float) $stats['min_temperature'], 2),
                        'maximum' => round((float) $stats['max_temperature'], 2),
                    ],
                    'humidity' => [
                        'average' => round((float) $stats['avg_humidity'], 2),
                    ],
                    'pressure' => [
                        'average' => round((float) $stats['avg_pressure'], 2),
                    ],
                    'wind' => [
                        'average_speed' => round((float) $stats['avg_wind_speed'], 2),
                    ],
                    'precipitation' => [
                        'total' => round((float) $stats['total_precipitation'], 2),
                    ],
                    'uv_index' => [
                        'maximum' => (int) $stats['max_uv_index'],
                    ],
                ],
                'weather_events' => [
                    'rainy_days' => $rainyDays,
                    'frost_risk_days' => $frostDays,
                    'condition_distribution' => $conditions,
                ],
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get weather statistics', ['error' => $e->getMessage()]);
            return Response::error('Failed to get statistics', 'STATS_ERROR', 500);
        }
    }

    /**
     * Get weather forecast (simple prediction based on recent data)
     * GET /api/weather/forecast?farm_id={id}&days={7}
     */
    public function forecast(): Response
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

            $days = (int) ($this->request->getQuery()['days'] ?? 7);
            $days = min(max($days, 1), 30); // Clamp to 1-30 days

            // Get recent weather to base forecast on
            $startDate = date('Y-m-d', strtotime('-30 days'));
            $endDate = date('Y-m-d');

            $stats = Weather::getStats($farmId, $startDate, $endDate, $this->db);

            if (!$stats) {
                return Response::success(
                    ['message' => 'Insufficient data for forecast'],
                    'Not enough observations'
                );
            }

            // Simple forecast based on averages
            $forecast = [];
            $today = new \DateTime();

            for ($i = 1; $i <= $days; $i++) {
                $date = clone $today;
                $date->modify("+$i days");

                // Add some variance to averages for realistic forecast
                $variance = (rand(-10, 10) / 100);

                $forecast[] = [
                    'date' => $date->format('Y-m-d'),
                    'temperature_high' => round((float) $stats['max_temperature'] * (1 + $variance), 2),
                    'temperature_low' => round((float) $stats['min_temperature'] * (1 + $variance), 2),
                    'humidity' => round((float) $stats['avg_humidity'], 2),
                    'wind_speed' => round((float) $stats['avg_wind_speed'], 2),
                    'precipitation_chance' => rand(0, 70),
                    'condition' => $this->predictCondition(),
                ];
            }

            Logger::info('Retrieved weather forecast', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
                'days' => $days,
            ]);

            return Response::success([
                'forecast_days' => $days,
                'forecast' => $forecast,
                'note' => 'Simple forecast based on historical data. For accurate weather forecasts, integrate with a weather API.',
            ]);
        } catch (\Exception $e) {
            Logger::error('Failed to get weather forecast', ['error' => $e->getMessage()]);
            return Response::error('Failed to get forecast', 'FORECAST_ERROR', 500);
        }
    }

    /**
     * Predict weather condition
     */
    private function predictCondition(): string
    {
        $conditions = ['clear', 'cloudy', 'partly_cloudy', 'rainy', 'overcast'];
        return $conditions[array_rand($conditions)];
    }
}
