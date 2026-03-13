<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

/**
 * Tests for Task API endpoints
 */
class TaskTest extends ApiTestCase
{
    private int $farmId;
    private int $taskId;

    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }

    /**
     * Test: Get tasks list
     */
    public function testGetTasksList(): void
    {
        $response = $this->apiCall('GET', '/api/tasks?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('tasks', $response['body']);
    }

    /**
     * Test: Create task
     */
    public function testCreateTask(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'title' => 'Water cattle',
            'description' => 'Daily watering of cattle',
            'priority' => 'high',
            'due_date' => date('Y-m-d', strtotime('+1 day')),
        ];

        $response = $this->apiCall('POST', '/api/tasks', $data);

        $this->assertEquals(201, $response['status']);
        $this->assertArrayHasKey('id', $response['body']);
        $this->taskId = (int) $response['body']['id'];
    }

    /**
     * Test: Get task details
     */
    public function testGetTask(): void
    {
        $this->testCreateTask();

        $response = $this->apiCall('GET', '/api/tasks/' . $this->taskId);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals('Water cattle', $response['body']['title']);
        $this->assertEquals('high', $response['body']['priority']);
    }

    /**
     * Test: Update task
     */
    public function testUpdateTask(): void
    {
        $this->testCreateTask();

        $data = [
            'status' => 'in_progress',
            'description' => 'Currently watering cattle',
        ];

        $response = $this->apiCall('PUT', '/api/tasks/' . $this->taskId, $data);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals('in_progress', $response['body']['status']);
    }

    /**
     * Test: Complete task
     */
    public function testCompleteTask(): void
    {
        $this->testCreateTask();

        $response = $this->apiCall('POST', '/api/tasks/' . $this->taskId . '/complete', []);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals('completed', $response['body']['status']);
        $this->assertNotNull($response['body']['completed_at']);
    }

    /**
     * Test: Assign task to user
     */
    public function testAssignTask(): void
    {
        $this->testCreateTask();

        $data = [
            'assigned_to' => 1, // Test user ID
        ];

        $response = $this->apiCall('POST', '/api/tasks/' . $this->taskId . '/assign', $data);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals(1, $response['body']['assigned_to']);
    }

    /**
     * Test: Delete task
     */
    public function testDeleteTask(): void
    {
        $this->testCreateTask();

        $response = $this->apiCall('DELETE', '/api/tasks/' . $this->taskId);

        $this->assertEquals(200, $response['status']);
    }

    /**
     * Test: Get task statistics
     */
    public function testGetTaskStats(): void
    {
        $this->testCreateTask();

        $response = $this->apiCall('GET', '/api/tasks/stats?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('summary', $response['body']);
        $this->assertArrayHasKey('total', $response['body']['summary']);
    }

    /**
     * Test: Filter by status
     */
    public function testFilterByStatus(): void
    {
        $this->testCreateTask();

        $response = $this->apiCall('GET', '/api/tasks?farm_id=' . $this->farmId . '&status=pending');

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('tasks', $response['body']);
    }

    /**
     * Test: Filter by priority
     */
    public function testFilterByPriority(): void
    {
        $this->testCreateTask();

        $response = $this->apiCall('GET', '/api/tasks?farm_id=' . $this->farmId . '&priority=high');

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('tasks', $response['body']);
    }

    /**
     * Test: Validation - Missing required fields
     */
    public function testCreateTaskValidation(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            // Missing required 'title' field
            'priority' => 'high',
        ];

        $response = $this->apiCall('POST', '/api/tasks', $data);

        $this->assertEquals(422, $response['status']);
    }

    /**
     * Test: Validation - Invalid priority
     */
    public function testValidationInvalidPriority(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'title' => 'Test task',
            'priority' => 'invalid_priority',
        ];

        $response = $this->apiCall('POST', '/api/tasks', $data);

        $this->assertEquals(422, $response['status']);
    }
}
