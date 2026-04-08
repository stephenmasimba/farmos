<?php

namespace FarmOS;

/**
 * Rate limiting using a fixed window counter.
 *
 * Prefers database-backed counters (shared-hosting friendly) and falls back to
 * in-memory storage if the database is not initialized or unavailable.
 */
class RateLimiter
{
    private static bool $dbReady = false;
    private static ?string $dbDriver = null;
    private static array $storage = [];

    /**
     * Check if request is allowed
     */
    public static function isAllowed(string $identifier, string $limit = 'api'): bool
    {
        $config = self::getConfig($limit);
        $now = time();
        $bucket = intdiv($now, $config['window']) * $config['window'];
        $expiresAt = $bucket + $config['window'];
        $key = hash('sha256', $identifier) . ':' . $limit . ':' . $bucket;

        if (self::tryDbIncrement($key, $limit, $bucket, $expiresAt)) {
            $count = self::dbGetCount($key, $limit, $bucket);
            if ($count > $config['requests']) {
                Logger::warning('Rate limit exceeded', [
                    'identifier' => $identifier,
                    'limit' => $limit,
                    'count' => $count,
                ]);
                return false;
            }
            return true;
        }

        $memKey = $identifier . ':' . $limit;
        if (!isset(self::$storage[$memKey])) {
            self::$storage[$memKey] = [];
        }

        self::$storage[$memKey] = array_filter(
            self::$storage[$memKey],
            static fn (int $timestamp): bool => $now - $timestamp < $config['window']
        );

        if (count(self::$storage[$memKey]) >= $config['requests']) {
            Logger::warning('Rate limit exceeded', [
                'identifier' => $identifier,
                'limit' => $limit,
                'count' => count(self::$storage[$memKey]),
            ]);
            return false;
        }

        self::$storage[$memKey][] = $now;
        return true;
    }

    public static function reset(): void
    {
        self::$storage = [];
    }

    /**
     * Get remaining requests
     */
    public static function getRemaining(string $identifier, string $limit = 'api'): int
    {
        $config = self::getConfig($limit);
        $now = time();
        $bucket = intdiv($now, $config['window']) * $config['window'];
        $key = hash('sha256', $identifier) . ':' . $limit . ':' . $bucket;

        if (self::ensureDbReady()) {
            $count = self::dbGetCount($key, $limit, $bucket);
            $remaining = $config['requests'] - $count;
            return $remaining > 0 ? $remaining : 0;
        }

        $memKey = $identifier . ':' . $limit;
        if (!isset(self::$storage[$memKey])) {
            return $config['requests'];
        }

        self::$storage[$memKey] = array_filter(
            self::$storage[$memKey],
            static fn (int $timestamp): bool => $now - $timestamp < $config['window']
        );

        $remaining = $config['requests'] - count(self::$storage[$memKey]);
        return $remaining > 0 ? $remaining : 0;
    }

    private static function getConfig(string $limit): array
    {
        $limitName = $limit;
        if (!in_array($limitName, ['auth', 'api', 'upload'], true)) {
            $limitName = 'api';
        }

        if ($limitName === 'auth') {
            $requests = (int) (getenv('API_RATE_LIMIT_AUTH') ?: 5);
            $window = 60;
        } elseif ($limitName === 'upload') {
            $requests = (int) (getenv('API_RATE_LIMIT_UPLOAD') ?: 50);
            $window = 3600;
        } else {
            $requests = (int) (getenv('API_RATE_LIMIT_API') ?: 100);
            $window = 60;
        }

        if ($requests < 1) {
            $requests = 1;
        }
        if ($window < 1) {
            $window = 1;
        }

        return [
            'requests' => $requests,
            'window' => $window,
        ];
    }

    private static function ensureDbReady(): bool
    {
        if (self::$dbReady) {
            return true;
        }

        try {
            $pdo = Database::get();
            $driver = (string) $pdo->getAttribute(\PDO::ATTR_DRIVER_NAME);
            self::$dbDriver = $driver;

            if ($driver === 'sqlite') {
                $pdo->exec(
                    'CREATE TABLE IF NOT EXISTS rate_limit_counters (
                        identifier TEXT NOT NULL,
                        limit_name TEXT NOT NULL,
                        bucket INTEGER NOT NULL,
                        count INTEGER NOT NULL,
                        expires_at INTEGER NOT NULL,
                        PRIMARY KEY (identifier, limit_name, bucket)
                    )'
                );
                $pdo->exec('CREATE INDEX IF NOT EXISTS idx_rate_limit_expires_at ON rate_limit_counters (expires_at)');
            } else {
                $pdo->exec(
                    'CREATE TABLE IF NOT EXISTS rate_limit_counters (
                        identifier VARCHAR(128) NOT NULL,
                        limit_name VARCHAR(20) NOT NULL,
                        bucket INT NOT NULL,
                        count INT NOT NULL,
                        expires_at INT NOT NULL,
                        PRIMARY KEY (identifier, limit_name, bucket),
                        INDEX idx_expires_at (expires_at)
                    ) ENGINE=InnoDB'
                );
            }

            self::$dbReady = true;
            return true;
        } catch (\Throwable $e) {
            self::$dbReady = false;
            return false;
        }
    }

    private static function tryDbIncrement(string $identifierKey, string $limit, int $bucket, int $expiresAt): bool
    {
        if (!self::ensureDbReady()) {
            return false;
        }

        try {
            $pdo = Database::get();

            if (self::$dbDriver === 'sqlite') {
                $stmt = $pdo->prepare(
                    'INSERT INTO rate_limit_counters (identifier, limit_name, bucket, count, expires_at)
                     VALUES (?, ?, ?, 1, ?)
                     ON CONFLICT(identifier, limit_name, bucket)
                     DO UPDATE SET count = count + 1'
                );
                $stmt->execute([$identifierKey, $limit, $bucket, $expiresAt]);
            } else {
                $stmt = $pdo->prepare(
                    'INSERT INTO rate_limit_counters (identifier, limit_name, bucket, count, expires_at)
                     VALUES (?, ?, ?, 1, ?)
                     ON DUPLICATE KEY UPDATE count = count + 1'
                );
                $stmt->execute([$identifierKey, $limit, $bucket, $expiresAt]);
            }

            if (random_int(1, 100) === 1) {
                $cleanup = $pdo->prepare('DELETE FROM rate_limit_counters WHERE expires_at < ?');
                $cleanup->execute([time()]);
            }

            return true;
        } catch (\Throwable $e) {
            return false;
        }
    }

    private static function dbGetCount(string $identifierKey, string $limit, int $bucket): int
    {
        try {
            $pdo = Database::get();
            $stmt = $pdo->prepare(
                'SELECT count FROM rate_limit_counters WHERE identifier = ? AND limit_name = ? AND bucket = ?'
            );
            $stmt->execute([$identifierKey, $limit, $bucket]);
            $row = $stmt->fetch(\PDO::FETCH_ASSOC);
            return $row ? (int) $row['count'] : 0;
        } catch (\Throwable $e) {
            return 0;
        }
    }
}
