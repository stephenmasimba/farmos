<?php

namespace FarmOS;

/**
 * Input validation and sanitization
 */
class Validation
{
    /**
     * Validate email
     */
    public static function validateEmail(string $email): bool
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * Validate phone number (basic)
     */
    public static function validatePhone(string $phone): bool
    {
        return preg_match('/^[\d\-\+\(\)\s]{7,}$/', $phone) === 1;
    }

    /**
     * Validate URL
     */
    public static function validateURL(string $url): bool
    {
        return filter_var($url, FILTER_VALIDATE_URL) !== false;
    }

    /**
     * Validate UUID
     */
    public static function validateUUID(string $uuid): bool
    {
        return preg_match(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',
            $uuid
        ) === 1;
    }

    /**
     * Validate password strength
     */
    public static function validatePassword(string $password): bool
    {
        // Already checked in Security::hashPassword
        return strlen($password) >= 8
            && preg_match('/[[:upper:]]/', $password)
            && preg_match('/[[:lower:]]/', $password)
            && preg_match('/[0-9]/', $password)
            && preg_match('/[!@#$%^&*()_+\-=\[\]{};:\'",.<>?\/\\|`~]/', $password);
    }

    /**
     * Sanitize string (prevent XSS)
     */
    public static function sanitizeString(string $input): string
    {
        return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
    }

    /**
     * Sanitize SQL identifier (table/column name)
     */
    public static function sanitizeSQLIdentifier(string $identifier): string
    {
        // Only allow alphanumeric and underscore
        if (!preg_match('/^[a-zA-Z_][a-zA-Z0-9_]*$/', $identifier)) {
            throw new \Exception('Invalid SQL identifier: ' . $identifier);
        }
        return $identifier;
    }

    /**
     * Validate integer
     */
    public static function validateInteger($value, ?int $min = null, ?int $max = null): bool
    {
        if (!is_numeric($value) || intval($value) != $value) {
            return false;
        }
        
        $int = intval($value);
        
        if ($min !== null && $int < $min) {
            return false;
        }
        
        if ($max !== null && $int > $max) {
            return false;
        }
        
        return true;
    }

    /**
     * Validate date in YYYY-MM-DD format
     */
    public static function validateDate(string $date): bool
    {
        $d = \DateTime::createFromFormat('Y-m-d', $date);
        return $d && $d->format('Y-m-d') === $date;
    }

    /**
     * Validate enum value
     */
    public static function validateEnum(string $value, array $allowed): bool
    {
        return in_array($value, $allowed, true);
    }

    /**
     * Validate required field
     */
    public static function validateRequired($value): bool
    {
        return !empty($value) && (!is_string($value) || trim($value) !== '');
    }
}
