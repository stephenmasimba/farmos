<?php

namespace FarmOS;

/**
 * Application Exception Handler
 * Manages custom exceptions and error handling
 */
class Exception extends \Exception
{
    protected string $code_string;
    protected array $details = [];
    protected int $http_status = 500;

    /**
     * Create a new exception
     * @param string $message Exception message
     * @param string $code_string Machine-readable error code
     * @param int $http_status HTTP status code
     * @param array $details Additional error details
     * @param \Throwable|null $previous Previous exception
     */
    public function __construct(
        string $message = '',
        string $code_string = 'INTERNAL_ERROR',
        int $http_status = 500,
        array $details = [],
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 0, $previous);
        $this->code_string = $code_string;
        $this->http_status = $http_status;
        $this->details = $details;
    }

    /**
     * Get machine-readable error code
     */
    public function getCodeString(): string
    {
        return $this->code_string;
    }

    /**
     * Get HTTP status code
     */
    public function getHttpStatus(): int
    {
        return $this->http_status;
    }

    /**
     * Get error details
     */
    public function getDetails(): array
    {
        return $this->details;
    }

    /**
     * Log exception
     */
    public function log(): void
    {
        Logger::error($this->message, [
            'code' => $this->code_string,
            'status' => $this->http_status,
            'details' => $this->details,
            'trace' => $this->getTraceAsString(),
        ]);
    }
}

/**
 * Validation Exception
 */
class ValidationException extends Exception
{
    public function __construct(
        string $message = 'Validation failed',
        array $details = [],
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 'VALIDATION_ERROR', 400, $details, $previous);
    }
}

/**
 * Authentication Exception
 */
class AuthenticationException extends Exception
{
    public function __construct(
        string $message = 'Unauthorized',
        array $details = [],
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 'AUTHENTICATION_ERROR', 401, $details, $previous);
    }
}

/**
 * Authorization Exception
 */
class AuthorizationException extends Exception
{
    public function __construct(
        string $message = 'Forbidden',
        array $details = [],
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 'AUTHORIZATION_ERROR', 403, $details, $previous);
    }
}

/**
 * Not Found Exception
 */
class NotFoundException extends Exception
{
    public function __construct(
        string $message = 'Resource not found',
        array $details = [],
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 'NOT_FOUND', 404, $details, $previous);
    }
}

/**
 * Rate Limit Exception
 */
class RateLimitException extends Exception
{
    protected int $retry_after = 60;

    public function __construct(
        string $message = 'Too many requests',
        int $retry_after = 60,
        array $details = [],
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 'RATE_LIMITED', 429, $details, $previous);
        $this->retry_after = $retry_after;
    }

    /**
     * Get retry-after header value
     */
    public function getRetryAfter(): int
    {
        return $this->retry_after;
    }
}

/**
 * Database Exception
 */
class DatabaseException extends Exception
{
    public function __construct(
        string $message = 'Database error',
        array $details = [],
        ?\Throwable $previous = null
    ) {
        // Don't expose internal database errors to client
        parent::__construct('Database operation failed', 'DATABASE_ERROR', 500, $details, $previous);

        // Log the actual error
        Logger::error('Database error: ' . $message, $details);
    }
}

/**
 * Configuration Exception
 */
class ConfigException extends Exception
{
    public function __construct(
        string $message = 'Configuration error',
        array $details = [],
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 'CONFIG_ERROR', 500, $details, $previous);
    }
}
