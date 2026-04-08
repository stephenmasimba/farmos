<?php

namespace FarmOS;

use PDO;
use PDOException;

/**
 * Database connection and query execution
 */
class Database
{
    private static ?PDO $connection = null;
    private PDO $pdo;

    public function __construct(string $dsn, string $username, string $password)
    {
        try {
            $this->pdo = new PDO(
                $dsn,
                $username,
                $password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        } catch (PDOException $e) {
            Logger::error('Database connection failed', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Initialize static connection
     */
    public static function init(string $dsn, string $username, string $password): self
    {
        if (self::$connection === null) {
            self::$connection = new PDO(
                $dsn,
                $username,
                $password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        }
        return new self($dsn, $username, $password);
    }

    /**
     * Get static connection
     */
    public static function get(): PDO
    {
        if (self::$connection === null) {
            throw new \Exception('Database not initialized');
        }
        return self::$connection;
    }

    /**
     * Execute query and return results
     */
    public function query(string $sql, array $params = []): array
    {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            Logger::error('Database query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Execute query and return single row
     */
    public function queryOne(string $sql, array $params = []): ?array
    {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetch() ?: null;
        } catch (PDOException $e) {
            Logger::error('Database query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Execute insert/update/delete
     */
    public function execute(string $sql, array $params = []): int
    {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->rowCount();
        } catch (PDOException $e) {
            Logger::error('Database execute failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get last inserted ID
     */
    public function lastInsertId(): string
    {
        return $this->pdo->lastInsertId();
    }

    /**
     * Begin transaction
     */
    public function beginTransaction(): void
    {
        $this->pdo->beginTransaction();
    }

    /**
     * Commit transaction
     */
    public function commit(): void
    {
        $this->pdo->commit();
    }

    /**
     * Rollback transaction
     */
    public function rollback(): void
    {
        $this->pdo->rollBack();
    }

    /**
     * Test connection
     */
    public function test(): bool
    {
        try {
            $this->pdo->query('SELECT 1');
            return true;
        } catch (PDOException $e) {
            Logger::error('Database test failed', ['error' => $e->getMessage()]);
            return false;
        }
    }
}
