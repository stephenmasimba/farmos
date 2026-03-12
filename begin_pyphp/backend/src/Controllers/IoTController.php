<?php

namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database, Logger, Validation};

class IoTController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    public function devices(): Response
    {
        try {
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

    public function latestSensors(): Response
    {
        try {
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

    public function alerts(): Response
    {
        try {
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

