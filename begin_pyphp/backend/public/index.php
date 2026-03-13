<?php

// Load environment
require_once __DIR__ . '/../config/env.php';

// Autoload classes
require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../src/Middleware/Middleware.php';

use FarmOS\{Request, Response, Logger, Security, Database, RateLimiter, Validation, Auth};

// Initialize
error_reporting(E_ALL);
ini_set('display_errors', '0');

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

// CORS handling
if ($method === 'OPTIONS') {
    if (!headers_sent()) {
        header('Access-Control-Allow-Origin: ' . getenv('CORS_ORIGIN'));
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        header('Access-Control-Max-Age: 3600');
    }
    Response::success()->send();
    exit;
}

// Add CORS headers
if (!headers_sent()) {
    header('Access-Control-Allow-Origin: ' . getenv('CORS_ORIGIN'));
}

// Health check without DB
if ($path === '/health') {
    if ($method !== 'GET') {
        Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
    } else {
        Response::success(['status' => 'ok'])->send();
    }
    exit;
}

$stateChanging = in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true);
if ($stateChanging) {
    if ($request->isJsonInvalid()) {
        Response::error('Invalid JSON', 'INVALID_JSON', 400)->send();
        exit;
    }

    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $corsOriginRaw = (string) (getenv('CORS_ORIGIN') ?: '');
    $appUrl = (string) (getenv('APP_URL') ?: '');
    if ($origin !== '' && $corsOriginRaw !== '*') {
        $allowedOrigins = array_values(array_unique(array_filter(array_map(
            'trim',
            array_merge(explode(',', $corsOriginRaw), [$appUrl])
        ))));
        if (!in_array($origin, $allowedOrigins, true)) {
            Response::error('Forbidden', 'FORBIDDEN', 403)->send();
            exit;
        }
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
    exit;
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
use FarmOS\Controllers\{LivestockController, InventoryController, FinancialController, TaskController, DashboardController, WeatherController, IoTController};
use FarmOS\Middleware\{AuthMiddleware, RateLimitMiddleware};

$livestockController = new LivestockController($db, $request);
$inventoryController = new InventoryController($db, $request);
$financialController = new FinancialController($db, $request);
$taskController = new TaskController($db, $request);
$dashboardController = new DashboardController($db, $request);
$weatherController = new WeatherController($db, $request);
$iotController = new IoTController($db, $request);

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

            $user = $request->getUser();
            
            if (!$user) {
                Response::unauthorized()->send();
                break;
            }

            $auth = new Auth($db);
            $userData = $auth->getUser($user['user_id']);
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
