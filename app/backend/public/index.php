<?php

// Load environment
require_once __DIR__ . '/../config/env.php';

// Autoload classes
require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../src/Middleware/Middleware.php';

use FarmOS\{Request, Response, Logger, Security, Database, RateLimiter, Validation, Auth};

// Initialize
error_reporting(E_ALL);
ini_set('display_errors', isset($GLOBALS['__FARMOS_TEST_RAW_BODY']) ? '1' : '0');

Logger::init(
    getenv('LOG_DIR') ?: '/var/log/farmos',
    getenv('LOG_FORMAT') ?: 'json'
);

if (empty($_SERVER['HTTP_X_REQUEST_ID'])) {
    $_SERVER['HTTP_X_REQUEST_ID'] = bin2hex(random_bytes(16));
}
Logger::setRequestId((string) $_SERVER['HTTP_X_REQUEST_ID']);

Security::init(getenv('JWT_SECRET'));

// Create request/response
$request = new Request();
$method = $request->getMethod();
$path = $request->getPath();
$requestStartedAt = microtime(true);

$corsOriginRaw = trim((string) (getenv('CORS_ORIGIN') ?: ''));
$corsMethods = trim((string) (getenv('CORS_METHODS') ?: 'GET,POST,PUT,PATCH,DELETE,OPTIONS'));
$corsHeaders = trim((string) (getenv('CORS_HEADERS') ?: 'Content-Type,Authorization,Accept,X-API-Key,X-Tenant-ID,X-Requested-With,X-Request-ID'));
$origin = (string) ($_SERVER['HTTP_ORIGIN'] ?? '');
$appUrl = trim((string) (getenv('APP_URL') ?: ''));
$allowedOrigins = [];
if ($corsOriginRaw !== '' && $corsOriginRaw !== '*') {
    $allowedOrigins = array_values(array_unique(array_filter(array_map(
        'trim',
        array_merge(explode(',', $corsOriginRaw), [$appUrl])
    ))));
}

$corsAllowOrigin = null;
if ($corsOriginRaw === '*') {
    $corsAllowOrigin = '*';
} elseif ($origin !== '' && in_array($origin, $allowedOrigins, true)) {
    $corsAllowOrigin = $origin;
} elseif ($origin === '' && $corsOriginRaw !== '' && $corsOriginRaw !== '*') {
    $corsAllowOrigin = $allowedOrigins[0] ?? null;
}

// CORS handling
if ($method === 'OPTIONS') {
    if (!headers_sent()) {
        if ($corsAllowOrigin !== null) {
            header('Access-Control-Allow-Origin: ' . $corsAllowOrigin);
            header('Vary: Origin');
        }
        header('Access-Control-Allow-Methods: ' . $corsMethods);
        header('Access-Control-Allow-Headers: ' . $corsHeaders);
        header('Access-Control-Max-Age: 3600');
    }
    Response::success()->send();
    if (!isset($GLOBALS['__FARMOS_TEST_RAW_BODY'])) {
        exit;
    }
    return;
}

// Add CORS headers
if (!headers_sent()) {
    if ($corsAllowOrigin !== null) {
        header('Access-Control-Allow-Origin: ' . $corsAllowOrigin);
        header('Vary: Origin');
    }
    header('Access-Control-Allow-Headers: ' . $corsHeaders);
}

// Health check without DB
if ($path === '/health') {
    if ($method !== 'GET') {
        Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
    } else {
        Response::success(['status' => 'ok'])->send();
    }
    if (!isset($GLOBALS['__FARMOS_TEST_RAW_BODY'])) {
        exit;
    }
    return;
}

$stateChanging = in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true);
if ($stateChanging) {
    if ($request->isJsonInvalid()) {
        Response::error('Invalid JSON', 'INVALID_JSON', 400)->send();
        if (!isset($GLOBALS['__FARMOS_TEST_RAW_BODY'])) {
            exit;
        }
        return;
    }

    if ($origin !== '' && $corsOriginRaw !== '*' && !in_array($origin, $allowedOrigins, true)) {
        Response::error('Forbidden', 'FORBIDDEN', 403)->send();
        if (!isset($GLOBALS['__FARMOS_TEST_RAW_BODY'])) {
            exit;
        }
        return;
    }
}

try {
    $db = Database::init(
        getenv('DATABASE_URL'),
        getenv('DB_USER') ?: 'farmos_user',
        getenv('DB_PASSWORD')
    );
} catch (\Exception $e) {
    Response::error('Database connection failed', 'DB_ERROR', 503)->send();
    if (!isset($GLOBALS['__FARMOS_TEST_RAW_BODY'])) {
        exit;
    }
    return;
}

// Rate limiting
$clientIP = $request->getIP();

if (!isset($GLOBALS['__FARMOS_TEST_RAW_BODY']) && (getenv('API_ANALYTICS_ENABLED') ?: 'false') === 'true') {
    register_shutdown_function(static function () use ($requestStartedAt, $request, $db, $method, $path, $clientIP): void {
        try {
            static $ensured = false;
            if (!$ensured) {
                $db->execute(
                    'CREATE TABLE IF NOT EXISTS api_request_logs (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                        method VARCHAR(10) NOT NULL,
                        path VARCHAR(255) NOT NULL,
                        status_code INT NOT NULL,
                        duration_ms INT NOT NULL,
                        ip VARCHAR(64) NULL,
                        user_id INT NULL,
                        user_agent VARCHAR(255) NULL,
                        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        INDEX idx_created_at (created_at),
                        INDEX idx_path (path),
                        INDEX idx_status_code (status_code),
                        INDEX idx_user_id (user_id)
                    )'
                );
                $ensured = true;
            }

            $durationMs = (int) round((microtime(true) - $requestStartedAt) * 1000);
            $status = (int) http_response_code();
            $user = $request->getUser();
            $userId = $user['user_id'] ?? null;
            $ua = $_SERVER['HTTP_USER_AGENT'] ?? null;

            $db->execute(
                'INSERT INTO api_request_logs (method, path, status_code, duration_ms, ip, user_id, user_agent) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [$method, $path, $status, $durationMs, $clientIP, $userId, $ua]
            );
        } catch (\Throwable $e) {
        }
    });
}

// Initialize controllers
use FarmOS\Controllers\{LivestockController, InventoryController, FinancialController, TaskController, DashboardController, WeatherController, IoTController, UsersController, SystemController, FieldsController, EquipmentController, SuppliersController, NotificationsController, TimesheetsController, HRController, ContractsController, PaymentsController, MarketplaceController, SalesCRMController, ComplianceController, VeterinaryController, FeedController, FeedFormulationController, ProductionManagementController, WasteController, PredictiveMaintenanceController, FinancialAnalyticsController, TraceabilityController, QRInventoryController, ImportController, WeatherIrrigationController, BreedingController, CircularityController, BiogasController, AccountingPlatformController, InventoryPlatformController, LivestockPlatformController};
use FarmOS\Middleware\{AuthMiddleware, RateLimitMiddleware};

$livestockController = new LivestockController($db, $request);
$inventoryController = new InventoryController($db, $request);
$financialController = new FinancialController($db, $request);
$taskController = new TaskController($db, $request);
$dashboardController = new DashboardController($db, $request);
$weatherController = new WeatherController($db, $request);
$iotController = new IoTController($db, $request);
$usersController = new UsersController($db, $request);
$systemController = new SystemController($db, $request);
$fieldsController = new FieldsController($db, $request);
$equipmentController = new EquipmentController($db, $request);
$suppliersController = new SuppliersController($db, $request);
$notificationsController = new NotificationsController($db, $request);
$timesheetsController = new TimesheetsController($db, $request);
$hrController = new HRController($db, $request);
$contractsController = new ContractsController($db, $request);
$paymentsController = new PaymentsController($db, $request);
$marketplaceController = new MarketplaceController($db, $request);
$salesCRMController = new SalesCRMController($db, $request);
$complianceController = new ComplianceController($db, $request);
$veterinaryController = new VeterinaryController($db, $request);
$feedController = new FeedController($db, $request);
$feedFormulationController = new FeedFormulationController($db, $request);
$productionManagementController = new ProductionManagementController($db, $request);
$wasteController = new WasteController($db, $request);
$predictiveMaintenanceController = new PredictiveMaintenanceController($db, $request);
$financialAnalyticsController = new FinancialAnalyticsController($db, $request);
$traceabilityController = new TraceabilityController($db, $request);
$qrInventoryController = new QRInventoryController($db, $request);
$importController = new ImportController($db, $request);
$weatherIrrigationController = new WeatherIrrigationController($db, $request);
$breedingController = new BreedingController($db, $request);
$circularityController = new CircularityController($db, $request);
$biogasController = new BiogasController($db, $request);
$accountingPlatformController = new AccountingPlatformController($db, $request);
$inventoryPlatformController = new InventoryPlatformController($db, $request);
$livestockPlatformController = new LivestockPlatformController($db, $request);

$ensureMobileSupportTables = static function () use ($db): void {
    $db->execute(
        'CREATE TABLE IF NOT EXISTS task_comments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            task_id INT NOT NULL,
            user_id INT NOT NULL,
            content TEXT NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_task_comments_task (task_id, created_at),
            INDEX idx_task_comments_user (user_id)
        )'
    );

    $db->execute(
        'CREATE TABLE IF NOT EXISTS livestock_weights (
            id INT AUTO_INCREMENT PRIMARY KEY,
            livestock_id INT NOT NULL,
            weight_kg DECIMAL(10,2) NOT NULL,
            date DATETIME NOT NULL,
            notes TEXT NULL,
            created_by INT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_livestock_weights_livestock (livestock_id, date)
        )'
    );

    $db->execute(
        'CREATE TABLE IF NOT EXISTS financial_attachments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            transaction_id INT NOT NULL,
            file_url VARCHAR(255) NOT NULL,
            file_name VARCHAR(255) NOT NULL,
            mime_type VARCHAR(100) NULL,
            created_by INT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_financial_attachments_txn (transaction_id, created_at)
        )'
    );

    $db->execute(
        'CREATE TABLE IF NOT EXISTS weather_alerts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            type VARCHAR(50) NOT NULL,
            message TEXT NOT NULL,
            severity VARCHAR(20) NOT NULL DEFAULT "info",
            location VARCHAR(255) NULL,
            issued_at DATETIME NOT NULL,
            expires_at DATETIME NULL,
            status VARCHAR(20) NOT NULL DEFAULT "active",
            acknowledged TINYINT(1) NOT NULL DEFAULT 0,
            acknowledged_by INT NULL,
            acknowledged_at DATETIME NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_weather_alerts_active (status, type, issued_at)
        )'
    );

    $db->execute(
        'CREATE TABLE IF NOT EXISTS mobile_device_tokens (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            device_token VARCHAR(255) NOT NULL,
            platform VARCHAR(30) NOT NULL DEFAULT "mobile",
            last_seen_at DATETIME NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uniq_device_token (device_token),
            INDEX idx_mobile_tokens_user (user_id)
        )'
    );

    $db->execute(
        'CREATE TABLE IF NOT EXISTS user_farm_preferences (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            farm_id INT NOT NULL,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY uniq_user_farm_preference (user_id)
        )'
    );

    $db->execute(
        'CREATE TABLE IF NOT EXISTS field_boundaries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            field_id INT NOT NULL,
            farm_id INT NULL,
            boundary_geojson LONGTEXT NULL,
            boundary_points_json LONGTEXT NULL,
            area_hectares DECIMAL(10,2) NULL,
            created_by INT NULL,
            updated_by INT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY uniq_field_boundary (field_id),
            INDEX idx_field_boundary_farm (farm_id)
        )'
    );

    $db->execute(
        'CREATE TABLE IF NOT EXISTS farms (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_id INT NULL,
            name VARCHAR(255) NOT NULL,
            location VARCHAR(255) NULL,
            city VARCHAR(100) NULL,
            state VARCHAR(100) NULL,
            country VARCHAR(100) NULL,
            zip_code VARCHAR(20) NULL,
            latitude DECIMAL(10,7) NULL,
            longitude DECIMAL(10,7) NULL,
            size DECIMAL(10,2) NULL,
            size_unit VARCHAR(20) NULL,
            type VARCHAR(100) NULL,
            established_year INT NULL,
            description TEXT NULL,
            logo_url VARCHAR(255) NULL,
            phone VARCHAR(50) NULL,
            email VARCHAR(255) NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )'
    );
};

$normalizeFarmPayload = static function (array $row): array {
    return [
        'id' => (int) ($row['id'] ?? 0),
        'owner_id' => isset($row['owner_id']) ? (int) $row['owner_id'] : 0,
        'name' => (string) ($row['name'] ?? ''),
        'location' => $row['location'] ?? null,
        'total_area_ha' => isset($row['size']) ? (float) $row['size'] : (isset($row['total_area_ha']) ? (float) $row['total_area_ha'] : null),
        'description' => $row['description'] ?? null,
        'created_at' => $row['created_at'] ?? null,
        'updated_at' => $row['updated_at'] ?? null,
        'city' => $row['city'] ?? null,
        'state' => $row['state'] ?? null,
        'country' => $row['country'] ?? null,
        'zip_code' => $row['zip_code'] ?? null,
        'latitude' => isset($row['latitude']) ? (float) $row['latitude'] : null,
        'longitude' => isset($row['longitude']) ? (float) $row['longitude'] : null,
        'type' => $row['type'] ?? null,
        'size_unit' => $row['size_unit'] ?? null,
    ];
};

$decodeBoundaryPoints = static function (?string $json): array {
    $points = json_decode((string) $json, true);
    if (!is_array($points)) {
        return [];
    }

    return array_values(array_filter(array_map(static function ($p): ?array {
        if (!is_array($p)) {
            return null;
        }
        if (!isset($p['latitude']) || !isset($p['longitude'])) {
            return null;
        }
        return [
            'latitude' => (float) $p['latitude'],
            'longitude' => (float) $p['longitude'],
        ];
    }, $points)));
};

// Routes
try {
    switch ($path) {
        // Health check
        case '/health':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }
            Response::success(['status' => 'ok'])->send();
            break;

        // Authentication endpoints
        case '/api/auth/login':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if (!RateLimiter::isAllowed($clientIP, 'auth')) {
                Response::rateLimited(60)->send();
                break;
            }

            $input = $request->getBody();
            
            if (empty($input['email']) || empty($input['password'])) {
                Response::validationError(['email', 'password'])->send();
                break;
            }

            $auth = new Auth($db);
            try {
                $result = $auth->login($input['email'], $input['password']);
                Response::success($result, 'Login successful')->send();
            } catch (\Exception $e) {
                if ($e->getMessage() === 'Invalid credentials') {
                    Response::unauthorized('Invalid credentials')->send();
                    break;
                }
                if ($e->getMessage() === 'Invalid email format') {
                    Response::validationError(['email' => 'Invalid email format'])->send();
                    break;
                }
                if ($e->getMessage() === 'Invalid password format') {
                    Response::validationError(['password' => 'Invalid password format'])->send();
                    break;
                }
                if ($e->getMessage() === 'User account is not active') {
                    Response::unauthorized('User account is not active')->send();
                    break;
                }
                throw $e;
            }
            break;

        case '/api/auth/register':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if (!RateLimiter::isAllowed($clientIP, 'auth')) {
                Response::rateLimited(60)->send();
                break;
            }

            $input = $request->getBody();
            
            if (empty($input['email']) || empty($input['password'])) {
                Response::validationError(['email', 'password'])->send();
                break;
            }

            $auth = new Auth($db);
            try {
                $result = $auth->register(
                    $input['email'],
                    $input['password'],
                    $input['first_name'] ?? null,
                    $input['last_name'] ?? null
                );
                Response::success($result, 'Registration successful', 201)->send();
            } catch (\Exception $e) {
                if ($e->getMessage() === 'Email already registered') {
                    Response::validationError(['email' => 'Email already registered'])->send();
                    break;
                }
                if ($e->getMessage() === 'Invalid email format') {
                    Response::validationError(['email' => 'Invalid email format'])->send();
                    break;
                }
                if (strpos($e->getMessage(), 'Password') === 0) {
                    Response::validationError(['password' => $e->getMessage()])->send();
                    break;
                }
                throw $e;
            }
            break;

        case '/api/auth/me':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }
            $authMw = new AuthMiddleware($request, $db);
            $authResult = $authMw->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $user = $request->getUser();

            $auth = new Auth($db);
            $userData = $auth->getUser($user['user_id']);
            if ($userData) {
                $farmId = (int) ($request->getQuery('farm_id', 1) ?: 1);
                $accessService = new \FarmOS\Services\AccessControlService($db);
                $userData['permissions'] = $accessService->getEffectivePermissions((int) $userData['id'], (string) ($userData['role'] ?? 'user'), $farmId);
                $userData['farm_id'] = $farmId;
            }
            Response::success($userData)->send();
            break;

        case '/api/auth/refresh-token':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if (!RateLimiter::isAllowed($clientIP, 'auth')) {
                Response::rateLimited(60)->send();
                break;
            }

            $user = $request->getUser();
            
            if (!$user) {
                Response::unauthorized()->send();
                break;
            }

            $auth = new Auth($db);
            $newToken = $auth->refreshToken($user);
            $expSecs = (int) (getenv('JWT_EXPIRY') ?: 3600);
            Response::success([
                'access_token' => $newToken,
                'token_type' => 'Bearer',
                'expires_in' => $expSecs,
            ])->send();
            break;

        case '/api/auth/refresh':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if (!RateLimiter::isAllowed($clientIP, 'auth')) {
                Response::rateLimited(60)->send();
                break;
            }

            $payload = $request->getBody();
            if (empty($payload['refresh_token'])) {
                Response::validationError(['refresh_token' => 'Required'])->send();
                break;
            }
            if (!is_string($payload['refresh_token']) || strlen($payload['refresh_token']) < 20) {
                Response::validationError(['refresh_token' => 'Invalid'])->send();
                break;
            }
            $auth = new Auth($db);
            try {
                $tokens = $auth->exchangeRefreshToken($payload['refresh_token']);
                Response::success($tokens)->send();
            } catch (\Exception $e) {
                Response::unauthorized($e->getMessage())->send();
            }
            break;

        case '/api/auth/logout':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if (!RateLimiter::isAllowed($clientIP, 'auth')) {
                Response::rateLimited(60)->send();
                break;
            }
            $user = $request->getUser();
            if (!$user) {
                Response::unauthorized()->send();
                break;
            }
            $auth = new Auth($db);
            $body = $request->getBody();
            if (!empty($body['refresh_token'])) {
                $auth->revokeRefreshToken($body['refresh_token']);
            }
            $auth->logout($user);
            Response::success(['message' => 'Logged out'])->send();
            break;

        case '/api/users':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $usersController->index()->send();
            } else {
                $usersController->store()->send();
            }
            break;

        case '/api/access/catalog':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $usersController->accessCatalog()->send();
            break;

        case '/api/access/audit':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $usersController->accessAudit()->send();
            break;

        case (preg_match('/^\/api\/users\/(\d+)\/access$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $usersController->userAccessProfile((string) $matches[1])->send();
            break;

        case (preg_match('/^\/api\/users\/(\d+)\/role$/', $path, $matches) ? true : false):
            if ($method !== 'PUT') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $usersController->assignRole((string) $matches[1])->send();
            break;

        case (preg_match('/^\/api\/users\/(\d+)\/permissions$/', $path, $matches) ? true : false):
            if (!in_array($method, ['PUT', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $usersController->replacePermissions((string) $matches[1])->send();
            break;

        case (preg_match('/^\/api\/users\/([^\/]+)$/', $path, $matches) ? true : false):
            if (!in_array($method, ['PUT', 'DELETE'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $userId = (string) $matches[1];
            if ($method === 'PUT') {
                $usersController->update($userId)->send();
            } else {
                $usersController->destroy($userId)->send();
            }
            break;

        case '/api/system':
            if (!in_array($method, ['GET', 'PUT'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $systemController->getSettings()->send();
            } else {
                $systemController->updateSettings()->send();
            }
            break;

        case '/api/tenants':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $systemController->listTenants()->send();
            break;

        case '/api/farms':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $user = $request->getUser();

            if ($method === 'GET') {
                $query = $request->getQuery();
                $type = strtolower(trim((string) ($query['type'] ?? '')));
                $sql = 'SELECT id, owner_id, name, location, city, state, country, zip_code, latitude, longitude,
                               size, size_unit, type, established_year, description, logo_url, phone, email,
                               created_at, updated_at
                        FROM farms';
                $params = [];

                if ($type !== '') {
                    if ($type === 'owned') {
                        $sql .= ' WHERE owner_id = ?';
                        $params[] = (int) ($user['user_id'] ?? 0);
                    } elseif ($type === 'managed') {
                        // For now managed maps to all farms visible to the authenticated user.
                    }
                }

                $sql .= ' ORDER BY name ASC, id ASC';
                $rows = $db->query($sql, $params);
                $payload = array_map($normalizeFarmPayload, $rows);
                Response::success($payload)->send();
                break;
            }

            $input = $request->getBody();
            $name = trim((string) ($input['name'] ?? ''));
            if ($name === '') {
                Response::validationError(['name' => 'Farm name is required'])->send();
                break;
            }

            $db->execute(
                'INSERT INTO farms (owner_id, name, location, city, state, country, zip_code, latitude, longitude, size, size_unit, type, established_year, description, logo_url, phone, email)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    (int) ($user['user_id'] ?? 0),
                    $name,
                    trim((string) ($input['location'] ?? '')),
                    trim((string) ($input['city'] ?? '')),
                    trim((string) ($input['state'] ?? '')),
                    trim((string) ($input['country'] ?? '')),
                    trim((string) ($input['zip_code'] ?? '')),
                    isset($input['latitude']) && is_numeric($input['latitude']) ? (float) $input['latitude'] : null,
                    isset($input['longitude']) && is_numeric($input['longitude']) ? (float) $input['longitude'] : null,
                    isset($input['total_area_ha']) && is_numeric($input['total_area_ha'])
                        ? (float) $input['total_area_ha']
                        : (isset($input['size']) && is_numeric($input['size']) ? (float) $input['size'] : null),
                    trim((string) ($input['size_unit'] ?? '')),
                    trim((string) ($input['type'] ?? '')),
                    isset($input['established_year']) && is_numeric($input['established_year']) ? (int) $input['established_year'] : null,
                    trim((string) ($input['description'] ?? '')),
                    trim((string) ($input['logo_url'] ?? '')),
                    trim((string) ($input['phone'] ?? '')),
                    trim((string) ($input['email'] ?? '')),
                ]
            );

            $created = $db->queryOne('SELECT * FROM farms WHERE id = ?', [(int) $db->lastInsertId()]);
            Response::success($normalizeFarmPayload($created ?? []), 'Farm created', 201)->send();
            break;

        case (preg_match('/^\/api\/farms\/(\d+)$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'PUT', 'DELETE'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $farmId = (int) $matches[1];
            $existingFarm = $db->queryOne('SELECT * FROM farms WHERE id = ?', [$farmId]);
            if (!$existingFarm) {
                Response::notFound('Farm not found')->send();
                break;
            }

            if ($method === 'GET') {
                Response::success($normalizeFarmPayload($existingFarm))->send();
                break;
            }

            if ($method === 'DELETE') {
                $db->execute('DELETE FROM farms WHERE id = ?', [$farmId]);
                Response::success(['deleted' => true])->send();
                break;
            }

            $input = $request->getBody();
            $name = trim((string) ($input['name'] ?? (string) ($existingFarm['name'] ?? '')));
            if ($name === '') {
                Response::validationError(['name' => 'Farm name is required'])->send();
                break;
            }

            $db->execute(
                'UPDATE farms
                 SET name = ?, location = ?, city = ?, state = ?, country = ?, zip_code = ?, latitude = ?, longitude = ?, size = ?,
                     size_unit = ?, type = ?, established_year = ?, description = ?, logo_url = ?, phone = ?, email = ?, updated_at = NOW()
                 WHERE id = ?',
                [
                    $name,
                    trim((string) ($input['location'] ?? (string) ($existingFarm['location'] ?? ''))),
                    trim((string) ($input['city'] ?? (string) ($existingFarm['city'] ?? ''))),
                    trim((string) ($input['state'] ?? (string) ($existingFarm['state'] ?? ''))),
                    trim((string) ($input['country'] ?? (string) ($existingFarm['country'] ?? ''))),
                    trim((string) ($input['zip_code'] ?? (string) ($existingFarm['zip_code'] ?? ''))),
                    isset($input['latitude']) && is_numeric($input['latitude']) ? (float) $input['latitude'] : (isset($existingFarm['latitude']) ? (float) $existingFarm['latitude'] : null),
                    isset($input['longitude']) && is_numeric($input['longitude']) ? (float) $input['longitude'] : (isset($existingFarm['longitude']) ? (float) $existingFarm['longitude'] : null),
                    isset($input['total_area_ha']) && is_numeric($input['total_area_ha'])
                        ? (float) $input['total_area_ha']
                        : (isset($input['size']) && is_numeric($input['size'])
                            ? (float) $input['size']
                            : (isset($existingFarm['size']) ? (float) $existingFarm['size'] : null)),
                    trim((string) ($input['size_unit'] ?? (string) ($existingFarm['size_unit'] ?? ''))),
                    trim((string) ($input['type'] ?? (string) ($existingFarm['type'] ?? ''))),
                    isset($input['established_year']) && is_numeric($input['established_year']) ? (int) $input['established_year'] : (isset($existingFarm['established_year']) ? (int) $existingFarm['established_year'] : null),
                    trim((string) ($input['description'] ?? (string) ($existingFarm['description'] ?? ''))),
                    trim((string) ($input['logo_url'] ?? (string) ($existingFarm['logo_url'] ?? ''))),
                    trim((string) ($input['phone'] ?? (string) ($existingFarm['phone'] ?? ''))),
                    trim((string) ($input['email'] ?? (string) ($existingFarm['email'] ?? ''))),
                    $farmId,
                ]
            );

            $updatedFarm = $db->queryOne('SELECT * FROM farms WHERE id = ?', [$farmId]);
            Response::success($normalizeFarmPayload($updatedFarm ?? []))->send();
            break;

        case (preg_match('/^\/api\/farms\/(\d+)\/preference$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'PUT'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $farmId = (int) $matches[1];
            $user = $request->getUser();
            $userId = (int) ($user['user_id'] ?? 0);

            $farm = $db->queryOne('SELECT id, name FROM farms WHERE id = ?', [$farmId]);
            if (!$farm) {
                Response::notFound('Farm not found')->send();
                break;
            }

            if ($method === 'GET') {
                $row = $db->queryOne('SELECT * FROM farms WHERE id = ?', [$farmId]);
                Response::success($normalizeFarmPayload($row ?? []))->send();
                break;
            }

            $db->execute(
                'INSERT INTO user_farm_preferences (user_id, farm_id)
                 VALUES (?, ?)
                 ON DUPLICATE KEY UPDATE farm_id = VALUES(farm_id), updated_at = CURRENT_TIMESTAMP',
                [$userId, $farmId]
            );

            $preferredFarm = $db->queryOne('SELECT * FROM farms WHERE id = ?', [$farmId]);
            Response::success($normalizeFarmPayload($preferredFarm ?? []))->send();
            break;

        case '/api/fields':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $fieldsController->index()->send();
            } else {
                $fieldsController->store()->send();
            }
            break;

        case '/api/fields/history':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->addHistory()->send();
            break;

        case '/api/fields/soil':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->addSoil()->send();
            break;

        case '/api/fields/harvest':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->addHarvest()->send();
            break;

        case '/api/fields/rotation':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->addRotation()->send();
            break;

        case '/api/fields/boundaries':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $query = $request->getQuery();
            $farmId = isset($query['farm_id']) && is_numeric($query['farm_id']) ? (int) $query['farm_id'] : 0;

            if ($method === 'GET') {
                $sql = 'SELECT fb.id, fb.field_id, fb.farm_id, fb.boundary_geojson, fb.boundary_points_json, fb.area_hectares,
                               fb.updated_at, f.name AS field_name
                        FROM field_boundaries fb
                        LEFT JOIN fields f ON f.id = fb.field_id';
                $params = [];
                if ($farmId > 0) {
                    $sql .= ' WHERE fb.farm_id = ?';
                    $params[] = $farmId;
                }
                $sql .= ' ORDER BY fb.updated_at DESC, fb.id DESC';
                $rows = $db->query($sql, $params);
                $payload = array_map(static function (array $row) use ($decodeBoundaryPoints): array {
                    return [
                        'field_id' => (int) ($row['field_id'] ?? 0),
                        'boundary_points' => $decodeBoundaryPoints($row['boundary_points_json'] ?? null),
                    ];
                }, $rows);
                Response::success($payload)->send();
                break;
            }

            $input = $request->getBody();
            $fieldId = isset($input['field_id']) && is_numeric($input['field_id']) ? (int) $input['field_id'] : 0;
            if ($fieldId <= 0) {
                Response::validationError(['field_id' => 'Field ID is required'])->send();
                break;
            }

            $field = $db->queryOne('SELECT id, farm_id FROM fields WHERE id = ?', [$fieldId]);
            if (!$field) {
                Response::notFound('Field not found')->send();
                break;
            }

            $points = $input['points'] ?? ($input['boundary_points'] ?? []);
            $geojson = $input['geojson'] ?? null;
            $areaHectares = isset($input['area_hectares']) && is_numeric($input['area_hectares']) ? (float) $input['area_hectares'] : null;
            $user = $request->getUser();
            $userId = (int) ($user['user_id'] ?? 0);

            $db->execute(
                'INSERT INTO field_boundaries (field_id, farm_id, boundary_geojson, boundary_points_json, area_hectares, created_by, updated_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE
                    farm_id = VALUES(farm_id),
                    boundary_geojson = VALUES(boundary_geojson),
                    boundary_points_json = VALUES(boundary_points_json),
                    area_hectares = VALUES(area_hectares),
                    updated_by = VALUES(updated_by),
                    updated_at = CURRENT_TIMESTAMP',
                [
                    $fieldId,
                    isset($input['farm_id']) && is_numeric($input['farm_id']) ? (int) $input['farm_id'] : (isset($field['farm_id']) ? (int) $field['farm_id'] : null),
                    $geojson !== null ? json_encode($geojson) : null,
                    json_encode($points),
                    $areaHectares,
                    $userId,
                    $userId,
                ]
            );

            $saved = $db->queryOne('SELECT field_id, boundary_points_json FROM field_boundaries WHERE field_id = ?', [$fieldId]);
            Response::success([
                'field_id' => (int) ($saved['field_id'] ?? 0),
                'boundary_points' => $decodeBoundaryPoints($saved['boundary_points_json'] ?? null),
            ], 'Field boundary saved', 201)->send();
            break;

        case (preg_match('/^\/api\/fields\/(\d+)\/boundary$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'POST', 'PUT', 'DELETE'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $fieldId = (int) $matches[1];

            if ($method === 'DELETE') {
                $db->execute('DELETE FROM field_boundaries WHERE field_id = ?', [$fieldId]);
                Response::success(['deleted' => true])->send();
                break;
            }

            if ($method === 'GET') {
                $boundary = $db->queryOne(
                    'SELECT field_id, boundary_points_json
                     FROM field_boundaries
                     WHERE field_id = ?',
                    [$fieldId]
                );
                if (!$boundary) {
                    Response::notFound('Field boundary not found')->send();
                    break;
                }
                Response::success([
                    'field_id' => (int) ($boundary['field_id'] ?? 0),
                    'boundary_points' => $decodeBoundaryPoints($boundary['boundary_points_json'] ?? null),
                ])->send();
                break;
            }

            $input = $request->getBody();
            $points = $input['points'] ?? ($input['boundary_points'] ?? []);
            $geojson = $input['geojson'] ?? null;
            $areaHectares = isset($input['area_hectares']) && is_numeric($input['area_hectares']) ? (float) $input['area_hectares'] : null;
            $field = $db->queryOne('SELECT id, farm_id FROM fields WHERE id = ?', [$fieldId]);
            if (!$field) {
                Response::notFound('Field not found')->send();
                break;
            }

            $user = $request->getUser();
            $userId = (int) ($user['user_id'] ?? 0);
            $db->execute(
                'INSERT INTO field_boundaries (field_id, farm_id, boundary_geojson, boundary_points_json, area_hectares, created_by, updated_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE
                    farm_id = VALUES(farm_id),
                    boundary_geojson = VALUES(boundary_geojson),
                    boundary_points_json = VALUES(boundary_points_json),
                    area_hectares = VALUES(area_hectares),
                    updated_by = VALUES(updated_by),
                    updated_at = CURRENT_TIMESTAMP',
                [
                    $fieldId,
                    isset($input['farm_id']) && is_numeric($input['farm_id']) ? (int) $input['farm_id'] : (isset($field['farm_id']) ? (int) $field['farm_id'] : null),
                    $geojson !== null ? json_encode($geojson) : null,
                    json_encode($points),
                    $areaHectares,
                    $userId,
                    $userId,
                ]
            );

            $updatedBoundary = $db->queryOne('SELECT field_id, boundary_points_json FROM field_boundaries WHERE field_id = ?', [$fieldId]);
            Response::success([
                'field_id' => (int) ($updatedBoundary['field_id'] ?? 0),
                'boundary_points' => $decodeBoundaryPoints($updatedBoundary['boundary_points_json'] ?? null),
            ])->send();
            break;

        case (preg_match('/^\/api\/fields\/(\d+)\/boundary-points$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $fieldId = (int) $matches[1];
            $boundary = $db->queryOne(
                'SELECT field_id, boundary_points_json FROM field_boundaries WHERE field_id = ?',
                [$fieldId]
            );
            if (!$boundary) {
                Response::notFound('Field boundary not found')->send();
                break;
            }

            $points = $decodeBoundaryPoints($boundary['boundary_points_json'] ?? null);
            Response::success($points)->send();
            break;

        case (preg_match('/^\/api\/fields\/(\d+)\/history$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->history((int) $matches[1])->send();
            break;

        case (preg_match('/^\/api\/fields\/(\d+)\/soil$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->soil((int) $matches[1])->send();
            break;

        case (preg_match('/^\/api\/fields\/(\d+)\/harvest$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->harvest((int) $matches[1])->send();
            break;

        case (preg_match('/^\/api\/fields\/(\d+)\/rotation$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $fieldsController->rotation((int) $matches[1])->send();
            break;

        case '/api/equipment':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $equipmentController->index()->send();
            } else {
                $equipmentController->store()->send();
            }
            break;

        case '/api/suppliers':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $suppliersController->index()->send();
            } else {
                $suppliersController->store()->send();
            }
            break;

        case '/api/notifications':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $notificationsController->index()->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $user = $request->getUser();
            $input = $request->getBody();
            $token = trim((string) ($input['device_token'] ?? ''));
            $platform = trim((string) ($input['platform'] ?? 'mobile'));

            if ($token === '') {
                Response::validationError(['device_token' => 'Device token is required'])->send();
                break;
            }

            $existing = $db->queryOne(
                'SELECT id FROM mobile_device_tokens WHERE device_token = ? LIMIT 1',
                [$token]
            );

            if ($existing) {
                $db->execute(
                    'UPDATE mobile_device_tokens SET user_id = ?, platform = ?, last_seen_at = NOW() WHERE id = ?',
                    [(int) ($user['user_id'] ?? 0), $platform, (int) $existing['id']]
                );
            } else {
                $db->execute(
                    'INSERT INTO mobile_device_tokens (user_id, device_token, platform, last_seen_at) VALUES (?, ?, ?, NOW())',
                    [(int) ($user['user_id'] ?? 0), $token, $platform]
                );
            }

            Response::success([
                'registered' => true,
                'device_token' => $token,
                'platform' => $platform,
            ], 'Device token registered')->send();
            break;

        case '/api/notifications/mark-all-read':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $notificationsController->markAllRead()->send();
            break;

        case (preg_match('/^\/api\/notifications\/(\d+)\/mark-read$/', $path, $matches) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $notificationsController->markRead((int) $matches[1])->send();
            break;

        case '/api/timesheets':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $timesheetsController->index()->send();
            break;

        case '/api/timesheets/stats':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $timesheetsController->stats()->send();
            break;

        case '/api/timesheets/log':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $timesheetsController->logHours()->send();
            break;

        case (preg_match('/^\/api\/timesheets\/(\d+)\/status$/', $path, $matches) ? true : false):
            if ($method !== 'PUT') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $timesheetsController->updateStatus((int) $matches[1])->send();
            break;

        case '/api/hr/sops':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $hrController->listSops()->send();
            } else {
                $hrController->createSop()->send();
            }
            break;

        case '/api/hr/tasks':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $hrController->listTasks()->send();
            } else {
                $hrController->createTask()->send();
            }
            break;

        case '/api/hr/schedules':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $hrController->listSchedules()->send();
            } else {
                $hrController->createSchedule()->send();
            }
            break;

        case '/api/hr/sops/executions':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $hrController->listExecutions()->send();
            break;

        case '/api/hr/sops/run':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $hrController->runSop()->send();
            break;

        case '/api/contracts':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $contractsController->index()->send();
            } else {
                $contractsController->store()->send();
            }
            break;

        case '/api/payments/methods':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $paymentsController->listMethods()->send();
            break;

        case '/api/payments/process':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $paymentsController->process()->send();
            break;

        case '/api/marketplace/listings':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $marketplaceController->listListings()->send();
            } else {
                $marketplaceController->createListing()->send();
            }
            break;

        case '/api/marketplace/customers':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $marketplaceController->listCustomers()->send();
            } else {
                $marketplaceController->createCustomer()->send();
            }
            break;

        case '/api/sales-crm/leads':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $salesCRMController->leads()->send();
            } else {
                $salesCRMController->createLead()->send();
            }
            break;

        case '/api/sales-crm/forecast':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $salesCRMController->forecast()->send();
            break;

        case '/api/accounting/accounts':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $accountingPlatformController->accounts()->send();
            break;

        case '/api/accounting/journal-entries':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $accountingPlatformController->journalEntries()->send();
            break;

        case '/api/accounting/trial-balance':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $accountingPlatformController->trialBalance()->send();
            break;

        case '/api/accounting/receivables':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $accountingPlatformController->receivables()->send();
            break;

        case '/api/accounting/payables':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $accountingPlatformController->payables()->send();
            break;

        case '/api/inventory-platform/warehouses':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $inventoryPlatformController->warehouses()->send();
            break;

        case '/api/inventory-platform/movements':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $inventoryPlatformController->movements()->send();
            break;

        case '/api/inventory-platform/transfers':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $inventoryPlatformController->transfer()->send();
            break;

        case '/api/inventory-platform/valuation':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $inventoryPlatformController->valuation()->send();
            break;

        case '/api/inventory-platform/reorder':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $inventoryPlatformController->reorder()->send();
            break;

        case '/api/livestock-platform/health':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $livestockPlatformController->health()->send();
            break;

        case '/api/livestock-platform/reproduction':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $livestockPlatformController->reproduction()->send();
            break;

        case '/api/livestock-platform/production':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $livestockPlatformController->production()->send();
            break;

        case '/api/livestock-platform/vaccinations':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $livestockPlatformController->vaccinations()->send();
            break;

        case '/api/predictive-maintenance/alerts':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $predictiveMaintenanceController->alerts()->send();
            break;

        case '/api/predictive-maintenance/fleet-health':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $predictiveMaintenanceController->fleetHealth()->send();
            break;

        case '/api/financial-analytics/forecast':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $financialAnalyticsController->forecast()->send();
            break;

        case '/api/financial-analytics/assets':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $financialAnalyticsController->assets()->send();
            break;

        case '/api/financial-analytics/roi':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $financialAnalyticsController->roi()->send();
            break;

        case '/api/blockchain/chain':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $traceabilityController->chain()->send();
            break;

        case '/api/qr/history':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $qrInventoryController->history()->send();
            break;

        case (preg_match('/^\/api\/import\/([a-z-]+)\/template$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $templateCsv = $importController->templateCsv((string) $matches[1]);
            header('Content-Type: text/csv; charset=utf-8');
            echo $templateCsv;
            break;

        case (preg_match('/^\/api\/import\/([a-z-]+)$/', $path, $matches) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $importController->importRows((string) $matches[1])->send();
            break;

        case '/api/weather-irrigation/decision':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $weatherIrrigationController->decision()->send();
            break;

        case '/api/weather-irrigation/schedule':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $weatherIrrigationController->schedule()->send();
            break;

        case '/api/weather-irrigation/moisture':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $weatherIrrigationController->moisture()->send();
            break;

        case '/api/breeding':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $breedingController->index()->send();
            } else {
                $breedingController->store()->send();
            }
            break;

        case '/api/circularity/compost':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $circularityController->compost()->send();
            break;

        case '/api/circularity/carbon':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $circularityController->carbon()->send();
            break;

        case '/api/circularity/bsf':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $circularityController->bsf()->send();
            break;

        case '/api/biogas/status':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $biogasController->status()->send();
            break;

        case '/api/biogas/zones':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $biogasController->zones()->send();
            break;

        case '/api/compliance/requirements':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $complianceController->requirements()->send();
            } else {
                $complianceController->storeRequirement()->send();
            }
            break;

        case '/api/veterinary/logs':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $veterinaryController->logs()->send();
            break;

        case '/api/veterinary/vaccinations':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $veterinaryController->vaccinations()->send();
            break;

        case (preg_match('/^\/api\/veterinary\/logs\/(\d+)\/status$/', $path, $matches) ? true : false):
            if ($method !== 'PUT') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $veterinaryController->updateLogStatus((int) $matches[1])->send();
            break;

        case '/api/veterinary/withdrawals':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $veterinaryController->withdrawals()->send();
            break;

        case '/api/feed/ingredients':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $feedController->ingredients()->send();
            } else {
                $feedController->storeIngredient()->send();
            }
            break;

        case '/api/feed/milling-logs':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $feedController->millingLogs()->send();
            break;

        case '/api/feed/calculate-pearson':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $feedController->calculatePearson()->send();
            break;

        case '/api/feed-formulation/ingredients':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $feedFormulationController->ingredients()->send();
            break;

        case '/api/feed-formulation/recent':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $feedFormulationController->recent()->send();
            break;

        case '/api/feed-formulation/calculate':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $feedFormulationController->calculate()->send();
            break;

        case '/api/production-management/pest-disease':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $productionManagementController->pestDisease()->send();
            break;

        case '/api/production-management/crop-rotation':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $productionManagementController->cropRotation()->send();
            break;

        // Livestock endpoints
        case '/api/livestock':
            if (!in_array($method, ['GET', 'POST'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            // Check authentication
            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            if ($method === 'GET') {
                $livestockController->index()->send();
            } else {
                $livestockController->store()->send();
            }
            break;

        case (preg_match('/^\/api\/livestock\/stats$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $livestockController->getStats()->send();
            break;

        case (preg_match('/^\/api\/livestock\/(\d+)$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'PUT', 'DELETE'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];

            if ($method === 'GET') {
                $livestockController->show($id)->send();
            } elseif ($method === 'PUT') {
                $livestockController->update($id)->send();
            } elseif ($method === 'DELETE') {
                $livestockController->destroy($id)->send();
            }
            break;

        case (preg_match('/^\/api\/livestock\/(\d+)\/events$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'POST'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];

            if ($method === 'GET') {
                $livestockController->getEvents($id)->send();
            } else {
                $livestockController->addEvent($id)->send();
            }
            break;

        case (preg_match('/^\/api\/livestock\/(\d+)\/weights$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $livestockId = (int) $matches[1];
            $user = $request->getUser();

            if ($method === 'GET') {
                $rows = $db->query(
                    'SELECT id, livestock_id, weight_kg, date, notes
                     FROM livestock_weights
                     WHERE livestock_id = ?
                     ORDER BY date ASC, id ASC',
                    [$livestockId]
                );
                Response::success($rows)->send();
                break;
            }

            $input = $request->getBody();
            $weightKg = isset($input['weight_kg']) ? (float) $input['weight_kg'] : 0.0;
            if ($weightKg <= 0) {
                Response::validationError(['weight_kg' => 'Weight must be greater than 0'])->send();
                break;
            }

            $notes = trim((string) ($input['notes'] ?? ''));
            $date = trim((string) ($input['date'] ?? ''));
            if ($date === '') {
                $date = date('Y-m-d H:i:s');
            }

            $db->execute(
                'INSERT INTO livestock_weights (livestock_id, weight_kg, date, notes, created_by)
                 VALUES (?, ?, ?, ?, ?)',
                [$livestockId, $weightKg, $date, $notes !== '' ? $notes : null, (int) ($user['user_id'] ?? 0)]
            );

            $created = $db->queryOne(
                'SELECT id, livestock_id, weight_kg, date, notes
                 FROM livestock_weights
                 WHERE id = ?',
                [(int) $db->lastInsertId()]
            );
            Response::success(['record' => $created], 'Weight recorded', 201)->send();
            break;

        case '/api/livestock/events':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $livestockController->addEventByBatch()->send();
            break;

        case '/api/livestock/breeding':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $livestockController->breeding()->send();
            break;

        // Inventory endpoints
        case '/api/inventory':
            if (!in_array($method, ['GET', 'POST'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            if ($method === 'GET') {
                $inventoryController->index()->send();
            } else {
                $inventoryController->store()->send();
            }
            break;

        case (preg_match('/^\/api\/inventory\/alerts$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $inventoryController->getAlerts()->send();
            break;

        case (preg_match('/^\/api\/inventory\/stats$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $inventoryController->getStats()->send();
            break;

        case (preg_match('/^\/api\/inventory\/category\/(.+)$/', $path, $matches) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $category = $matches[1];
            $inventoryController->byCategory($category)->send();
            break;

        case (preg_match('/^\/api\/inventory\/(\d+)$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'PUT', 'DELETE'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];

            if ($method === 'GET') {
                $inventoryController->show($id)->send();
            } elseif ($method === 'PUT') {
                $inventoryController->update($id)->send();
            } elseif ($method === 'DELETE') {
                $inventoryController->destroy($id)->send();
            }
            break;

        case (preg_match('/^\/api\/inventory\/(\d+)\/adjust$/', $path, $matches) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];
            $inventoryController->adjustQuantity($id)->send();
            break;

        case '/api/inventory/barcode/search':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $query = $request->getQuery();
            $term = trim((string) ($query['q'] ?? $query['barcode'] ?? $query['query'] ?? ''));
            if ($term === '') {
                Response::validationError(['q' => 'Search term is required'])->send();
                break;
            }

            $farmId = isset($query['farm_id']) && is_numeric($query['farm_id']) ? (int) $query['farm_id'] : 0;
            $like = '%' . $term . '%';
            $params = [$like, $like, $like, $like];
            $sql = 'SELECT id, farm_id, name, category, quantity, unit, batch_number, location, updated_at
                    FROM inventory
                    WHERE (batch_number LIKE ? OR name LIKE ? OR category LIKE ? OR location LIKE ?)';
            if ($farmId > 0) {
                $sql .= ' AND farm_id = ?';
                $params[] = $farmId;
            }
            $sql .= ' ORDER BY updated_at DESC, id DESC LIMIT 100';

            $rows = $db->query($sql, $params);
            $payload = array_map(static function (array $row): array {
                return [
                    'barcode' => (string) ($row['batch_number'] ?? ''),
                    'item_id' => (int) ($row['id'] ?? 0),
                    'item_name' => (string) ($row['name'] ?? ''),
                    'category' => (string) ($row['category'] ?? ''),
                    'quantity' => (float) ($row['quantity'] ?? 0),
                    'unit' => (string) ($row['unit'] ?? ''),
                    'sku' => $row['batch_number'] ?? null,
                ];
            }, $rows);
            Response::success($payload)->send();
            break;

        case '/api/inventory/barcode/lookup':
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $query = $request->getQuery();
            $barcode = trim((string) ($query['barcode'] ?? $query['code'] ?? $query['value'] ?? ''));
            if ($barcode === '') {
                Response::validationError(['barcode' => 'Barcode is required'])->send();
                break;
            }

            $farmId = isset($query['farm_id']) && is_numeric($query['farm_id']) ? (int) $query['farm_id'] : 0;
            $sql = 'SELECT id, farm_id, name, category, description, quantity, unit, min_level, max_level, cost_per_unit,
                           supplier, location, expiry_date, batch_number, notes, created_at, updated_at
                    FROM inventory
                    WHERE (batch_number = ? OR name = ?)';
            $params = [$barcode, $barcode];
            if ($farmId > 0) {
                $sql .= ' AND farm_id = ?';
                $params[] = $farmId;
            }
            $sql .= ' ORDER BY updated_at DESC, id DESC LIMIT 1';

            $row = $db->queryOne($sql, $params);
            if (!$row) {
                Response::notFound('Inventory item not found for barcode')->send();
                break;
            }

            Response::success([
                'barcode' => (string) ($row['batch_number'] ?? $barcode),
                'item_id' => (int) ($row['id'] ?? 0),
                'item_name' => (string) ($row['name'] ?? ''),
                'category' => (string) ($row['category'] ?? ''),
                'quantity' => (float) ($row['quantity'] ?? 0),
                'unit' => (string) ($row['unit'] ?? ''),
                'sku' => $row['batch_number'] ?? null,
            ])->send();
            break;

        case '/api/inventory/bulk-adjust':
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $input = $request->getBody();
            $adjustments = $input['adjustments'] ?? null;
            if (!is_array($adjustments) || $adjustments === []) {
                Response::validationError(['adjustments' => 'At least one adjustment is required'])->send();
                break;
            }

            $user = $request->getUser();
            $results = [];
            $errors = [];

            foreach ($adjustments as $index => $adj) {
                $itemId = isset($adj['inventory_id']) && is_numeric($adj['inventory_id'])
                    ? (int) $adj['inventory_id']
                    : (isset($adj['item_id']) && is_numeric($adj['item_id'])
                        ? (int) $adj['item_id']
                        : (isset($adj['id']) && is_numeric($adj['id']) ? (int) $adj['id'] : 0));
                $amount = isset($adj['amount']) && is_numeric($adj['amount'])
                    ? (float) $adj['amount']
                    : (isset($adj['quantity']) && is_numeric($adj['quantity']) ? (float) $adj['quantity'] : null);
                $reason = trim((string) ($adj['reason'] ?? 'Bulk adjustment'));

                if ($itemId <= 0 || $amount === null) {
                    $errors[] = ['index' => $index, 'message' => 'inventory_id and numeric amount are required'];
                    continue;
                }

                $item = $db->queryOne('SELECT id, quantity, notes FROM inventory WHERE id = ?', [$itemId]);
                if (!$item) {
                    $errors[] = ['index' => $index, 'inventory_id' => $itemId, 'message' => 'Inventory item not found'];
                    continue;
                }

                $currentQty = (float) ($item['quantity'] ?? 0);
                $newQty = $currentQty + $amount;
                if ($newQty < 0) {
                    $errors[] = ['index' => $index, 'inventory_id' => $itemId, 'message' => 'Adjustment would result in negative quantity'];
                    continue;
                }

                $notes = (string) ($item['notes'] ?? '');
                $noteLine = '[' . date('Y-m-d H:i:s') . '] Bulk adjustment: ' . $amount . ' (' . $reason . ')';
                $updatedNotes = trim($notes) === '' ? $noteLine : $notes . "\n" . $noteLine;

                $db->execute(
                    'UPDATE inventory SET quantity = ?, notes = ?, updated_at = NOW() WHERE id = ?',
                    [$newQty, $updatedNotes, $itemId]
                );

                $updated = $db->queryOne('SELECT * FROM inventory WHERE id = ?', [$itemId]);
                $results[] = [
                    'inventory_id' => $itemId,
                    'amount' => $amount,
                    'new_quantity' => $newQty,
                    'item' => $updated,
                    'updated_by' => (int) ($user['user_id'] ?? 0),
                ];
            }

            Response::success([
                'updated_count' => count($results),
                'error_count' => count($errors),
                'results' => $results,
                'errors' => $errors,
            ])->send();
            break;
        // Financial endpoints
        case '/api/financial/records':
            if (!in_array($method, ['GET', 'POST'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            if ($method === 'GET') {
                $financialController->index()->send();
            } else {
                $financialController->store()->send();
            }
            break;

        case (preg_match('/^\/api\/financial\/summary$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $financialController->getSummary()->send();
            break;

        case (preg_match('/^\/api\/financial\/report\/monthly$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $financialController->getMonthlyReport()->send();
            break;

        case (preg_match('/^\/api\/financial\/report\/yearly$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $financialController->getYearlyReport()->send();
            break;

        case (preg_match('/^\/api\/financial\/categories$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $financialController->getCategories()->send();
            break;

        case '/api/financial/budgets':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $financialController->budgets()->send();
            break;

        case '/api/financial/invoices':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $financialController->invoices()->send();
            break;

        case (preg_match('/^\/api\/financial\/records\/(\d+)$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'PUT', 'DELETE'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];

            if ($method === 'GET') {
                $financialController->show($id)->send();
            } elseif ($method === 'PUT') {
                $financialController->update($id)->send();
            } elseif ($method === 'DELETE') {
                $financialController->destroy($id)->send();
            }
            break;

        case (preg_match('/^\/api\/financial\/records\/(\d+)\/attachments$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $transactionId = (int) $matches[1];
            $user = $request->getUser();

            if ($method === 'GET') {
                $rows = $db->query(
                    'SELECT id, transaction_id, file_url, file_name, created_at AS uploaded_at
                     FROM financial_attachments
                     WHERE transaction_id = ?
                     ORDER BY created_at ASC, id ASC',
                    [$transactionId]
                );
                Response::success($rows)->send();
                break;
            }

            $input = $request->getBody();
            $fileData = trim((string) ($input['file_data'] ?? ''));
            $fileName = trim((string) ($input['file_name'] ?? 'receipt.jpg'));
            $mimeType = trim((string) ($input['mime_type'] ?? 'image/jpeg'));
            $allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
            $maxUploadBytes = 5 * 1024 * 1024;
            if ($fileData === '') {
                Response::validationError(['file_data' => 'File data is required'])->send();
                break;
            }

            if (!in_array($mimeType, $allowedMimeTypes, true)) {
                Response::validationError(['mime_type' => 'Unsupported file type'])->send();
                break;
            }

            $uploadDir = __DIR__ . '/../storage/uploads/receipts';
            if (!is_dir($uploadDir)) {
                @mkdir($uploadDir, 0775, true);
            }

            $safeName = preg_replace('/[^a-zA-Z0-9._-]/', '_', $fileName) ?: 'receipt.jpg';
            $storedName = 'txn_' . $transactionId . '_' . time() . '_' . $safeName;
            $raw = base64_decode($fileData, true);
            if ($raw === false) {
                Response::validationError(['file_data' => 'Invalid base64 payload'])->send();
                break;
            }

            if (strlen($raw) > $maxUploadBytes) {
                Response::validationError(['file_data' => 'File too large (max 5 MB)'])->send();
                break;
            }

            $storedPath = $uploadDir . '/' . $storedName;
            file_put_contents($storedPath, $raw);
            $fileUrl = '/storage/uploads/receipts/' . $storedName;

            $db->execute(
                'INSERT INTO financial_attachments (transaction_id, file_url, file_name, mime_type, created_by)
                 VALUES (?, ?, ?, ?, ?)',
                [$transactionId, $fileUrl, $fileName, $mimeType, (int) ($user['user_id'] ?? 0)]
            );

            $created = $db->queryOne(
                'SELECT id, transaction_id, file_url, file_name, created_at AS uploaded_at
                 FROM financial_attachments
                 WHERE id = ?',
                [(int) $db->lastInsertId()]
            );
            Response::success($created, 'Attachment uploaded', 201)->send();
            break;

        case (preg_match('/^\/api\/financial\/records\/attachments\/(\d+)$/', $path, $matches) ? true : false):
            if ($method !== 'DELETE') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $attachmentId = (int) $matches[1];
            $row = $db->queryOne(
                'SELECT id, file_url FROM financial_attachments WHERE id = ?',
                [$attachmentId]
            );
            if (!$row) {
                Response::notFound('Attachment not found')->send();
                break;
            }

            $fileName = basename((string) $row['file_url']);
            $diskPath = __DIR__ . '/../storage/uploads/receipts/' . $fileName;
            if (is_file($diskPath)) {
                @unlink($diskPath);
            }

            $db->execute('DELETE FROM financial_attachments WHERE id = ?', [$attachmentId]);
            Response::success(['deleted' => true])->send();
            break;

        case '/api/attachments':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $user = $request->getUser();

            if ($method === 'GET') {
                $query = $request->getQuery();
                $transactionId = isset($query['transaction_id']) && is_numeric($query['transaction_id']) ? (int) $query['transaction_id'] : 0;
                $sql = 'SELECT id, transaction_id, file_url, file_name, mime_type, created_at AS uploaded_at
                        FROM financial_attachments';
                $params = [];
                if ($transactionId > 0) {
                    $sql .= ' WHERE transaction_id = ?';
                    $params[] = $transactionId;
                }
                $sql .= ' ORDER BY created_at DESC, id DESC LIMIT 200';

                $rows = $db->query($sql, $params);
                Response::success($rows)->send();
                break;
            }

            $input = $request->getBody();
            $transactionId = isset($input['transaction_id']) && is_numeric($input['transaction_id']) ? (int) $input['transaction_id'] : 0;
            $fileData = trim((string) ($input['file_data'] ?? ''));
            $fileName = trim((string) ($input['file_name'] ?? 'attachment.jpg'));
            $mimeType = trim((string) ($input['mime_type'] ?? 'image/jpeg'));
            $allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
            $maxUploadBytes = 5 * 1024 * 1024;

            if ($transactionId <= 0) {
                Response::validationError(['transaction_id' => 'transaction_id is required'])->send();
                break;
            }
            if ($fileData === '') {
                Response::validationError(['file_data' => 'File data is required'])->send();
                break;
            }
            if (!in_array($mimeType, $allowedMimeTypes, true)) {
                Response::validationError(['mime_type' => 'Unsupported file type'])->send();
                break;
            }

            $uploadDir = __DIR__ . '/../storage/uploads/receipts';
            if (!is_dir($uploadDir)) {
                @mkdir($uploadDir, 0775, true);
            }

            $safeName = preg_replace('/[^a-zA-Z0-9._-]/', '_', $fileName) ?: 'attachment.jpg';
            $storedName = 'txn_' . $transactionId . '_' . time() . '_' . $safeName;
            $raw = base64_decode($fileData, true);
            if ($raw === false) {
                Response::validationError(['file_data' => 'Invalid base64 payload'])->send();
                break;
            }
            if (strlen($raw) > $maxUploadBytes) {
                Response::validationError(['file_data' => 'File too large (max 5 MB)'])->send();
                break;
            }

            $storedPath = $uploadDir . '/' . $storedName;
            file_put_contents($storedPath, $raw);
            $fileUrl = '/storage/uploads/receipts/' . $storedName;

            $db->execute(
                'INSERT INTO financial_attachments (transaction_id, file_url, file_name, mime_type, created_by)
                 VALUES (?, ?, ?, ?, ?)',
                [$transactionId, $fileUrl, $fileName, $mimeType, (int) ($user['user_id'] ?? 0)]
            );

            $created = $db->queryOne(
                'SELECT id, transaction_id, file_url, file_name, mime_type, created_at AS uploaded_at
                 FROM financial_attachments
                 WHERE id = ?',
                [(int) $db->lastInsertId()]
            );

            Response::success($created, 'Attachment uploaded', 201)->send();
            break;

        // Task endpoints
        case '/api/tasks':
            if (!in_array($method, ['GET', 'POST'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            if ($method === 'GET') {
                $taskController->index()->send();
            } else {
                $taskController->store()->send();
            }
            break;

        case (preg_match('/^\/api\/tasks\/stats$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $taskController->getStats()->send();
            break;

        case (preg_match('/^\/api\/tasks\/(\d+)$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'PUT', 'DELETE'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];

            if ($method === 'GET') {
                $taskController->show($id)->send();
            } elseif ($method === 'PUT') {
                $taskController->update($id)->send();
            } elseif ($method === 'DELETE') {
                $taskController->destroy($id)->send();
            }
            break;

        case (preg_match('/^\/api\/tasks\/(\d+)\/assign$/', $path, $matches) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];
            $taskController->assign($id)->send();
            break;

        case (preg_match('/^\/api\/tasks\/(\d+)\/complete$/', $path, $matches) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $id = (int) $matches[1];
            $taskController->complete($id)->send();
            break;

        case '/api/tasks/comments':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $user = $request->getUser();

            if ($method === 'GET') {
                $taskId = (int) ($request->getQuery()['task_id'] ?? 0);
                if ($taskId <= 0) {
                    Response::validationError(['task_id' => 'task_id is required'])->send();
                    break;
                }

                $rows = $db->query(
                    'SELECT c.id, c.task_id, c.user_id, COALESCE(u.first_name, u.email, "User") AS user_name,
                            c.content, c.created_at, c.updated_at
                     FROM task_comments c
                     LEFT JOIN users u ON u.id = c.user_id
                     WHERE c.task_id = ?
                     ORDER BY c.created_at ASC, c.id ASC',
                    [$taskId]
                );
                Response::success($rows)->send();
                break;
            }

            $input = $request->getBody();
            $taskId = isset($input['task_id']) && is_numeric($input['task_id']) ? (int) $input['task_id'] : 0;
            $content = trim((string) ($input['content'] ?? ''));
            if ($taskId <= 0 || $content === '') {
                Response::validationError([
                    'task_id' => $taskId <= 0 ? 'task_id is required' : null,
                    'content' => $content === '' ? 'Comment content is required' : null,
                ])->send();
                break;
            }

            $db->execute(
                'INSERT INTO task_comments (task_id, user_id, content) VALUES (?, ?, ?)',
                [$taskId, (int) ($user['user_id'] ?? 0), $content]
            );

            $created = $db->queryOne(
                'SELECT c.id, c.task_id, c.user_id, COALESCE(u.first_name, u.email, "User") AS user_name,
                        c.content, c.created_at, c.updated_at
                 FROM task_comments c
                 LEFT JOIN users u ON u.id = c.user_id
                 WHERE c.id = ?',
                [(int) $db->lastInsertId()]
            );
            Response::success($created, 'Comment added', 201)->send();
            break;

        case (preg_match('/^\/api\/tasks\/(\d+)\/comments$/', $path, $matches) ? true : false):
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $taskId = (int) $matches[1];
            $user = $request->getUser();

            if ($method === 'GET') {
                $rows = $db->query(
                    'SELECT c.id, c.task_id, c.user_id, COALESCE(u.first_name, u.email, "User") AS user_name,
                            c.content, c.created_at, c.updated_at
                     FROM task_comments c
                     LEFT JOIN users u ON u.id = c.user_id
                     WHERE c.task_id = ?
                     ORDER BY c.created_at ASC, c.id ASC',
                    [$taskId]
                );
                Response::success($rows)->send();
                break;
            }

            $input = $request->getBody();
            $content = trim((string) ($input['content'] ?? ''));
            if ($content === '') {
                Response::validationError(['content' => 'Comment content is required'])->send();
                break;
            }

            $db->execute(
                'INSERT INTO task_comments (task_id, user_id, content) VALUES (?, ?, ?)',
                [$taskId, (int) ($user['user_id'] ?? 0), $content]
            );
            $commentId = (int) $db->lastInsertId();
            $created = $db->queryOne(
                'SELECT c.id, c.task_id, c.user_id, COALESCE(u.first_name, u.email, "User") AS user_name,
                        c.content, c.created_at, c.updated_at
                 FROM task_comments c
                 LEFT JOIN users u ON u.id = c.user_id
                 WHERE c.id = ?',
                [$commentId]
            );

            Response::success($created, 'Comment added', 201)->send();
            break;

        case (preg_match('/^\/api\/comments\/(\d+)$/', $path, $matches) ? true : false):
            if (!in_array($method, ['PUT', 'DELETE'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $commentId = (int) $matches[1];
            $user = $request->getUser();
            $existing = $db->queryOne('SELECT * FROM task_comments WHERE id = ?', [$commentId]);
            if (!$existing) {
                Response::notFound('Comment not found')->send();
                break;
            }

            if ((int) ($existing['user_id'] ?? 0) !== (int) ($user['user_id'] ?? 0)) {
                Response::forbidden('You can only modify your own comment')->send();
                break;
            }

            if ($method === 'DELETE') {
                $db->execute('DELETE FROM task_comments WHERE id = ?', [$commentId]);
                Response::success(['deleted' => true])->send();
                break;
            }

            $input = $request->getBody();
            $content = trim((string) ($input['content'] ?? ''));
            if ($content === '') {
                Response::validationError(['content' => 'Comment content is required'])->send();
                break;
            }

            $db->execute(
                'UPDATE task_comments SET content = ?, updated_at = NOW() WHERE id = ?',
                [$content, $commentId]
            );
            $updated = $db->queryOne(
                'SELECT c.id, c.task_id, c.user_id, COALESCE(u.first_name, u.email, "User") AS user_name,
                        c.content, c.created_at, c.updated_at
                 FROM task_comments c
                 LEFT JOIN users u ON u.id = c.user_id
                 WHERE c.id = ?',
                [$commentId]
            );
            Response::success($updated)->send();
            break;

        case (preg_match('/^\/api\/weather\/alerts$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $query = $request->getQuery();
            $status = trim((string) ($query['status'] ?? 'active'));
            $type = trim((string) ($query['type'] ?? ''));
            $limit = max(1, min(200, (int) ($query['limit'] ?? 50)));

            $sql = 'SELECT id, type, message, severity, issued_at, expires_at, location, acknowledged
                    FROM weather_alerts
                    WHERE status = ?';
            $params = [$status];
            if ($type !== '') {
                $sql .= ' AND type = ?';
                $params[] = $type;
            }
            $sql .= ' ORDER BY issued_at DESC, id DESC LIMIT ' . $limit;

            $rows = $db->query($sql, $params);
            Response::success($rows)->send();
            break;

        case (preg_match('/^\/api\/weather\/alerts\/(\d+)$/', $path, $matches) ? true : false):
            if ($method !== 'PUT') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            $authResult = $auth->handle();
            if ($authResult !== true) {
                $authResult->send();
                break;
            }

            $ensureMobileSupportTables();
            $alertId = (int) $matches[1];
            $user = $request->getUser();
            $input = $request->getBody();
            $ack = (bool) ($input['acknowledged'] ?? false);

            $existing = $db->queryOne('SELECT id FROM weather_alerts WHERE id = ?', [$alertId]);
            if (!$existing) {
                Response::notFound('Alert not found')->send();
                break;
            }

            $db->execute(
                'UPDATE weather_alerts
                 SET acknowledged = ?, acknowledged_by = ?, acknowledged_at = ?
                 WHERE id = ?',
                [$ack ? 1 : 0, (int) ($user['user_id'] ?? 0), $ack ? date('Y-m-d H:i:s') : null, $alertId]
            );

            $updated = $db->queryOne(
                'SELECT id, type, message, severity, issued_at, expires_at, location, acknowledged
                 FROM weather_alerts WHERE id = ?',
                [$alertId]
            );
            Response::success($updated)->send();
            break;

        // Dashboard endpoints
        case (preg_match('/^\/api\/dashboard\/overview$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->overview()->send();
            break;

        case (preg_match('/^\/api\/dashboard\/summary$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->summary()->send();
            break;

        case (preg_match('/^\/api\/dashboard\/health$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->health()->send();
            break;

        case (preg_match('/^\/api\/dashboard\/alerts$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->alerts()->send();
            break;

        case (preg_match('/^\/api\/dashboard\/timeline$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->timeline()->send();
            break;

        case (preg_match('/^\/api\/dashboard\/forecast$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->forecast()->send();
            break;

        // Weather endpoints
        case (preg_match('/^\/api\/weather\/current$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $weatherController->current()->send();
            break;

        case (preg_match('/^\/api\/weather\/observation$/', $path) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $weatherController->store()->send();
            break;

        case (preg_match('/^\/api\/weather\/history$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $weatherController->history()->send();
            break;

        case (preg_match('/^\/api\/weather\/stats$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $weatherController->stats()->send();
            break;

        case (preg_match('/^\/api\/weather\/forecast$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $weatherController->forecast()->send();
            break;

        case (preg_match('/^\/api\/energy\/status$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $iotController->energyStatus()->send();
            break;

        case (preg_match('/^\/api\/energy\/loads$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $iotController->energyLoads()->send();
            break;

        case (preg_match('/^\/api\/energy\/history$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $iotController->energyHistory()->send();
            break;

        case '/api/waste/biogas':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $wasteController->biogas()->send();
            } else {
                $wasteController->biogas()->send();
            }
            break;

        case '/api/waste/compost':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $wasteController->compost()->send();
            } else {
                $wasteController->compost()->send();
            }
            break;

        case '/api/waste/manure':
            if (!in_array($method, ['GET', 'POST'], true)) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            if ($method === 'GET') {
                $wasteController->manure()->send();
            } else {
                $wasteController->manure()->send();
            }
            break;

        // IoT endpoints
        case (preg_match('/^\/api\/iot\/devices$/', $path) ? true : false):
            if (!in_array($method, ['GET', 'POST'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            if ($method === 'GET') {
                $iotController->devices()->send();
            } else {
                $iotController->createDevice()->send();
            }
            break;

        case (preg_match('/^\/api\/iot\/sensors$/', $path) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $iotController->ingestSensor()->send();
            break;

        case (preg_match('/^\/api\/iot\/sensors\/latest$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $iotController->latestSensors()->send();
            break;

        case (preg_match('/^\/api\/iot\/alerts$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $iotController->alerts()->send();
            break;

        case (preg_match('/^\/api\/iot\/water-quality$/', $path) ? true : false):
            if (!in_array($method, ['GET', 'POST'])) {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            if ($method === 'GET') {
                $iotController->waterQuality()->send();
            } else {
                $iotController->createWaterQuality()->send();
            }
            break;

        case (preg_match('/^\/api\/reports\/types$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->reportTypes()->send();
            break;

        case (preg_match('/^\/api\/reports\/generate$/', $path) ? true : false):
            if ($method !== 'POST') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->generateReport()->send();
            break;

        case (preg_match('/^\/api\/reports\/download$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $token = (string) ($_GET['token'] ?? '');
            $export = $dashboardController->getReportExportByToken($token);
            if (!$export) {
                Response::notFound('Report not found')->send();
                break;
            }

            http_response_code(200);
            if (!headers_sent()) {
                foreach (Security::getSecurityHeaders() as $name => $value) {
                    header("$name: $value");
                }
                header('Content-Type: ' . $export['content_type']);
                $disposition = stripos((string) $export['content_type'], 'text/html') !== false ? 'inline' : 'attachment';
                header('Content-Disposition: ' . $disposition . '; filename="' . str_replace('"', '', (string) $export['filename']) . '"');
            }
            echo $export['body'];
            break;

        case (preg_match('/^\/api\/analytics\/dashboard$/', $path) ? true : false):
            if ($method !== 'GET') {
                Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
                break;
            }

            $auth = new AuthMiddleware($request, $db);
            if ($auth->handle() !== true) {
                $auth->handle()->send();
                break;
            }

            $dashboardController->analyticsDashboard()->send();
            break;

        // Default 404
        default:
            Response::notFound('Endpoint not found')->send();
            break;
    }
} catch (\Exception $e) {
    Logger::error('Request failed', [
        'path' => $path,
        'method' => $method,
        'error' => $e->getMessage(),
    ]);
    
    $debug = (string) (getenv('APP_DEBUG') ?: 'false');
    $isDebug = strtolower($debug) === 'true' || $debug === '1';
    $message = $isDebug ? $e->getMessage() : 'Internal server error';
    $details = $isDebug ? ['exception' => get_class($e)] : [];
    Response::error($message, 'INTERNAL_ERROR', 500, $details)->send();
}
