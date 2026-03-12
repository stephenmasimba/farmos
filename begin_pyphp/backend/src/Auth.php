<?php

namespace FarmOS;

/**
 * Authentication handler
 */
class Auth
{
    private Database $db;

    public function __construct(Database $db)
    {
        $this->$db = $db;
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

        $token = Security::encodeJWT([
            'user_id' => $user['id'],
            'email' => $user['email'],
            'role' => $user['role'],
        ]);

        Logger::info('User logged in', ['user_id' => $user['id'], 'email' => $email]);

        return [
            'access_token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => 3600,
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
                [$email, $passwordHash, $firstName, $lastName, 'active', 'viewer']
            );

            $userId = $this->db->lastInsertId();

            Logger::info('User registered', ['user_id' => $userId, 'email' => $email]);

            return [
                'id' => $userId,
                'email' => $email,
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
        return Security::encodeJWT($claims);
    }
}
