<?php

// Load environment
require_once __DIR__ . '/../config/env.php';

// Autoload classes
require_once __DIR__ . '/../vendor/autoload.php';

use FarmOS\{Request, Response, Logger, Security, Database, RateLimiter, Validation, Auth};

// Initialize
error_reporting(E_ALL);
ini_set('display_errors', '0');

Logger::init(
    getenv('LOG_DIR') ?: '/var/log/farmos',
    getenv('LOG_FORMAT') ?: 'json'
);

Security::init(getenv('JWT_SECRET'));

// Create request/response
$request = new Request();
$method = $request->getMethod();
$path = $request->getPath();

// CORS handling
if ($method === 'OPTIONS') {
    header('Access-Control-Allow-Origin: ' . getenv('CORS_ORIGIN'));
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Access-Control-Max-Age: 3600');
    Response::success()->send();
    exit;
}

// Add CORS headers
header('Access-Control-Allow-Origin: ' . getenv('CORS_ORIGIN'));

// Health check without DB
if ($path === '/health') {
    if ($method !== 'GET') {
        Response::error('Method not allowed', 'METHOD_NOT_ALLOWED', 405)->send();
    } else {
        Response::success(['status' => 'ok'])->send();
    }
    exit;
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
            $result = $auth->login($input['email'], $input['password']);
            Response::success($result, 'Login successful')->send();
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
            $result = $auth->register(
                $input['email'],
                $input['password'],
                $input['first_name'] ?? null,
                $input['last_name'] ?? null
            );
            Response::success($result, 'Registration successful', 201)->send();
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

            $user = $request->getUser();
            
            if (!$user) {
                Response::unauthorized()->send();
                break;
            }

            $auth = new Auth($db);
            $newToken = $auth->refreshToken($user);
            Response::success([
                'access_token' => $newToken,
                'token_type' => 'Bearer',
                'expires_in' => 3600,
            ])->send();
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
    
    Response::error($e->getMessage(), 'INTERNAL_ERROR', 500)->send();
}
