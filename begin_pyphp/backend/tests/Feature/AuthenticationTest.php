<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

/**
 * Tests for Authentication API endpoints
 */
class AuthenticationTest extends ApiTestCase
{
    /**
     * Test: User registration
     */
    public function testUserRegistration(): void
    {
        $data = [
            'email' => 'newuser@example.com',
            'password' => 'SecurePassword123!',
            'first_name' => 'John',
            'last_name' => 'Doe',
        ];

        $response = $this->apiCall('POST', '/api/auth/register', $data, '');

        $this->assertEquals(201, $response['status']);
        $this->assertArrayHasKey('access_token', $response['body']);
    }

    /**
     * Test: User login
     */
    public function testUserLogin(): void
    {
        $data = [
            'email' => self::$testUser,
            'password' => self::$testPassword,
        ];

        $response = $this->apiCall('POST', '/api/auth/login', $data, '');

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('access_token', $response['body']);
        $this->assertEquals('Bearer', $response['body']['token_type']);
    }

    /**
     * Test: Get current user
     */
    public function testGetCurrentUser(): void
    {
        $response = $this->apiCall('GET', '/api/auth/me');

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('id', $response['body']);
        $this->assertEquals(self::$testUser, $response['body']['email']);
    }

    /**
     * Test: Refresh token
     */
    public function testRefreshToken(): void
    {
        $response = $this->apiCall('POST', '/api/auth/refresh-token', []);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('access_token', $response['body']);
    }

    /**
     * Test: Invalid login credentials
     */
    public function testInvalidLoginCredentials(): void
    {
        $data = [
            'email' => self::$testUser,
            'password' => 'WrongPassword123!',
        ];

        $response = $this->apiCall('POST', '/api/auth/login', $data, '');

        $this->assertEquals(401, $response['status']);
    }

    /**
     * Test: Login validation - Missing email
     */
    public function testLoginValidationMissingEmail(): void
    {
        $data = [
            'password' => 'SomePassword123!',
        ];

        $response = $this->apiCall('POST', '/api/auth/login', $data, '');

        $this->assertEquals(422, $response['status']);
    }

    /**
     * Test: Registration validation - Email already exists
     */
    public function testRegistrationDuplicateEmail(): void
    {
        $data = [
            'email' => self::$testUser,
            'password' => 'NewPassword123!',
            'first_name' => 'Another',
            'last_name' => 'User',
        ];

        $response = $this->apiCall('POST', '/api/auth/register', $data, '');

        $this->assertEquals(422, $response['status']);
    }

    /**
     * Test: Invalid token
     */
    public function testInvalidToken(): void
    {
        $response = $this->apiCall('GET', '/api/auth/me', null, 'invalid_token_here');

        $this->assertEquals(401, $response['status']);
    }

    /**
     * Test: Rate limiting on login attempts
     */
    public function testLoginRateLimiting(): void
    {
        // Attempt multiple failed logins to trigger rate limiting
        for ($i = 0; $i < 6; $i++) {
            $data = [
                'email' => self::$testUser,
                'password' => 'WrongPassword123!' . $i,
            ];
            $this->apiCall('POST', '/api/auth/login', $data, '');
        }

        // Next attempt should be rate limited
        $data = [
            'email' => self::$testUser,
            'password' => 'WrongPassword123!999',
        ];
        $response = $this->apiCall('POST', '/api/auth/login', $data, '');

        $this->assertEquals(429, $response['status']);
    }
}
