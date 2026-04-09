<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

final class EnergyStatusTest extends ApiTestCase
{
    private int $farmId;

    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }

    public function testGetEnergyStatusRequiresFarmId(): void
    {
        $response = $this->apiCall('GET', '/api/energy/status');
        $this->assertEquals(200, $response['status']);
    }

    public function testGetEnergyStatusReturnsDefaultsWhenNoLogs(): void
    {
        $response = $this->apiCall('GET', '/api/energy/status?farm_id=' . $this->farmId);
        $this->assertEquals(200, $response['status']);

        $body = $response['body'];
        $this->assertArrayHasKey('battery_percentage', $body);
        $this->assertArrayHasKey('battery_voltage', $body);
        $this->assertArrayHasKey('solar_generation_watts', $body);
        $this->assertArrayHasKey('total_consumption_watts', $body);
        $this->assertArrayHasKey('active_loads', $body);
        $this->assertArrayHasKey('load_shedding_active', $body);
        $this->assertArrayHasKey('essential_loads_only', $body);
        $this->assertArrayHasKey('non_essential_cutoff_v', $body);
        $this->assertArrayHasKey('critical_cutoff_v', $body);
        $this->assertArrayHasKey('last_event', $body);
    }
}
