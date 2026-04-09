<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

final class SalesCRMTest extends ApiTestCase
{
    private int $farmId;

    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }

    public function testCreateAndListLeads(): void
    {
        $create = $this->apiCall('POST', '/api/sales-crm/leads', [
            'farm_id' => $this->farmId,
            'first_name' => 'Amina',
            'last_name' => 'Customer',
            'email' => 'amina@example.com',
            'company' => 'Local Market',
            'lead_temperature' => 'HOT_LEAD',
            'conversion_probability' => 80,
            'expected_deal_value' => 250.00,
        ]);
        $this->assertEquals(201, $create['status']);
        $this->assertArrayHasKey('id', $create['body']);

        $list = $this->apiCall('GET', '/api/sales-crm/leads?farm_id=' . $this->farmId);
        $this->assertEquals(200, $list['status']);
        $this->assertIsArray($list['body']);
        $this->assertNotEmpty($list['body']);
        $this->assertArrayHasKey('first_name', $list['body'][0]);
    }

    public function testForecastUsesWeightedProbability(): void
    {
        self::$db->execute(
            'INSERT INTO farms (owner_id, name, type, location) VALUES (?, ?, ?, ?)',
            [1, 'Forecast Farm', 'mixed', 'Test Location']
        );
        $farmId = (int) self::$db->lastInsertId();

        $this->apiCall('POST', '/api/sales-crm/leads', [
            'farm_id' => $farmId,
            'first_name' => 'Lead',
            'last_name' => 'One',
            'conversion_probability' => 50,
            'expected_deal_value' => 100.00,
        ]);
        $this->apiCall('POST', '/api/sales-crm/leads', [
            'farm_id' => $farmId,
            'first_name' => 'Lead',
            'last_name' => 'Two',
            'conversion_probability' => 80,
            'expected_deal_value' => 200.00,
        ]);

        $forecast = $this->apiCall('GET', '/api/sales-crm/forecast?farm_id=' . $farmId);
        $this->assertEquals(200, $forecast['status']);
        $this->assertEquals(300.00, (float) $forecast['body']['total_deals_value']);
        $this->assertEquals(210.00, (float) $forecast['body']['total_weighted_value']);
        $this->assertEquals(2, (int) $forecast['body']['deal_count']);
    }
}
