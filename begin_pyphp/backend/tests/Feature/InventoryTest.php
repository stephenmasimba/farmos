<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

/**
 * Tests for Inventory API endpoints
 */
class InventoryTest extends ApiTestCase
{
    private int $farmId;
    private int $inventoryId;

    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }

    /**
     * Test: Get inventory list
     */
    public function testGetInventoryList(): void
    {
        $response = $this->apiCall('GET', '/api/inventory?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('inventory', $response['body']);
        $this->assertArrayHasKey('pagination', $response['body']);
    }

    /**
     * Test: Create inventory item
     */
    public function testCreateInventoryItem(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'name' => 'Cattle Feed',
            'category' => 'feed',
            'quantity' => 100,
            'unit' => 'kg',
            'min_level' => 20,
            'max_level' => 500,
            'cost_per_unit' => 15.50,
        ];

        $response = $this->apiCall('POST', '/api/inventory', $data);

        $this->assertEquals(201, $response['status']);
        $this->assertArrayHasKey('id', $response['body']);
        $this->inventoryId = (int) $response['body']['id'];
    }

    /**
     * Test: Get inventory item details
     */
    public function testGetInventoryItem(): void
    {
        $this->testCreateInventoryItem();

        $response = $this->apiCall('GET', '/api/inventory/' . $this->inventoryId);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals('Cattle Feed', $response['body']['name']);
        $this->assertEquals('feed', $response['body']['category']);
    }

    /**
     * Test: Update inventory item
     */
    public function testUpdateInventoryItem(): void
    {
        $this->testCreateInventoryItem();

        $data = [
            'cost_per_unit' => 16.00,
        ];

        $response = $this->apiCall('PUT', '/api/inventory/' . $this->inventoryId, $data);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals(16.00, $response['body']['cost_per_unit']);
    }

    /**
     * Test: Adjust inventory quantity
     */
    public function testAdjustQuantity(): void
    {
        $this->testCreateInventoryItem();

        $data = [
            'amount' => -10,
            'reason' => 'used for feeding',
        ];

        $response = $this->apiCall('POST', '/api/inventory/' . $this->inventoryId . '/adjust', $data);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals(90, $response['body']['quantity']);
    }

    /**
     * Test: Get low stock alerts
     */
    public function testGetLowStockAlerts(): void
    {
        // Create item with low stock
        $data = [
            'farm_id' => $this->farmId,
            'name' => 'Low Stock Item',
            'category' => 'supplies',
            'quantity' => 5,
            'min_level' => 20,
            'unit' => 'each',
        ];
        $this->apiCall('POST', '/api/inventory', $data);

        $response = $this->apiCall('GET', '/api/inventory/alerts?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('alerts', $response['body']);
        $this->assertArrayHasKey('low_stock', $response['body']['alerts']);
    }

    /**
     * Test: Get inventory by category
     */
    public function testGetInventoryByCategory(): void
    {
        $this->testCreateInventoryItem();

        $response = $this->apiCall('GET', '/api/inventory/category/feed?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('inventory', $response['body']);
    }

    /**
     * Test: Get inventory statistics
     */
    public function testGetInventoryStats(): void
    {
        $this->testCreateInventoryItem();

        $response = $this->apiCall('GET', '/api/inventory/stats?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('total_items', $response['body']);
        $this->assertArrayHasKey('total_value', $response['body']);
    }

    /**
     * Test: Delete inventory item
     */
    public function testDeleteInventoryItem(): void
    {
        $this->testCreateInventoryItem();

        $response = $this->apiCall('DELETE', '/api/inventory/' . $this->inventoryId);

        $this->assertEquals(200, $response['status']);
    }

    /**
     * Test: Validation - Missing required fields
     */
    public function testCreateInventoryValidation(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            // Missing required 'name' field
            'category' => 'feed',
        ];

        $response = $this->apiCall('POST', '/api/inventory', $data);

        $this->assertEquals(422, $response['status']);
    }

    /**
     * Test: Expiry date validation
     */
    public function testInventoryExpiryDate(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'name' => 'Perishable Item',
            'category' => 'medicine',
            'quantity' => 50,
            'unit' => 'each',
            'expiry_date' => date('Y-m-d', strtotime('+10 days')),
        ];

        $response = $this->apiCall('POST', '/api/inventory', $data);

        $this->assertEquals(201, $response['status']);
        $this->assertNotNull($response['body']['expiry_date']);
    }
}
