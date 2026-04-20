<?php
/**
 * JWT Token Manager for Frontend
 * Handles token storage, refresh, and lifecycle management
 * Replaces pure session-based auth with stateless JWT tokens
 */

class JWTManager
{
    private const STORAGE_DIR = __DIR__ . '/../../storage/tokens';
    private const TOKEN_FILE = 'jwt_tokens.json';
    private const LOCK_FILE = 'jwt_tokens.lock';
    private $userId;
    private $farmId;

    public function __construct()
    {
        // Ensure storage directory exists
        if (!is_dir(self::STORAGE_DIR)) {
            mkdir(self::STORAGE_DIR, 0755, true);
        }
    }

    /**
     * Store tokens after login
     */
    public function setTokens(
        string $accessToken,
        string $refreshToken,
        int $expiresIn,
        int $userId,
        ?int $farmId = null
    ): void {
        $data = [
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'access_expires_at' => time() + $expiresIn,
            'user_id' => $userId,
            'farm_id' => $farmId ?? 1,
            'created_at' => time(),
        ];

        $this->writeTokens($data);

        // Also store in session for backward compatibility
        $_SESSION['access_token'] = $accessToken;
        $_SESSION['refresh_token'] = $refreshToken;
        $_SESSION['user_id'] = $userId;
        $_SESSION['farm_id'] = $farmId ?? 1;
    }

    /**
     * Get valid access token (refresh if needed)
     */
    public function getAccessToken(): ?string
    {
        $tokens = $this->readTokens();

        if (!$tokens) {
            return null;
        }

        // Check if token is expired or expiring soon (within 5 minutes)
        if ($tokens['access_expires_at'] <= time() + 300) {
            // Try to refresh
            if (!$this->refreshAccessToken($tokens['refresh_token'])) {
                // Refresh failed, clear tokens
                $this->clearTokens();
                return null;
            }
            $tokens = $this->readTokens();
        }

        return $tokens['access_token'] ?? null;
    }

    /**
     * Refresh access token using refresh token
     */
    public function refreshAccessToken(string $refreshToken): bool
    {
        $ch = curl_init();
        $url = rtrim($this->getApiBaseUrl(), '/') . '/api/auth/refresh';

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'refresh_token' => $refreshToken
        ]));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json',
        ]);
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
        curl_setopt($ch, CURLOPT_FAILONERROR, false);

        $response = curl_exec($ch);
        $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpcode !== 200) {
            error_log("Token refresh failed: HTTP $httpcode");
            return false;
        }

        $json = json_decode($response, true);

        if (!isset($json['access_token'])) {
            error_log("Token refresh response missing access_token");
            return false;
        }

        // Update tokens
        $oldTokens = $this->readTokens() ?? [];
        $newTokens = [
            'access_token' => $json['access_token'],
            'refresh_token' => $json['refresh_token'] ?? $oldTokens['refresh_token'],
            'access_expires_at' => time() + ($json['expires_in'] ?? 3600),
            'user_id' => $oldTokens['user_id'] ?? null,
            'farm_id' => $oldTokens['farm_id'] ?? 1,
            'created_at' => $oldTokens['created_at'] ?? time(),
        ];

        $this->writeTokens($newTokens);

        return true;
    }

    /**
     * Get current user ID
     */
    public function getUserId(): ?int
    {
        $tokens = $this->readTokens();
        return $tokens['user_id'] ?? null;
    }

    /**
     * Get current farm ID
     */
    public function getFarmId(): int
    {
        $tokens = $this->readTokens();
        return $tokens['farm_id'] ?? 1;
    }

    /**
     * Check if user is authenticated
     */
    public function isAuthenticated(): bool
    {
        return $this->getAccessToken() !== null;
    }

    /**
     * Clear all tokens (logout)
     */
    public function clearTokens(): void
    {
        $tokenFile = self::STORAGE_DIR . '/' . self::TOKEN_FILE;
        if (file_exists($tokenFile)) {
            unlink($tokenFile);
        }

        // Clear session
        $_SESSION['access_token'] = null;
        $_SESSION['refresh_token'] = null;
        $_SESSION['user_id'] = null;
        $_SESSION['farm_id'] = null;
    }

    /**
     * Get request headers with Bearer token
     */
    public function getAuthHeaders(): array
    {
        $token = $this->getAccessToken();

        if (!$token) {
            return [];
        }

        return [
            'Authorization: Bearer ' . $token,
        ];
    }

    /**
     * Write tokens to secure file storage
     */
    private function writeTokens(array $data): void
    {
        $tokenFile = self::STORAGE_DIR . '/' . self::TOKEN_FILE;
        $lockFile = self::STORAGE_DIR . '/' . self::LOCK_FILE;

        // Simple file locking
        $lock = fopen($lockFile, 'c');
        flock($lock, LOCK_EX);

        try {
            file_put_contents(
                $tokenFile,
                json_encode($data),
                LOCK_EX
            );
            chmod($tokenFile, 0600); // Read/write for owner only
        } finally {
            flock($lock, LOCK_UN);
            fclose($lock);
        }
    }

    /**
     * Read tokens from file storage
     */
    private function readTokens(): ?array
    {
        $tokenFile = self::STORAGE_DIR . '/' . self::TOKEN_FILE;

        if (!file_exists($tokenFile)) {
            return null;
        }

        $content = file_get_contents($tokenFile);
        return json_decode($content, true);
    }

    /**
     * Get API base URL (matches api_client.php logic)
     */
    private function getApiBaseUrl(): string
    {
        $explicit = getenv('PHP_API_BASE_URL') ?: getenv('API_BASE_URL');
        if (!empty($explicit)) {
            return rtrim($explicit, '/');
        }

        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1';
        $scriptName = $_SERVER['SCRIPT_NAME'] ?? '';
        $dir = str_replace('\\', '/', rtrim(dirname($scriptName), '/'));

        $base = $dir;
        if (substr($base, -strlen('/frontend/public')) === '/frontend/public') {
            $base = substr($base, 0, -strlen('/frontend/public'));
        } elseif (substr($base, -strlen('/frontend')) === '/frontend') {
            $base = substr($base, 0, -strlen('/frontend'));
        }

        if ($base === '' || $base === '.') {
            $base = '/farmos/app';
        }

        return "{$scheme}://{$host}{$base}/backend";
    }
}

// Global JWT manager instance
$jwt_manager = $jwt_manager ?? new JWTManager();
?>
