<?php

namespace FarmOS;

use DateTime;

/**
 * Structured logging system
 */
class Logger
{
    private static string $logDir = '/var/log/farmos';
    private static string $format = 'json'; // 'json' or 'text'
    private static string $requestId = '';

    public static function init(string $logDir, string $format = 'json'): void
    {
        self::$logDir = $logDir;
        self::$format = $format;

        if (!is_dir(self::$logDir)) {
            if (!@mkdir(self::$logDir, 0755, true) && !is_dir(self::$logDir)) {
                self::$logDir = rtrim(sys_get_temp_dir(), '\\/') . DIRECTORY_SEPARATOR . 'farmos_logs';
                if (!is_dir(self::$logDir)) {
                    @mkdir(self::$logDir, 0755, true);
                }
            }
        }
    }

    public static function setRequestId(string $requestId): void
    {
        self::$requestId = $requestId;
    }

    public static function getRequestId(): string
    {
        if (self::$requestId !== '') {
            return self::$requestId;
        }

        $fromHeader = (string) ($_SERVER['HTTP_X_REQUEST_ID'] ?? '');
        if ($fromHeader !== '') {
            self::$requestId = $fromHeader;
            return self::$requestId;
        }

        self::$requestId = bin2hex(random_bytes(8));
        return self::$requestId;
    }

    public static function info(string $message, array $context = []): void
    {
        self::log('INFO', $message, $context);
    }

    public static function warning(string $message, array $context = []): void
    {
        self::log('WARNING', $message, $context);
    }

    public static function error(string $message, array $context = []): void
    {
        self::log('ERROR', $message, $context);
    }

    public static function debug(string $message, array $context = []): void
    {
        self::log('DEBUG', $message, $context);
    }

    private static function log(string $level, string $message, array $context = []): void
    {
        if (!self::shouldLog($level)) {
            return;
        }

        $timestamp = date('Y-m-d H:i:s');
        $logFile = rtrim(self::$logDir, '\\/') . DIRECTORY_SEPARATOR . ($level === 'ERROR' ? 'error' : 'farmos') . '.log';
        if (self::$format === 'json') {
            $logEntry = json_encode([
                'timestamp' => $timestamp,
                'level' => $level,
                'message' => $message,
                'context' => $context,
                'request_id' => self::getRequestId(),
            ]) . PHP_EOL;
        } else {
            $logEntry = "[$timestamp] $level: $message";
            if (!empty($context)) {
                $logEntry .= ' ' . json_encode($context);
            }
            $logEntry .= PHP_EOL;
        }

        @error_log($logEntry, 3, $logFile);
    }

    private static function shouldLog(string $level): bool
    {
        $current = strtolower((string) (getenv('LOG_LEVEL') ?: 'info'));
        $map = [
            'debug' => 10,
            'info' => 20,
            'warning' => 30,
            'error' => 40,
        ];

        $threshold = $map[$current] ?? 20;
        $lvl = $map[strtolower($level)] ?? 20;
        return $lvl >= $threshold;
    }

    /**
     * Get logs from file
     */
    public static function getLogs(string $type = 'farmos', int $lines = 100): array
    {
        $logFile = self::$logDir . '/' . $type . '.log';

        if (!file_exists($logFile)) {
            return [];
        }

        $logLines = array_slice(file($logFile, FILE_IGNORE_NEW_LINES), -$lines);
        return array_map(fn($line) => json_decode($line, true) ?? ['raw' => $line], $logLines);
    }
}
