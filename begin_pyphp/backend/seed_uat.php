<?php declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(400);
    echo "CLI only\n";
    exit(1);
}

require_once __DIR__ . '/config/env.php';
require_once __DIR__ . '/vendor/autoload.php';

use FarmOS\{Database, Security, Logger};

Logger::init(sys_get_temp_dir() . '/farmos-uat-seed', 'json');
Security::init(getenv('JWT_SECRET'));

$dsn = (string) getenv('DATABASE_URL');
$user = (string) (getenv('DB_USER') ?: 'root');
$pass = (string) (getenv('DB_PASSWORD') ?: '');

$db = Database::init($dsn, $user, $pass);

$adminEmail = (string) (getenv('UAT_ADMIN_EMAIL') ?: 'admin@example.com');
$adminPassword = (string) (getenv('UAT_ADMIN_PASSWORD') ?: '');
if ($adminPassword === '') {
    $adminPassword = 'Uat!' . bin2hex(random_bytes(12)) . 'Aa1';
}

$row = $db->queryOne('SELECT id FROM users WHERE email = ? LIMIT 1', [$adminEmail]);
if ($row) {
    $adminId = (int) $row['id'];
    $passwordOut = '(unchanged)';
} else {
    $hash = Security::hashPassword($adminPassword);
    $db->execute(
        'INSERT INTO users (email, password_hash, first_name, last_name, role, status) VALUES (?, ?, ?, ?, ?, ?)',
        [$adminEmail, $hash, 'UAT', 'Admin', 'admin', 'active']
    );
    $adminId = (int) $db->lastInsertId();
    $passwordOut = $adminPassword;
}

$farmRow = $db->queryOne('SELECT id FROM farms WHERE owner_id = ? ORDER BY id ASC LIMIT 1', [$adminId]);
if ($farmRow) {
    $farmId = (int) $farmRow['id'];
} else {
    $db->execute(
        'INSERT INTO farms (owner_id, name, type, location) VALUES (?, ?, ?, ?)',
        [$adminId, 'UAT Farm', 'mixed', 'UAT']
    );
    $farmId = (int) $db->lastInsertId();
}

$inventoryItems = [
    ['Maize Feed', 'feed', 250, 'kg', 0, 500, 0.85, 'UAT Supplier', 'Store A'],
    ['Vaccine A', 'medicine', 40, 'units', 10, 100, 2.50, 'Vet Supplier', 'Clinic'],
    ['Diesel', 'fuel', 600, 'liters', 100, 1000, 1.20, 'Fuel Depot', 'Tank'],
];

foreach ($inventoryItems as $item) {
    [$name, $category, $qty, $unit, $min, $max, $cpu, $supplier, $location] = $item;
    $exists = $db->queryOne('SELECT id FROM inventory WHERE farm_id = ? AND name = ? LIMIT 1', [$farmId, $name]);
    if ($exists) {
        continue;
    }
    $db->execute(
        'INSERT INTO inventory (farm_id, name, category, quantity, unit, min_level, max_level, cost_per_unit, supplier, location) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [$farmId, $name, $category, $qty, $unit, $min, $max, $cpu, $supplier, $location]
    );
}

$livestockBatches = [
    ['Batch A', 'cattle', 'Brahman', 'female', 420.0],
    ['Batch B', 'goat', 'Boer', 'male', 55.5],
    ['Batch C', 'sheep', 'Dorper', 'female', 65.0],
];

foreach ($livestockBatches as $batch) {
    [$name, $species, $breed, $gender, $weight] = $batch;
    $exists = $db->queryOne('SELECT id FROM livestock WHERE farm_id = ? AND name = ? LIMIT 1', [$farmId, $name]);
    if ($exists) {
        continue;
    }
    $db->execute(
        'INSERT INTO livestock (farm_id, name, species, breed, gender, weight, status, acquisition_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [$farmId, $name, $species, $breed, $gender, $weight, 'active', date('Y-m-d')]
    );
}

$tasks = [
    ['Daily water check', 'Verify water points are clean and filled', 'high'],
    ['Inventory count', 'Count feed stock and record variances', 'medium'],
    ['Vet check', 'Routine inspection for Batch A', 'medium'],
];

foreach ($tasks as $task) {
    [$title, $desc, $prio] = $task;
    $exists = $db->queryOne('SELECT id FROM tasks WHERE farm_id = ? AND title = ? LIMIT 1', [$farmId, $title]);
    if ($exists) {
        continue;
    }
    $db->execute(
        'INSERT INTO tasks (farm_id, title, description, status, priority, created_by) VALUES (?, ?, ?, ?, ?, ?)',
        [$farmId, $title, $desc, 'pending', $prio, $adminId]
    );
}

echo "Seeded UAT data.\n";
echo "Admin: {$adminEmail}\n";
echo "Password: {$passwordOut}\n";
echo "Farm ID: {$farmId}\n";
