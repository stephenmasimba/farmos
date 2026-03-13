<?php

namespace FarmOS\Middleware;

use FarmOS\{Request, Response, Logger, RateLimiter, Security};
use FarmOS\Models\User;
use FarmOS\Database;

/**
 * Base Middleware class
 * All middleware should extend this class
 */
abstract class Middleware
{
    protected Request $request;
    protected Database $db;

    public function __construct(Request $request, Database $db)
    {
        $this->request = $request;
        $this->db = $db;
    }

    /**
     * Handle the request
     * Return true to continue, Response to return early
     */
    abstract public function handle();
}

/**
 * Authentication Middleware
 * Verifies JWT token and sets user context
 */
class AuthMiddleware extends Middleware
{
    private static bool $blacklistEnsured = false;

    public function handle()
    {
        $user = $this->request->getUser();

        if (!$user || empty($user['user_id'])) {
            return Response::unauthorized('Invalid or expired token')->setStatusCode(401);
        }

        if (!empty($user['jti'])) {
            if (!self::$blacklistEnsured) {
                $this->db->execute('CREATE TABLE IF NOT EXISTS jwt_blacklist (
                    jti VARCHAR(64) PRIMARY KEY,
                    user_id INT NOT NULL,
                    expires_at DATETIME NOT NULL,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )');
                self::$blacklistEnsured = true;
            }
            $row = $this->db->queryOne('SELECT jti FROM jwt_blacklist WHERE jti = ? AND expires_at > NOW()', [$user['jti']]);
            if ($row) {
                return Response::unauthorized('Token revoked')->setStatusCode(401);
            }
        }

        // Optional: Verify user still exists in database
        $userModel = User::find($user['user_id'], $this->db);
        if (!$userModel || !$userModel->isActive()) {
            return Response::unauthorized('User account inactive')->setStatusCode(401);
        }

        // User is authenticated, continue
        return true;
    }
}

/**
 * Rate Limiting Middleware
 * Enforces rate limits per IP address
 */
class RateLimitMiddleware extends Middleware
{
    protected string $limit = 'api'; // 'api', 'auth', 'upload'

    public function __construct(Request $request, Database $db, string $limit = 'api')
    {
        parent::__construct($request, $db);
        $this->limit = $limit;
    }

    public function handle()
    {
        $clientIP = $this->request->getIP();

        if (!RateLimiter::isAllowed($clientIP, $this->limit)) {
            $retryAfter = 60;
            if ($this->limit === 'upload') {
                $retryAfter = 3600;
            }

            return Response::rateLimited($retryAfter)->setStatusCode(429);
        }

        return true;
    }
}

/**
 * CORS Middleware
 * Handles CORS headers and preflight requests
 */
class CorsMiddleware extends Middleware
{
    public function handle()
    {
        $origin = getenv('CORS_ORIGIN');
        $requestOrigin = $_SERVER['HTTP_ORIGIN'] ?? '';

        // Allow specific origin
        if ($requestOrigin === $origin) {
            header("Access-Control-Allow-Origin: $requestOrigin");
        }

        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
        header('Access-Control-Max-Age: 3600');
        header('Access-Control-Allow-Credentials: true');

        // Handle preflight
        if ($this->request->getMethod() === 'OPTIONS') {
            return Response::success()->setStatusCode(200);
        }

        return true;
    }
}

/**
 * Admin Middleware
 * Verifies user is admin
 */
class AdminMiddleware extends Middleware
{
    public function handle()
    {
        $user = $this->request->getUser();

        if (!$user || empty($user['user_id'])) {
            return Response::unauthorized('Authentication required')->setStatusCode(401);
        }

        $userModel = User::find($user['user_id'], $this->db);

        if (!$userModel || !$userModel->isAdmin()) {
            return Response::forbidden('Administrator access required')->setStatusCode(403);
        }

        return true;
    }
}

/**
 * Validation Middleware
 * Basic request validation
 */
class ValidationMiddleware extends Middleware
{
    protected array $rules = [];

    public function __construct(Request $request, Database $db, array $rules = [])
    {
        parent::__construct($request, $db);
        $this->rules = $rules;
    }

    public function handle()
    {
        $body = $this->request->getBody();
        $errors = [];

        foreach ($this->rules as $field => $rule) {
            if (!isset($body[$field]) && strpos($rule, 'required') !== false) {
                $errors[$field] = "Field is required";
            }
        }

        if (!empty($errors)) {
            return Response::validationError($errors)->setStatusCode(400);
        }

        return true;
    }
}

/**
 * Logging Middleware
 * Logs all requests
 */
class LoggingMiddleware extends Middleware
{
    public function handle()
    {
        Logger::info('Request', [
            'method' => $this->request->getMethod(),
            'path' => $this->request->getPath(),
            'ip' => $this->request->getIP(),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
        ]);

        return true;
    }
}

/**
 * Security Headers Middleware
 * Adds security headers to responses
 */
class SecurityHeadersMiddleware extends Middleware
{
    public function handle()
    {
        $headers = Security::getSecurityHeaders();

        foreach ($headers as $name => $value) {
            header("$name: $value");
        }

        return true;
    }
}

/**
 * Middleware Pipeline
 * Manages middleware execution order
 */
class Pipeline
{
    protected array $middlewares = [];
    protected Request $request;
    protected Database $db;

    public function __construct(Request $request, Database $db)
    {
        $this->request = $request;
        $this->db = $db;
    }

    /**
     * Add middleware
     */
    public function add(...$middlewares): self
    {
        foreach ($middlewares as $middleware) {
            if (is_string($middleware)) {
                $class = 'FarmOS\\Middleware\\' . $middleware;
                $this->middlewares[] = new $class($this->request, $this->db);
            } else {
                $this->middlewares[] = $middleware;
            }
        }

        return $this;
    }

    /**
     * Execute pipeline
     * Returns the final response or true if all pass
     */
    public function execute()
    {
        foreach ($this->middlewares as $middleware) {
            $result = $middleware->handle();

            if ($result instanceof Response || $result instanceof \Exception) {
                return $result;
            }

            if ($result !== true) {
                return Response::error('Middleware error', 'MIDDLEWARE_ERROR', 500);
            }
        }

        return true;
    }
}
