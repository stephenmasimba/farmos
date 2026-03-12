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

    /**
     * Set up test database connection
     */
    public static function setUpBeforeClass(): void
    {
        try {
            self::$db = Database::init(
                'mysql:host=' . getenv('DB_HOST') . ':' . getenv('DB_PORT'),
                getenv('DB_USER'),
                getenv('DB_PASSWORD')
            );

            // Create test database
            self::$db->exec('DROP DATABASE IF EXISTS ' . self::$testDbName);
            self::$db->exec('CREATE DATABASE ' . self::$testDbName);
            self::$db->exec('USE ' . self::$testDbName);

            // Run migrations
            self::runMigrations();

            // Create test user
            self::createTestUser();
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
        self::$db->exec('
            CREATE TABLE users (
                user_id INT PRIMARY KEY AUTO_INCREMENT,
                email VARCHAR(255) UNIQUE NOT NULL,
                password VARCHAR(255) NOT NULL,
                first_name VARCHAR(100),
                last_name VARCHAR(100),
                role ENUM("user", "admin", "farm_manager") DEFAULT "user",
                status ENUM("active", "inactive", "suspended") DEFAULT "active",
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ');

        // Farms table
        self::$db->exec('
            CREATE TABLE farms (
                farm_id INT PRIMARY KEY AUTO_INCREMENT,
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
                FOREIGN KEY (owner_id) REFERENCES users(user_id)
            )
        ');

        // Livestock table
        self::$db->exec('
            CREATE TABLE livestock (
                livestock_id INT PRIMARY KEY AUTO_INCREMENT,
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
                FOREIGN KEY (farm_id) REFERENCES farms(farm_id)
            )
        ');

        // Inventory table
        self::$db->exec('
            CREATE TABLE inventory (
                inventory_id INT PRIMARY KEY AUTO_INCREMENT,
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
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (farm_id) REFERENCES farms(farm_id)
            )
        ');

        // Financial records table
        self::$db->exec('
            CREATE TABLE financial_records (
                financial_id INT PRIMARY KEY AUTO_INCREMENT,
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
                FOREIGN KEY (farm_id) REFERENCES farms(farm_id)
            )
        ');

        // Tasks table
        self::$db->exec('
            CREATE TABLE tasks (
                task_id INT PRIMARY KEY AUTO_INCREMENT,
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
                FOREIGN KEY (farm_id) REFERENCES farms(farm_id),
                FOREIGN KEY (assigned_to) REFERENCES users(user_id),
                FOREIGN KEY (created_by) REFERENCES users(user_id)
            )
        ');

        // Weather table
        self::$db->exec('
            CREATE TABLE weather (
                weather_id INT PRIMARY KEY AUTO_INCREMENT,
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
                condition VARCHAR(100),
                visibility DECIMAL(8,2),
                uv_index INT,
                source VARCHAR(100),
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (farm_id) REFERENCES farms(farm_id)
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
        $baseUrl = getenv('API_BASE_URL') ?: 'http://localhost:8001';
        $url = rtrim($baseUrl, '/') . $path;
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Authorization: Bearer ' . ($token ?? self::$testToken),
        ]);

        if ($data) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

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
            'SELECT farm_id FROM farms LIMIT 1'
        );

        if (empty($result)) {
            // Create test farm
            $result = self::$db->query(
                'INSERT INTO farms (owner_id, name, type, location) VALUES (?, ?, ?, ?)',
                [1, 'Test Farm', 'dairy', 'Test Location']
            );
            return self::$db->lastInsertId();
        }

        return $result[0]['farm_id'] ?? 0;
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
            self::$db->exec('DROP DATABASE ' . self::$testDbName);
        } catch (\Exception $e) {
            echo "Database cleanup failed: " . $e->getMessage() . "\n";
        }
    }
}
