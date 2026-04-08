<?php

namespace FarmOS;

/**
 * Security utility class for JWT, password hashing, and encryption
 */
class Security
{
    private static string $secret;
    private static ?string $issuer = null;
    private static ?string $audience = null;
    private static int $leeway = 0;
    public static function init(string $jwtSecret): void
    {
        if (strlen($jwtSecret) < 32) {
            throw new \Exception('JWT_SECRET must be at least 32 characters');
        }
        self::$secret = $jwtSecret;
        self::$issuer = getenv('JWT_ISS') ?: (getenv('APP_NAME') ?: 'FarmOS');
        self::$audience = getenv('JWT_AUD') ?: 'FarmOS-API';
        $leeway = getenv('JWT_LEEWAY') ?: '0';
        self::$leeway = is_numeric($leeway) ? (int) $leeway : 0;
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
        $now = time();
        $payload['iat'] = $payload['iat'] ?? $now;
        $payload['nbf'] = $payload['nbf'] ?? $now;
        $payload['exp'] = $payload['exp'] ?? ($now + (int) ($expiresIn ?: (int) (getenv('JWT_EXPIRY') ?: 3600)));
        if (isset($payload['user_id']) && !isset($payload['sub'])) {
            $payload['sub'] = (string) $payload['user_id'];
        }
        if (self::$issuer && !isset($payload['iss'])) {
            $payload['iss'] = self::$issuer;
        }
        if (self::$audience && !isset($payload['aud'])) {
            $payload['aud'] = self::$audience;
        }
        if (!isset($payload['jti'])) {
            $payload['jti'] = self::generateToken(16);
        }

        $headerArr = ['alg' => 'HS256', 'typ' => 'JWT'];
        $header = self::base64UrlEncode(json_encode($headerArr));
        $payloadStr = self::base64UrlEncode(json_encode($payload));

        $signature = hash_hmac('sha256', "$header.$payloadStr", self::$secret, true);
        $signature = self::base64UrlEncode($signature);

        return "$header.$payloadStr.$signature";
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

        list($headerB64, $payloadB64, $signatureB64) = $parts;

        // Decode and validate header
        $headerJson = self::base64UrlDecode($headerB64);
        $header = json_decode($headerJson, true);
        if (!$header || ($header['typ'] ?? '') !== 'JWT' || ($header['alg'] ?? '') !== 'HS256') {
            throw new \Exception('Invalid token header');
        }

        // Verify signature
        $expectedSignature = hash_hmac('sha256', "$headerB64.$payloadB64", self::$secret, true);
        $expectedSignatureB64 = self::base64UrlEncode($expectedSignature);

        if (!self::constantTimeCompare($signatureB64, $expectedSignatureB64)) {
            throw new \Exception('Invalid token signature');
        }

        // Decode payload
        $payloadJson = self::base64UrlDecode($payloadB64);
        $decoded = json_decode($payloadJson, true);
        if (!$decoded) {
            throw new \Exception('Invalid token payload');
        }

        // Check expiration
        $now = time();
        if (isset($decoded['nbf']) && ($decoded['nbf'] - self::$leeway) > $now) {
            throw new \Exception('Token not yet valid');
        }
        if (isset($decoded['exp']) && ($decoded['exp'] + self::$leeway) < $now) {
            throw new \Exception('Token expired');
        }
        if (self::$issuer && isset($decoded['iss']) && $decoded['iss'] !== self::$issuer) {
            throw new \Exception('Invalid token issuer');
        }
        if (self::$audience && isset($decoded['aud']) && $decoded['aud'] !== self::$audience) {
            throw new \Exception('Invalid token audience');
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

    private static function base64UrlEncode(string $data): string
    {
        $b64 = base64_encode($data);
        return rtrim(strtr($b64, '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $data): string
    {
        $b64 = strtr($data, '-_', '+/');
        $pad = strlen($b64) % 4;
        if ($pad > 0) {
            $b64 .= str_repeat('=', 4 - $pad);
        }
        return base64_decode($b64) ?: '';
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
