<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

final class FrontendIntegrationTest extends ApiTestCase
{
    private static $serverProc = null;
    private static int $serverPort = 0;

    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();

        self::$serverPort = self::pickPort();
        $descriptorSpec = [
            0 => ['pipe', 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];

        $cmd = sprintf('php -S 127.0.0.1:%d -t public/', self::$serverPort);
        self::$serverProc = proc_open($cmd, $descriptorSpec, $pipes, BASE_PATH);
        if (!is_resource(self::$serverProc)) {
            throw new \RuntimeException('Failed to start PHP server');
        }
        foreach ($pipes as $pipe) {
            if (is_resource($pipe)) {
                fclose($pipe);
            }
        }

        self::waitForServer(self::$serverPort);

        require_once BASE_PATH . '/../frontend/lib/api_client.php';
        putenv('PHP_API_BASE_URL=http://127.0.0.1:' . self::$serverPort);
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }
        $_SESSION = [];
    }

    public static function tearDownAfterClass(): void
    {
        if (is_resource(self::$serverProc)) {
            proc_terminate(self::$serverProc);
            proc_close(self::$serverProc);
        }
        self::$serverProc = null;

        parent::tearDownAfterClass();
    }

    public function testFrontendApiClientCanLoginAndCallMe(): void
    {
        $health = call_api('/health', 'GET', null, 1);
        $this->assertEquals(200, $health['status']);

        $login = call_api('/api/auth/login', 'POST', [
            'email' => self::$testUser,
            'password' => self::$testPassword,
        ], 1);
        $this->assertEquals(200, $login['status']);
        $this->assertArrayHasKey('access_token', $login['data']);
        $this->assertArrayHasKey('refresh_token', $login['data']);

        $_SESSION['access_token'] = $login['data']['access_token'];

        $me = call_api('/api/auth/me', 'GET', null, 1);
        $this->assertEquals(200, $me['status']);
        $this->assertEquals(self::$testUser, $me['data']['email'] ?? null);
    }

    public function testRefreshRotationAndLogoutRevokesTokens(): void
    {
        $login = call_api('/api/auth/login', 'POST', [
            'email' => self::$testUser,
            'password' => self::$testPassword,
        ], 1);
        $this->assertEquals(200, $login['status']);

        $refresh = $login['data']['refresh_token'] ?? null;
        $this->assertNotEmpty($refresh);

        $exchange = call_api('/api/auth/refresh', 'POST', ['refresh_token' => $refresh], 1);
        $this->assertEquals(200, $exchange['status']);
        $this->assertArrayHasKey('access_token', $exchange['data']);
        $this->assertArrayHasKey('refresh_token', $exchange['data']);

        $_SESSION['access_token'] = $exchange['data']['access_token'];

        $logout = call_api('/api/auth/logout', 'POST', ['refresh_token' => $exchange['data']['refresh_token']], 1);
        $this->assertEquals(200, $logout['status']);

        $me = call_api('/api/auth/me', 'GET', null, 1);
        $this->assertEquals(401, $me['status']);
        $this->assertArrayHasKey('error', $me);
    }

    public function testSecurityHeadersPresentOnHealth(): void
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1:' . self::$serverPort . '/health');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HEADER, true);
        curl_setopt($ch, CURLOPT_NOBODY, false);
        $raw = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
        curl_close($ch);

        $this->assertEquals(200, $httpCode);
        $headersRaw = substr((string) $raw, 0, (int) $headerSize);
        $headersRaw = strtolower($headersRaw);
        $this->assertStringContainsString('x-content-type-options:', $headersRaw);
        $this->assertStringContainsString('x-frame-options:', $headersRaw);
        $this->assertStringContainsString('strict-transport-security:', $headersRaw);
        $this->assertStringContainsString('content-security-policy:', $headersRaw);
    }

    private static function pickPort(): int
    {
        $base = 8800 + (int) (microtime(true) * 1000) % 500;
        for ($i = 0; $i < 50; $i++) {
            $port = $base + $i;
            $sock = @fsockopen('127.0.0.1', $port);
            if ($sock === false) {
                return $port;
            }
            fclose($sock);
        }
        return 8999;
    }

    private static function waitForServer(int $port): void
    {
        $deadline = microtime(true) + 5.0;
        while (microtime(true) < $deadline) {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1:' . $port . '/health');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT_MS, 500);
            curl_setopt($ch, CURLOPT_CONNECTTIMEOUT_MS, 200);
            curl_exec($ch);
            $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            if ($code === 200) {
                return;
            }
            usleep(100000);
        }
        throw new \RuntimeException('Server did not become ready');
    }
}

