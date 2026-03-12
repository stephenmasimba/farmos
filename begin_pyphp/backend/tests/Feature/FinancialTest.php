<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

/**
 * Tests for Financial API endpoints
 */
class FinancialTest extends ApiTestCase
{
    private int $farmId;
    private int $recordId;

    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }

    /**
     * Test: Get financial records
     */
    public function testGetFinancialRecords(): void
    {
        $response = $this->apiCall('GET', '/api/financial/records?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('records', $response['body']);
    }

    /**
     * Test: Create income record
     */
    public function testCreateIncomeRecord(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'type' => 'income',
            'category' => 'milk_sales',
            'description' => 'Milk sales',
            'amount' => 1500.00,
            'currency' => 'USD',
            'date' => date('Y-m-d'),
        ];

        $response = $this->apiCall('POST', '/api/financial/records', $data);

        $this->assertEquals(201, $response['status']);
        $this->assertArrayHasKey('id', $response['body']);
        $this->recordId = $response['body']['id'];
    }

    /**
     * Test: Create expense record
     */
    public function testCreateExpenseRecord(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'type' => 'expense',
            'category' => 'feed',
            'description' => 'Cattle feed purchase',
            'amount' => 500.00,
            'currency' => 'USD',
            'date' => date('Y-m-d'),
        ];

        $response = $this->apiCall('POST', '/api/financial/records', $data);

        $this->assertEquals(201, $response['status']);
    }

    /**
     * Test: Get financial record details
     */
    public function testGetFinancialRecord(): void
    {
        $this->testCreateIncomeRecord();

        $response = $this->apiCall('GET', '/api/financial/records/' . $this->recordId);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals('income', $response['body']['type']);
        $this->assertEquals(1500.00, $response['body']['amount']);
    }

    /**
     * Test: Update financial record
     */
    public function testUpdateFinancialRecord(): void
    {
        $this->testCreateIncomeRecord();

        $data = [
            'amount' => 1600.00,
            'description' => 'Updated milk sales',
        ];

        $response = $this->apiCall('PUT', '/api/financial/records/' . $this->recordId, $data);

        $this->assertEquals(200, $response['status']);
        $this->assertEquals(1600.00, $response['body']['amount']);
    }

    /**
     * Test: Delete financial record
     */
    public function testDeleteFinancialRecord(): void
    {
        $this->testCreateIncomeRecord();

        $response = $this->apiCall('DELETE', '/api/financial/records/' . $this->recordId);

        $this->assertEquals(200, $response['status']);
    }

    /**
     * Test: Get financial summary
     */
    public function testGetFinancialSummary(): void
    {
        // Create income and expense records
        $this->testCreateIncomeRecord();
        $this->testCreateExpenseRecord();

        $response = $this->apiCall('GET', '/api/financial/summary?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('summary', $response['body']);
        $this->assertArrayHasKey('total_income', $response['body']['summary']);
        $this->assertArrayHasKey('total_expense', $response['body']['summary']);
        $this->assertArrayHasKey('net_profit', $response['body']['summary']);
    }

    /**
     * Test: Get monthly report
     */
    public function testGetMonthlyReport(): void
    {
        $this->testCreateIncomeRecord();

        $year = date('Y');
        $month = date('m');

        $response = $this->apiCall('GET', "/api/financial/report/monthly?farm_id={$this->farmId}&year={$year}&month={$month}");

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('report', $response['body']);
    }

    /**
     * Test: Get yearly report
     */
    public function testGetYearlyReport(): void
    {
        $this->testCreateIncomeRecord();

        $year = date('Y');

        $response = $this->apiCall('GET', "/api/financial/report/yearly?farm_id={$this->farmId}&year={$year}");

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('yearly_summary', $response['body']);
    }

    /**
     * Test: Get categories
     */
    public function testGetFinancialCategories(): void
    {
        $this->testCreateIncomeRecord();

        $response = $this->apiCall('GET', '/api/financial/categories?farm_id=' . $this->farmId);

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('categories', $response['body']);
    }

    /**
     * Test: Filter by type
     */
    public function testFilterByType(): void
    {
        $this->testCreateIncomeRecord();
        $this->testCreateExpenseRecord();

        $response = $this->apiCall('GET', '/api/financial/records?farm_id=' . $this->farmId . '&type=income');

        $this->assertEquals(200, $response['status']);
        $this->assertArrayHasKey('records', $response['body']);
    }

    /**
     * Test: Validation - Invalid type
     */
    public function testValidationInvalidType(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'type' => 'invalid_type',
            'category' => 'test',
            'amount' => 100,
            'date' => date('Y-m-d'),
        ];

        $response = $this->apiCall('POST', '/api/financial/records', $data);

        $this->assertEquals(422, $response['status']);
    }

    /**
     * Test: Validation - Missing amount
     */
    public function testValidationMissingAmount(): void
    {
        $data = [
            'farm_id' => $this->farmId,
            'type' => 'income',
            'category' => 'sales',
            'date' => date('Y-m-d'),
        ];

        $response = $this->apiCall('POST', '/api/financial/records', $data);

        $this->assertEquals(422, $response['status']);
    }
}
