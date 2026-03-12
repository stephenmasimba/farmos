"""
FarmOS IoT Simulation Configuration
=====================================
Adjust the values below to match your local environment.
"""

import os

# ---------------------------------------------------------------------------
# Database – connects directly to MySQL to insert sensor_data / iot_alerts
# (no HTTP endpoint exists for raw sensor pushes)
# ---------------------------------------------------------------------------
DB_HOST     = os.getenv("DATABASE_HOST",     "localhost")
DB_PORT     = int(os.getenv("DATABASE_PORT", "3306"))
DB_NAME     = os.getenv("DATABASE_NAME",     "begin_masimba_farm")
DB_USER     = os.getenv("DB_USER",           "root")
DB_PASSWORD = os.getenv("DB_PASSWORD",       "")          # change if needed

# ---------------------------------------------------------------------------
# PHP/API backend  (used only for device registration & water-quality POSTs)
# Typical WAMP path:  http://localhost/farmos/begin_pyphp/backend/public
# ---------------------------------------------------------------------------
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost/farmos/begin_pyphp/backend/public")
API_EMAIL    = os.getenv("API_EMAIL",    "admin@example.com")
API_PASSWORD = os.getenv("API_PASSWORD", "password123")

# ---------------------------------------------------------------------------
# Simulation behaviour
# ---------------------------------------------------------------------------
SIMULATION_INTERVAL_SECONDS = int(os.getenv("SIM_INTERVAL", "10"))   # delay between rounds
ROUNDS = int(os.getenv("SIM_ROUNDS", "0"))                           # 0 = run forever
ANOMALY_PROBABILITY = 0.08   # ~8 % chance a reading breaches threshold → triggers alert

# ---------------------------------------------------------------------------
# Sensor definitions
# Each entry: (sensor_type, unit, normal_min, normal_max, alert_min, alert_max, alert_severity)
# ---------------------------------------------------------------------------
SENSOR_TYPES = [
    # type               unit      norm_min  norm_max  alert_min  alert_max  severity
    ("temperature",      "°C",       16.0,    30.0,      5.0,      38.0,    "warning"),
    ("humidity",         "%",        40.0,    75.0,     20.0,      90.0,    "warning"),
    ("soil_moisture",    "%",        20.0,    60.0,     10.0,      80.0,    "warning"),
    ("ph",               "pH",        6.0,     7.5,      4.5,       9.0,    "critical"),
    ("ammonia",          "ppm",       0.0,    25.0,      0.0,      40.0,    "critical"),
    ("water_level",      "cm",       30.0,   200.0,     10.0,     210.0,    "warning"),
    ("weight",           "kg",       50.0,   500.0,     20.0,     600.0,    "warning"),
    ("co2",              "ppm",     400.0,  2000.0,    300.0,    3000.0,    "warning"),
    ("light",            "lux",       0.0, 80000.0,      0.0,  110000.0,    "warning"),
    ("dissolved_oxygen", "mg/L",      5.0,    12.0,      3.0,      15.0,    "critical"),
]

# ---------------------------------------------------------------------------
# IoT Device registry
# Format: (device_id, device_name, device_type, location)
# device_type should match one of the sensor_type strings above
# ---------------------------------------------------------------------------
DEVICES = [
    # Barns – temperature & humidity & ammonia & CO2
    ("dev-temp-barn1",   "Barn 1 Temperature",   "temperature",      "Barn 1"),
    ("dev-temp-barn2",   "Barn 2 Temperature",   "temperature",      "Barn 2"),
    ("dev-hum-barn1",    "Barn 1 Humidity",       "humidity",         "Barn 1"),
    ("dev-hum-barn2",    "Barn 2 Humidity",       "humidity",         "Barn 2"),
    ("dev-nh3-barn1",    "Barn 1 Ammonia",        "ammonia",          "Barn 1"),
    ("dev-nh3-barn2",    "Barn 2 Ammonia",        "ammonia",          "Barn 2"),
    ("dev-co2-barn1",    "Barn 1 CO2",            "co2",              "Barn 1"),

    # Fields – soil moisture, temperature, light
    ("dev-soil-field-a", "Field A Soil Moisture", "soil_moisture",    "Field A"),
    ("dev-soil-field-b", "Field B Soil Moisture", "soil_moisture",    "Field B"),
    ("dev-temp-field-a", "Field A Temperature",   "temperature",      "Field A"),
    ("dev-light-field-a","Field A Light",          "light",            "Field A"),

    # Water systems – pH, level, dissolved oxygen
    ("dev-ph-tank1",     "Water Tank 1 pH",        "ph",               "Water Tank 1"),
    ("dev-ph-tank2",     "Water Tank 2 pH",        "ph",               "Water Tank 2"),
    ("dev-wl-tank1",     "Water Tank 1 Level",     "water_level",      "Water Tank 1"),
    ("dev-wl-tank2",     "Water Tank 2 Level",     "water_level",      "Water Tank 2"),
    ("dev-do-tank1",     "Water Tank 1 DO",        "dissolved_oxygen", "Water Tank 1"),

    # Feed bins – weight
    ("dev-wt-bin1",      "Feed Bin 1 Weight",      "weight",           "Feed Bin 1"),
    ("dev-wt-bin2",      "Feed Bin 2 Weight",      "weight",           "Feed Bin 2"),

    # Storage – temperature & humidity
    ("dev-temp-store",   "Storage Temperature",    "temperature",      "Storage Room"),
    ("dev-hum-store",    "Storage Humidity",       "humidity",         "Storage Room"),
]

# Friendly messages for alert generation
ALERT_MESSAGES = {
    "temperature":      ("High temperature detected in {location}: {value:.1f} °C",
                         "Low temperature detected in {location}: {value:.1f} °C"),
    "humidity":         ("High humidity in {location}: {value:.1f}%",
                         "Low humidity in {location}: {value:.1f}%"),
    "soil_moisture":    ("Soil over-saturated in {location}: {value:.1f}%",
                         "Soil too dry in {location}: {value:.1f}%"),
    "ph":               ("pH critical HIGH in {location}: {value:.2f}",
                         "pH critical LOW in {location}: {value:.2f}"),
    "ammonia":          ("Dangerous ammonia level in {location}: {value:.1f} ppm",
                         "Ammonia sensor fault in {location}: {value:.1f} ppm"),
    "water_level":      ("Water tank overflow risk in {location}: {value:.1f} cm",
                         "Water level critically low in {location}: {value:.1f} cm"),
    "weight":           ("Feed bin overloaded in {location}: {value:.1f} kg",
                         "Feed bin nearly empty in {location}: {value:.1f} kg"),
    "co2":              ("High CO2 in {location}: {value:.0f} ppm",
                         "CO2 sensor fault in {location}: {value:.0f} ppm"),
    "dissolved_oxygen": ("DO critically LOW in {location}: {value:.2f} mg/L",
                         "DO abnormally HIGH in {location}: {value:.2f} mg/L"),
    "light":            ("Extreme light intensity in {location}: {value:.0f} lux",
                         "No light detected in {location}: {value:.0f} lux"),
}
