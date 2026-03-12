<?php
/**
 * FarmOS PHP Backend Configuration
 * Replaces Python FastAPI backend with PHP API
 */

// Database Configuration
define('DB_HOST', 'localhost');
define('DB_NAME', 'begin_masimba_farm');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// API Configuration
define('API_BASE_URL', 'http://localhost/farmos/begin_php/backend/api/');
define('FRONTEND_URL', 'http://localhost/farmos/begin_php/frontend/');

// Security Configuration
define('JWT_SECRET', 'lSlpyRmU8xQ7fZ3nK2mV9pT5wH1sJ6rY4vN7bX2cF9dE3gA8zL1oP5iU2tR');
define('JWT_ALGORITHM', 'HS256');
define('TOKEN_EXPIRY', 3600); // 1 hour

// CORS Configuration
define('CORS_ORIGIN', 'http://localhost/farmos/begin_php/frontend/');

// Error Reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Session Configuration
ini_set('session.cookie_httponly', 1);
ini_set('session.use_only_cookies', 1);
ini_set('session.cookie_secure', 0); // Set to 1 for HTTPS

// Timezone
date_default_timezone_set('Africa/Nairobi');

// Multi-tenant Support
define('DEFAULT_TENANT', 'default');

// API Response Helper
function api_response($data = null, $message = '', $status = 200, $error = null) {
    header('Content-Type: application/json');
    http_response_code($status);
    
    $response = [
        'status' => $status,
        'message' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    if ($error !== null) {
        $response['error'] = $error;
    }
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    exit;
}

// CORS Headers
function set_cors_headers() {
    header("Access-Control-Allow-Origin: " . CORS_ORIGIN);
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Tenant-ID");
    header("Access-Control-Allow-Credentials: true");
}

// Database Connection
function get_db_connection() {
    static $conn = null;
    
    if ($conn === null) {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
            $conn = new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false
            ]);
        } catch (PDOException $e) {
            api_response(null, 'Database connection failed', 500, $e->getMessage());
        }
    }
    
    return $conn;
}

// JWT Helper Functions
function generate_jwt($user_id, $tenant_id = DEFAULT_TENANT) {
    $header = json_encode(['typ' => 'JWT', 'alg' => JWT_ALGORITHM]);
    $payload = json_encode([
        'user_id' => $user_id,
        'tenant_id' => $tenant_id,
        'iat' => time(),
        'exp' => time() + TOKEN_EXPIRY
    ]);
    
    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
    
    $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET, true);
    $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
    
    return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
}

function verify_jwt($token) {
    if (!$token) {
        return false;
    }
    
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return false;
    }
    
    list($header, $payload, $signature) = $parts;
    
    // Verify signature
    $signature_check = hash_hmac('sha256', $header . "." . $payload, JWT_SECRET, true);
    $base64UrlSignature_check = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature_check));
    
    if ($base64UrlSignature_check !== $signature) {
        return false;
    }
    
    // Verify expiration
    $payload_data = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $payload)), true);
    if (!$payload_data || $payload_data['exp'] < time()) {
        return false;
    }
    
    return $payload_data;
}

// Get Tenant ID from Headers
function get_tenant_id() {
    return $_SERVER['HTTP_X_TENANT_ID'] ?? DEFAULT_TENANT;
}

// Authentication Middleware
function require_auth() {
    $headers = getallheaders();
    $auth_header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    if (!$auth_header || !preg_match('/Bearer\s+(.*)$/i', $auth_header, $matches)) {
        api_response(null, 'Authorization token required', 401);
    }
    
    $token = $matches[1];
    $payload = verify_jwt($token);
    
    if (!$payload) {
        api_response(null, 'Invalid or expired token', 401);
    }
    
    return $payload;
}

// Logging Function
function log_message($message, $level = 'INFO') {
    $log_file = __DIR__ . '/logs/farmos_' . date('Y-m-d') . '.log';
    $log_dir = dirname($log_file);
    
    if (!is_dir($log_dir)) {
        mkdir($log_dir, 0755, true);
    }
    
    $timestamp = date('Y-m-d H:i:s');
    $log_entry = "[$timestamp] [$level] $message" . PHP_EOL;
    
    file_put_contents($log_file, $log_entry, FILE_APPEND | LOCK_EX);
}

// Initialize
set_cors_headers();

// Handle OPTIONS requests for CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
?>
