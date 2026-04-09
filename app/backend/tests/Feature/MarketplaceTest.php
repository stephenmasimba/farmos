<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

final class MarketplaceTest extends ApiTestCase
{
    private int $farmId;

    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }

    public function testCreateAndListMarketplaceListings(): void
    {
        $create = $this->apiCall('POST', '/api/marketplace/listings', [
            'farm_id' => $this->farmId,
            'title' => 'Maize Grain',
            'description' => 'Clean, bagged maize grain',
            'category' => 'Crops',
            'location' => 'On farm',
            'price' => 12.50,
            'unit' => 'kg',
            'quantity' => 100,
        ]);
        $this->assertEquals(201, $create['status']);
        $this->assertArrayHasKey('id', $create['body']);

        $list = $this->apiCall('GET', '/api/marketplace/listings?farm_id=' . $this->farmId);
        $this->assertEquals(200, $list['status']);
        $this->assertIsArray($list['body']);
        $this->assertNotEmpty($list['body']);
        $this->assertArrayHasKey('title', $list['body'][0]);
    }

    public function testCreateAndListMarketplaceCustomers(): void
    {
        $create = $this->apiCall('POST', '/api/marketplace/customers', [
            'farm_id' => $this->farmId,
            'name' => 'John Buyer',
            'email' => 'buyer@example.com',
            'phone' => '+1 555 000 0000',
            'address' => 'Main Road',
            'notes' => 'Prefers monthly pickups',
        ]);
        $this->assertEquals(201, $create['status']);
        $this->assertArrayHasKey('id', $create['body']);

        $list = $this->apiCall('GET', '/api/marketplace/customers?farm_id=' . $this->farmId);
        $this->assertEquals(200, $list['status']);
        $this->assertIsArray($list['body']);
        $this->assertNotEmpty($list['body']);
        $this->assertArrayHasKey('name', $list['body'][0]);
    }
}

