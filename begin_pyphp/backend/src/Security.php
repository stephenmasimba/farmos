<?php

namespace FarmOS;

/**
 * Security utility class for JWT, password hashing, and encryption
 */
class Security
{
    private static string $secret;
    
    public static function init(string $jwtSecret): void
    {
        if (strlen($jwtSecret) < 32) {
            throw new \Exception('JWT_SECRET must be at least 32 characters');
        }
        self::$secret = $jwtSecret;
    }

    /**
     * Hash password using bcrypt
     */
    public static function hashPassword(string $password): string
    {
        if (strlen($password) < 8) {
            throw new \Exception('Password must be at least 8 characters');
        }
        if (!preg_match('/[[:upper:]]/', $password)) {
            throw new \Exception('Password must contain uppercase letters');
        }
        if (!preg_match('/[[:lower:]]/', $password)) {
            throw new \Exception('Password must contain lowercase letters');
        }
        if (!preg_match('/[0-9]/', $password)) {
            throw new \Exception('Password must contain digits');
        }
        if (!preg_match('/[!@#$%^&*()_+\-=\[\]{};:\'",.<>?\/\\|`~]/', $password)) {
            throw new \Exception('Password must contain special characters');
        }
        
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Verify password against hash
     */
    public static function verifyPassword(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }

    /**
     * Encode JWT token
     */
    public static function encodeJWT(array $payload, int $expiresIn = 3600): string
    {
        $payload['iat'] = time();
        $payload['exp'] = time() + $expiresIn;
        
        $header = base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
        $payload = base64_encode(json_encode($payload));
        
        $signature = hash_hmac(
            'sha256',
            "$header.$payload",
            self::$secret,
            true
        );
        $signature = base64_encode($signature);
        
        return "$header.$payload.$signature";
    }

    /**
     * Decode and verify JWT token
     */
    public static function decodeJWT(string $token): array
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new \Exception('Invalid token format');
        }

        list($header, $payload, $signature) = $parts;

        // Verify signature
        $expectedSignature = hash_hmac(
            'sha256',
            "$header.$payload",
            self::$secret,
            true
        );
        $expectedSignature = base64_encode($expectedSignature);

        if (!self::constantTimeCompare($signature, $expectedSignature)) {
            throw new \Exception('Invalid token signature');
        }

        // Decode payload
        $decoded = json_decode(base64_decode($payload), true);
        
        if (!$decoded) {
            throw new \Exception('Invalid token payload');
        }

        // Check expiration
        if (isset($decoded['exp']) && $decoded['exp'] < time()) {
            throw new \Exception('Token expired');
        }

        return $decoded;
    }

    /**
     * Refresh JWT token
     */
    public static function refreshToken(string $token): string
    {
        $payload = self::decodeJWT($token);
        unset($payload['iat'], $payload['exp']);
        
        return self::encodeJWT($payload);
    }

    /**
     * Constant time string comparison (prevent timing attacks)
     */
    private static function constantTimeCompare(string $a, string $b): bool
    {
        return hash_equals($a, $b);
    }

    /**
     * Generate secure random token
     */
    public static function generateToken(int $length = 32): string
    {
        return bin2hex(random_bytes($length));
    }

    /**
     * Get security headers for responses
     */
    public static function getSecurityHeaders(): array
    {
        return [
            'X-Content-Type-Options' => 'nosniff',
            'X-Frame-Options' => 'DENY',
            'X-XSS-Protection' => '1; mode=block',
            'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
            'Content-Security-Policy' => "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'",
        ];
    }
}
