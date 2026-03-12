<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

/**
 * Tests for Livestock API endpoints
 */
class LivestockTest extends ApiTestCase
{
    private int $farmId;
    private int $livestockId;

    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }

    /**
     * Test: Get livestock list
     */
    public function testGetLivestockList(): void
    {
        $response = $this->apiCall('GET', '/api/livestock?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('livestock', $response['body']);
        $this->assertArrayHasKey('pagination', $response['body']);
    }

    /**
     * Test: Create livestock
     */
    public function testCreateLivestock(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'name' => 'Bessie',
            'species' => 'cattle',
            'breed' => 'Holstein',
            'gender' => 'female',
            'status' => 'active',
        ];

        $response = $this->apiCall('POST', '/api/livestock', $data);

        $this->assertEquals(201, $response['status']);
        $this->assertArrayHasKey('id', $response['body']);
        $this->livestockId = $response['body']['id'];
    }

    /**
     * Test: Get livestock details
     */
    public function testGetLivestock(): void
    {
        // First create
        $this->testCreateLivestock();

        $response = $this->apiCall('GET', '/api/livestock/' . $this->livestockId);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals('Bessie', $response['body']['name']);
        $this->assertEquals('cattle', $response['body']['species']);
    }

    /**
     * Test: Update livestock
     */
    public function testUpdateLivestock(): void
    {
        $this->testCreateLivestock();

        $data = [
            'name' => 'Bessie Updated',
            'weight' => 650.5,
        ];

        $response = $this->apiCall('PUT', '/api/livestock/' . $this->livestockId, $data);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals('Bessie Updated', $response['body']['name']);
    }

    /**
     * Test: Delete livestock
     */
    public function testDeleteLivestock(): void
    {
        $this->testCreateLivestock();

        $response = $this->apiCall('DELETE', '/api/livestock/' . $this->livestockId);

        $this->assertEquals(200, $response['status']);
    }

    /**
     * Test: Get livestock statistics
     */
    public function testGetLivestockStats(): void
    {
        $response = $this->apiCall('GET', '/api/livestock/stats?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('total', $response['body']);
    }

    /**
     * Test: Validation - Missing required fields
     */
    public function testCreateLivestockValidation(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            // Missing required 'species' field
            'breed' => 'Holstein',
        ];

        $response = $this->apiCall('POST', '/api/livestock', $data);

        $this->assertEquals(422, $response['status']);
        $this->assertArrayHasKey('errors', $response['body']);
    }

    /**
     * Test: Unauthorized access without token
     */
    public function testUnauthorizedAccess(): void
    {
        $response = $this->apiCall('GET', '/api/livestock?farm_id=' . $this->farmId, null, '');

        $this->assertEquals(401, $response['status']);
    }

    /**
     * Test: Add event to livestock
     */
    public function testAddLivestockEvent(): void
    {
        $this->testCreateLivestock();

        $data = [
            'event_type' => 'birth',
            'description' => 'Calf born',
            'date' => date('Y-m-d'),
        ];

        $response = $this->apiCall('POST', '/api/livestock/' . $this->livestockId . '/events', $data);

        $this->assertEquals(201, $response['status']);
    }

    /**
     * Test: Get livestock events
     */
    public function testGetLivestockEvents(): void
    {
        $this->testAddLivestockEvent();

        $response = $this->apiCall('GET', '/api/livestock/' . $this->livestockId . '/events');

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('events', $response['body']);
    }

    /**
     * Test: Pagination
     */
    public function testLivestockPagination(): void
    {
        // Create multiple livestock
        for ($i = 0; $i < 5; $i++) {
            $data = [
                'farm_id' => $this->farmId,
                'name' => 'Animal ' . $i,
                'species' => 'cattle',
                'status' => 'active',
            ];
            $this->apiCall('POST', '/api/livestock', $data);
        }

        $response = $this->apiCall('GET', '/api/livestock?farm_id=' . $this->farmId . '&page=1&per_page=2');

        $this->assertEquals(200, $response['status']);
        $this->assertCount(2, $response['body']['livestock']);
        $this->assertEquals(1, $response['body']['pagination']['page']);
    }
}
