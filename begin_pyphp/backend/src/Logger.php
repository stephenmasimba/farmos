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

    public static function init(string $logDir, string $format = 'json'): void
    {
        self::$logDir = $logDir;
        self::$format = $format;
        
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }
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
        if (getenv('LOG_LEVEL') === 'DEBUG') {
            self::log('DEBUG', $message, $context);
        }
    }

    private static function log(string $level, string $message, array $context = []): void
    {
        $timestamp = date('Y-m-d H:i:s');
        $logFile = self::$logDir . '/' . ($level === 'ERROR' ? 'error' : 'farmos') . '.log';

        if (self::$format === 'json') {
            $logEntry = json_encode([
                'timestamp' => $timestamp,
                'level' => $level,
                'message' => $message,
                'context' => $context,
                'request_id' => $_SERVER['HTTP_X_REQUEST_ID'] ?? uniqid(),
            ]) . PHP_EOL;
        } else {
            $logEntry = "[$timestamp] $level: $message";
            if (!empty($context)) {
                $logEntry .= ' ' . json_encode($context);
            }
            $logEntry .= PHP_EOL;
        }

        error_log($logEntry, 3, $logFile);
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
