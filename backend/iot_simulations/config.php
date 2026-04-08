<?php declare(strict_types=1);

$dbHost = getenv('DATABASE_HOST') !== false ? (string) getenv('DATABASE_HOST') : 'localhost';
$dbPort = getenv('DATABASE_PORT') !== false ? (int) getenv('DATABASE_PORT') : 3306;
$dbName = getenv('DATABASE_NAME') !== false ? (string) getenv('DATABASE_NAME') : 'begin_masimba_farm';
$dbUser = getenv('DB_USER') !== false ? (string) getenv('DB_USER') : 'root';
$dbPassword = getenv('DB_PASSWORD') !== false ? (string) getenv('DB_PASSWORD') : '';

$apiBaseUrl = getenv('API_BASE_URL') !== false ? (string) getenv('API_BASE_URL') : 'http://localhost/farmos/app/backend/public';
$apiEmail = getenv('API_EMAIL') !== false ? (string) getenv('API_EMAIL') : 'admin@example.com';
$apiPassword = getenv('API_PASSWORD') !== false ? (string) getenv('API_PASSWORD') : 'password123';

$simulationIntervalSeconds = getenv('SIM_INTERVAL') !== false ? (int) getenv('SIM_INTERVAL') : 10;
$rounds = getenv('SIM_ROUNDS') !== false ? (int) getenv('SIM_ROUNDS') : 0;
$anomalyProbability = 0.08;

$sensorTypes = [
    'temperature' => ['unit' => '°C', 'norm_min' => 16.0, 'norm_max' => 30.0, 'alert_min' => 5.0, 'alert_max' => 38.0, 'severity' => 'warning'],
    'humidity' => ['unit' => '%', 'norm_min' => 40.0, 'norm_max' => 75.0, 'alert_min' => 20.0, 'alert_max' => 90.0, 'severity' => 'warning'],
    'ammonia' => ['unit' => 'ppm', 'norm_min' => 0.0, 'norm_max' => 25.0, 'alert_min' => 0.0, 'alert_max' => 40.0, 'severity' => 'critical'],
    'co2' => ['unit' => 'ppm', 'norm_min' => 400.0, 'norm_max' => 2000.0, 'alert_min' => 300.0, 'alert_max' => 3000.0, 'severity' => 'warning'],
    'soil_moisture' => ['unit' => '%', 'norm_min' => 20.0, 'norm_max' => 60.0, 'alert_min' => 10.0, 'alert_max' => 80.0, 'severity' => 'warning'],
    'light' => ['unit' => 'lux', 'norm_min' => 0.0, 'norm_max' => 80000.0, 'alert_min' => 0.0, 'alert_max' => 110000.0, 'severity' => 'warning'],
    'ph' => ['unit' => 'pH', 'norm_min' => 6.0, 'norm_max' => 7.5, 'alert_min' => 4.5, 'alert_max' => 9.0, 'severity' => 'critical'],
    'water_level' => ['unit' => 'cm', 'norm_min' => 30.0, 'norm_max' => 200.0, 'alert_min' => 10.0, 'alert_max' => 210.0, 'severity' => 'warning'],
    'dissolved_oxygen' => ['unit' => 'mg/L', 'norm_min' => 5.0, 'norm_max' => 12.0, 'alert_min' => 3.0, 'alert_max' => 15.0, 'severity' => 'critical'],
    'weight' => ['unit' => 'kg', 'norm_min' => 50.0, 'norm_max' => 500.0, 'alert_min' => 20.0, 'alert_max' => 600.0, 'severity' => 'warning'],
];

$devices = [
    ['id' => 'dev-temp-barn1', 'name' => 'Barn 1 Temperature', 'type' => 'temperature', 'location' => 'Barn 1'],
    ['id' => 'dev-temp-barn2', 'name' => 'Barn 2 Temperature', 'type' => 'temperature', 'location' => 'Barn 2'],
    ['id' => 'dev-hum-barn1', 'name' => 'Barn 1 Humidity', 'type' => 'humidity', 'location' => 'Barn 1'],
    ['id' => 'dev-hum-barn2', 'name' => 'Barn 2 Humidity', 'type' => 'humidity', 'location' => 'Barn 2'],
    ['id' => 'dev-nh3-barn1', 'name' => 'Barn 1 Ammonia', 'type' => 'ammonia', 'location' => 'Barn 1'],
    ['id' => 'dev-nh3-barn2', 'name' => 'Barn 2 Ammonia', 'type' => 'ammonia', 'location' => 'Barn 2'],
    ['id' => 'dev-co2-barn1', 'name' => 'Barn 1 CO2', 'type' => 'co2', 'location' => 'Barn 1'],
    ['id' => 'dev-soil-field-a', 'name' => 'Field A Soil Moisture', 'type' => 'soil_moisture', 'location' => 'Field A'],
    ['id' => 'dev-soil-field-b', 'name' => 'Field B Soil Moisture', 'type' => 'soil_moisture', 'location' => 'Field B'],
    ['id' => 'dev-temp-field-a', 'name' => 'Field A Temperature', 'type' => 'temperature', 'location' => 'Field A'],
    ['id' => 'dev-light-field-a', 'name' => 'Field A Light', 'type' => 'light', 'location' => 'Field A'],
    ['id' => 'dev-ph-tank1', 'name' => 'Water Tank 1 pH', 'type' => 'ph', 'location' => 'Water Tank 1'],
    ['id' => 'dev-ph-tank2', 'name' => 'Water Tank 2 pH', 'type' => 'ph', 'location' => 'Water Tank 2'],
    ['id' => 'dev-wl-tank1', 'name' => 'Water Tank 1 Level', 'type' => 'water_level', 'location' => 'Water Tank 1'],
    ['id' => 'dev-wl-tank2', 'name' => 'Water Tank 2 Level', 'type' => 'water_level', 'location' => 'Water Tank 2'],
    ['id' => 'dev-do-tank1', 'name' => 'Water Tank 1 DO', 'type' => 'dissolved_oxygen', 'location' => 'Water Tank 1'],
    ['id' => 'dev-wt-bin1', 'name' => 'Feed Bin 1 Weight', 'type' => 'weight', 'location' => 'Feed Bin 1'],
    ['id' => 'dev-wt-bin2', 'name' => 'Feed Bin 2 Weight', 'type' => 'weight', 'location' => 'Feed Bin 2'],
    ['id' => 'dev-temp-store', 'name' => 'Storage Temperature', 'type' => 'temperature', 'location' => 'Storage Room'],
    ['id' => 'dev-hum-store', 'name' => 'Storage Humidity', 'type' => 'humidity', 'location' => 'Storage Room'],
];

$alertMessages = [
    'temperature' => ['High temperature detected in %s: %.1f °C', 'Low temperature detected in %s: %.1f °C'],
    'humidity' => ['High humidity in %s: %.1f%%', 'Low humidity in %s: %.1f%%'],
    'soil_moisture' => ['Soil over-saturated in %s: %.1f%%', 'Soil too dry in %s: %.1f%%'],
    'ph' => ['pH critical HIGH in %s: %.2f', 'pH critical LOW in %s: %.2f'],
    'ammonia' => ['Dangerous ammonia level in %s: %.1f ppm', 'Ammonia sensor fault in %s: %.1f ppm'],
    'water_level' => ['Water tank overflow risk in %s: %.1f cm', 'Water level critically low in %s: %.1f cm'],
    'weight' => ['Feed bin overloaded in %s: %.1f kg', 'Feed bin nearly empty in %s: %.1f kg'],
    'co2' => ['High CO2 in %s: %.0f ppm', 'CO2 sensor fault in %s: %.0f ppm'],
    'dissolved_oxygen' => ['DO critically LOW in %s: %.2f mg/L', 'DO abnormally HIGH in %s: %.2f mg/L'],
    'light' => ['Extreme light intensity in %s: %.0f lux', 'No light detected in %s: %.0f lux'],
];

return [
    'db' => [
        'host' => $dbHost,
        'port' => $dbPort,
        'name' => $dbName,
        'user' => $dbUser,
        'password' => $dbPassword,
    ],
    'api' => [
        'base_url' => rtrim($apiBaseUrl, '/'),
        'email' => $apiEmail,
        'password' => $apiPassword,
    ],
    'simulation' => [
        'interval_seconds' => max(0, $simulationIntervalSeconds),
        'rounds' => max(0, $rounds),
        'anomaly_probability' => $anomalyProbability,
    ],
    'sensors' => [
        'types' => $sensorTypes,
        'devices' => $devices,
        'alert_messages' => $alertMessages,
    ],
];
