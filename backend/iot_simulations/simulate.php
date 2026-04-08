<?php declare(strict_types=1);

require_once __DIR__ . '/db_setup.php';

function iotSimTs(?DateTimeInterface $dt = null): string
{
    $d = $dt ?? new DateTimeImmutable('now');
    return $d->format('Y-m-d H:i:s');
}

function iotSimRandFloat(float $min, float $max): float
{
    $r = mt_rand() / mt_getrandmax();
    return $min + ($max - $min) * $r;
}

function iotSimSensorMeta(array $cfg, string $sensorType): ?array
{
    return $cfg['sensors']['types'][$sensorType] ?? null;
}

function iotSimGenerateValue(array $cfg, array &$lastValues, string $deviceId, string $sensorType, bool $forceAnomaly): float
{
    $meta = iotSimSensorMeta($cfg, $sensorType);
    if ($meta === null) {
        return round(iotSimRandFloat(0, 100), 2);
    }

    $normMin = (float) $meta['norm_min'];
    $normMax = (float) $meta['norm_max'];
    $alertMin = (float) $meta['alert_min'];
    $alertMax = (float) $meta['alert_max'];

    if ($forceAnomaly) {
        if (iotSimRandFloat(0, 1) < 0.5) {
            $value = iotSimRandFloat($alertMax, $alertMax * 1.15 + 1);
        } else {
            $low = max(0.0, $alertMin * 0.85);
            $value = iotSimRandFloat($low, max($low, $alertMin));
        }
        return round($value, 4);
    }

    $key = $deviceId . ':' . $sensorType;
    if (array_key_exists($key, $lastValues)) {
        $prev = (float) $lastValues[$key];
        $spread = ($normMax - $normMin) * 0.05;
        $value = $prev + iotSimRandFloat(-$spread, $spread);
    } else {
        $value = iotSimRandFloat($normMin, $normMax);
    }

    $value = max($normMin, min($normMax, $value));
    $lastValues[$key] = $value;
    return round($value, 4);
}

function iotSimIsAlert(array $cfg, string $sensorType, float $value): array
{
    $meta = iotSimSensorMeta($cfg, $sensorType);
    if ($meta === null) {
        return [false, '', 'warning'];
    }
    if ($value > (float) $meta['alert_max']) {
        return [true, 'high', (string) $meta['severity']];
    }
    if ($value < (float) $meta['alert_min']) {
        return [true, 'low', (string) $meta['severity']];
    }
    return [false, '', (string) $meta['severity']];
}

function iotSimBuildAlertMessage(array $cfg, string $sensorType, string $location, float $value, string $direction): string
{
    $tpls = $cfg['sensors']['alert_messages'][$sensorType] ?? null;
    if (!is_array($tpls) || count($tpls) !== 2) {
        return sprintf('Sensor alert [%s] at %s: %s', $sensorType, $location, (string) $value);
    }
    $tpl = $direction === 'high' ? $tpls[0] : $tpls[1];
    return sprintf((string) $tpl, $location, $value);
}

function iotSimHttpPostJson(string $url, array $payload, array $headers = [], int $timeoutSeconds = 5): array
{
    $body = json_encode($payload);
    if ($body === false) {
        return ['status' => 0, 'body' => ''];
    }

    $baseHeaders = [
        'Content-Type: application/json',
        'Accept: application/json',
    ];

    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        if ($ch === false) {
            return ['status' => 0, 'body' => ''];
        }
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array_merge($baseHeaders, $headers));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeoutSeconds);
        curl_setopt($ch, CURLOPT_TIMEOUT, $timeoutSeconds);
        $respBody = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        return ['status' => $status, 'body' => is_string($respBody) ? $respBody : ''];
    }

    $headerText = implode("\r\n", array_merge($baseHeaders, $headers));
    $ctx = stream_context_create([
        'http' => [
            'method' => 'POST',
            'header' => $headerText,
            'content' => $body,
            'timeout' => $timeoutSeconds,
        ],
    ]);
    $respBody = @file_get_contents($url, false, $ctx);
    $status = 0;
    if (isset($http_response_header) && is_array($http_response_header)) {
        foreach ($http_response_header as $line) {
            if (preg_match('/^HTTP\/\S+\s+(\d+)/', $line, $m)) {
                $status = (int) $m[1];
                break;
            }
        }
    }
    return ['status' => $status, 'body' => is_string($respBody) ? $respBody : ''];
}

function iotSimApiLogin(array $cfg, ?string &$token): ?string
{
    $url = $cfg['api']['base_url'] . '/api/auth/login';
    $resp = iotSimHttpPostJson($url, ['email' => $cfg['api']['email'], 'password' => $cfg['api']['password']]);
    if ($resp['status'] < 200 || $resp['status'] >= 300) {
        return null;
    }
    $data = json_decode((string) $resp['body'], true);
    if (!is_array($data)) {
        return null;
    }
    $t = null;
    if (isset($data['data']) && is_array($data['data'])) {
        $t = $data['data']['access_token'] ?? null;
    } else {
        $t = $data['access_token'] ?? null;
    }
    if (is_string($t) && $t !== '') {
        $token = $t;
        return $t;
    }
    return null;
}

function iotSimApiRegisterDevice(array $cfg, ?string &$token, array $device): bool
{
    if ($token === null) {
        iotSimApiLogin($cfg, $token);
    }
    if ($token === null) {
        return false;
    }
    $url = $cfg['api']['base_url'] . '/api/iot/devices';
    $payload = [
        'id' => (string) $device['id'],
        'name' => (string) $device['name'],
        'type' => (string) $device['type'],
        'location' => (string) $device['location'],
        'status' => 'online',
        'last_seen' => (new DateTimeImmutable('now'))->format(DateTimeInterface::ATOM),
    ];
    $resp = iotSimHttpPostJson($url, $payload, ['Authorization: Bearer ' . $token]);
    return $resp['status'] === 200 || $resp['status'] === 201;
}

function iotSimApiPostWaterQuality(array $cfg, ?string &$token, string $source, float $ph, float $do, float $turbidity): bool
{
    if ($token === null) {
        iotSimApiLogin($cfg, $token);
    }
    if ($token === null) {
        return false;
    }
    $url = $cfg['api']['base_url'] . '/api/iot/water-quality';
    $payload = [
        'date' => (new DateTimeImmutable('now'))->format('Y-m-d'),
        'source' => $source,
        'ph' => round($ph, 2),
        'dissolved_oxygen' => round($do, 2),
        'turbidity' => round($turbidity, 2),
    ];
    $resp = iotSimHttpPostJson($url, $payload, ['Authorization: Bearer ' . $token]);
    return $resp['status'] === 200 || $resp['status'] === 201;
}

function iotSimDbUpsertDevice(PDO $pdo, string $deviceId, string $name, string $type, string $location, ?string $lastSeen): void
{
    $sql = "
        INSERT INTO iot_devices (device_id, device_name, device_type, location, status, last_seen)
        VALUES (:device_id, :device_name, :device_type, :location, 'active', :last_seen)
        ON DUPLICATE KEY UPDATE
            device_name = VALUES(device_name),
            device_type = VALUES(device_type),
            location = VALUES(location),
            status = 'active',
            last_seen = COALESCE(VALUES(last_seen), last_seen),
            updated_at = CURRENT_TIMESTAMP
    ";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':device_id' => $deviceId,
        ':device_name' => $name,
        ':device_type' => $type,
        ':location' => $location,
        ':last_seen' => $lastSeen,
    ]);
}

function iotSimDbInsertSensor(PDO $pdo, string $deviceId, string $sensorType, float $value, string $unit, string $location, string $timestamp): void
{
    $stmt = $pdo->prepare('INSERT INTO sensor_data (sensor_type, value, unit, location, timestamp, device_id) VALUES (?, ?, ?, ?, ?, ?)');
    $stmt->execute([$sensorType, $value, $unit, $location, $timestamp, $deviceId]);
}

function iotSimDbInsertAlert(PDO $pdo, string $severity, string $message, string $deviceId, string $sensorType): void
{
    $stmt = $pdo->prepare("INSERT INTO iot_alerts (severity, message, status, device_id, sensor_type) VALUES (?, ?, 'active', ?, ?)");
    $stmt->execute([$severity, $message, $deviceId, $sensorType]);
}

function iotSimDbInsertWaterQuality(PDO $pdo, string $source, float $ph, float $do, float $turbidity, ?string $date = null): void
{
    $d = $date ?? (new DateTimeImmutable('now'))->format('Y-m-d');
    $stmt = $pdo->prepare('INSERT INTO water_quality_logs (date, source, ph, dissolved_oxygen, turbidity, notes) VALUES (?, ?, ?, ?, ?, ?)');
    $stmt->execute([$d, $source, round($ph, 2), round($do, 2), round($turbidity, 2), null]);
}

function iotSimSeedHistorical(PDO $pdo, array $cfg, int $rounds, array &$lastValues): void
{
    fwrite(STDOUT, sprintf("[seed] Inserting %d historical rounds...\n", $rounds));
    $interval = new DateInterval('PT10M');
    $start = (new DateTimeImmutable('now'))->sub(new DateInterval('PT' . ($rounds * 10) . 'M'));

    $pdo->beginTransaction();
    try {
        for ($i = 0; $i < $rounds; $i++) {
            $tsDt = $start->add(new DateInterval('PT' . ($i * 10) . 'M'));
            $ts = iotSimTs($tsDt);
            $dateStr = $tsDt->format('Y-m-d');

            foreach ($cfg['sensors']['devices'] as $dev) {
                $forceAnomaly = iotSimRandFloat(0, 1) < 0.05;
                $value = iotSimGenerateValue($cfg, $lastValues, (string) $dev['id'], (string) $dev['type'], $forceAnomaly);
                $meta = iotSimSensorMeta($cfg, (string) $dev['type']);
                $unit = $meta ? (string) $meta['unit'] : '';

                iotSimDbInsertSensor($pdo, (string) $dev['id'], (string) $dev['type'], $value, $unit, (string) $dev['location'], $ts);
                [$breached, $direction, $severity] = iotSimIsAlert($cfg, (string) $dev['type'], $value);
                if ($breached) {
                    $msg = iotSimBuildAlertMessage($cfg, (string) $dev['type'], (string) $dev['location'], $value, (string) $direction);
                    iotSimDbInsertAlert($pdo, (string) $severity, $msg, (string) $dev['id'], (string) $dev['type']);
                }
            }

            if (($i % 6) === 0) {
                foreach (['Water Tank 1', 'Water Tank 2'] as $tank) {
                    $ph = iotSimGenerateValue($cfg, $lastValues, 'wq-' . $tank, 'ph', false);
                    $do = iotSimGenerateValue($cfg, $lastValues, 'wq-do-' . $tank, 'dissolved_oxygen', false);
                    $turbidity = round(iotSimRandFloat(0.5, 5.0), 2);
                    iotSimDbInsertWaterQuality($pdo, $tank, $ph, $do, $turbidity, $dateStr);
                }
            }
        }
        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }

    fwrite(STDOUT, sprintf("[seed] Done - inserted %d rounds of historical data.\n", $rounds));
}

function iotSimSimulationLoop(PDO $pdo, array $cfg, int $maxRounds, array &$lastValues): void
{
    fwrite(STDOUT, "[sim] Starting live simulation. Press Ctrl-C to stop.\n\n");

    $roundNum = 0;
    $waterQualityCounter = 0;
    $token = null;

    while (true) {
        $roundNum++;
        $now = new DateTimeImmutable('now');
        $ts = iotSimTs($now);
        fwrite(STDOUT, sprintf("[sim] Round %d at %s\n", $roundNum, $ts));

        $readingsThisRound = 0;
        $alertsThisRound = 0;

        $pdo->beginTransaction();
        try {
            foreach ($cfg['sensors']['devices'] as $dev) {
                $forceAnomaly = iotSimRandFloat(0, 1) < (float) $cfg['simulation']['anomaly_probability'];
                $value = iotSimGenerateValue($cfg, $lastValues, (string) $dev['id'], (string) $dev['type'], $forceAnomaly);
                $meta = iotSimSensorMeta($cfg, (string) $dev['type']);
                $unit = $meta ? (string) $meta['unit'] : '';

                iotSimDbInsertSensor($pdo, (string) $dev['id'], (string) $dev['type'], $value, $unit, (string) $dev['location'], $ts);
                $readingsThisRound++;

                $stmt = $pdo->prepare("UPDATE iot_devices SET last_seen = ?, status = 'active' WHERE device_id = ?");
                $stmt->execute([$ts, (string) $dev['id']]);

                [$breached, $direction, $severity] = iotSimIsAlert($cfg, (string) $dev['type'], $value);
                if ($breached) {
                    $msg = iotSimBuildAlertMessage($cfg, (string) $dev['type'], (string) $dev['location'], $value, (string) $direction);
                    iotSimDbInsertAlert($pdo, (string) $severity, $msg, (string) $dev['id'], (string) $dev['type']);
                    $alertsThisRound++;
                    fwrite(STDOUT, sprintf("  ALERT [%s] %s\n", strtoupper((string) $severity), $msg));
                } else {
                    fwrite(STDOUT, sprintf("  OK %s (%s): %s %s\n", (string) $dev['name'], (string) $dev['location'], (string) $value, $unit));
                }
            }

            $waterQualityCounter++;
            if ($waterQualityCounter >= 6) {
                $waterQualityCounter = 0;
                foreach (['Water Tank 1', 'Water Tank 2'] as $tank) {
                    $ph = iotSimGenerateValue($cfg, $lastValues, 'wq-' . $tank, 'ph', false);
                    $do = iotSimGenerateValue($cfg, $lastValues, 'wq-do-' . $tank, 'dissolved_oxygen', false);
                    $turbidity = round(iotSimRandFloat(0.5, 5.0), 2);
                    $ok = iotSimApiPostWaterQuality($cfg, $token, $tank, $ph, $do, $turbidity);
                    if (!$ok) {
                        iotSimDbInsertWaterQuality($pdo, $tank, $ph, $do, $turbidity, null);
                    }
                    fwrite(STDOUT, sprintf("  WATER %s: pH=%s, DO=%s mg/L, turbidity=%s\n", $tank, (string) round($ph, 2), (string) round($do, 2), (string) $turbidity));
                }
            }

            $pdo->commit();
        } catch (Throwable $e) {
            $pdo->rollBack();
            throw $e;
        }

        fwrite(STDOUT, sprintf("  -> %d readings, %d alerts\n\n", $readingsThisRound, $alertsThisRound));

        if ($maxRounds > 0 && $roundNum >= $maxRounds) {
            fwrite(STDOUT, sprintf("[sim] Reached %d rounds. Exiting.\n", $maxRounds));
            break;
        }

        $sleep = (int) $cfg['simulation']['interval_seconds'];
        if ($sleep > 0) {
            sleep($sleep);
        }
    }
}

function iotSimMain(): int
{
    if (PHP_SAPI !== 'cli') {
        fwrite(STDERR, "CLI only\n");
        return 1;
    }

    $cfg = require __DIR__ . '/config.php';
    $pdo = iotSimPdo($cfg);
    iotSimSetupTables($pdo);

    $token = null;
    iotSimApiLogin($cfg, $token);

    $pdo->beginTransaction();
    try {
        foreach ($cfg['sensors']['devices'] as $dev) {
            iotSimDbUpsertDevice($pdo, (string) $dev['id'], (string) $dev['name'], (string) $dev['type'], (string) $dev['location'], iotSimTs());
            iotSimApiRegisterDevice($cfg, $token, $dev);
        }
        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }

    $opts = getopt('', ['seed:']);
    $seedRounds = 0;
    if (is_array($opts) && array_key_exists('seed', $opts)) {
        $seedRounds = (int) $opts['seed'];
    }

    $lastValues = [];
    if ($seedRounds > 0) {
        iotSimSeedHistorical($pdo, $cfg, $seedRounds, $lastValues);
        return 0;
    }

    $maxRounds = (int) $cfg['simulation']['rounds'];
    iotSimSimulationLoop($pdo, $cfg, $maxRounds, $lastValues);
    return 0;
}

exit(iotSimMain());
