<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$logs_res = call_api('/api/veterinary/logs', 'GET');
$logs_data = $logs_res['data'] ?? [];
$logs = [];
if (is_array($logs_data)) {
    foreach ($logs_data as $item) {
        if (is_array($item)) {
            $logs[] = $item;
        }
    }
}

$vaccinations_res = call_api('/api/veterinary/vaccinations', 'GET');
$vaccinations_data = $vaccinations_res['data'] ?? [];
$vaccinations = [];
if (is_array($vaccinations_data)) {
    foreach ($vaccinations_data as $item) {
        if (is_array($item)) {
            $vaccinations[] = $item;
        }
    }
}

$withdrawals_res = call_api('/api/veterinary/withdrawals', 'GET');
$withdrawals_data = $withdrawals_res['data'] ?? [];
$withdrawals = [];
if (is_array($withdrawals_data)) {
    foreach ($withdrawals_data as $item) {
        if (is_array($item)) {
            $withdrawals[] = $item;
        }
    }
}

$page_title = 'Veterinary Management - Begin Masimba';
$active_page = 'veterinary';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Veterinary Management</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Medical logs, vaccination schedules, and withdrawal safety</p>
        </div>
        <div class="flex space-x-3">
            <button class="bg-primary-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-primary-700">
                Log Treatment
            </button>
        </div>
    </div>

    <!-- Withdrawal Alerts -->
    <?php if (!empty($withdrawals)): ?>
    <div class="mb-8 space-y-4">
        <?php foreach ($withdrawals as $alert): ?>
        <?php
            $animalId = isset($alert['animal_id']) ? $alert['animal_id'] : (isset($alert['batch_id']) ? ('Batch #' . $alert['batch_id']) : 'Unknown');
            $endDateRaw = isset($alert['end_date']) ? $alert['end_date'] : null;
            $daysRemaining = isset($alert['days_remaining']) ? (int)$alert['days_remaining'] : 0;
            $endDateFormatted = 'Unknown';
            if ($endDateRaw) {
                $ts = strtotime($endDateRaw);
                if ($ts !== false) {
                    $endDateFormatted = date('M j, Y', $ts);
                }
            }
        ?>
        <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800/50 p-4 rounded-xl flex items-center justify-between">
            <div class="flex items-center">
                <div class="w-10 h-10 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center mr-4 text-red-600">
                    ⚠️
                </div>
                <div>
                    <h4 class="font-bold text-red-800 dark:text-red-400">Withdrawal Alert: <?php echo htmlspecialchars($animalId); ?></h4>
                    <p class="text-sm text-red-700 dark:text-red-300">Product safety period active until <?php echo $endDateFormatted; ?></p>
                </div>
            </div>
            <span class="bg-red-600 text-white px-3 py-1 rounded-full text-xs font-bold"><?php echo $daysRemaining; ?> DAYS LEFT</span>
        </div>
        <?php endforeach; ?>
    </div>
    <?php endif; ?>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Medical Logs -->
        <div class="lg:col-span-2 space-y-8">
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div class="p-6 border-b border-gray-100 dark:border-gray-700">
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white">Recent Medical Logs</h3>
                </div>
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/30">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Animal / Batch</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Treatment</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Withdrawal</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($logs as $log): ?>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($log['animal_id'] ?? 'Unknown'); ?></div>
                                <div class="text-xs text-gray-500"><?php echo htmlspecialchars($log['animal_type'] ?? ''); ?></div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm text-gray-900 dark:text-white font-medium"><?php echo htmlspecialchars($log['treatment_type'] ?? ''); ?></div>
                                <div class="text-xs text-gray-500">
                                    <?php echo htmlspecialchars($log['medication'] ?? ''); ?>
                                    <?php if (!empty($log['dosage'])): ?>
                                        (<?php echo htmlspecialchars($log['dosage']); ?>)
                                    <?php endif; ?>
                                </div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-xs text-gray-500">
                                <?php if (!empty($log['withdrawal_period_days']) && $log['withdrawal_period_days'] > 0): ?>
                                    <?php
                                        $weRaw = $log['withdrawal_end_date'] ?? null;
                                        $weFmt = '';
                                        if ($weRaw) {
                                            $ts = strtotime($weRaw);
                                            if ($ts !== false) {
                                                $weFmt = date('M j', $ts);
                                            }
                                        }
                                    ?>
                                    Ends <?php echo $weFmt ?: '-'; ?>
                                <?php else: ?>
                                    None
                                <?php endif; ?>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 py-1 text-[10px] font-bold rounded <?php 
                                    $status = $log['status'] ?? '';
                                    echo $status === 'CLEARED' ? 'bg-emerald-100 text-emerald-800' : 'bg-red-100 text-red-800'; 
                                ?>">
                                    <?php echo htmlspecialchars($status); ?>
                                </span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Vaccination Schedule -->
        <div class="space-y-6">
            <div class="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-6">Vaccination Schedule</h3>
                <div class="space-y-6">
                    <?php foreach ($vaccinations as $v): ?>
                    <div class="relative pl-6 border-l-2 border-primary-500">
                        <div class="absolute -left-1.5 top-0 w-3 h-3 bg-primary-500 rounded-full border-2 border-white dark:border-gray-800"></div>
                        <div class="flex justify-between items-start mb-1">
                            <h4 class="text-sm font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($v['vaccine_name']); ?></h4>
                            <span class="text-[10px] font-bold text-primary-600 uppercase"><?php echo $v['status']; ?></span>
                        </div>
                        <p class="text-xs text-gray-500"><?php echo htmlspecialchars($v['batch_id']); ?> • Target Day <?php echo $v['target_age_days']; ?></p>
                        <p class="text-xs font-medium text-gray-700 dark:text-gray-300 mt-2"><?php echo date('D, M j, Y', strtotime($v['scheduled_date'])); ?></p>
                    </div>
                    <?php endforeach; ?>
                </div>
                <button class="w-full mt-8 bg-gray-50 dark:bg-gray-700/30 text-gray-700 dark:text-gray-300 py-3 rounded-xl text-sm font-bold hover:bg-gray-100 transition-colors">
                    View Full Calendar
                </button>
            </div>
        </div>
    </div>
</div>
