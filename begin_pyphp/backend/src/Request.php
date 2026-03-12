<?php

namespace FarmOS;

/**
 * HTTP Request handling
 */
class Request
{
    private array $headers;
    private array $body;
    private string $method;
    private string $path;
    private array $query;

    public function __construct()
    {
        $this->method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        $rawPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
        $scriptName = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '');
        $mount = $scriptName;
        if ($mount !== '' && substr($mount, -strlen('/public/index.php')) === '/public/index.php') {
            $mount = substr($mount, 0, -strlen('/public/index.php'));
        } elseif ($mount !== '' && substr($mount, -strlen('/index.php')) === '/index.php') {
            $mount = substr($mount, 0, -strlen('/index.php'));
        }
        $mount = rtrim($mount, '/');

        if ($mount !== '' && strpos($rawPath, $mount) === 0) {
            $rawPath = substr($rawPath, strlen($mount));
            if ($rawPath === '') {
                $rawPath = '/';
            }
        }

        if ($rawPath !== '/' && substr($rawPath, -1) === '/') {
            $rawPath = rtrim($rawPath, '/');
        }

        $this->path = $rawPath;
        $this->headers = $this->getHeaders();
        $this->query = $_GET ?? [];
        $this->body = $this->getBody();
    }

    public function getMethod(): string
    {
        return $this->method;
    }

    public function getPath(): string
    {
        return $this->path;
    }

    public function getHeaders(): array
    {
        if (!empty($this->headers)) {
            return $this->headers;
        }

        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (strpos($name, 'HTTP_') === 0) {
                $header = str_replace('HTTP_', '', $name);
                $header = str_replace('_', '-', $header);
                $headers[strtolower($header)] = $value;
            }
        }
        
        return $headers;
    }

    public function getHeader(string $name): ?string
    {
        return $this->headers[strtolower($name)] ?? null;
    }

    public function getBody(): array
    {
        if (!empty($this->body)) {
            return $this->body;
        }

        $contentType = $this->getHeader('content-type') ?: '';
        
        if (strpos($contentType, 'application/json') !== false) {
            $raw = isset($GLOBALS['__FARMOS_TEST_RAW_BODY']) ? (string) $GLOBALS['__FARMOS_TEST_RAW_BODY'] : file_get_contents('php://input');
            $decoded = json_decode($raw, true);
            $body = $decoded ?: [];
        } elseif (!empty($_POST)) {
            $body = $_POST;
        } else {
            $body = [];
        }

        if (!isset($body['farm_id'])) {
            $tenantId = $this->getHeader('x-tenant-id');
            if (is_numeric($tenantId)) {
                $body['farm_id'] = (int) $tenantId;
            }
        }

        return $body;
    }

    public function getQuery(?string $key = null, $default = null)
    {
        if ($key === null) {
            $query = $this->query;
            if (!isset($query['farm_id'])) {
                $tenantId = $this->getHeader('x-tenant-id');
                if (is_numeric($tenantId)) {
                    $query['farm_id'] = (int) $tenantId;
                } else {
                    $query['farm_id'] = 1;
                }
            }
            return $query;
        }

        return $this->query[$key] ?? $default;
    }

    public function getInput(string $key, $default = null)
    {
        return $this->body[$key] ?? $default;
    }

    public function getIP(): string
    {
        return $_SERVER['HTTP_X_REAL_IP'] 
            ?? $_SERVER['HTTP_X_FORWARDED_FOR']
            ?? $_SERVER['REMOTE_ADDR'] 
            ?? 'unknown';
    }

    public function getToken(): ?string
    {
        $auth = $this->getHeader('authorization');
        
        if (!$auth) {
            return null;
        }

        if (preg_match('/Bearer\s+(.+)/', $auth, $matches)) {
            return $matches[1];
        }

        return null;
    }

    public function getUser(): ?array
    {
        $token = $this->getToken();
        
        if (!$token) {
            return null;
        }

        try {
            return Security::decodeJWT($token);
        } catch (\Exception $e) {
            Logger::warning('Invalid token', ['error' => $e->getMessage()]);
            return null;
        }
    }
}
