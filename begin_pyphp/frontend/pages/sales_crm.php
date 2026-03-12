<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$leads_res = call_api('/api/sales-crm/leads', 'GET');
$leads_data = $leads_res['data'] ?? $leads_res ?? [];
$leads = [];
if (is_array($leads_data)) {
    foreach ($leads_data as $item) {
        if (is_array($item)) {
            $leads[] = $item;
        }
    }
}

$forecast_res = call_api('/api/sales-crm/forecast', 'GET');
$forecast_data = $forecast_res['data'] ?? $forecast_res ?? [];
$forecast = is_array($forecast_data) ? $forecast_data : [];

$pipelineValue = isset($forecast['total_deals_value']) ? (float)$forecast['total_deals_value'] : 0;
$weightedValue = isset($forecast['total_weighted_value']) ? (float)$forecast['total_weighted_value'] : 0;
$dealCount = isset($forecast['deal_count']) ? (int)$forecast['deal_count'] : 0;

$page_title = 'Sales & CRM - Begin Masimba';
$active_page = 'sales_crm';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Sales & CRM</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Lead scoring and pipeline forecasting</p>
        </div>
        <div class="flex space-x-3">
            <button class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                New Lead
            </button>
        </div>
    </div>

    <!-- Forecast Summary -->
    <div class="grid grid-cols-1 gap-6 sm:grid-cols-3 mb-8">
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Pipeline Value</p>
            <p class="mt-2 text-3xl font-bold text-gray-900 dark:text-white">$<?php echo number_format($pipelineValue, 2); ?></p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Weighted Forecast</p>
            <p class="mt-2 text-3xl font-bold text-emerald-600">$<?php echo number_format($weightedValue, 2); ?></p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Open Deals</p>
            <p class="mt-2 text-3xl font-bold text-gray-900 dark:text-white"><?php echo $dealCount; ?></p>
        </div>
    </div>

    <!-- Leads Table -->
    <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden mb-8">
        <div class="px-6 py-4 border-b border-gray-100 dark:border-gray-700 flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Hot Leads</h3>
            <a href="#" class="text-sm text-indigo-600 hover:text-indigo-500 font-medium">View all leads</a>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/30">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Lead</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Company</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Temperature</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Prob.</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Recommended Action</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                    <?php foreach ($leads as $lead): ?>
                    <?php
                        if (!is_array($lead)) {
                            continue;
                        }
                        $firstName = $lead['first_name'] ?? '';
                        $lastName = $lead['last_name'] ?? '';
                        $nameInitials = ($firstName !== '' ? substr($firstName, 0, 1) : '') . ($lastName !== '' ? substr($lastName, 0, 1) : '');
                        $fullName = trim($firstName . ' ' . $lastName);
                        $email = $lead['email'] ?? '';
                        $company = $lead['company'] ?? '';
                        $leadTemp = $lead['lead_temperature'] ?? 'WARM_LEAD';
                        $probability = isset($lead['conversion_probability']) ? $lead['conversion_probability'] : 0;
                        $recommendation = $lead['recommended_action'] ?? '';
                        $tempClass = $leadTemp === 'HOT_LEAD' ? 'bg-orange-100 text-orange-800' : 'bg-blue-100 text-blue-800';
                    ?>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="h-8 w-8 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-indigo-700 dark:text-indigo-400 font-bold text-xs">
                                    <?php echo htmlspecialchars($nameInitials); ?>
                                </div>
                                <div class="ml-3">
                                    <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($fullName); ?></div>
                                    <div class="text-xs text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($email); ?></div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($company); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 py-1 text-xs rounded-md font-medium <?php 
                                echo $tempClass; 
                            ?>">
                                <?php echo str_replace('_', ' ', $leadTemp); ?>
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo $probability; ?>%</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($recommendation); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            <button class="text-indigo-600 hover:text-indigo-900">Contact</button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
