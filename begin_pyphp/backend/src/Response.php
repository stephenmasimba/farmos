<?php

namespace FarmOS;

/**
 * HTTP Response handling
 */
class Response
{
    private int $statusCode = 200;
    private array $data = [];
    private array $headers = [];

    public function __construct(int $statusCode = 200)
    {
        $this->statusCode = $statusCode;
        $this->headers = Security::getSecurityHeaders();
        $this->headers['Content-Type'] = 'application/json';
    }

    public static function json(array $data, int $statusCode = 200): self
    {
        $response = new self($statusCode);
        $response->data = $data;
        return $response;
    }

    public static function success(array $data = [], string $message = 'Success', int $statusCode = 200): self
    {
        return self::json($data, $statusCode);
    }

    public static function error(string $message, string $code = 'ERROR', int $statusCode = 400, array $details = []): self
    {
        return self::json([
            'error' => [
                'code' => $code,
                'message' => $message,
                'details' => $details,
            ],
        ], $statusCode);
    }

    public static function notFound(string $message = 'Not found'): self
    {
        return self::error($message, 'NOT_FOUND', 404);
    }

    public static function unauthorized(string $message = 'Unauthorized'): self
    {
        return self::error($message, 'UNAUTHORIZED', 401);
    }

    public static function forbidden(string $message = 'Forbidden'): self
    {
        return self::error($message, 'FORBIDDEN', 403);
    }

    public static function validationError(array $errors): self
    {
        return self::error('Validation failed', 'VALIDATION_ERROR', 422, $errors);
    }

    public static function rateLimited(int $retryAfter = 60): self
    {
        $response = self::error('Rate limit exceeded', 'RATE_LIMIT_EXCEEDED', 429);
        $response->headers['Retry-After'] = (string) $retryAfter;
        return $response;
    }

    public function setStatusCode(int $code): self
    {
        $this->statusCode = $code;
        return $this;
    }

    public function setHeader(string $name, string $value): self
    {
        $this->headers[$name] = $value;
        return $this;
    }

    public function send(): void
    {
        http_response_code($this->statusCode);
        
        foreach ($this->headers as $name => $value) {
            header("$name: $value");
        }

        echo json_encode($this->data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    }

    public function __toString(): string
    {
        return json_encode($this->data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    }
}
