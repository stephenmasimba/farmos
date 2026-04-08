<?php declare(strict_types=1);

function iotSimPdo(array $cfg): PDO
{
    $db = $cfg['db'];
    $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $db['host'], $db['port'], $db['name']);
    $pdo = new PDO($dsn, (string) $db['user'], (string) $db['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    return $pdo;
}

function iotSimSetupTables(PDO $pdo): void
{
    $ddl = [];

    $ddl[] = "
        CREATE TABLE IF NOT EXISTS iot_devices (
            id              INT AUTO_INCREMENT PRIMARY KEY,
            device_id       VARCHAR(100)  NOT NULL UNIQUE,
            device_name     VARCHAR(150)  NOT NULL,
            device_type     VARCHAR(80)   NOT NULL DEFAULT 'sensor',
            location        VARCHAR(150)  DEFAULT '',
            status          VARCHAR(20)   NOT NULL DEFAULT 'offline',
            last_seen       DATETIME      NULL,
            registered_by   INT           NULL,
            created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
            updated_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_device_id (device_id),
            INDEX idx_updated_at (updated_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ";

    $ddl[] = "
        CREATE TABLE IF NOT EXISTS sensor_data (
            id          BIGINT AUTO_INCREMENT PRIMARY KEY,
            sensor_type VARCHAR(80)    NOT NULL,
            value       DECIMAL(12,4)  NOT NULL,
            unit        VARCHAR(30)    NOT NULL DEFAULT '',
            location    VARCHAR(150)   NOT NULL DEFAULT '',
            timestamp   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
            device_id   VARCHAR(100)   NULL,
            INDEX idx_timestamp  (timestamp DESC),
            INDEX idx_sensor_type (sensor_type),
            INDEX idx_device_id   (device_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ";

    $ddl[] = "
        CREATE TABLE IF NOT EXISTS iot_alerts (
            id          INT AUTO_INCREMENT PRIMARY KEY,
            severity    VARCHAR(20)   NOT NULL DEFAULT 'warning',
            message     TEXT          NOT NULL,
            status      VARCHAR(20)   NOT NULL DEFAULT 'active',
            device_id   VARCHAR(100)  NULL,
            sensor_type VARCHAR(80)   NULL,
            created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
            resolved_at DATETIME      NULL,
            INDEX idx_status     (status),
            INDEX idx_created_at (created_at DESC)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ";

    $ddl[] = "
        CREATE TABLE IF NOT EXISTS water_quality_logs (
            id                  INT AUTO_INCREMENT PRIMARY KEY,
            date                DATE          NOT NULL,
            source              VARCHAR(100)  NOT NULL,
            ph                  DECIMAL(4,2)  NOT NULL,
            dissolved_oxygen    DECIMAL(6,2)  NOT NULL,
            turbidity           DECIMAL(8,2)  NOT NULL,
            notes               TEXT          NULL,
            created_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_date (date DESC)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ";

    foreach ($ddl as $sql) {
        $pdo->exec(trim($sql));
    }
}

if (PHP_SAPI === 'cli' && basename((string) $_SERVER['argv'][0]) === 'db_setup.php') {
    $cfg = require __DIR__ . '/config.php';
    $pdo = iotSimPdo($cfg);
    iotSimSetupTables($pdo);
    fwrite(STDOUT, "IoT tables verified / created.\n");
}
