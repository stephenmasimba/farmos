<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$status_res = call_api('/api/biogas/status', 'GET');
$status_data = $status_res['data'] ?? $status_res ?? [];
$systems = [];
if (is_array($status_data)) {
    foreach ($status_data as $item) {
        if (is_array($item)) {
            $systems[] = $item;
        }
    }
}

if (empty($systems)) {
    $systems = [
        [
            'system_name' => 'Biogas System 1',
            'alert_level' => 'OPERATIONAL',
            'current_pressure_bar' => 2.5,
            'pressure_percentage' => 75,
            'net_flow_rate_m3h' => 120,
            'gas_production_rate_m3h' => 85,
            'gas_consumption_rate_m3h' => 65,
            'last_maintenance_date' => '2024-01-15T00:00:00'
        ],
        [
            'system_name' => 'Biogas System 2',
            'alert_level' => 'WARNING',
            'current_pressure_bar' => 1.8,
            'pressure_percentage' => 45,
            'net_flow_rate_m3h' => 95,
            'gas_production_rate_m3h' => 70,
            'gas_consumption_rate_m3h' => 85,
            'last_maintenance_date' => '2024-01-10T00:00:00'
        ]
    ];
}

$zones_res = call_api('/api/biogas/zones', 'GET');
$zones_data = $zones_res['data'] ?? $zones_res ?? [];
$zones = [];
if (is_array($zones_data)) {
    foreach ($zones_data as $item) {
        if (is_array($item)) {
            $zones[] = $item;
        }
    }
}

if (empty($zones)) {
    $zones = [
        [
            'zone_id' => 1, 'zone_name' => 'Zone A', 'zone_type' => 'digester',
            'current_pressure' => 0.9, 'pressure_status' => 'STABLE', 'risk_level' => 'NORMAL'
        ],
        [
            'zone_id' => 2, 'zone_name' => 'Zone B', 'zone_type' => 'pipeline',
            'current_pressure' => 1.1, 'pressure_status' => 'RAPID_DROP', 'risk_level' => 'HIGH_RISK'
        ]
    ];
}

$page_title = 'Biogas Management - Begin Masimba';
$active_page = 'biogas';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Biogas Systems</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Advanced leak detection and zone isolation</p>
        </div>
        <div class="flex space-x-3">
            <button class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500">
                Run Leak Analysis
            </button>
        </div>
    </div>

    <!-- Systems Grid -->
    <div class="grid grid-cols-1 gap-6 lg:grid-cols-2 mb-8">
        <?php foreach ($systems as $system): ?>
        <?php
            if (!is_array($system)) {
                continue;
            }
            $system_name = $system['system_name'] ?? 'Biogas System';
            $alert_level = $system['alert_level'] ?? 'OPERATIONAL';
            $current_pressure_bar = isset($system['current_pressure_bar']) ? $system['current_pressure_bar'] : 0;
            $pressure_percentage = isset($system['pressure_percentage']) ? $system['pressure_percentage'] : 0;
            $net_flow = isset($system['net_flow_rate_m3h']) ? $system['net_flow_rate_m3h'] : ($system['net_flow_m3h'] ?? 0);
            $prod_rate = isset($system['gas_production_rate_m3h']) ? $system['gas_production_rate_m3h'] : ($system['production_rate_m3h'] ?? 0);
            $cons_rate = isset($system['gas_consumption_rate_m3h']) ? $system['gas_consumption_rate_m3h'] : ($system['consumption_rate_m3h'] ?? 0);
            $last_maint_raw = $system['last_maintenance_date'] ?? ($system['last_maintenance'] ?? null);
            $last_maint = $last_maint_raw ? date('M d, Y', strtotime($last_maint_raw)) : 'N/A';
            $alert_class = $alert_level === 'OPERATIONAL'
                ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400'
                : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400';
        ?>
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 overflow-hidden">
            <div class="p-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white"><?php echo htmlspecialchars($system_name); ?></h3>
                    <span class="px-2.5 py-0.5 rounded-full text-xs font-medium <?php 
                        echo $alert_class; 
                    ?>">
                        <?php echo htmlspecialchars($alert_level); ?>
                    </span>
                </div>
                
                <div class="grid grid-cols-2 gap-4 mb-6">
                    <div class="bg-gray-50 dark:bg-gray-700/30 p-3 rounded-lg">
                        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase font-semibold">Pressure</p>
                        <p class="text-xl font-bold text-gray-900 dark:text-white"><?php echo $current_pressure_bar; ?> bar</p>
                        <div class="mt-2 w-full bg-gray-200 dark:bg-gray-600 rounded-full h-1.5">
                            <div class="bg-emerald-500 h-1.5 rounded-full" style="width: <?php echo $pressure_percentage; ?>%"></div>
                        </div>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700/30 p-3 rounded-lg">
                        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase font-semibold">Net Flow</p>
                        <p class="text-xl font-bold text-gray-900 dark:text-white"><?php echo $net_flow; ?> m³/h</p>
                    </div>
                </div>

                <div class="space-y-3">
                    <div class="flex justify-between text-sm">
                        <span class="text-gray-500 dark:text-gray-400">Production Rate</span>
                        <span class="font-medium text-gray-900 dark:text-white"><?php echo $prod_rate; ?> m³/h</span>
                    </div>
                    <div class="flex justify-between text-sm">
                        <span class="text-gray-500 dark:text-gray-400">Consumption Rate</span>
                        <span class="font-medium text-gray-900 dark:text-white"><?php echo $cons_rate; ?> m³/h</span>
                    </div>
                    <div class="flex justify-between text-sm">
                        <span class="text-gray-500 dark:text-gray-400">Last Maintenance</span>
                        <span class="font-medium text-gray-900 dark:text-white"><?php echo $last_maint; ?></span>
                    </div>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    </div>

    <!-- Zones Table -->
    <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-100 dark:border-gray-700">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Zone Monitoring</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/30">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Zone Name</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Type</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Pressure</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Risk</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                    <?php foreach ($zones as $zone): ?>
                    <?php
                        if (!is_array($zone)) {
                            continue;
                        }
                        $zone_name = $zone['zone_name'] ?? 'Zone';
                        $zone_type = $zone['zone_type'] ?? 'zone';
                        $current_pressure = isset($zone['current_pressure']) ? $zone['current_pressure'] : 0;
                        $pressure_status = $zone['pressure_status'] ?? 'STABLE';
                        $risk_level = $zone['risk_level'] ?? 'NORMAL';
                        $pressure_class = $pressure_status === 'STABLE' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800';
                        $risk_class = $risk_level === 'NORMAL' ? 'bg-gray-100 text-gray-800' : 'bg-red-100 text-red-800';
                    ?>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($zone_name); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo ucfirst($zone_type); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo $current_pressure; ?> bar</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 py-1 text-xs rounded-md font-medium <?php 
                                echo $pressure_class; 
                            ?>">
                                <?php echo htmlspecialchars($pressure_status); ?>
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 py-1 text-xs rounded-md font-medium <?php 
                                echo $risk_class; 
                            ?>">
                                <?php echo htmlspecialchars($risk_level); ?>
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            <button class="text-emerald-600 hover:text-emerald-900">Isolate</button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
