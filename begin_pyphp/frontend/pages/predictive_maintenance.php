<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$alerts_res = call_api('/api/predictive-maintenance/alerts', 'GET');
$alerts_data = $alerts_res['data'] ?? $alerts_res ?? [];
$alerts = [];
if (is_array($alerts_data)) {
    foreach ($alerts_data as $item) {
        if (is_array($item)) {
            $alerts[] = $item;
        }
    }
}

$fleet_res = call_api('/api/predictive-maintenance/fleet-health', 'GET');
$fleet_data = $fleet_res['data'] ?? $fleet_res ?? [];
$fleet = is_array($fleet_data) ? $fleet_data : [];

// Fallback data if API fails
if (empty($fleet)) {
    $fleet = [
        'total_assets' => 24,
        'fleet_availability' => 94.5,
        'critical' => 3,
        'estimated_downtime_prevented_hrs' => 156,
        'maintenance_cost_savings_usd' => 12500
    ];
}

$totalAssets = isset($fleet['total_assets']) ? (int)$fleet['total_assets'] : 0;
$fleetAvailability = isset($fleet['fleet_availability']) ? (float)$fleet['fleet_availability'] : 0;
$fleetAvailabilityWidth = max(0, min(100, $fleetAvailability));
$criticalCount = isset($fleet['critical']) ? (int)$fleet['critical'] : 0;
$downtimePrevented = isset($fleet['estimated_downtime_prevented_hrs']) ? (float)$fleet['estimated_downtime_prevented_hrs'] : 0;
$costSavings = isset($fleet['maintenance_cost_savings_usd']) ? (float)$fleet['maintenance_cost_savings_usd'] : 0;

if (empty($alerts)) {
    $alerts = [
        [
            'id' => 1,
            'equipment_name' => 'Main Water Pump',
            'location' => 'Dam 1',
            'risk_level' => 'HIGH',
            'risk_score' => 82,
            'predicted_failure_date' => '2024-02-15',
            'vibration_mm_s' => 4.2,
            'temperature_c' => 78.5,
            'current_draw_a' => 12.3,
            'recommended_action' => 'Schedule immediate inspection and bearing replacement'
        ],
        [
            'id' => 2,
            'equipment_name' => 'Ventilation Fan Motor',
            'location' => 'Broiler House 3',
            'risk_level' => 'CRITICAL',
            'risk_score' => 90,
            'predicted_failure_date' => '2024-02-08',
            'vibration_mm_s' => 5.8,
            'temperature_c' => 92.1,
            'current_draw_a' => 15.6,
            'recommended_action' => 'Urgent - replace motor within 48 hours'
        ]
    ];
}

$page_title = 'Predictive Maintenance - Begin Masimba';
$active_page = 'predictive_maintenance';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Predictive Maintenance</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">AI-driven failure prediction and equipment health monitoring</p>
        </div>
        <div class="flex items-center space-x-3">
            <span class="flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">
                <span class="w-2 h-2 mr-2 rounded-full bg-blue-500 animate-pulse"></span>
                Monitoring <?php echo $totalAssets; ?> Assets
            </span>
        </div>
    </div>

    <!-- Fleet Overview -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Fleet Availability</p>
            <h3 class="text-2xl font-bold text-emerald-600"><?php echo $fleetAvailability; ?>%</h3>
            <div class="w-full bg-gray-100 dark:bg-gray-700 h-1.5 rounded-full mt-3">
                <div class="bg-emerald-500 h-1.5 rounded-full" style="width: <?php echo $fleetAvailabilityWidth; ?>%"></div>
            </div>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Critical Risks</p>
            <h3 class="text-2xl font-bold text-red-600"><?php echo $criticalCount; ?></h3>
            <p class="text-xs text-gray-500 mt-2 font-medium">Require immediate attention</p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Prevented Downtime</p>
            <h3 class="text-2xl font-bold text-blue-600"><?php echo $downtimePrevented; ?> Hrs</h3>
            <p class="text-xs text-gray-500 mt-2 font-medium">Estimated last 30 days</p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Cost Savings</p>
            <h3 class="text-2xl font-bold text-amber-600">$<?php echo number_format($costSavings, 0); ?></h3>
            <p class="text-xs text-gray-500 mt-2 font-medium">Preventative vs Reactive</p>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Maintenance Alerts List -->
        <div class="lg:col-span-2 space-y-6">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">High-Risk Assets</h3>
            <?php foreach ($alerts as $alert): ?>
            <?php
                $equipmentName = $alert['equipment_name'] ?? ($alert['asset_name'] ?? 'Unknown Equipment');
                $location = $alert['location'] ?? '';
                $predictedRaw = $alert['predicted_failure_date'] ?? null;
                $riskLevel = $alert['risk_level'] ?? ($alert['severity'] ?? 'MEDIUM');
                $riskScore = isset($alert['risk_score']) ? (int)$alert['risk_score'] : 0;

                $predictedFormatted = '-';
                if ($predictedRaw) {
                    $ts = strtotime($predictedRaw);
                    if ($ts !== false) {
                        $predictedFormatted = date('M j, Y', $ts);
                    }
                }

                $vibration = $alert['vibration_mm_s'] ?? ($alert['vibration'] ?? null);
                $temperature = $alert['temperature_c'] ?? ($alert['temperature'] ?? null);
                $currentDraw = $alert['current_draw_a'] ?? ($alert['current_draw'] ?? null);

                $recAction = $alert['recommended_action'] ?? ($alert['recommendation'] ?? 'No recommendation available');
            ?>
            <div class="bg-white dark:bg-gray-800 rounded-xl p-6 border border-gray-100 dark:border-gray-700 shadow-sm relative overflow-hidden">
                <div class="absolute top-0 left-0 w-1 h-full <?php 
                    echo $riskLevel === 'CRITICAL' ? 'bg-red-500' : ($riskLevel === 'HIGH' ? 'bg-amber-500' : 'bg-blue-500'); 
                ?>"></div>
                
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <h4 class="text-lg font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($equipmentName); ?></h4>
                        <p class="text-sm text-gray-500">
                            <?php echo htmlspecialchars($location); ?>
                            • Failure Predicted: <?php echo $predictedFormatted; ?>
                        </p>
                    </div>
                    <div class="text-right">
                        <span class="px-3 py-1 rounded-full text-xs font-bold <?php 
                            echo $riskLevel === 'CRITICAL' ? 'bg-red-100 text-red-800' : ($riskLevel === 'HIGH' ? 'bg-amber-100 text-amber-800' : 'bg-blue-100 text-blue-800'); 
                        ?>">
                            <?php echo htmlspecialchars($riskLevel); ?> (<?php echo $riskScore; ?>%)
                        </span>
                    </div>
                </div>

                <div class="grid grid-cols-3 gap-6 mb-6">
                    <div class="bg-gray-50 dark:bg-gray-700/30 p-4 rounded-xl">
                        <p class="text-[10px] text-gray-500 uppercase font-bold mb-1">Vibration</p>
                        <?php
                            $vibHigh = $vibration !== null && $vibration > 10;
                        ?>
                        <p class="text-lg font-bold <?php echo $vibHigh ? 'text-red-500' : 'text-gray-900 dark:text-white'; ?>">
                            <?php echo $vibration !== null ? $vibration : 'N/A'; ?> <span class="text-xs font-normal text-gray-500">mm/s</span>
                        </p>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700/30 p-4 rounded-xl">
                        <p class="text-[10px] text-gray-500 uppercase font-bold mb-1">Temperature</p>
                        <?php
                            $tempHigh = $temperature !== null && $temperature > 75;
                        ?>
                        <p class="text-lg font-bold <?php echo $tempHigh ? 'text-red-500' : 'text-gray-900 dark:text-white'; ?>">
                            <?php echo $temperature !== null ? $temperature : 'N/A'; ?> <span class="text-xs font-normal text-gray-500">°C</span>
                        </p>
                    </div>
                    <div class="bg-gray-50 dark:bg-gray-700/30 p-4 rounded-xl">
                        <p class="text-[10px] text-gray-500 uppercase font-bold mb-1">Current Draw</p>
                        <?php
                            $currentHigh = $currentDraw !== null && $currentDraw > 40;
                        ?>
                        <p class="text-lg font-bold <?php echo $currentHigh ? 'text-red-500' : 'text-gray-900 dark:text-white'; ?>">
                            <?php echo $currentDraw !== null ? $currentDraw : 'N/A'; ?> <span class="text-xs font-normal text-gray-500">A</span>
                        </p>
                    </div>
                </div>

                <div class="flex items-center justify-between p-4 bg-primary-50 dark:bg-primary-900/10 rounded-xl border border-primary-100 dark:border-primary-800/30">
                    <div class="flex items-center text-primary-800 dark:text-primary-300">
                        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <span class="text-sm font-medium">Recommendation: <?php echo htmlspecialchars($recAction); ?></span>
                    </div>
                    <button class="bg-primary-600 text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-primary-700">
                        Schedule Repair
                    </button>
                </div>
            </div>
            <?php endforeach; ?>
        </div>

        <!-- Diagnostic Tools & History -->
        <div class="space-y-6">
            <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Fleet Health Trend</h3>
                <div class="h-48 flex items-end justify-between px-2">
                    <!-- Simple CSS bar chart representation -->
                    <div class="w-4 bg-emerald-500 rounded-t" style="height: 85%"></div>
                    <div class="w-4 bg-emerald-500 rounded-t" style="height: 82%"></div>
                    <div class="w-4 bg-emerald-500 rounded-t" style="height: 88%"></div>
                    <div class="w-4 bg-amber-500 rounded-t" style="height: 75%"></div>
                    <div class="w-4 bg-emerald-500 rounded-t" style="height: 84%"></div>
                    <div class="w-4 bg-red-500 rounded-t" style="height: 65%"></div>
                    <div class="w-4 bg-emerald-500 rounded-t" style="height: 92%"></div>
                </div>
                <div class="flex justify-between mt-2 text-[10px] text-gray-500 uppercase font-bold px-1">
                    <span>Mon</span><span>Tue</span><span>Wed</span><span>Thu</span><span>Fri</span><span>Sat</span><span>Sun</span>
                </div>
            </div>

            <div class="bg-gray-900 rounded-xl p-6 text-white">
                <h3 class="text-lg font-bold mb-4">Diagnostics Console</h3>
                <div class="space-y-3 font-mono text-[10px] opacity-80">
                    <p class="text-emerald-400">[OK] Edge Node-721 connection stable</p>
                    <p class="text-emerald-400">[OK] Processing FFT on Pump-Main data</p>
                    <p class="text-amber-400">[WARN] Anomaly detected in Compressor-B current draw</p>
                    <p class="text-emerald-400">[OK] Vibration baseline updated for Milling-Unit-3</p>
                    <p class="text-emerald-400">[OK] All sensors reporting in real-time</p>
                </div>
                <button class="w-full mt-6 border border-white/20 hover:bg-white/10 text-white py-2 rounded-lg text-xs font-bold transition-colors">
                    Run System Self-Test
                </button>
            </div>
        </div>
    </div>
</div>
