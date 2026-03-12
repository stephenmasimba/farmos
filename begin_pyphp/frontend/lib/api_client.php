<?php
/**
 * Enhanced API Client with Better Error Handling and Offline Support
 */

function api_base_url() {
    $host = getenv('PY_API_HOST') ?: '127.0.0.1';
    $port = getenv('PY_API_PORT') ?: '8000';
    return "http://{$host}:{$port}";
}

function api_headers() {
    $headers = [
        'Content-Type: application/json',
        'X-API-Key: ' . (getenv('API_KEY') ?: 'local-dev-key'),
        'X-Tenant-ID: ' . (getenv('TENANT_ID') ?: '1')
    ];
    if (!empty($_SESSION['access_token'])) {
        $headers[] = 'Authorization: Bearer ' . $_SESSION['access_token'];
    }
    return $headers;
}

function call_api($path, $method = 'GET', $data = null, $retry_count = 2) {
    $url = api_base_url() . $path;
    
    for ($attempt = 1; $attempt <= $retry_count; $attempt++) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, api_headers());
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
        curl_setopt($ch, CURLOPT_TIMEOUT, 8);
        curl_setopt($ch, CURLOPT_FAILONERROR, false);
        
        switch (strtoupper($method)) {
            case 'POST':
                curl_setopt($ch, CURLOPT_POST, true);
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data ?: []));
                break;
            case 'PUT':
            case 'PATCH':
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, strtoupper($method));
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data ?: []));
                break;
            default:
                // GET
                break;
        }
        
        $response = curl_exec($ch);
        $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        
        if (curl_errno($ch)) {
            $error = curl_error($ch);
            curl_close($ch);
            
            // Log error for debugging
            error_log("API Error (Attempt $attempt): $error - URL: $url");
            
            if ($attempt == $retry_count) {
                // Return fallback data for critical endpoints
                return get_fallback_data($path, $error);
            }
            continue;
        }
        
        curl_close($ch);
        $json = json_decode($response, true);
        
        if ($httpcode >= 200 && $httpcode < 300) {
            return ['data' => $json, 'status' => $httpcode];
        } else {
            error_log("API HTTP Error: $httpcode - URL: $url - Response: $response");
            
            if ($attempt == $retry_count) {
                return [
                    'error' => $json['message'] ?? "HTTP $httpcode", 
                    'status' => $httpcode,
                    'data' => get_fallback_data($path, "HTTP $httpcode")['data']
                ];
            }
        }
        
        // Wait before retry
        usleep(500000); // 0.5 seconds
    }
}

function get_fallback_data($path, $error) {
    // Provide fallback data for critical dashboard endpoints
    $fallback_data = [
        '/api/dashboard/summary' => [
            'alerts' => 0,
            'tasks_due' => 0,
            'livestock_batches' => 0,
            'inventory_low' => 0,
            'low_stock_items' => [],
            'financial' => [
                'total_income' => 0,
                'total_expense' => 0,
                'net_profit' => 0,
            ],
            '_fallback' => true,
            '_error' => $error
        ],
        '/api/livestock' => [
            'batches' => [],
            '_fallback' => true,
            '_error' => $error
        ],
        '/api/inventory' => [
            'items' => [],
            '_fallback' => true,
            '_error' => $error
        ]
    ];
    
    return [
        'data' => $fallback_data[$path] ?? ['_fallback' => true, '_error' => $error],
        'status' => 200,
        'fallback' => true
    ];
}

function is_api_available() {
    $result = call_api('/health', 'GET', null, 1);
    return !isset($result['error']) && $result['status'] == 200;
}
?>
