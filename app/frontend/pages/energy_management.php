<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$status_res = call_api('/api/energy/status', 'GET');
$status_data = $status_res['data'] ?? [];
$status = is_array($status_data) ? $status_data : [];

$battery_percentage = isset($status['battery_percentage']) ? (float)$status['battery_percentage'] : 0;
$battery_voltage = isset($status['battery_voltage']) ? (float)$status['battery_voltage'] : 0;
$solar_generation_watts = isset($status['solar_generation_watts']) ? (float)$status['solar_generation_watts'] : 0;
$total_consumption_watts = isset($status['total_consumption_watts']) ? (float)$status['total_consumption_watts'] : 0;
$active_loads_count = isset($status['active_loads']) ? (int)$status['active_loads'] : 0;
$load_shedding_active = !empty($status['load_shedding_active']);
$essential_loads_only = !empty($status['essential_loads_only']);
$non_essential_cutoff_v = isset($status['non_essential_cutoff_v']) ? (float)$status['non_essential_cutoff_v'] : 48.0;
$critical_cutoff_v = isset($status['critical_cutoff_v']) ? (float)$status['critical_cutoff_v'] : 46.5;
$last_event = isset($status['last_event']) ? $status['last_event'] : 'No recent events';

$loads_res = call_api('/api/energy/loads', 'GET');
$loads_data = $loads_res['data'] ?? [];
$loads = [];
if (is_array($loads_data)) {
    foreach ($loads_data as $item) {
        if (is_array($item)) {
            $loads[] = $item;
        }
    }
}

$history_res = call_api('/api/energy/history', 'GET');
$history = is_array($history_res['data'] ?? null) ? $history_res['data'] : [];

$page_title = 'Energy Management - Begin Masimba';
$active_page = 'energy_management';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Smart Energy & Load Shedding</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Power prioritization and battery health monitoring</p>
        </div>
        <div class="flex items-center space-x-3">
            <span class="flex items-center px-3 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400">
                <span class="w-2 h-2 mr-2 rounded-full bg-emerald-500 animate-pulse"></span>
                System Operational
            </span>
        </div>
    </div>

    <!-- Main Status Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Battery Level</p>
            <div class="flex items-end justify-between">
                <div>
                    <h3 class="text-2xl font-bold text-gray-900 dark:text-white"><?php echo $battery_percentage; ?>%</h3>
                    <p class="text-xs text-gray-500"><?php echo $battery_voltage; ?>V</p>
                </div>
                    <div class="w-12 h-6 bg-gray-200 dark:bg-gray-700 rounded relative overflow-hidden border border-gray-300 dark:border-gray-600">
                    <div class="h-full bg-emerald-500" style="width: <?php echo max(0, min(100, $battery_percentage)); ?>%"></div>
                </div>
            </div>
        </div>

        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Solar Generation</p>
            <div class="flex items-end justify-between">
                <div>
                    <h3 class="text-2xl font-bold text-amber-600 dark:text-amber-400"><?php echo $solar_generation_watts; ?>W</h3>
                    <p class="text-xs text-gray-500">Current Yield</p>
                </div>
                <svg class="w-8 h-8 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M12 8a4 4 0 100 8 4 4 0 000-8z" />
                </svg>
            </div>
        </div>

        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Total Consumption</p>
            <div class="flex items-end justify-between">
                <div>
                    <h3 class="text-2xl font-bold text-blue-600 dark:text-blue-400"><?php echo $total_consumption_watts; ?>W</h3>
                    <p class="text-xs text-gray-500"><?php echo $active_loads_count; ?> Active Loads</p>
                </div>
                <svg class="w-8 h-8 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
            </div>
        </div>

        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Load Shedding</p>
            <div class="flex items-end justify-between">
                <div>
                    <h3 class="text-2xl font-bold <?php echo $load_shedding_active ? 'text-red-600' : 'text-emerald-600'; ?>">
                        <?php echo $load_shedding_active ? 'ACTIVE' : 'INACTIVE'; ?>
                    </h3>
                    <p class="text-xs text-gray-500"><?php echo $essential_loads_only ? 'Essential Only' : 'Full Access'; ?></p>
                </div>
                <svg class="w-8 h-8 <?php echo $load_shedding_active ? 'text-red-500' : 'text-emerald-500'; ?>" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Load Priority Table -->
        <div class="lg:col-span-2">
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div class="p-6 border-b border-gray-100 dark:border-gray-700 flex justify-between items-center">
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white">Load Prioritization</h3>
                    <button class="text-sm text-primary-600 font-semibold hover:text-primary-700">Configure Thresholds</button>
                </div>
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/30">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Load Name</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Priority</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Power</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($loads as $load): ?>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($load['name']); ?></div>
                                <div class="text-xs text-gray-500"><?php echo htmlspecialchars($load['location']); ?></div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 py-1 text-xs font-bold rounded <?php 
                                    echo $load['is_essential'] ? 'bg-purple-100 text-purple-800' : 'bg-gray-100 text-gray-800'; 
                                ?>">
                                    <?php echo $load['is_essential'] ? 'ESSENTIAL' : 'P' . $load['priority']; ?>
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                                <?php echo $load['power_watts']; ?>W
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="flex items-center">
                                    <span class="w-2 h-2 mr-2 rounded-full <?php echo $load['status'] === 'on' ? 'bg-emerald-500' : 'bg-red-500'; ?>"></span>
                                    <span class="text-sm text-gray-700 dark:text-gray-300"><?php echo strtoupper($load['status']); ?></span>
                                </span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- System Alerts & Actions -->
        <div class="space-y-6">
            <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Threshold Settings</h3>
                <div class="space-y-4">
                    <div>
                        <label class="text-xs font-semibold text-gray-500 uppercase">Non-Essential Cutoff</label>
                        <div class="flex items-center justify-between mt-1">
                            <span class="text-sm font-medium"><?php echo $non_essential_cutoff_v; ?>V</span>
                            <span class="text-xs text-gray-400">48.0V Recommended</span>
                        </div>
                        <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-1 mt-2">
                            <div class="bg-primary-500 h-1 rounded-full" style="width: 70%"></div>
                        </div>
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-gray-500 uppercase">Critical Cutoff</label>
                        <div class="flex items-center justify-between mt-1">
                            <span class="text-sm font-medium"><?php echo $critical_cutoff_v; ?>V</span>
                            <span class="text-xs text-gray-400">46.5V Recommended</span>
                        </div>
                        <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-1 mt-2">
                            <div class="bg-red-500 h-1 rounded-full" style="width: 50%"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bg-amber-50 dark:bg-amber-900/20 p-6 rounded-xl border border-amber-100 dark:border-amber-800/50">
                <div class="flex items-center mb-3">
                    <svg class="w-5 h-5 text-amber-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                    <h4 class="font-bold text-amber-800 dark:text-amber-400">Recent Event</h4>
                </div>
                <p class="text-sm text-amber-800/80 dark:text-amber-400/80">
                    <?php echo htmlspecialchars($last_event); ?>
                </p>
                <button class="mt-4 w-full bg-amber-600 hover:bg-amber-700 text-white font-semibold py-2 rounded-lg text-sm">
                    View Logs
                </button>
            </div>
        </div>
    </div>
</div>
