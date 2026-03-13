<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

final class ReportsAnalyticsTest extends ApiTestCase
{
    public function testReportTypes(): void
    {
        $farmId = $this->getTestFarmId();
        $res = $this->apiCall('GET', '/api/reports/types?farm_id=' . $farmId);
        $this->assertSame(200, $res['status']);
        $this->assertIsArray($res['body']);
        $this->assertContains('Financial', $res['body']);
    }

    public function testGenerateAndDownloadFinancialCsv(): void
    {
        $farmId = $this->getTestFarmId();
        $create = $this->apiCall('POST', '/api/financial/records', [
            'farm_id' => $farmId,
            'type' => 'income',
            'category' => 'sales',
            'amount' => 100,
            'currency' => 'USD',
            'date' => date('Y-m-d'),
            'description' => 'Test income',
        ]);
        $this->assertSame(201, $create['status']);

        $gen = $this->apiCall('POST', '/api/reports/generate', [
            'farm_id' => $farmId,
            'type' => 'Financial',
            'format' => 'csv',
            'start_date' => date('Y-m-d', strtotime('-1 day')),
            'end_date' => date('Y-m-d'),
        ]);

        $this->assertSame(200, $gen['status']);
        $this->assertIsArray($gen['body']);
        $this->assertArrayHasKey('url', $gen['body']);

        $url = (string) $gen['body']['url'];
        $parts = parse_url($url);
        $this->assertIsArray($parts);
        $this->assertArrayHasKey('query', $parts);
        parse_str((string) $parts['query'], $q);
        $this->assertArrayHasKey('token', $q);

        $download = $this->apiCall('GET', '/api/reports/download?token=' . $q['token'], null, '');
        $this->assertSame(200, $download['status']);
        $this->assertIsString($download['body']);
        $this->assertNotFalse(strpos($download['body'], 'date,type,category,amount,currency,status,description'));
    }

    public function testAnalyticsDashboard(): void
    {
        $farmId = $this->getTestFarmId();
        $res = $this->apiCall('GET', '/api/analytics/dashboard?farm_id=' . $farmId);
        $this->assertSame(200, $res['status']);
        $this->assertIsArray($res['body']);
        $this->assertArrayHasKey('active_tasks', $res['body']);
        $this->assertArrayHasKey('critical_alerts', $res['body']);
        $this->assertArrayHasKey('daily_revenue', $res['body']);
        $this->assertIsArray($res['body']['daily_revenue']);
        $this->assertCount(7, $res['body']['daily_revenue']);
    }

    public function testIoTSensorIngestAndLatest(): void
    {
        $ingest = $this->apiCall('POST', '/api/iot/sensors', [
            'device_id' => 'dev_test_1',
            'type' => 'temperature',
            'value' => 31.5,
            'unit' => 'C',
            'location' => 'Barn',
            'timestamp' => date('c'),
        ]);

        $this->assertSame(201, $ingest['status']);

        $latest = $this->apiCall('GET', '/api/iot/sensors/latest?limit=5');
        $this->assertSame(200, $latest['status']);
        $this->assertIsArray($latest['body']);
        $this->assertNotEmpty($latest['body']);
        $this->assertArrayHasKey('type', $latest['body'][0]);
        $this->assertArrayHasKey('value', $latest['body'][0]);
        $this->assertArrayHasKey('timestamp', $latest['body'][0]);
    }

    public function testIoTAlertsEndpoint(): void
    {
        $ingest = $this->apiCall('POST', '/api/iot/sensors', [
            'device_id' => 'dev_test_2',
            'type' => 'temperature',
            'value' => 45,
            'unit' => 'C',
            'location' => 'Field',
            'timestamp' => date('c'),
        ]);

        $this->assertSame(201, $ingest['status']);

        $alerts = $this->apiCall('GET', '/api/iot/alerts');
        $this->assertSame(200, $alerts['status']);
        $this->assertIsArray($alerts['body']);
    }
}
