#!/usr/bin/env python3
"""
FarmOS IoT Sensor Simulator
============================
Simulates all farm IoT sensors and pushes data into the FarmOS database so
the app dashboard, sensor views, and alerts work with realistic test data.

Usage
-----
    # From this directory:
    python simulate.py                  # run forever (10-second interval)
    SIM_ROUNDS=50 python simulate.py    # run 50 rounds then exit
    SIM_INTERVAL=5 python simulate.py   # 5-second interval
    DB_PASSWORD=secret python simulate.py

    # One-off seed (populate historical data fast):
    python simulate.py --seed 200       # insert 200 rounds instantly, no delay

Environment variables (override config.py defaults)
----------------------------------------------------
    DATABASE_HOST, DATABASE_PORT, DATABASE_NAME, DB_USER, DB_PASSWORD
    API_BASE_URL, API_EMAIL, API_PASSWORD
    SIM_INTERVAL, SIM_ROUNDS
"""

import argparse
import random
import sys
import time
from datetime import datetime, timedelta

import pymysql
import requests

import config
import db_setup


# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

def _ts(dt: datetime = None) -> str:
    """Return a MySQL-compatible timestamp string."""
    return (dt or datetime.now()).strftime("%Y-%m-%d %H:%M:%S")


def _sensor_meta(sensor_type: str) -> dict:
    """Return the metadata tuple for a sensor type as a dict."""
    for row in config.SENSOR_TYPES:
        if row[0] == sensor_type:
            return dict(
                type=row[0], unit=row[1],
                norm_min=row[2], norm_max=row[3],
                alert_min=row[4], alert_max=row[5],
                severity=row[6],
            )
    return None


# ─────────────────────────────────────────────────────────────────────────────
# Value generator
# ─────────────────────────────────────────────────────────────────────────────

# Persistent state so values drift smoothly between rounds
_last_values: dict[str, float] = {}


def generate_value(device_id: str, sensor_type: str, force_anomaly: bool = False) -> float:
    """
    Generate a realistic sensor reading.
    - Values drift ±5 % from the previous reading (bounded to normal range).
    - If force_anomaly is True the value is pushed outside the alert threshold.
    """
    meta = _sensor_meta(sensor_type)
    if meta is None:
        return round(random.uniform(0, 100), 2)

    norm_min, norm_max = meta["norm_min"], meta["norm_max"]
    alert_min, alert_max = meta["alert_min"], meta["alert_max"]

    if force_anomaly:
        # Randomly pick high or low breach
        if random.random() < 0.5:
            # HIGH breach – between alert_max and alert_max * 1.2
            value = random.uniform(alert_max, alert_max * 1.15 + 1)
        else:
            # LOW breach – between alert_min * 0.85 and alert_min
            low = max(0, alert_min * 0.85)
            value = random.uniform(low, max(low, alert_min))
        return round(value, 4)

    # Smooth drift from last known value
    key = f"{device_id}:{sensor_type}"
    if key in _last_values:
        prev = _last_values[key]
        spread = (norm_max - norm_min) * 0.05
        value = prev + random.uniform(-spread, spread)
    else:
        value = random.uniform(norm_min, norm_max)

    value = max(norm_min, min(norm_max, value))
    _last_values[key] = value
    return round(value, 4)


# ─────────────────────────────────────────────────────────────────────────────
# API helpers (best-effort; failures are non-fatal)
# ─────────────────────────────────────────────────────────────────────────────

_api_token: str | None = None


def _api_login() -> str | None:
    """Attempt to log into the FarmOS API and return a JWT token."""
    global _api_token
    try:
        resp = requests.post(
            f"{config.API_BASE_URL}/api/auth/login",
            json={"email": config.API_EMAIL, "password": config.API_PASSWORD},
            timeout=5,
        )
        data = resp.json()
        token = (data.get("data") or data).get("access_token")
        if token:
            _api_token = token
            print(f"[api] Authenticated as {config.API_EMAIL}")
            return token
    except Exception as exc:
        print(f"[api] Login failed (API may be offline): {exc}")
    return None


def _api_register_device(device_id: str, name: str, dtype: str, location: str) -> bool:
    """Register / update a device via the API (best-effort)."""
    global _api_token
    if not _api_token:
        _api_login()
    if not _api_token:
        return False
    try:
        resp = requests.post(
            f"{config.API_BASE_URL}/api/iot/devices",
            json={
                "id": device_id,
                "name": name,
                "type": dtype,
                "location": location,
                "status": "online",
                "last_seen": datetime.now().isoformat(),
            },
            headers={"Authorization": f"Bearer {_api_token}"},
            timeout=5,
        )
        return resp.status_code in (200, 201)
    except Exception:
        return False


def _api_post_water_quality(source: str, ph: float, do_: float, turbidity: float) -> bool:
    """Post a water-quality record via the API (best-effort)."""
    global _api_token
    if not _api_token:
        _api_login()
    if not _api_token:
        return False
    try:
        resp = requests.post(
            f"{config.API_BASE_URL}/api/iot/water-quality",
            json={
                "date": datetime.now().strftime("%Y-%m-%d"),
                "source": source,
                "ph": round(ph, 2),
                "dissolved_oxygen": round(do_, 2),
                "turbidity": round(turbidity, 2),
            },
            headers={"Authorization": f"Bearer {_api_token}"},
            timeout=5,
        )
        return resp.status_code in (200, 201)
    except Exception:
        return False


# ─────────────────────────────────────────────────────────────────────────────
# Direct-DB inserts
# ─────────────────────────────────────────────────────────────────────────────

def db_upsert_device(cur, device_id: str, name: str, dtype: str, location: str):
    """Insert or update a device record directly in MySQL."""
    now = _ts()
    cur.execute(
        """
        INSERT INTO iot_devices (device_id, device_name, device_type, location, status, last_seen)
        VALUES (%s, %s, %s, %s, 'active', %s)
        ON DUPLICATE KEY UPDATE
            device_name = VALUES(device_name),
            device_type = VALUES(device_type),
            location    = VALUES(location),
            status      = 'active',
            last_seen   = VALUES(last_seen),
            updated_at  = CURRENT_TIMESTAMP
        """,
        (device_id, name, dtype, location, now),
    )


def db_insert_sensor(cur, device_id: str, sensor_type: str, value: float,
                     unit: str, location: str, ts: str):
    """Insert a single sensor reading into sensor_data."""
    cur.execute(
        "INSERT INTO sensor_data (sensor_type, value, unit, location, timestamp, device_id) "
        "VALUES (%s, %s, %s, %s, %s, %s)",
        (sensor_type, value, unit, location, ts, device_id),
    )


def db_insert_alert(cur, severity: str, message: str, device_id: str, sensor_type: str):
    """Insert an IoT alert."""
    cur.execute(
        "INSERT INTO iot_alerts (severity, message, status, device_id, sensor_type) "
        "VALUES (%s, %s, 'active', %s, %s)",
        (severity, message, device_id, sensor_type),
    )


def db_insert_water_quality(cur, source: str, ph: float, do_: float, turbidity: float,
                             date: str = None):
    cur.execute(
        "INSERT INTO water_quality_logs (date, source, ph, dissolved_oxygen, turbidity) "
        "VALUES (%s, %s, %s, %s, %s)",
        (date or datetime.now().strftime("%Y-%m-%d"), source,
         round(ph, 2), round(do_, 2), round(turbidity, 2)),
    )


# ─────────────────────────────────────────────────────────────────────────────
# Threshold check
# ─────────────────────────────────────────────────────────────────────────────

def is_alert(sensor_type: str, value: float) -> tuple[bool, str, str]:
    """Return (is_breach, direction, severity)."""
    meta = _sensor_meta(sensor_type)
    if meta is None:
        return False, "", "warning"
    if value > meta["alert_max"]:
        return True, "high", meta["severity"]
    if value < meta["alert_min"]:
        return True, "low", meta["severity"]
    return False, "", meta["severity"]


def build_alert_message(sensor_type: str, location: str, value: float, direction: str) -> str:
    templates = config.ALERT_MESSAGES.get(sensor_type)
    if not templates:
        return f"Sensor alert [{sensor_type}] at {location}: {value}"
    high_tpl, low_tpl = templates
    tpl = high_tpl if direction == "high" else low_tpl
    return tpl.format(location=location, value=value)


# ─────────────────────────────────────────────────────────────────────────────
# Seed historical data (fast-fill, no sleep)
# ─────────────────────────────────────────────────────────────────────────────

def seed_historical(conn, rounds: int):
    """Insert `rounds` readings back-dated to simulate history."""
    print(f"[seed] Inserting {rounds} historical rounds …")
    interval = timedelta(minutes=10)
    start_dt = datetime.now() - interval * rounds

    with conn.cursor() as cur:
        for i in range(rounds):
            ts_dt = start_dt + interval * i
            ts = _ts(ts_dt)
            date_str = ts_dt.strftime("%Y-%m-%d")

            for dev_id, dev_name, dev_type, location in config.DEVICES:
                # Keep a low anomaly rate in historical data
                force_anomaly = random.random() < 0.05
                value = generate_value(dev_id, dev_type, force_anomaly)
                meta = _sensor_meta(dev_type)
                unit = meta["unit"] if meta else ""

                db_insert_sensor(cur, dev_id, dev_type, value, unit, location, ts)

                breached, direction, severity = is_alert(dev_type, value)
                if breached:
                    msg = build_alert_message(dev_type, location, value, direction)
                    db_insert_alert(cur, severity, msg, dev_id, dev_type)

            # Water quality every 6th round
            if i % 6 == 0:
                for tank in ["Water Tank 1", "Water Tank 2"]:
                    ph = generate_value(f"wq-{tank}", "ph")
                    do_ = generate_value(f"wq-do-{tank}", "dissolved_oxygen")
                    turbidity = round(random.uniform(0.5, 5.0), 2)
                    db_insert_water_quality(cur, tank, ph, do_, turbidity, date_str)

    conn.commit()
    print(f"[seed] Done – inserted {rounds} rounds of historical data.")


# ─────────────────────────────────────────────────────────────────────────────
# Live simulation loop
# ─────────────────────────────────────────────────────────────────────────────

def simulation_loop(conn, max_rounds: int = 0):
    """Run the live simulation (max_rounds=0 means forever)."""
    print("\n[sim] Starting live simulation …  Press Ctrl-C to stop.\n")
    round_num = 0
    water_quality_counter = 0

    while True:
        round_num += 1
        now = datetime.now()
        ts = _ts(now)
        print(f"[sim] Round {round_num} at {ts}")

        readings_this_round = 0
        alerts_this_round = 0

        with conn.cursor() as cur:
            for dev_id, dev_name, dev_type, location in config.DEVICES:
                force_anomaly = random.random() < config.ANOMALY_PROBABILITY
                value = generate_value(dev_id, dev_type, force_anomaly)
                meta = _sensor_meta(dev_type)
                unit = meta["unit"] if meta else ""

                db_insert_sensor(cur, dev_id, dev_type, value, unit, location, ts)
                readings_this_round += 1

                # Update device last_seen
                cur.execute(
                    "UPDATE iot_devices SET last_seen = %s, status = 'active' WHERE device_id = %s",
                    (ts, dev_id),
                )

                breached, direction, severity = is_alert(dev_type, value)
                if breached:
                    msg = build_alert_message(dev_type, location, value, direction)
                    db_insert_alert(cur, severity, msg, dev_id, dev_type)
                    alerts_this_round += 1
                    print(f"  ⚠  ALERT [{severity.upper()}] {msg}")
                else:
                    print(f"  ✓  {dev_name} ({location}): {value} {unit}")

            # Water quality reading every 6 rounds
            water_quality_counter += 1
            if water_quality_counter >= 6:
                water_quality_counter = 0
                for tank in ["Water Tank 1", "Water Tank 2"]:
                    ph = generate_value(f"wq-{tank}", "ph")
                    do_ = generate_value(f"wq-do-{tank}", "dissolved_oxygen")
                    turbidity = round(random.uniform(0.5, 5.0), 2)
                    ok = _api_post_water_quality(tank, ph, do_, turbidity)
                    if not ok:
                        db_insert_water_quality(cur, tank, ph, do_, turbidity)
                    print(f"  💧 Water quality logged for {tank}: pH={ph}, DO={do_} mg/L, turbidity={turbidity}")

        conn.commit()
        print(f"  → {readings_this_round} readings, {alerts_this_round} alerts\n")

        if max_rounds and round_num >= max_rounds:
            print(f"[sim] Reached {max_rounds} rounds. Exiting.")
            break

        time.sleep(config.SIMULATION_INTERVAL_SECONDS)


# ─────────────────────────────────────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="FarmOS IoT Sensor Simulator")
    parser.add_argument(
        "--seed", type=int, default=0, metavar="N",
        help="Insert N historical rounds instantly (no sleep) then exit.",
    )
    args = parser.parse_args()

    # ── 1. Connect to DB ────────────────────────────────────────────────────
    print(f"[init] Connecting to MySQL {config.DB_USER}@{config.DB_HOST}/{config.DB_NAME} …")
    try:
        conn = db_setup.get_connection()
    except Exception as exc:
        print(f"[init] ERROR: Cannot connect to MySQL: {exc}")
        print("       Make sure WAMP/MySQL is running and credentials are correct.")
        print(f"       Edit config.py or set DB_USER / DB_PASSWORD env vars.")
        sys.exit(1)

    # ── 2. Create tables if needed ──────────────────────────────────────────
    db_setup.setup_tables(conn)

    # ── 3. Try API login (non-fatal) ─────────────────────────────────────────
    _api_login()

    # ── 4. Register all devices ──────────────────────────────────────────────
    print("[init] Registering devices …")
    with conn.cursor() as cur:
        for dev_id, dev_name, dev_type, location in config.DEVICES:
            db_upsert_device(cur, dev_id, dev_name, dev_type, location)
            _api_register_device(dev_id, dev_name, dev_type, location)
    conn.commit()
    print(f"[init] {len(config.DEVICES)} devices registered.\n")

    # ── 5. Seed or live simulation ───────────────────────────────────────────
    try:
        if args.seed > 0:
            seed_historical(conn, args.seed)
        else:
            simulation_loop(conn, max_rounds=config.ROUNDS)
    except KeyboardInterrupt:
        print("\n[sim] Stopped by user.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
