<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$decision_res = call_api('/api/weather-irrigation/decision', 'GET');
$decision_data = $decision_res['data'] ?? $decision_res ?? [];
$decision = is_array($decision_data) ? $decision_data : [];

$schedule_res = call_api('/api/weather-irrigation/schedule', 'GET');
$schedule_data = $schedule_res['data'] ?? $schedule_res ?? [];
$schedule = [];
if (is_array($schedule_data)) {
    foreach ($schedule_data as $item) {
        if (is_array($item)) {
            $schedule[] = $item;
        }
    }
}

$moisture_res = call_api('/api/weather-irrigation/moisture', 'GET');
$moisture_data = $moisture_res['data'] ?? $moisture_res ?? [];
$moisture = [];
if (is_array($moisture_data)) {
    foreach ($moisture_data as $item) {
        if (is_array($item)) {
            $moisture[] = $item;
        }
    }
}

$page_title = 'Weather Irrigation - Begin Masimba';
$active_page = 'weather_irrigation';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Smart Weather Irrigation</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Weather-aware automated scheduling and water conservation</p>
        </div>
        <div class="flex items-center space-x-3">
            <span class="flex items-center px-3 py-1 rounded-full text-xs font-medium bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400">
                <span class="w-2 h-2 mr-2 rounded-full bg-amber-500 animate-pulse"></span>
                Weather Override Active
            </span>
        </div>
    </div>

    <!-- Weather Decision Card -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm border border-gray-100 dark:border-gray-700 mb-10 overflow-hidden relative">
        <div class="relative z-10 flex flex-col md:flex-row items-center justify-between gap-8">
            <div class="flex items-center">
                <div class="w-16 h-16 bg-blue-100 dark:bg-blue-900/30 rounded-2xl flex items-center justify-center mr-6 text-blue-600">
                    <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" />
                    </svg>
                </div>
                <div>
                    <?php
                        $forecastRain = isset($decision['forecast_rain_12h']) ? (float)$decision['forecast_rain_12h'] : 0.0;
                        $skipReason = isset($decision['skip_reason']) ? $decision['skip_reason'] : 'No skip reason available';
                        $confidence = isset($decision['confidence_score']) ? (int)$decision['confidence_score'] : 0;
                        $shouldSkip = !empty($decision['should_skip_irrigation']);
                    ?>
                    <h3 class="text-2xl font-bold text-gray-900 dark:text-white">
                        Rain Forecast: <?php echo $forecastRain; ?>mm
                    </h3>
                    <p class="text-gray-500 mt-1"><?php echo htmlspecialchars($skipReason); ?></p>
                </div>
            </div>
            <div class="flex items-center space-x-6">
                <div class="text-center">
                    <p class="text-[10px] text-gray-500 uppercase font-bold mb-1">Confidence</p>
                    <p class="text-xl font-bold text-gray-900 dark:text-white"><?php echo $confidence; ?>%</p>
                </div>
                <div class="h-12 w-px bg-gray-200 dark:bg-gray-700"></div>
                <div class="text-center">
                    <p class="text-[10px] text-gray-500 uppercase font-bold mb-1">Decision</p>
                    <p class="text-xl font-bold <?php echo $shouldSkip ? 'text-amber-600' : 'text-emerald-600'; ?>">
                        <?php echo $shouldSkip ? 'SKIP AUTO' : 'PROCEED'; ?>
                    </p>
                </div>
                <button class="bg-gray-900 text-white px-6 py-3 rounded-xl font-bold hover:bg-gray-800 transition-colors">
                    Manual Override
                </button>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Irrigation Schedule -->
        <div class="lg:col-span-2 space-y-8">
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div class="p-6 border-b border-gray-100 dark:border-gray-700">
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white">Active Schedule</h3>
                </div>
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/30">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Zone / Field</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Time</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Duration</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($schedule as $item): ?>
                        <?php
                            $zoneName = isset($item['zone_name']) ? $item['zone_name'] : 'Unknown Zone';
                            $fieldName = isset($item['field_name']) ? $item['field_name'] : '';
                            $scheduledTimeRaw = isset($item['scheduled_time']) ? $item['scheduled_time'] : null;
                            $durationMin = isset($item['duration_min']) ? (int)$item['duration_min'] : 0;
                            $status = isset($item['status']) ? $item['status'] : 'SCHEDULED';

                            $timeStr = '-';
                            if ($scheduledTimeRaw) {
                                $ts = strtotime($scheduledTimeRaw);
                                if ($ts !== false) {
                                    $timeStr = date('H:i', $ts);
                                }
                            }

                            $badgeClass = 'bg-blue-100 text-blue-800';
                            if ($status === 'COMPLETED') {
                                $badgeClass = 'bg-emerald-100 text-emerald-800';
                            } elseif ($status === 'AUTO_SKIPPED') {
                                $badgeClass = 'bg-amber-100 text-amber-800';
                            }
                        ?>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($zoneName); ?></div>
                                <div class="text-xs text-gray-500"><?php echo htmlspecialchars($fieldName); ?></div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><?php echo $timeStr; ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><?php echo $durationMin; ?> min</td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 py-1 text-[10px] font-bold rounded <?php echo $badgeClass; ?>">
                                    <?php echo htmlspecialchars($status); ?>
                                </span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Soil Moisture & Controls -->
        <div class="space-y-6">
            <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-6">Soil Moisture Status</h3>
                <div class="space-y-6">
                    <?php foreach ($moisture as $m): ?>
                    <?php
                        $zone = isset($m['zone']) ? $m['zone'] : 'Unknown Zone';
                        $status = isset($m['status']) ? $m['status'] : 'OK';
                        $moisturePct = isset($m['moisture_pct']) ? (int)$m['moisture_pct'] : 0;
                        $threshold = isset($m['threshold']) ? (int)$m['threshold'] : 0;
                        $barWidth = max(0, min(100, $moisturePct));
                        $isDry = $moisturePct < $threshold;
                    ?>
                    <div>
                        <div class="flex justify-between items-center mb-2">
                            <h4 class="text-sm font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($zone); ?></h4>
                            <span class="text-xs font-bold <?php echo $isDry ? 'text-red-500' : 'text-blue-500'; ?>"><?php echo htmlspecialchars($status); ?></span>
                        </div>
                        <div class="flex justify-between text-[10px] text-gray-500 mb-1">
                            <span>Current: <?php echo $moisturePct; ?>%</span>
                            <span>Threshold: <?php echo $threshold; ?>%</span>
                        </div>
                        <div class="w-full bg-gray-100 dark:bg-gray-700 rounded-full h-2">
                            <div class="h-2 rounded-full <?php echo $isDry ? 'bg-red-500' : 'bg-blue-500'; ?>" style="width: <?php echo $barWidth; ?>%"></div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <div class="bg-blue-600 rounded-xl p-6 text-white shadow-lg">
                <h3 class="text-lg font-bold mb-4">Water Savings</h3>
                <div class="flex items-center justify-between mb-2">
                    <span class="text-sm opacity-80">Today's Savings</span>
                    <span class="font-bold text-xl">12,400L</span>
                </div>
                <div class="flex items-center justify-between mb-4">
                    <span class="text-sm opacity-80">Monthly Total</span>
                    <span class="font-bold text-xl">185,200L</span>
                </div>
                <div class="pt-4 border-t border-white/20">
                    <p class="text-[10px] uppercase font-bold opacity-60 mb-2">Conservation impact</p>
                    <div class="flex space-x-1">
                        <?php for($i=0; $i<8; $i++): ?>
                            <div class="h-8 w-full bg-white/20 rounded-sm overflow-hidden">
                                <div class="bg-white h-full" style="height: <?php echo rand(40, 100); ?>%"></div>
                            </div>
                        <?php endfor; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
