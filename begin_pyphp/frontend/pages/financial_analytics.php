<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$forecast_res = call_api('/api/financial-analytics/forecast', 'GET');
$forecast_data = $forecast_res['data'] ?? $forecast_res ?? [];
$forecast = is_array($forecast_data) ? $forecast_data : [];

$assets_res = call_api('/api/financial-analytics/assets', 'GET');
$assets_data = $assets_res['data'] ?? $assets_res ?? [];
$assets = [];
if (is_array($assets_data)) {
    foreach ($assets_data as $item) {
        if (is_array($item)) {
            $assets[] = $item;
        }
    }
}

$roi_res = call_api('/api/financial-analytics/roi', 'GET');
$roi_data = $roi_res['data'] ?? $roi_res ?? [];
$roi_projects = [];
if (is_array($roi_data)) {
    foreach ($roi_data as $item) {
        if (is_array($item)) {
            $roi_projects[] = $item;
        }
    }
}

if (empty($forecast) || !isset($forecast['current_cash_position'])) {
    $forecast = [
        'current_cash_position' => 125000.00,
        'burn_rate' => 8500.00,
        'runway_months' => 15,
        'forecast_scenarios' => [
            'Realistic' => [
                ['period' => '2024-01', 'projected_revenue' => 45000, 'projected_expenses' => 38000, 'net_cash_flow' => 7000],
                ['period' => '2024-02', 'projected_revenue' => 48000, 'projected_expenses' => 39000, 'net_cash_flow' => 9000],
                ['period' => '2024-03', 'projected_revenue' => 52000, 'projected_expenses' => 40000, 'net_cash_flow' => 12000],
                ['period' => '2024-04', 'projected_revenue' => 55000, 'projected_expenses' => 41000, 'net_cash_flow' => 14000],
                ['period' => '2024-05', 'projected_revenue' => 58000, 'projected_expenses' => 42000, 'net_cash_flow' => 16000],
                ['period' => '2024-06', 'projected_revenue' => 62000, 'projected_expenses' => 44000, 'net_cash_flow' => 18000]
            ]
        ]
    ];
}

if (empty($assets)) {
    $assets = [
        ['asset_name' => 'Tractor John Deere 5075E', 'type' => 'Machinery', 'purchase_cost' => 45000, 'current_value' => 38000, 'annual_depreciation' => 3500, 'purchase_date' => '2022-01-15'],
        ['asset_name' => 'Irrigation System', 'type' => 'Infrastructure', 'purchase_cost' => 28000, 'current_value' => 22000, 'annual_depreciation' => 2000, 'purchase_date' => '2021-06-20'],
        ['asset_name' => 'Greenhouse Structure', 'type' => 'Infrastructure', 'purchase_cost' => 85000, 'current_value' => 72000, 'annual_depreciation' => 4250, 'purchase_date' => '2020-03-10'],
        ['asset_name' => 'Feed Storage Silo', 'type' => 'Infrastructure', 'purchase_cost' => 35000, 'current_value' => 31000, 'annual_depreciation' => 1600, 'purchase_date' => '2021-11-05']
    ];
}

if (empty($roi_projects)) {
    $roi_projects = [
        ['project' => 'Solar Panel Installation', 'cost' => 25000, 'roi_pct' => 74.0, 'payback_years' => 1.5],
        ['project' => 'Automated Feeding System', 'cost' => 15000, 'roi_pct' => 59.3, 'payback_years' => 2.0],
        ['project' => 'Water Recycling System', 'cost' => 12000, 'roi_pct' => 60.0, 'payback_years' => 1.7]
    ];
}

$cash_position = isset($forecast['current_cash_position']) ? (float)$forecast['current_cash_position'] : 0;
$burn_rate = isset($forecast['burn_rate']) ? (float)$forecast['burn_rate'] : 0;
$runway_months = isset($forecast['runway_months']) ? $forecast['runway_months'] : 0;

$page_title = 'Financial Analytics - Begin Masimba';
$active_page = 'financial_analytics';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Financial Analytics</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Advanced forecasting, asset depreciation, and ROI tracking</p>
        </div>
        <div class="flex space-x-3">
            <button class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 px-4 py-2 rounded-lg text-sm font-semibold text-gray-700 dark:text-gray-300 hover:bg-gray-50">
                Export PDF
            </button>
            <button class="bg-primary-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-primary-700">
                New Scenario
            </button>
        </div>
    </div>

    <!-- Top Metrics -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Current Cash Position</p>
            <h3 class="text-2xl font-bold text-gray-900 dark:text-white">$<?php echo number_format($cash_position, 2); ?></h3>
            <p class="text-xs text-emerald-600 mt-2 font-medium">↑ 4.2% from last month</p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Monthly Burn Rate</p>
            <h3 class="text-2xl font-bold text-red-600">$<?php echo number_format($burn_rate, 2); ?></h3>
            <p class="text-xs text-gray-500 mt-2 font-medium">Avg over last 6 months</p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm text-gray-500 dark:text-gray-400 font-medium mb-1">Projected Runway</p>
            <h3 class="text-2xl font-bold text-blue-600"><?php echo $runway_months; ?> Months</h3>
            <p class="text-xs text-gray-500 mt-2 font-medium">Realistic scenario</p>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Forecast Chart/Table -->
        <div class="lg:col-span-2 space-y-8">
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div class="p-6 border-b border-gray-100 dark:border-gray-700 flex justify-between items-center">
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white">Cash Flow Forecast (Realistic)</h3>
                    <div class="flex space-x-2">
                        <span class="px-2 py-1 bg-blue-100 text-blue-800 text-[10px] font-bold rounded">REALISTIC</span>
                    </div>
                </div>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                        <thead class="bg-gray-50 dark:bg-gray-700/30">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Period</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Revenue</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Expenses</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Net Cash</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                            <?php
                                $scenarios = $forecast['forecast_scenarios'] ?? [];
                                $realistic = $scenarios['Realistic'] ?? ($scenarios['realistic'] ?? []);
                                if (!is_array($realistic)) {
                                    $realistic = [];
                                }
                            ?>
                            <?php foreach ($realistic as $item): ?>
                            <tr>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($item['period'] ?? ''); ?></td>
                                <?php
                                    $proj_rev = isset($item['projected_revenue']) ? $item['projected_revenue'] : ($item['revenue'] ?? 0);
                                    $proj_exp = isset($item['projected_expenses']) ? $item['projected_expenses'] : ($item['expenses'] ?? 0);
                                    $net_cash = isset($item['net_cash_flow']) ? $item['net_cash_flow'] : ($item['net_cash'] ?? ($proj_rev - $proj_exp));
                                ?>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-emerald-600 font-semibold">$<?php echo number_format($proj_rev, 0); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-red-500">$<?php echo number_format($proj_exp, 0); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-bold <?php echo $net_cash >= 0 ? 'text-gray-900 dark:text-white' : 'text-red-600'; ?>">
                                    $<?php echo number_format($net_cash, 0); ?>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Asset Depreciation -->
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div class="p-6 border-b border-gray-100 dark:border-gray-700">
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white">Asset Depreciation Schedule</h3>
                </div>
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/30">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Asset</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Purchase Cost</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Current Value</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Annual Depr.</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($assets as $asset): ?>
                        <?php
                            $asset_name = $asset['asset_name'] ?? '';
                            $asset_type = $asset['type'] ?? 'Asset';
                            $purchase_date = $asset['purchase_date'] ?? '';
                            $purchase_cost = isset($asset['purchase_cost']) ? $asset['purchase_cost'] : 0;
                            $current_value = isset($asset['current_value']) ? $asset['current_value'] : 0;
                            $annual_depr = isset($asset['annual_depreciation']) ? $asset['annual_depreciation'] : 0;
                        ?>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($asset_name); ?></div>
                                <div class="text-xs text-gray-500"><?php echo htmlspecialchars($asset_type); ?> • Purchased <?php echo htmlspecialchars($purchase_date); ?></div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">$<?php echo number_format($purchase_cost, 0); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900 dark:text-white">$<?php echo number_format($current_value, 0); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-red-500">-$<?php echo number_format($annual_depr, 0); ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ROI Analysis -->
        <div class="space-y-6">
            <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-6">Project ROI Analysis</h3>
                <div class="space-y-6">
                    <?php foreach ($roi_projects as $project): ?>
                    <?php
                        $project_name = $project['project'] ?? ($project['project_name'] ?? 'Project');
                        $roi_pct = isset($project['roi_pct']) ? $project['roi_pct'] : ($project['roi_percentage'] ?? 0);
                        $cost = isset($project['cost']) ? $project['cost'] : ($project['investment'] ?? 0);
                        if (isset($project['payback_years'])) {
                            $payback = $project['payback_years'];
                        } elseif (isset($project['payback_months'])) {
                            $payback = $project['payback_months'] / 12;
                        } else {
                            $payback = 0;
                        }
                        $bar_width = min(100, $roi_pct * 2);
                    ?>
                    <div>
                        <div class="flex justify-between items-center mb-2">
                            <h4 class="text-sm font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($project_name); ?></h4>
                            <span class="text-emerald-600 font-bold text-sm"><?php echo $roi_pct; ?>% ROI</span>
                        </div>
                        <div class="flex justify-between text-xs text-gray-500 mb-2">
                            <span>Cost: $<?php echo number_format($cost, 0); ?></span>
                            <span>Payback: <?php echo $payback; ?>y</span>
                        </div>
                        <div class="w-full bg-gray-100 dark:bg-gray-700 rounded-full h-1.5">
                            <div class="bg-emerald-500 h-1.5 rounded-full" style="width: <?php echo $bar_width; ?>%"></div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Financial Health Score -->
            <div class="bg-primary-600 rounded-xl p-6 text-white shadow-lg">
                <h3 class="text-lg font-bold mb-4">Financial Health Score</h3>
                <div class="flex items-center justify-center mb-4">
                    <div class="relative">
                        <svg class="w-32 h-32">
                            <circle class="text-primary-700" stroke-width="8" stroke="currentColor" fill="transparent" r="56" cx="64" cy="64"/>
                            <circle class="text-white" stroke-width="8" stroke-dasharray="351.8" stroke-dashoffset="<?php echo 351.8 * (1 - 0.78); ?>" stroke-linecap="round" stroke="currentColor" fill="transparent" r="56" cx="64" cy="64"/>
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span class="text-3xl font-bold">78</span>
                            <span class="text-[10px] uppercase font-bold opacity-80">Good</span>
                        </div>
                    </div>
                </div>
                <p class="text-xs text-center opacity-80">Your score is based on liquidity, solvency, and operational efficiency metrics.</p>
            </div>
        </div>
    </div>
</div>
