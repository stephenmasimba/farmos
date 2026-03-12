<?php

// Load .env file if it exists
$envFile = __DIR__ . '/.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') === false || strpos($line, '#') === 0) {
            continue;
        }
        [$key, $value] = explode('=', $line, 2);
        $key = trim($key);
        $value = trim($value);
        
        // Remove quotes
        if (preg_match('/^"(.*)"$/', $value, $m)) {
            $value = $m[1];
        } elseif (preg_match("/^'(.*)'$/", $value, $m)) {
            $value = $m[1];
        }
        
        if (!array_key_exists($key, $_ENV)) {
            putenv("$key=$value");
            $_ENV[$key] = $value;
        }
    }
}

// Set defaults
$defaults = [
    // App
    'APP_NAME' => 'FarmOS',
    'APP_ENV' => 'development',
    'APP_DEBUG' => 'false',
    'APP_URL' => 'http://localhost:8081',
    'APP_PORT' => 8081,
    
    // Database
    'DATABASE_HOST' => 'localhost',
    'DATABASE_PORT' => '3306',
    'DATABASE_NAME' => 'begin_masimba_farm',
    'DB_USER' => 'root',
    'DB_PASSWORD' => '',
    'DATABASE_URL' => 'mysql:host=localhost;port=3306;dbname=begin_masimba_farm;charset=utf8mb4',
    
    // JWT
    'JWT_SECRET' => 'your-secret-key-here-change-in-production',
    'JWT_EXPIRY' => '3600', // 1 hour in seconds
    'JWT_REFRESH_EXPIRY' => '2592000', // 30 days in seconds
    
    // Security
    'BCRYPT_COST' => '12',
    'API_RATE_LIMIT_AUTH' => '5', // per minute
    'API_RATE_LIMIT_API' => '100', // per minute
    'API_RATE_LIMIT_UPLOAD' => '50', // per hour
    'SESSION_TIMEOUT' => '1800', // 30 minutes
    
    // CORS
    'CORS_ORIGIN' => 'http://localhost',
    'CORS_METHODS' => 'GET,POST,PUT,DELETE,OPTIONS',
    'CORS_HEADERS' => 'Content-Type,Authorization',
    
    // Logging
    'LOG_DIR' => '/var/log/farmos',
    'LOG_FORMAT' => 'json', // 'json' or 'text'
    'LOG_LEVEL' => 'info', // 'debug', 'info', 'warning', 'error'
    
    // Email
    'MAIL_DRIVER' => 'log',
    'MAIL_HOST' => 'smtp.mailtrap.io',
    'MAIL_PORT' => '465',
    'MAIL_USERNAME' => '',
    'MAIL_PASSWORD' => '',
    'MAIL_FROM_ADDRESS' => 'noreply@farmos.local',
    'MAIL_FROM_NAME' => 'FarmOS',
    
    // Redis
    'REDIS_HOST' => 'localhost',
    'REDIS_PORT' => '6379',
    'REDIS_PASSWORD' => '',
    'REDIS_DB' => '0',
    
    // File upload
    'UPLOAD_DIR' => getenv('UPLOAD_DIR') ?: __DIR__ . '/../storage/uploads',
    'MAX_UPLOAD_SIZE' => '52428800', // 50MB
    'ALLOWED_FILE_TYPES' => 'jpg,jpeg,png,gif,pdf,doc,docx,xls,xlsx,csv',
];

// Apply defaults if not set
foreach ($defaults as $key => $value) {
    if (!getenv($key)) {
        putenv("$key=$value");
        $_ENV[$key] = $value;
    }
}

// Create upload directory if it doesn't exist
$uploadDir = getenv('UPLOAD_DIR');
if (!is_dir($uploadDir)) {
    @mkdir($uploadDir, 0755, true);
}

// Create log directory if it doesn't exist
$logDir = getenv('LOG_DIR');
if (!is_dir($logDir)) {
    @mkdir($logDir, 0755, true);
}
