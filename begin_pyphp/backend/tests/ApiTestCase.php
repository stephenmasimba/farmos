<?php declare(strict_types=1);

namespace Tests;

use PHPUnit\Framework\TestCase;
use FarmOS\{Database, Request, Response, Logger, Security, Auth};
use FarmOS\Models\User;

/**
 * Base test case for API testing
 */
abstract class ApiTestCase extends TestCase
{
    protected static Database $db;
    protected static string $testDbName = 'farmos_test';
    protected static string $testUser = 'test@example.com';
    protected static string $testPassword = 'TestPassword123!';
    protected static string $testToken = '';

    protected function setUp(): void
    {
        parent::setUp();
        \FarmOS\RateLimiter::reset();
    }

    /**
     * Set up test database connection
     */
    public static function setUpBeforeClass(): void
    {
        try {
            $host = getenv('DB_HOST') ?: 'localhost';
            $port = getenv('DB_PORT') ?: '3306';
            $user = getenv('DB_USER') ?: 'root';
            $pass = getenv('DB_PASSWORD') ?: '';

            self::$db = Database::init(
                'mysql:host=' . $host . ';port=' . $port . ';charset=utf8mb4',
                $user,
                $pass
            );

            // Create test database
            self::$db->execute('DROP DATABASE IF EXISTS ' . self::$testDbName);
            self::$db->execute('CREATE DATABASE ' . self::$testDbName);
            self::$db->execute('USE ' . self::$testDbName);

            // Run migrations
            self::runMigrations();

            // Create test user
            self::createTestUser();

            putenv('DATABASE_URL=mysql:host=' . $host . ';port=' . $port . ';dbname=' . self::$testDbName . ';charset=utf8mb4');
            putenv('DB_USER=' . $user);
            putenv('DB_PASSWORD=' . $pass);
        } catch (\Exception $e) {
            echo "Database setup failed: " . $e->getMessage() . "\n";
            exit(1);
        }
    }

    /**
     * Run database migrations
     */
    protected static function runMigrations(): void
    {
        // Users table
        self::$db->execute('
            CREATE TABLE users (
                id INT PRIMARY KEY AUTO_INCREMENT,
                email VARCHAR(191) UNIQUE NOT NULL,
                password_hash VARCHAR(255) NOT NULL,
                first_name VARCHAR(100),
                last_name VARCHAR(100),
                role VARCHAR(50) DEFAULT "user",
                status VARCHAR(20) DEFAULT "active",
                last_login DATETIME NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ');

        // Farms table
        self::$db->execute('
            CREATE TABLE farms (
                id INT PRIMARY KEY AUTO_INCREMENT,
                owner_id INT NOT NULL,
                name VARCHAR(255) NOT NULL,
                type VARCHAR(100),
                location VARCHAR(255),
                city VARCHAR(100),
                state VARCHAR(100),
                country VARCHAR(100),
                latitude DECIMAL(10,8),
                longitude DECIMAL(11,8),
                size DECIMAL(10,2),
                established_year INT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (owner_id) REFERENCES users(id)
            )
        ');

        // Livestock table
        self::$db->execute('
            CREATE TABLE livestock (
                id INT PRIMARY KEY AUTO_INCREMENT,
                farm_id INT NOT NULL,
                name VARCHAR(255),
                species VARCHAR(100) NOT NULL,
                breed VARCHAR(100),
                birth_date DATE,
                gender VARCHAR(50),
                weight DECIMAL(10,2),
                status ENUM("active", "sold", "deceased", "quarantine") DEFAULT "active",
                acquisition_date DATE,
                acquisition_cost DECIMAL(12,2),
                microchip_id VARCHAR(100),
                tag_number VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (farm_id) REFERENCES farms(id)
            )
        ');

        self::$db->execute('
            CREATE TABLE animal_events (
                id INT PRIMARY KEY AUTO_INCREMENT,
                livestock_id INT NOT NULL,
                event_type VARCHAR(100) NOT NULL,
                description TEXT,
                date DATETIME,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (livestock_id) REFERENCES livestock(id)
            )
        ');

        // Inventory table
        self::$db->execute('
            CREATE TABLE inventory (
                id INT PRIMARY KEY AUTO_INCREMENT,
                farm_id INT NOT NULL,
                name VARCHAR(255) NOT NULL,
                category VARCHAR(100),
                description TEXT,
                quantity DECIMAL(10,2) NOT NULL,
                unit VARCHAR(50),
                min_level DECIMAL(10,2),
                max_level DECIMAL(10,2),
                cost_per_unit DECIMAL(12,2),
                supplier VARCHAR(255),
                location VARCHAR(255),
                expiry_date DATE,
                batch_number VARCHAR(100),
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (farm_id) REFERENCES farms(id)
            )
        ');

        // Financial records table
        self::$db->execute('
            CREATE TABLE financial_records (
                id INT PRIMARY KEY AUTO_INCREMENT,
                farm_id INT NOT NULL,
                type ENUM("income", "expense") NOT NULL,
                category VARCHAR(100),
                description TEXT,
                amount DECIMAL(12,2) NOT NULL,
                currency VARCHAR(3) DEFAULT "USD",
                date DATETIME,
                reference_number VARCHAR(100),
                payment_method VARCHAR(100),
                status ENUM("completed", "pending", "cancelled") DEFAULT "completed",
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (farm_id) REFERENCES farms(id)
            )
        ');

        // Tasks table
        self::$db->execute('
            CREATE TABLE tasks (
                id INT PRIMARY KEY AUTO_INCREMENT,
                farm_id INT NOT NULL,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                assigned_to INT,
                status ENUM("pending", "in_progress", "completed", "cancelled") DEFAULT "pending",
                priority ENUM("low", "medium", "high", "critical") DEFAULT "medium",
                due_date DATETIME,
                completed_at DATETIME,
                created_by INT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (farm_id) REFERENCES farms(id),
                FOREIGN KEY (assigned_to) REFERENCES users(id),
                FOREIGN KEY (created_by) REFERENCES users(id)
            )
        ');

        // Weather table
        self::$db->execute('
            CREATE TABLE weather (
                id INT PRIMARY KEY AUTO_INCREMENT,
                farm_id INT NOT NULL,
                observation_date DATETIME,
                temperature DECIMAL(6,2),
                temperature_min DECIMAL(6,2),
                temperature_max DECIMAL(6,2),
                humidity INT,
                pressure DECIMAL(8,2),
                wind_speed DECIMAL(6,2),
                wind_direction VARCHAR(3),
                precipitation DECIMAL(8,2),
                `condition` VARCHAR(100),
                visibility DECIMAL(8,2),
                uv_index INT,
                source VARCHAR(100),
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (farm_id) REFERENCES farms(id)
            )
        ');
    }

    /**
     * Create test user and get token
     */
    protected static function createTestUser(): void
    {
        $auth = new Auth(self::$db);
        $result = $auth->register(
            self::$testUser,
            self::$testPassword,
            'Test',
            'User'
        );
        self::$testToken = $result['access_token'] ?? '';
    }

    /**
     * Make API request
     */
    protected function apiCall(string $method, string $path, ?array $data = null, ?string $token = null): array
    {
        $uri = $path;
        $parsed = parse_url($uri);
        $requestPath = $parsed['path'] ?? $uri;
        $_GET = [];
        if (!empty($parsed['query'])) {
            parse_str($parsed['query'], $_GET);
        }

        $_SERVER['REQUEST_METHOD'] = $method;
        $_SERVER['REQUEST_URI'] = $uri;
        $_SERVER['SCRIPT_NAME'] = '/index.php';
        $_SERVER['REMOTE_ADDR'] = '127.0.0.1';
        $_SERVER['HTTP_CONTENT_TYPE'] = 'application/json';

        $bearer = $token ?? self::$testToken;
        if (!empty($bearer)) {
            $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $bearer;
        } else {
            unset($_SERVER['HTTP_AUTHORIZATION']);
        }

        $GLOBALS['__FARMOS_TEST_RAW_BODY'] = $data ? json_encode($data) : '';

        http_response_code(200);
        ob_start();
        include BASE_PATH . '/public/index.php';
        $response = ob_get_clean();
        $httpCode = http_response_code();
        unset($GLOBALS['__FARMOS_TEST_RAW_BODY']);

        return [
            'status' => $httpCode,
            'body' => json_decode($response, true) ?? $response,
        ];
    }

    /**
     * Get test farm ID
     */
    protected function getTestFarmId(): int
    {
        $result = self::$db->query(
            'SELECT id FROM farms LIMIT 1'
        );

        if (empty($result)) {
            // Create test farm
            self::$db->execute(
                'INSERT INTO farms (owner_id, name, type, location) VALUES (?, ?, ?, ?)',
                [1, 'Test Farm', 'dairy', 'Test Location']
            );
            return (int) self::$db->lastInsertId();
        }

        return (int) ($result[0]['id'] ?? 0);
    }

    /**
     * Clean up after each test
     */
    protected function tearDown(): void
    {
        // Clear test data (optional - can keep for debugging)
    }

    /**
     * Clean up test database
     */
    public static function tearDownAfterClass(): void
    {
        try {
            self::$db->execute('DROP DATABASE ' . self::$testDbName);
        } catch (\Exception $e) {
            echo "Database cleanup failed: " . $e->getMessage() . "\n";
        }
    }
}
