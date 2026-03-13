<?php

namespace FarmOS;

/**
 * Authentication handler
 */
class Auth
{
    private Database $db;
    private int $refreshTtl;
    private int $accessTtl;
    private static bool $refreshTableEnsured = false;
    private static bool $blacklistTableEnsured = false;

    public function __construct(Database $db)
    {
        $this->db = $db;
        $this->accessTtl = (int) (getenv('JWT_EXPIRY') ?: 3600);
        $this->refreshTtl = (int) (getenv('JWT_REFRESH_EXPIRY') ?: 2592000);
    }

    /**
     * Login user
     */
    public function login(string $email, string $password): array
    {
        if (!Validation::validateEmail($email)) {
            throw new \Exception('Invalid email format');
        }

        if (!Validation::validatePassword($password)) {
            throw new \Exception('Invalid password format');
        }

        $user = $this->db->queryOne(
            'SELECT id, email, password_hash, role, status FROM users WHERE email = ?',
            [$email]
        );

        if (!$user) {
            Logger::warning('Login failed: user not found', ['email' => $email]);
            throw new \Exception('Invalid credentials');
        }

        if ($user['status'] !== 'active') {
            Logger::warning('Login failed: user inactive', ['user_id' => $user['id']]);
            throw new \Exception('User account is not active');
        }

        if (!Security::verifyPassword($password, $user['password_hash'])) {
            Logger::warning('Login failed: invalid password', ['user_id' => $user['id']]);
            throw new \Exception('Invalid credentials');
        }

        $this->db->execute(
            'UPDATE users SET last_login = NOW() WHERE id = ?',
            [$user['id']]
        );

        $expires = $this->accessTtl;
        $token = Security::encodeJWT([
            'user_id' => $user['id'],
            'email' => $user['email'],
            'role' => $user['role'],
        ], $expires);

        $refresh = $this->issueRefreshToken((int)$user['id']);

        Logger::info('User logged in', ['user_id' => $user['id'], 'email' => $email]);

        return [
            'access_token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => $expires,
            'refresh_token' => $refresh['token'],
            'refresh_expires_in' => $refresh['expires_in'],
            'user' => [
                'id' => $user['id'],
                'email' => $user['email'],
                'role' => $user['role'],
            ],
        ];
    }

    /**
     * Register new user
     */
    public function register(string $email, string $password, ?string $firstName = null, ?string $lastName = null): array
    {
        if (!Validation::validateEmail($email)) {
            throw new \Exception('Invalid email format');
        }

        if (!Validation::validatePassword($password)) {
            throw new \Exception('Password must be at least 8 characters with uppercase, lowercase, digit, and special character');
        }

        // Check if email exists
        $existing = $this->db->queryOne(
            'SELECT id FROM users WHERE email = ?',
            [$email]
        );

        if ($existing) {
            throw new \Exception('Email already registered');
        }

        $passwordHash = Security::hashPassword($password);

        try {
            $this->db->execute(
                'INSERT INTO users (email, password_hash, first_name, last_name, status, role) VALUES (?, ?, ?, ?, ?, ?)',
                [$email, $passwordHash, $firstName, $lastName, 'active', 'user']
            );

            $userId = $this->db->lastInsertId();

            Logger::info('User registered', ['user_id' => $userId, 'email' => $email]);

            $expires = $this->accessTtl;
            $token = Security::encodeJWT([
                'user_id' => $userId,
                'email' => $email,
                'role' => 'user',
            ], $expires);

            $refresh = $this->issueRefreshToken((int)$userId);

            return [
                'id' => $userId,
                'email' => $email,
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => $expires,
                'refresh_token' => $refresh['token'],
                'refresh_expires_in' => $refresh['expires_in'],
                'user' => [
                    'id' => $userId,
                    'email' => $email,
                    'role' => 'user',
                    'status' => 'active',
                ],
                'message' => 'User registered successfully',
            ];
        } catch (\Exception $e) {
            Logger::error('Registration failed', ['email' => $email, 'error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get current user
     */
    public function getUser(int $userId): ?array
    {
        return $this->db->queryOne(
            'SELECT id, email, first_name, last_name, role, status, last_login, created_at FROM users WHERE id = ?',
            [$userId]
        );
    }

    /**
     * Refresh token
     */
    public function refreshToken(array $claims): string
    {
        unset($claims['iat'], $claims['exp']);
        $expires = $this->accessTtl;
        return Security::encodeJWT($claims, $expires);
    }

    public function logout(array $claims): void
    {
        if (empty($claims['jti']) || empty($claims['user_id']) || empty($claims['exp'])) {
            return;
        }
        if (!self::$blacklistTableEnsured) {
            $this->db->execute('CREATE TABLE IF NOT EXISTS jwt_blacklist (
                jti VARCHAR(64) PRIMARY KEY,
                user_id INT NOT NULL,
                expires_at DATETIME NOT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
            )');
            self::$blacklistTableEnsured = true;
        }
        $this->db->execute(
            'INSERT IGNORE INTO jwt_blacklist (jti, user_id, expires_at) VALUES (?, ?, FROM_UNIXTIME(?))',
            [$claims['jti'], (int) $claims['user_id'], (int) $claims['exp']]
        );
    }

    private function ensureRefreshTable(): void
    {
        if (self::$refreshTableEnsured) {
            return;
        }
        $this->db->execute('CREATE TABLE IF NOT EXISTS refresh_tokens (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            token_hash VARCHAR(128) NOT NULL UNIQUE,
            expires_at DATETIME NOT NULL,
            revoked_at DATETIME NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        )');
        self::$refreshTableEnsured = true;
    }

    private function hashRefresh(string $token): string
    {
        return hash('sha256', $token);
    }

    public function issueRefreshToken(int $userId): array
    {
        $this->ensureRefreshTable();
        $token = Security::generateToken(32);
        $hash = $this->hashRefresh($token);
        $this->db->execute(
            'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? SECOND))',
            [$userId, $hash, $this->refreshTtl]
        );
        return ['token' => $token, 'expires_in' => $this->refreshTtl];
    }

    public function exchangeRefreshToken(string $refreshToken): array
    {
        $this->ensureRefreshTable();
        $hash = $this->hashRefresh($refreshToken);
        $row = $this->db->queryOne(
            'SELECT rt.user_id, u.email, u.role, rt.expires_at, rt.revoked_at
             FROM refresh_tokens rt
             JOIN users u ON u.id = rt.user_id
             WHERE rt.token_hash = ? LIMIT 1',
            [$hash]
        );
        if (!$row) {
            throw new \Exception('Invalid refresh token');
        }
        if ($row['revoked_at'] !== null) {
            throw new \Exception('Refresh token revoked');
        }
        if (strtotime($row['expires_at']) <= time()) {
            throw new \Exception('Refresh token expired');
        }
        $this->db->execute('UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = ?', [$hash]);
        $newRefresh = $this->issueRefreshToken((int)$row['user_id']);
        $access = Security::encodeJWT([
            'user_id' => (int)$row['user_id'],
            'email' => $row['email'],
            'role' => $row['role'],
        ], $this->accessTtl);
        return [
            'access_token' => $access,
            'token_type' => 'Bearer',
            'expires_in' => $this->accessTtl,
            'refresh_token' => $newRefresh['token'],
            'refresh_expires_in' => $newRefresh['expires_in'],
        ];
    }

    public function revokeRefreshToken(string $refreshToken): void
    {
        $this->ensureRefreshTable();
        $hash = $this->hashRefresh($refreshToken);
        $this->db->execute('UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = ?', [$hash]);
    }
}
