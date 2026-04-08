# FarmOS IoT Sensor Simulator

Simulates **20 IoT devices** across barns, fields, water tanks, and feed bins and
populates the FarmOS database with realistic sensor readings so every dashboard,
chart, and alert page works with test data.

## Sensors simulated

| Type | Unit | Locations |
|------|------|-----------|
| Temperature | °C | Barn 1, Barn 2, Field A, Storage Room |
| Humidity | % | Barn 1, Barn 2, Storage Room |
| Ammonia | ppm | Barn 1, Barn 2 |
| CO₂ | ppm | Barn 1 |
| Soil Moisture | % | Field A, Field B |
| Light Intensity | lux | Field A |
| Water pH | pH | Water Tank 1, Water Tank 2 |
| Water Level | cm | Water Tank 1, Water Tank 2 |
| Dissolved Oxygen | mg/L | Water Tank 1 |
| Feed Bin Weight | kg | Feed Bin 1, Feed Bin 2 |

About **8 %** of readings are randomly pushed outside the normal range to
generate IoT alerts for testing.

## Files

```
backend/iot_simulations/
├── config.php       – all thresholds, device list, DB & API settings
├── db_setup.php     – creates the 4 IoT tables if they are missing
├── simulate.php     – main runner
└── README.md        – this file
```

## Quick start

### 1. Configure credentials (if needed)

The simulator uses the same database as the FarmOS app
(`begin_masimba_farm`, `root`, no password by default).

If your MySQL `root` account has a password, set it as an environment variable:

```powershell
$env:DB_PASSWORD = "your_mysql_password"
```

Or edit `config.php` directly.

### 2. Seed historical data (recommended first step)

This inserts **144 rounds × 20 devices = 2 880 readings** back-dated over the
last 24 hours – no waiting required.

```powershell
php simulate.php --seed 144
```

### 3. Run the live simulator

```powershell
php simulate.php                              # run forever, new reading every 10 s
$env:SIM_INTERVAL = "5"; php simulate.php     # every 5 seconds
$env:SIM_ROUNDS   = "100"; php simulate.php   # stop after 100 rounds
```

Press **Ctrl-C** to stop at any time.

## API endpoints populated

| Endpoint | Table | How |
|---|---|---|
| `GET /api/iot/sensors/latest` | `sensor_data` | direct DB insert |
| `GET /api/iot/devices` | `iot_devices` | direct DB + API POST |
| `GET /api/iot/alerts` | `iot_alerts` | direct DB insert |
| `GET /api/iot/water-quality` | `water_quality_logs` | API POST, fallback to DB |

## Troubleshooting

**Cannot connect to MySQL**
- Make sure WAMP is running (green icon in system tray).
- If root has a password set `$env:DB_PASSWORD = "…"`.

**Access denied for root**
- Open phpMyAdmin (`http://localhost/phpmyadmin`), log in, and check
  the password for the `root` account.  Then set `$env:DB_PASSWORD`.

**API login fails**
- This is non-fatal.  Device registration and water-quality inserts fall back
  to direct DB writes automatically.
- If you want API auth to work, make sure the PHP backend is running and that
  `API_EMAIL` / `API_PASSWORD` in `config.php` match a real FarmOS user.
