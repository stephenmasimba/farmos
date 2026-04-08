<?php

namespace FarmOS\Models;

use FarmOS\Database;

/**
 * User Model
 * Represents a user in the system
 */
class User extends Model
{
    protected static string $table = 'users';
    protected static array $fillable = [
        'email',
        'password',
        'first_name',
        'last_name',
        'role',
        'status',
        'phone',
        'address',
        'city',
        'state',
        'zip_code',
        'country',
        'avatar_url',
        'bio',
        'last_login',
        'password_changed_at',
        'email_verified_at',
        'two_factor_enabled',
        'preferences',
        'metadata',
    ];

    protected static array $hidden = [
        'password',
        'two_factor_secret',
    ];

    protected static array $casts = [
        'id' => 'int',
        'email_verified_at' => 'datetime',
        'last_login' => 'datetime',
        'password_changed_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'preferences' => 'json',
        'metadata' => 'json',
        'two_factor_enabled' => 'bool',
    ];

    /**
     * Find user by email
     */
    public static function findByEmail(string $email, Database $db): ?self
    {
        return self::where('email', $email, $db);
    }

    /**
     * Check if email exists
     */
    public static function emailExists(string $email, Database $db): bool
    {
        $result = $db->queryOne(
            'SELECT id FROM ' . self::$table . ' WHERE email = ? LIMIT 1',
            [$email]
        );
        return $result !== null;
    }

    /**
     * Get all active users
     */
    public static function active(Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE status = ? ORDER BY created_at DESC',
            ['active']
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get users by role
     */
    public static function byRole(string $role, Database $db): array
    {
        $results = $db->query(
            'SELECT * FROM ' . self::$table . ' WHERE role = ? ORDER BY first_name',
            [$role]
        );
        return array_map(fn($row) => new self($db, $row), $results);
    }

    /**
     * Get user profile (without sensitive fields)
     */
    public function profile(): array
    {
        return [
            'id' => $this->attributes['id'] ?? null,
            'email' => $this->attributes['email'] ?? null,
            'first_name' => $this->attributes['first_name'] ?? null,
            'last_name' => $this->attributes['last_name'] ?? null,
            'role' => $this->attributes['role'] ?? 'admin',
            'status' => $this->attributes['status'] ?? 'active',
            'phone' => $this->attributes['phone'] ?? null,
            'avatar_url' => $this->attributes['avatar_url'] ?? null,
            'created_at' => $this->attributes['created_at'] ?? null,
            'last_login' => $this->attributes['last_login'] ?? null,
        ];
    }

    /**
     * Check if user has permission
     */
    public function hasRole(string $role): bool
    {
        return $this->attributes['role'] === $role;
    }

    /**
     * Check if user is admin
     */
    public function isAdmin(): bool
    {
        return $this->hasRole('admin');
    }

    /**
     * Check if user is active
     */
    public function isActive(): bool
    {
        return $this->attributes['status'] === 'active';
    }

    /**
     * Update last login timestamp
     */
    public function updateLastLogin(): void
    {
        $this->attributes['last_login'] = date('Y-m-d H:i:s');
        $this->update();
    }

    /**
     * Generate user reference for logs
     */
    public function reference(): string
    {
        return "[User #{$this->attributes['id']} {$this->attributes['email']}]";
    }
}
