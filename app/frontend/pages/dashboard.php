<?php
if (empty($_SESSION['user'])) {
    header('Location: ../pages/login.php');
    exit;
}

$summary = call_api('/api/dashboard/summary', 'GET');
$data = $summary['data'] ?? [];
$low_stock_items = $data['low_stock_items'] ?? [];
$financial = $data['financial'] ?? [
    'total_income' => 0,
    'total_expense' => 0,
    'net_profit' => 0,
];

// Check if we're using fallback data
$is_fallback = $summary['fallback'] ?? false;

$page_title = 'Dashboard - Begin Masimba';
$active_page = 'dashboard';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Overview</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                <?php 
                if ($is_fallback) {
                    echo "⚠️ Running in offline mode - Backend API unavailable";
                } else {
                    echo "Welcome back! Here's what's happening on your farm.";
                }
                ?>
            </p>
        </div>
        <div class="text-sm text-gray-500 dark:text-gray-400 bg-white dark:bg-gray-800 px-3 py-1 rounded-md shadow-sm border border-gray-100 dark:border-gray-700">
            Last updated: <?php echo date('M d, Y H:i'); ?>
            <?php if ($is_fallback): ?>
                <span class="ml-2 text-amber-600">● Offline</span>
            <?php endif; ?>
        </div>
    </div>
    
    <!-- Stats Grid -->
    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <!-- Card 1: Alerts -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm hover:shadow-md transition-shadow rounded-xl border border-gray-100 dark:border-gray-700">
            <div class="p-6">
                <div class="flex items-center">
                    <div class="flex-shrink-0 bg-red-100 dark:bg-red-900/30 rounded-lg p-3">
                        <svg class="h-6 w-6 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path></svg>
                    </div>
                    <div class="ml-4 w-0 flex-1">
                        <dl>
                            <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Active Alerts</dt>
                            <dd class="text-2xl font-semibold text-gray-900 dark:text-white mt-1" data-metric="alerts"><?php echo $data['alerts'] ?? 0; ?></dd>
                        </dl>
                    </div>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-gray-700/30 px-6 py-2">
                <a href="?page=notifications" class="text-xs font-medium text-red-600 dark:text-red-400 hover:text-red-500 flex items-center">
                    View details <span aria-hidden="true" class="ml-1">&rarr;</span>
                </a>
            </div>
        </div>

        <!-- Card 2: Tasks -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm hover:shadow-md transition-shadow rounded-xl border border-gray-100 dark:border-gray-700">
            <div class="p-6">
                <div class="flex items-center">
                    <div class="flex-shrink-0 bg-amber-100 dark:bg-amber-900/30 rounded-lg p-3">
                        <svg class="h-6 w-6 text-amber-600 dark:text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path></svg>
                    </div>
                    <div class="ml-4 w-0 flex-1">
                        <dl>
                            <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Tasks Due</dt>
                            <dd class="text-2xl font-semibold text-gray-900 dark:text-white mt-1" data-metric="tasks"><?php echo $data['tasks_due'] ?? 0; ?></dd>
                        </dl>
                    </div>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-gray-700/30 px-6 py-2">
                <a href="?page=tasks" class="text-xs font-medium text-amber-600 dark:text-amber-400 hover:text-amber-500 flex items-center">
                    View schedule <span aria-hidden="true" class="ml-1">&rarr;</span>
                </a>
            </div>
        </div>

        <!-- Card 3: Livestock -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm hover:shadow-md transition-shadow rounded-xl border border-gray-100 dark:border-gray-700">
            <div class="p-6">
                <div class="flex items-center">
                    <div class="flex-shrink-0 bg-emerald-100 dark:bg-emerald-900/30 rounded-lg p-3">
                        <svg class="h-6 w-6 text-emerald-600 dark:text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <div class="ml-4 w-0 flex-1">
                        <dl>
                            <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Livestock Batches</dt>
                            <dd class="text-2xl font-semibold text-gray-900 dark:text-white mt-1" data-metric="livestock"><?php echo $data['livestock_batches'] ?? 0; ?></dd>
                        </dl>
                    </div>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-gray-700/30 px-6 py-2">
                <a href="?page=livestock" class="text-xs font-medium text-emerald-600 dark:text-emerald-400 hover:text-emerald-500 flex items-center">
                    Manage herd <span aria-hidden="true" class="ml-1">&rarr;</span>
                </a>
            </div>
        </div>

        <!-- Card 4: Inventory -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm hover:shadow-md transition-shadow rounded-xl border border-gray-100 dark:border-gray-700">
            <div class="p-6">
                <div class="flex items-center">
                    <div class="flex-shrink-0 bg-blue-100 dark:bg-blue-900/30 rounded-lg p-3">
                        <svg class="h-6 w-6 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path></svg>
                    </div>
                    <div class="ml-4 w-0 flex-1">
                        <dl>
                            <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Inventory Low</dt>
                            <dd class="text-2xl font-semibold text-gray-900 dark:text-white mt-1" data-metric="inventory"><?php echo $data['inventory_low'] ?? 0; ?></dd>
                        </dl>
                    </div>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-gray-700/30 px-6 py-2">
                <a href="?page=inventory" class="text-xs font-medium text-blue-600 dark:text-blue-400 hover:text-blue-500 flex items-center">
                    Check stock <span aria-hidden="true" class="ml-1">&rarr;</span>
                </a>
            </div>
        </div>
    </div>

    <div class="mt-8 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-4">
            <p class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">Total Income</p>
            <p class="mt-2 text-2xl font-semibold text-emerald-600 dark:text-emerald-400">
                $<?php echo number_format((float)($financial['total_income'] ?? 0), 2); ?>
            </p>
        </div>
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-4">
            <p class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">Total Expense</p>
            <p class="mt-2 text-2xl font-semibold text-red-600 dark:text-red-400">
                $<?php echo number_format((float)($financial['total_expense'] ?? 0), 2); ?>
            </p>
        </div>
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-4">
            <p class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">Net Profit</p>
            <p class="mt-2 text-2xl font-semibold <?php echo (($financial['net_profit'] ?? 0) >= 0) ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'; ?>">
                $<?php echo number_format((float)($financial['net_profit'] ?? 0), 2); ?>
            </p>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Financial Overview</h3>
            <div class="relative h-64">
                <canvas id="financialChart"></canvas>
            </div>
        </div>

        <!-- Low Stock Alert Widget -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-6">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Low Stock Alerts</h3>
                <span class="px-2.5 py-0.5 text-xs font-semibold rounded-full bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">
                    <?php echo count($low_stock_items); ?> Items
                </span>
            </div>
            <div class="overflow-y-auto max-h-64 pr-2">
                <?php if (empty($low_stock_items)): ?>
                    <div class="text-center py-8">
                        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">Inventory levels are healthy.</p>
                    </div>
                <?php else: ?>
                    <ul class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($low_stock_items as $item): ?>
                        <li class="py-3 flex justify-between items-center hover:bg-gray-50 dark:hover:bg-gray-700/50 rounded-lg px-2 -mx-2 transition-colors">
                            <div>
                                <p class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($item['name']); ?></p>
                                <p class="text-xs text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($item['location']); ?></p>
                            </div>
                            <div class="flex items-center">
                                <span class="text-sm font-bold text-red-600 dark:text-red-400 mr-3"><?php echo $item['quantity'] . ' ' . $item['unit']; ?></span>
                                <a href="?page=inventory" class="text-xs text-primary-600 hover:text-primary-700 dark:text-primary-400 font-medium">Restock</a>
                            </div>
                        </li>
                        <?php endforeach; ?>
                    </ul>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<script>
    // Chart Logic
    const ctx = document.getElementById('financialChart').getContext('2d');
    
    // Check for dark mode
    const isDarkMode = document.documentElement.classList.contains('dark') || 
                      (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
    
    const textColor = isDarkMode ? '#e5e7eb' : '#374151'; // gray-200 : gray-700
    const gridColor = isDarkMode ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.05)';
    
    const financialChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [{
                label: 'Income',
                data: [1200, 1900, 3000, 500, 2000, 3000],
                backgroundColor: 'rgba(16, 185, 129, 0.2)', // primary-500 with opacity
                borderColor: 'rgba(16, 185, 129, 1)',
                borderWidth: 1,
                borderRadius: 4
            }, {
                label: 'Expenses',
                data: [800, 1000, 2000, 1500, 1000, 1200],
                backgroundColor: 'rgba(239, 68, 68, 0.2)', // red-500 with opacity
                borderColor: 'rgba(239, 68, 68, 1)',
                borderWidth: 1,
                borderRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        color: textColor
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: gridColor
                    },
                    ticks: {
                        color: textColor
                    }
                },
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        color: textColor
                    }
                }
            }
        }
    });
</script>

<?php require __DIR__ . '/../components/footer.php'; ?>
