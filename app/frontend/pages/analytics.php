<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$dashboardData = [];
$res = call_api('/api/analytics/dashboard');
if ($res['status'] === 200) {
    $dashboardData = $res['data'];
}

$page_title = 'Analytics - Begin Masimba';
$active_page = 'analytics';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">Farm Analytics</h2>

    <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 mb-8">
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-100 dark:border-gray-700">
            <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Active Tasks</dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white"><?php echo htmlspecialchars($dashboardData['active_tasks'] ?? 0); ?></dd>
            </div>
        </div>
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-100 dark:border-gray-700">
            <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Critical Alerts</dt>
                <dd class="mt-1 text-3xl font-semibold text-red-600 dark:text-red-400"><?php echo htmlspecialchars($dashboardData['critical_alerts'] ?? 0); ?></dd>
            </div>
        </div>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow rounded-lg border border-gray-100 dark:border-gray-700 p-6">
        <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white mb-4">Daily Revenue (Last 7 Days)</h3>
        <!-- Simple Bar Chart Visualization using HTML/CSS -->
        <div class="flex items-end space-x-2 h-64">
            <?php 
            $revenueData = $dashboardData['daily_revenue'] ?? [];
            $maxVal = !empty($revenueData) ? max($revenueData) : 1;
            foreach ($revenueData as $val): 
                $height = ($val / $maxVal) * 100;
            ?>
            <div class="flex-1 flex flex-col items-center">
                <div class="w-full bg-primary-500 dark:bg-primary-600 hover:bg-primary-600 dark:hover:bg-primary-500 transition-all duration-300 rounded-t" style="height: <?php echo $height; ?>%;"></div>
                <span class="text-xs text-gray-500 dark:text-gray-400 mt-2">$<?php echo $val; ?></span>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</main>
<?php require __DIR__ . '/../components/footer.php'; ?>
