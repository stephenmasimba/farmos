<?php

namespace FarmOS;

/**
 * Rate limiting using sliding window algorithm
 */
class RateLimiter
{
    private static array $limits = [
        'auth' => ['requests' => 5, 'window' => 60],      // 5 req/min
        'api' => ['requests' => 100, 'window' => 60],     // 100 req/min
        'upload' => ['requests' => 50, 'window' => 3600], // 50 req/hour
    ];

    private static array $storage = [];

    /**
     * Check if request is allowed
     */
    public static function isAllowed(string $identifier, string $limit = 'api'): bool
    {
        if (!isset(self::$limits[$limit])) {
            $limit = 'api';
        }

        $config = self::$limits[$limit];
        $now = time();
        $key = "$identifier:$limit";

        if (!isset(self::$storage[$key])) {
            self::$storage[$key] = [];
        }

        // Remove old entries outside window
        self::$storage[$key] = array_filter(
            self::$storage[$key],
            fn($timestamp) => $now - $timestamp < $config['window']
        );

        // Check if limit exceeded
        if (count(self::$storage[$key]) >= $config['requests']) {
            Logger::warning('Rate limit exceeded', [
                'identifier' => $identifier,
                'limit' => $limit,
                'count' => count(self::$storage[$key]),
            ]);
            return false;
        }

        // Add current request
        self::$storage[$key][] = $now;
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
        if (!isset(self::$limits[$limit])) {
            $limit = 'api';
        }

        $config = self::$limits[$limit];
        $now = time();
        $key = "$identifier:$limit";

        if (!isset(self::$storage[$key])) {
            return $config['requests'];
        }

        self::$storage[$key] = array_filter(
            self::$storage[$key],
            fn($timestamp) => $now - $timestamp < $config['window']
        );

        return $config['requests'] - count(self::$storage[$key]);
    }
}
