<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class IoTController
{
    protected Database $db;
    protected Request $request;
    private static bool $devicesTableEnsured = false;
    private static bool $sensorDataTableEnsured = false;
    private static bool $alertsTableEnsured = false;
    private static bool $energyStatusTableEnsured = false;
    private static bool $energyLoadsTableEnsured = false;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    public function devices(): Response
    {
        try {
            $this->ensureDevicesTable();
            $rows = $this->db->query('SELECT * FROM iot_devices ORDER BY updated_at DESC');
            $devices = array_map(function ($row) {
                $lastSeen = $row['last_seen'] ?? null;
                $status = $row['status'] ?? 'offline';
                if ($lastSeen) {
                    $lastSeenTs = strtotime((string) $lastSeen);
                    if ($lastSeenTs !== false && $lastSeenTs > (time() - 600)) {
                        $status = 'online';
                    } else {
                        $status = 'offline';
                    }
                }

                return [
                    'id' => (string) ($row['device_id'] ?? $row['id']),
                    'name' => (string) ($row['device_name'] ?? ''),
                    'type' => (string) ($row['device_type'] ?? 'sensor'),
                    'location' => (string) ($row['location'] ?? ''),
                    'status' => $status,
                    'last_seen' => $lastSeen ? date('c', strtotime((string) $lastSeen)) : date('c', time() - 3600),
                ];
            }, $rows);

            return Response::success($devices);
        } catch (\Exception $e) {
            Logger::error('Failed to list iot devices', ['error' => $e->getMessage()]);
            return Response::success([]);
        }
    }

    public function createDevice(): Response
    {
        try {
            $this->ensureDevicesTable();
            $input = $this->request->getBody();

            $deviceId = Validation::sanitizeString((string) ($input['id'] ?? $input['device_id'] ?? ''));
            $name = Validation::sanitizeString((string) ($input['name'] ?? $input['device_name'] ?? ''));
            $type = Validation::sanitizeString((string) ($input['type'] ?? $input['device_type'] ?? 'sensor'));
            $location = Validation::sanitizeString((string) ($input['location'] ?? ''));
            $status = Validation::sanitizeString((string) ($input['status'] ?? 'offline'));
            $lastSeen = $input['last_seen'] ?? null;

            if ($deviceId === '' || $name === '') {
                return Response::validationError(['id' => 'Device ID is required', 'name' => 'Name is required']);
            }

            $dbStatus = ($status === 'offline') ? 'offline' : 'active';
            $lastSeenSql = null;
            if (!empty($lastSeen)) {
                $ts = strtotime((string) $lastSeen);
                if ($ts !== false) {
                    $lastSeenSql = date('Y-m-d H:i:s', $ts);
                }
            }

            $existing = $this->db->queryOne('SELECT id FROM iot_devices WHERE device_id = ?', [$deviceId]);
            if ($existing) {
                $this->db->execute(
                    'UPDATE iot_devices SET device_name = ?, device_type = ?, location = ?, status = ?, last_seen = COALESCE(?, last_seen) WHERE device_id = ?',
                    [$name, $type, $location, $dbStatus, $lastSeenSql, $deviceId]
                );
            } else {
                $user = $this->request->getUser();
                $registeredBy = $user['user_id'] ?? null;
                $this->db->execute(
                    'INSERT INTO iot_devices (device_id, device_name, device_type, location, status, last_seen, registered_by) VALUES (?, ?, ?, ?, ?, ?, ?)',
                    [$deviceId, $name, $type, $location, $dbStatus, $lastSeenSql, $registeredBy]
                );
            }

            return Response::success(['ok' => true]);
        } catch (\Exception $e) {
            Logger::error('Failed to create iot device', ['error' => $e->getMessage()]);
            return Response::error('Failed to create device', 'IOT_DEVICE_CREATE_ERROR', 500);
        }
    }

    private function ensureDevicesTable(): void
    {
        if (self::$devicesTableEnsured) {
            return;
        }

        $this->db->execute(
            "CREATE TABLE IF NOT EXISTS iot_devices (
                id INT AUTO_INCREMENT PRIMARY KEY,
                device_id VARCHAR(100) NOT NULL UNIQUE,
                device_name VARCHAR(255) NOT NULL,
                device_type VARCHAR(50) NOT NULL DEFAULT 'sensor',
                location VARCHAR(255) NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'offline',
                last_seen DATETIME NULL,
                registered_by INT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )"
        );

        self::$devicesTableEnsured = true;
    }

    private function ensureSensorDataTable(): void
    {
        if (self::$sensorDataTableEnsured) {
            return;
        }

        $this->db->execute(
            "CREATE TABLE IF NOT EXISTS sensor_data (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                device_id VARCHAR(100) NULL,
                sensor_type VARCHAR(50) NOT NULL,
                value DECIMAL(12,4) NOT NULL,
                unit VARCHAR(20) NULL,
                location VARCHAR(255) NULL,
                timestamp DATETIME NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_timestamp (timestamp),
                INDEX idx_sensor_type (sensor_type),
                INDEX idx_device_id (device_id)
            )"
        );

        self::$sensorDataTableEnsured = true;
    }

    private function ensureAlertsTable(): void
    {
        if (self::$alertsTableEnsured) {
            return;
        }

        $this->db->execute(
            "CREATE TABLE IF NOT EXISTS iot_alerts (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                severity VARCHAR(20) NOT NULL,
                message TEXT NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'active',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                resolved_at DATETIME NULL,
                INDEX idx_status (status),
                INDEX idx_created_at (created_at)
            )"
        );

        self::$alertsTableEnsured = true;
    }

    private function ensureEnergyStatusTable(): void
    {
        if (self::$energyStatusTableEnsured) {
            return;
        }

        $this->db->execute(
            "CREATE TABLE IF NOT EXISTS energy_status_logs (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                battery_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
                battery_voltage DECIMAL(6,2) NOT NULL DEFAULT 0,
                solar_generation_watts DECIMAL(10,2) NOT NULL DEFAULT 0,
                total_consumption_watts DECIMAL(10,2) NOT NULL DEFAULT 0,
                active_loads INT NOT NULL DEFAULT 0,
                load_shedding_active BOOLEAN NOT NULL DEFAULT FALSE,
                essential_loads_only BOOLEAN NOT NULL DEFAULT FALSE,
                non_essential_cutoff_v DECIMAL(6,2) NOT NULL DEFAULT 48.0,
                critical_cutoff_v DECIMAL(6,2) NOT NULL DEFAULT 46.5,
                last_event VARCHAR(255) NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_farm_created (farm_id, created_at)
            )"
        );

        self::$energyStatusTableEnsured = true;
    }

    private function ensureEnergyLoadsTable(): void
    {
        if (self::$energyLoadsTableEnsured) {
            return;
        }

        $this->db->execute(
            "CREATE TABLE IF NOT EXISTS energy_loads (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                farm_id INT NOT NULL,
                name VARCHAR(150) NOT NULL,
                location VARCHAR(150) NULL,
                priority INT NOT NULL DEFAULT 1,
                is_essential BOOLEAN NOT NULL DEFAULT FALSE,
                power_watts DECIMAL(10,2) NOT NULL DEFAULT 0,
                status VARCHAR(20) NOT NULL DEFAULT 'off',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_farm_priority (farm_id, priority),
                INDEX idx_farm_status (farm_id, status)
            )"
        );

        self::$energyLoadsTableEnsured = true;
    }

    public function energyStatus(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::success([
                    'battery_percentage' => 0,
                    'battery_voltage' => 0,
                    'solar_generation_watts' => 0,
                    'total_consumption_watts' => 0,
                    'active_loads' => 0,
                    'load_shedding_active' => false,
                    'essential_loads_only' => false,
                    'non_essential_cutoff_v' => 48.0,
                    'critical_cutoff_v' => 46.5,
                    'last_event' => 'No recent events',
                    'timestamp' => date('c'),
                ]);
            }

            $this->ensureEnergyStatusTable();

            $row = $this->db->queryOne(
                'SELECT battery_percentage, battery_voltage, solar_generation_watts, total_consumption_watts, active_loads, load_shedding_active, essential_loads_only, non_essential_cutoff_v, critical_cutoff_v, last_event, created_at
                 FROM energy_status_logs
                 WHERE farm_id = ?
                 ORDER BY created_at DESC
                 LIMIT 1',
                [$farmId]
            );

            if (!$row) {
                return Response::success([
                    'battery_percentage' => 0,
                    'battery_voltage' => 0,
                    'solar_generation_watts' => 0,
                    'total_consumption_watts' => 0,
                    'active_loads' => 0,
                    'load_shedding_active' => false,
                    'essential_loads_only' => false,
                    'non_essential_cutoff_v' => 48.0,
                    'critical_cutoff_v' => 46.5,
                    'last_event' => 'No recent events',
                    'timestamp' => date('c'),
                ]);
            }

            $payload = [
                'battery_percentage' => (float) ($row['battery_percentage'] ?? 0),
                'battery_voltage' => (float) ($row['battery_voltage'] ?? 0),
                'solar_generation_watts' => (float) ($row['solar_generation_watts'] ?? 0),
                'total_consumption_watts' => (float) ($row['total_consumption_watts'] ?? 0),
                'active_loads' => (int) ($row['active_loads'] ?? 0),
                'load_shedding_active' => !empty($row['load_shedding_active']),
                'essential_loads_only' => !empty($row['essential_loads_only']),
                'non_essential_cutoff_v' => (float) ($row['non_essential_cutoff_v'] ?? 48.0),
                'critical_cutoff_v' => (float) ($row['critical_cutoff_v'] ?? 46.5),
                'last_event' => (string) ($row['last_event'] ?? 'No recent events'),
                'timestamp' => !empty($row['created_at']) ? date('c', strtotime((string) $row['created_at'])) : date('c'),
            ];

            Logger::info('Retrieved energy status', [
                'user_id' => $user['user_id'],
                'farm_id' => $farmId,
            ]);

            return Response::success($payload);
        } catch (\Exception $e) {
            Logger::error('Failed to get energy status', ['error' => $e->getMessage()]);
            return Response::error('Failed to get energy status', 'ENERGY_STATUS_ERROR', 500);
        }
    }

    public function energyLoads(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::success([]);
            }

            $this->ensureEnergyLoadsTable();
            $rows = $this->db->query(
                'SELECT name, location, priority, is_essential, power_watts, status
                 FROM energy_loads
                 WHERE farm_id = ?
                 ORDER BY is_essential DESC, priority ASC, id ASC',
                [$farmId]
            );

            $loads = array_map(static function (array $row): array {
                return [
                    'name' => (string) ($row['name'] ?? ''),
                    'location' => (string) ($row['location'] ?? ''),
                    'priority' => (int) ($row['priority'] ?? 1),
                    'is_essential' => !empty($row['is_essential']),
                    'power_watts' => (float) ($row['power_watts'] ?? 0),
                    'status' => (string) ($row['status'] ?? 'off'),
                ];
            }, $rows);

            return Response::success($loads);
        } catch (\Exception $e) {
            Logger::error('Failed to get energy loads', ['error' => $e->getMessage()]);
            return Response::error('Failed to get energy loads', 'ENERGY_LOADS_ERROR', 500);
        }
    }

    public function energyHistory(): Response
    {
        try {
            $user = $this->request->getUser();
            if (!$user) {
                return Response::unauthorized();
            }

            $farmId = (int) ($this->request->getQuery()['farm_id'] ?? 0);
            if (!$farmId) {
                return Response::success([]);
            }

            $this->ensureEnergyStatusTable();
            $rows = $this->db->query(
                'SELECT created_at, battery_percentage, solar_generation_watts, total_consumption_watts, load_shedding_active
                 FROM energy_status_logs
                 WHERE farm_id = ?
                 ORDER BY created_at DESC
                 LIMIT 24',
                [$farmId]
            );

            $history = array_map(static function (array $row): array {
                return [
                    'timestamp' => !empty($row['created_at']) ? date('c', strtotime((string) $row['created_at'])) : date('c'),
                    'battery_percentage' => (float) ($row['battery_percentage'] ?? 0),
                    'solar_generation_watts' => (float) ($row['solar_generation_watts'] ?? 0),
                    'total_consumption_watts' => (float) ($row['total_consumption_watts'] ?? 0),
                    'load_shedding_active' => !empty($row['load_shedding_active']),
                ];
            }, $rows);

            return Response::success($history);
        } catch (\Exception $e) {
            Logger::error('Failed to get energy history', ['error' => $e->getMessage()]);
            return Response::error('Failed to get energy history', 'ENERGY_HISTORY_ERROR', 500);
        }
    }

    public function latestSensors(): Response
    {
        try {
            $this->ensureSensorDataTable();
            $limit = (int) ($this->request->getQuery('limit', 20));
            $limit = max(1, min($limit, 200));

            $rows = $this->db->query(
                'SELECT sensor_type, value, unit, location, timestamp FROM sensor_data ORDER BY timestamp DESC LIMIT ?',
                [$limit]
            );

            $readings = array_map(fn($r) => [
                'type' => (string) ($r['sensor_type'] ?? ''),
                'value' => isset($r['value']) ? (float) $r['value'] : 0.0,
                'unit' => (string) ($r['unit'] ?? ''),
                'location' => (string) ($r['location'] ?? ''),
                'timestamp' => !empty($r['timestamp']) ? date('c', strtotime((string) $r['timestamp'])) : date('c'),
            ], $rows);

            return Response::success($readings);
        } catch (\Exception $e) {
            Logger::error('Failed to get latest sensor data', ['error' => $e->getMessage()]);
            return Response::success([]);
        }
    }

    public function ingestSensor(): Response
    {
        try {
            $this->ensureSensorDataTable();
            $this->ensureDevicesTable();
            $this->ensureAlertsTable();

            $input = $this->request->getBody();
            $deviceId = Validation::sanitizeString((string) ($input['device_id'] ?? $input['device'] ?? ''));
            $type = Validation::sanitizeString((string) ($input['type'] ?? $input['sensor_type'] ?? ''));
            $unit = Validation::sanitizeString((string) ($input['unit'] ?? ''));
            $location = Validation::sanitizeString((string) ($input['location'] ?? ''));
            $timestamp = Validation::sanitizeString((string) ($input['timestamp'] ?? ''));

            if ($type === '') {
                return Response::validationError(['type' => 'Sensor type is required']);
            }
            if (!isset($input['value']) || !is_numeric($input['value'])) {
                return Response::validationError(['value' => 'Must be numeric']);
            }

            $tsSql = date('Y-m-d H:i:s');
            if ($timestamp !== '') {
                $ts = strtotime($timestamp);
                if ($ts === false) {
                    return Response::validationError(['timestamp' => 'Invalid timestamp']);
                }
                $tsSql = date('Y-m-d H:i:s', $ts);
            }

            $val = (float) $input['value'];

            $this->db->execute(
                'INSERT INTO sensor_data (device_id, sensor_type, value, unit, location, timestamp) VALUES (?, ?, ?, ?, ?, ?)',
                [$deviceId !== '' ? $deviceId : null, $type, $val, $unit !== '' ? $unit : null, $location !== '' ? $location : null, $tsSql]
            );

            if ($deviceId !== '') {
                $row = $this->db->queryOne('SELECT id FROM iot_devices WHERE device_id = ? LIMIT 1', [$deviceId]);
                if ($row) {
                    $this->db->execute('UPDATE iot_devices SET last_seen = ?, status = ? WHERE device_id = ?', [$tsSql, 'active', $deviceId]);
                }
            }

            $alert = $this->evaluateAlert($type, $val, $unit);
            if ($alert) {
                $this->db->execute(
                    "INSERT INTO iot_alerts (severity, message, status) VALUES (?, ?, 'active')",
                    [$alert['severity'], $alert['message']]
                );
            }

            return Response::success(['ok' => true], 'Created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to ingest sensor data', ['error' => $e->getMessage()]);
            return Response::error('Failed to ingest sensor data', 'SENSOR_INGEST_ERROR', 500);
        }
    }

    private function evaluateAlert(string $type, float $value, string $unit): ?array
    {
        $t = strtolower($type);
        if ($t === 'temperature' || $t === 'temp') {
            if ($value >= 40.0) {
                return ['severity' => 'critical', 'message' => 'High temperature: ' . $value . ($unit !== '' ? (' ' . $unit) : '')];
            }
            if ($value <= 0.0) {
                return ['severity' => 'critical', 'message' => 'Low temperature: ' . $value . ($unit !== '' ? (' ' . $unit) : '')];
            }
        }
        if ($t === 'humidity') {
            if ($value >= 90.0) {
                return ['severity' => 'warning', 'message' => 'High humidity: ' . $value . ($unit !== '' ? (' ' . $unit) : '')];
            }
            if ($value <= 20.0) {
                return ['severity' => 'warning', 'message' => 'Low humidity: ' . $value . ($unit !== '' ? (' ' . $unit) : '')];
            }
        }
        if ($t === 'ph') {
            if ($value < 6.5 || $value > 8.5) {
                return ['severity' => 'warning', 'message' => 'Out-of-range pH: ' . $value];
            }
        }
        return null;
    }

    public function alerts(): Response
    {
        try {
            $this->ensureAlertsTable();
            $rows = $this->db->query(
                "SELECT severity, message, created_at FROM iot_alerts WHERE status = 'active' ORDER BY created_at DESC LIMIT 50"
            );

            $alerts = array_map(fn($r) => [
                'type' => (($r['severity'] ?? '') === 'critical') ? 'critical' : 'warning',
                'message' => (string) ($r['message'] ?? ''),
                'time' => !empty($r['created_at']) ? date('M j, g:i a', strtotime((string) $r['created_at'])) : '',
            ], $rows);

            return Response::success($alerts);
        } catch (\Exception $e) {
            Logger::error('Failed to list iot alerts', ['error' => $e->getMessage()]);
            return Response::success([]);
        }
    }

    private function ensureWaterQualityTable(): void
    {
        $this->db->execute(
            "CREATE TABLE IF NOT EXISTS water_quality_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                date DATE NOT NULL,
                source VARCHAR(100) NOT NULL,
                ph DECIMAL(4,2) NOT NULL,
                dissolved_oxygen DECIMAL(6,2) NOT NULL,
                turbidity DECIMAL(8,2) NOT NULL,
                notes TEXT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )"
        );
    }

    public function waterQuality(): Response
    {
        try {
            $this->ensureWaterQualityTable();
            $rows = $this->db->query('SELECT date, source, ph, dissolved_oxygen, turbidity, notes FROM water_quality_logs ORDER BY date DESC, created_at DESC LIMIT 100');
            $logs = array_map(fn($r) => [
                'date' => (string) ($r['date'] ?? date('Y-m-d')),
                'source' => (string) ($r['source'] ?? ''),
                'ph' => isset($r['ph']) ? (float) $r['ph'] : 0.0,
                'dissolved_oxygen' => isset($r['dissolved_oxygen']) ? (float) $r['dissolved_oxygen'] : 0.0,
                'turbidity' => isset($r['turbidity']) ? (float) $r['turbidity'] : 0.0,
                'notes' => $r['notes'] ?? null,
            ], $rows);
            return Response::success($logs);
        } catch (\Exception $e) {
            Logger::error('Failed to list water quality logs', ['error' => $e->getMessage()]);
            return Response::success([]);
        }
    }

    public function createWaterQuality(): Response
    {
        try {
            $this->ensureWaterQualityTable();
            $input = $this->request->getBody();

            $date = Validation::sanitizeString((string) ($input['date'] ?? date('Y-m-d')));
            $source = Validation::sanitizeString((string) ($input['source'] ?? ''));
            $notes = Validation::sanitizeString((string) ($input['notes'] ?? ''));

            if ($source === '') {
                return Response::validationError(['source' => 'Source is required']);
            }
            if (!Validation::validateDate($date, 'Y-m-d')) {
                return Response::validationError(['date' => 'Invalid date format']);
            }

            foreach (['ph', 'dissolved_oxygen', 'turbidity'] as $f) {
                if (!isset($input[$f]) || !is_numeric($input[$f])) {
                    return Response::validationError([$f => 'Must be numeric']);
                }
            }

            $this->db->execute(
                'INSERT INTO water_quality_logs (date, source, ph, dissolved_oxygen, turbidity, notes) VALUES (?, ?, ?, ?, ?, ?)',
                [
                    $date,
                    $source,
                    (float) $input['ph'],
                    (float) $input['dissolved_oxygen'],
                    (float) $input['turbidity'],
                    $notes !== '' ? $notes : null,
                ]
            );

            return Response::success(['ok' => true], 'Created', 201);
        } catch (\Exception $e) {
            Logger::error('Failed to create water quality log', ['error' => $e->getMessage()]);
            return Response::error('Failed to create water quality log', 'WATER_QUALITY_CREATE_ERROR', 500);
        }
    }
}
