"""
FarmOS IoT Simulation – Database Setup
=======================================
Creates the four IoT-related tables if they are not already present.
Column names must match exactly what IoTController.php queries expect.
"""

import pymysql
import config


def get_connection():
    return pymysql.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
        charset="utf8mb4",
        autocommit=True,
    )


DDL_STATEMENTS = [
    # -------------------------------------------------------------------------
    # iot_devices  – queried by IoTController::devices()
    # -------------------------------------------------------------------------
    """
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
    """,

    # -------------------------------------------------------------------------
    # sensor_data  – queried by IoTController::latestSensors()
    # -------------------------------------------------------------------------
    """
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
    """,

    # -------------------------------------------------------------------------
    # iot_alerts   – queried by IoTController::alerts()
    # -------------------------------------------------------------------------
    """
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
    """,

    # -------------------------------------------------------------------------
    # water_quality_logs – managed by IoTController (CREATE IF NOT EXISTS inline)
    # Reproduced here so the simulator can insert without relying on the PHP app
    # -------------------------------------------------------------------------
    """
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
    """,
]


def setup_tables(conn=None):
    """Create all IoT tables.  Pass an open connection or let us create one."""
    owns_conn = conn is None
    if owns_conn:
        conn = get_connection()
    try:
        with conn.cursor() as cur:
            for ddl in DDL_STATEMENTS:
                cur.execute(ddl.strip())
        print("[db_setup] IoT tables verified / created.")
    finally:
        if owns_conn:
            conn.close()


if __name__ == "__main__":
    setup_tables()
    print("Done.")
