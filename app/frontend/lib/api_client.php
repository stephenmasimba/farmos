<?php
/**
 * Enhanced API Client with Better Error Handling and Offline Support
 * Now using JWT Manager for stateless authentication
 */

require_once __DIR__ . '/../../backend/config/env.php';
require_once __DIR__ . '/jwt_manager.php';

// Initialize session for backward compatibility
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

function api_base_url() {
    $explicit = getenv('PHP_API_BASE_URL') ?: getenv('API_BASE_URL');
    if (!empty($explicit)) {
        return rtrim($explicit, '/');
    }

    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1';
    $scriptName = $_SERVER['SCRIPT_NAME'] ?? '';
    $dir = str_replace('\\', '/', rtrim(dirname($scriptName), '/'));

    $base = $dir;
    if (substr($base, -strlen('/frontend/public')) === '/frontend/public') {
        $base = substr($base, 0, -strlen('/frontend/public'));
    } elseif (substr($base, -strlen('/frontend')) === '/frontend') {
        $base = substr($base, 0, -strlen('/frontend'));
    }

    if ($base === '' || $base === '.') {
        $base = '/farmos/app';
    }

    return "{$scheme}://{$host}{$base}/backend";
}

function api_key(): string {
    return (string) (getenv('API_KEY') ?: 'local-dev-key');
}

function api_headers() {
    global $jwt_manager;
    
    $headers = [
        'Content-Type: application/json',
        'Accept: application/json',
        'X-Tenant-ID: ' . current_farm_id(),
        'X-API-Key: ' . api_key(),
    ];
    
    // Use JWT Manager for authorization header
    $authHeaders = $jwt_manager->getAuthHeaders();
    return array_merge($headers, $authHeaders);
}

function current_farm_id(): int {
    global $jwt_manager;
    
    // Primary: JWT Manager
    $farmId = $jwt_manager->getFarmId();
    if ($farmId > 0) {
        return $farmId;
    }
    
    // Fallback: Session
    if (!empty($_SESSION['farm_id'])) {
        return (int) $_SESSION['farm_id'];
    }
    if (!empty($_SESSION['user']['farm_id'])) {
        return (int) $_SESSION['user']['farm_id'];
    }
    
    return 1;
}

function call_api($path, $method = 'GET', $data = null, $retry_count = 2) {
    $path = (string) $path;
    if ($path === '' || $path[0] !== '/') {
        $path = '/' . $path;
    }
    if ($path !== '/') {
        $path = rtrim($path, '/');
    }

    $methodUpper = strtoupper((string) $method);
    $farmId = current_farm_id();
    $needsFarmId = (
        strpos($path, '/api/dashboard') === 0 ||
        strpos($path, '/api/livestock') === 0 ||
        strpos($path, '/api/inventory') === 0 ||
        strpos($path, '/api/financial') === 0 ||
        strpos($path, '/api/tasks') === 0 ||
        strpos($path, '/api/weather') === 0 ||
        strpos($path, '/api/energy') === 0 ||
        strpos($path, '/api/marketplace') === 0 ||
        strpos($path, '/api/sales-crm') === 0
    );

    if ($needsFarmId) {
        if ($methodUpper === 'GET') {
            if (strpos($path, 'farm_id=') === false) {
                $path .= (strpos($path, '?') === false ? '?' : '&') . 'farm_id=' . $farmId;
            }
        } else {
            if (is_array($data) && !isset($data['farm_id'])) {
                $data['farm_id'] = $farmId;
            }
        }
    }

    $url = api_base_url() . $path;
    
    for ($attempt = 1; $attempt <= $retry_count; $attempt++) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, api_headers());
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
        curl_setopt($ch, CURLOPT_TIMEOUT, 8);
        curl_setopt($ch, CURLOPT_FAILONERROR, false);
        
        switch ($methodUpper) {
            case 'POST':
                curl_setopt($ch, CURLOPT_POST, true);
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data ?: []));
                break;
            case 'PUT':
            case 'PATCH':
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $methodUpper);
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
                    'error' => $json['error']['message'] ?? ($json['message'] ?? "HTTP $httpcode"), 
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
        '/api/dashboard/overview' => [
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
