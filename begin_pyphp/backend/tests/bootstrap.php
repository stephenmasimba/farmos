<?php

/**
 * Bootstrap for PHPUnit tests
 */

// Define base path
define('BASE_PATH', __DIR__ . '/..');

// Load environment variables
require_once BASE_PATH . '/config/env.php';

// Load autoloader
require_once BASE_PATH . '/vendor/autoload.php';

// Set up test environment
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Initialize logger for tests
\FarmOS\Logger::init(
    sys_get_temp_dir() . '/farmos-tests',
    'json'
);

// Initialize security
\FarmOS\Security::init(getenv('JWT_SECRET'));

// Make sure tests can access the base path
$_SERVER['PHP_SELF'] = '/test';
