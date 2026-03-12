<?php
// Expects $page_title and $active_page to be set
require_once __DIR__ . '/../lib/i18n.php';

// Navigation Items with Icons (SVG paths)
$nav_items = [
    'dashboard' => ['label' => __('dashboard'), 'icon' => 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6'],
    'livestock' => ['label' => __('livestock'), 'icon' => 'M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10'],
    'breeding' => ['label' => __('breeding'), 'icon' => 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z'],
    'inventory' => ['label' => __('inventory'), 'icon' => 'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4'],
    'fields' => ['label' => __('fields'), 'icon' => 'M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z'],
    'iot' => ['label' => __('iot'), 'icon' => 'M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z'],
    'financial' => ['label' => __('financial'), 'icon' => 'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z'],
    'tasks' => ['label' => __('tasks'), 'icon' => 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01'],
    'reports' => ['label' => __('reports'), 'icon' => 'M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'],
    'weather' => ['label' => __('weather'), 'icon' => 'M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z'],
    'settings' => ['label' => __('settings'), 'icon' => 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.006c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.006c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z'],
];

// Fallback icon for others
$default_icon = 'M4 6h16M4 12h16M4 18h16';

// Merge with full list if needed, or just use these and add others as generic
$all_items = [
    'equipment' => __('equipment'),
    'timesheets' => __('labor'),
    'payments' => __('payments'),
    'marketplace' => 'Marketplace',
    'traceability' => 'Traceability',
    'feed' => 'Feed',
    'waste' => 'Waste',
    'hr' => 'HR',
    'analytics' => __('analytics'),
    'users' => __('users'),
    'compliance' => 'Compliance',
    'suppliers' => 'Suppliers',
    'contracts' => 'Contracts',
    'field_mode' => 'Field Mode',
    'data_import' => 'Data Import',
    'biogas' => 'Biogas',
    'sales_crm' => 'Sales CRM',
    'production_management' => 'Production',
    'energy_management' => 'Energy',
    'waste_circularity' => 'Circularity',
    'financial_analytics' => 'Finance',
    'predictive_maintenance' => 'Maintenance',
    'feed_formulation' => 'Feed',
    'weather_irrigation' => 'Irrigation',
    'veterinary' => 'Vet',
    'qr_inventory' => 'QR',
];

foreach ($all_items as $k => $v) {
    if (!isset($nav_items[$k])) {
        $nav_items[$k] = ['label' => $v, 'icon' => $default_icon];
    }
}

$user_role = $_SESSION['user']['role'] ?? null;
if ($user_role && in_array($user_role, ['worker', 'field_worker'], true)) {
    $allowed_items = ['dashboard', 'tasks', 'fields', 'iot', 'field_mode', 'notifications'];
    $nav_items = array_filter(
        $nav_items,
        function ($key) use ($allowed_items) {
            return in_array($key, $allowed_items, true);
        },
        ARRAY_FILTER_USE_KEY
    );
}
?>
<!DOCTYPE html>
<html lang="<?php echo $lang_code; ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($page_title ?? 'Begin Masimba'); ?></title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                    colors: {
                        primary: {
                            50: '#ecfdf5',
                            100: '#d1fae5',
                            500: '#10b981',
                            600: '#059669',
                            700: '#047857',
                            800: '#065f46',
                            900: '#064e3b',
                        }
                    }
                }
            }
        }
    </script>
    
    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="/farmos/begin_pyphp/frontend/public/js/preferences.js"></script>
    <script src="/farmos/begin_pyphp/frontend/public/js/offline-sync.js"></script>
    <script src="/farmos/begin_pyphp/frontend/public/js/offline.service.js"></script>
    <script src="/farmos/begin_pyphp/frontend/public/js/websocket-client.js"></script>
    <script>
        if ('serviceWorker' in navigator) {
            window.addEventListener('load', function() {
                navigator.serviceWorker.register('/farmos/begin_pyphp/frontend/public/service-worker.js');
            });
        }
    </script>
</head>
<body class="bg-gray-50 text-gray-900 dark:bg-gray-900 dark:text-gray-100 font-sans antialiased">

<div class="flex h-screen overflow-hidden">
    <!-- Sidebar Overlay -->
    <div id="sidebar-overlay" class="fixed inset-0 bg-gray-600 bg-opacity-75 z-20 hidden lg:hidden transition-opacity"></div>

    <!-- Sidebar -->
    <aside id="sidebar" class="fixed inset-y-0 left-0 z-30 w-64 transform -translate-x-full transition-transform duration-300 ease-in-out bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 lg:translate-x-0 lg:static lg:inset-auto flex flex-col">
        <!-- Logo -->
        <div class="flex items-center justify-center h-16 bg-primary-800 dark:bg-gray-900 shadow-md">
            <h1 class="text-xl font-bold text-white tracking-wide">Begin Masimba</h1>
        </div>

        <!-- Nav Links -->
        <nav class="flex-1 overflow-y-auto py-4 px-2 space-y-4">
            <?php
                $group_labels = [
                    'overview' => 'Overview',
                    'operations' => 'Operations',
                    'production' => 'Production',
                    'finance' => 'Finance',
                    'systems' => 'Systems',
                    'admin' => 'Admin',
                ];

                $group_map = [
                    'dashboard' => 'overview',
                    'analytics' => 'overview',
                    'reports' => 'overview',
                    'weather' => 'overview',
                    'tasks' => 'operations',
                    'timesheets' => 'operations',
                    'fields' => 'operations',
                    'field_mode' => 'operations',
                    'equipment' => 'operations',
                    'inventory' => 'operations',
                    'qr_inventory' => 'operations',
                    'hr' => 'operations',
                    'suppliers' => 'operations',
                    'contracts' => 'operations',
                    'marketplace' => 'operations',
                    'traceability' => 'operations',
                    'livestock' => 'production',
                    'breeding' => 'production',
                    'veterinary' => 'production',
                    'feed' => 'production',
                    'feed_formulation' => 'production',
                    'weather_irrigation' => 'production',
                    'production_management' => 'production',
                    'financial' => 'finance',
                    'payments' => 'finance',
                    'financial_analytics' => 'finance',
                    'sales_crm' => 'finance',
                    'iot' => 'systems',
                    'biogas' => 'systems',
                    'energy_management' => 'systems',
                    'waste' => 'systems',
                    'waste_circularity' => 'systems',
                    'predictive_maintenance' => 'systems',
                    'compliance' => 'admin',
                    'users' => 'admin',
                    'settings' => 'admin',
                    'data_import' => 'admin',
                ];

                $group_order = ['overview', 'operations', 'production', 'finance', 'systems', 'admin'];
                $grouped_items = [];

                foreach ($nav_items as $key => $item) {
                    $group_key = $group_map[$key] ?? 'operations';
                    if (!isset($grouped_items[$group_key])) {
                        $grouped_items[$group_key] = [];
                    }
                    $grouped_items[$group_key][$key] = $item;
                }
            ?>

            <?php foreach ($group_order as $group_key): ?>
                <?php if (empty($grouped_items[$group_key] ?? [])) continue; ?>
                <div>
                    <div class="px-3 mb-1 text-xs font-semibold text-gray-400 tracking-wide uppercase">
                        <?php echo $group_labels[$group_key]; ?>
                    </div>
                    <div class="space-y-1">
                        <?php foreach ($grouped_items[$group_key] as $key => $item): 
                            $active = ($active_page === $key);
                            $classes = $active 
                                ? 'bg-primary-50 text-primary-700 dark:bg-gray-700 dark:text-white border-r-4 border-primary-600' 
                                : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white';
                        ?>
                        <a href="?page=<?php echo $key; ?>" class="<?php echo $classes; ?> group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors">
                            <svg class="<?php echo $active ? 'text-primary-600 dark:text-primary-400' : 'text-gray-400 group-hover:text-gray-500 dark:text-gray-400'; ?> mr-3 flex-shrink-0 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="<?php echo $item['icon']; ?>" />
                            </svg>
                            <?php echo $item['label']; ?>
                        </a>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php endforeach; ?>
        </nav>
        
        <!-- User Profile (Bottom Sidebar) -->
        <div class="border-t border-gray-200 dark:border-gray-700 p-4">
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <span class="inline-block h-8 w-8 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden">
                        <svg class="h-full w-full text-gray-400" fill="currentColor" viewBox="0 0 24 24"><path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" /></svg>
                    </span>
                </div>
                <div class="ml-3">
                    <p class="text-sm font-medium text-gray-700 dark:text-gray-200"><?php echo htmlspecialchars($_SESSION['user']['name'] ?? 'User'); ?></p>
                    <p class="text-xs font-medium text-gray-500 dark:text-gray-400 group-hover:text-gray-700">View Profile</p>
                </div>
            </div>
            <a href="?page=logout" class="mt-4 block w-full text-center px-4 py-2 border border-transparent text-xs font-medium rounded text-red-700 bg-red-100 hover:bg-red-200 dark:bg-red-900 dark:text-red-100 dark:hover:bg-red-800">
                <?php echo __('logout'); ?>
            </a>
        </div>
    </aside>

    <!-- Main Content Wrapper -->
    <div class="flex-1 flex flex-col overflow-hidden relative">
        <!-- Top Header -->
        <header class="bg-white dark:bg-gray-800 shadow-sm z-10">
            <div class="px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-16">
                    <!-- Left: Mobile Menu Button -->
                    <div class="flex items-center lg:hidden">
                        <button id="mobile-menu-button" type="button" class="text-gray-500 hover:text-gray-700 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500">
                            <span class="sr-only">Open sidebar</span>
                            <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                            </svg>
                        </button>
                    </div>

                    <!-- Right: Actions -->
                    <div class="flex items-center justify-end w-full lg:w-auto space-x-4">
                        <!-- Language -->
                        <select onchange="window.location.href='?lang='+this.value + '&page=<?php echo htmlspecialchars($active_page); ?>'" class="bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 text-sm rounded-md focus:ring-primary-500 focus:border-primary-500 block p-1">
                            <option value="en" <?php echo ($lang_code == 'en') ? 'selected' : ''; ?>>EN</option>
                            <option value="sn" <?php echo ($lang_code == 'sn') ? 'selected' : ''; ?>>SN</option>
                            <option value="nd" <?php echo ($lang_code == 'nd') ? 'selected' : ''; ?>>ND</option>
                        </select>

                        <!-- Theme Toggle -->
                        <button id="theme-toggle" class="text-gray-500 hover:text-gray-700 dark:text-gray-300 dark:hover:text-white focus:outline-none p-1 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                            </svg>
                        </button>
                        
                        <!-- Notifications -->
                        <a href="?page=notifications" class="text-gray-500 hover:text-gray-700 dark:text-gray-300 dark:hover:text-white p-1 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 relative">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path></svg>
                        </a>
                        
                        <!-- WebSocket Status -->
                        <div id="websocket-status" class="flex items-center text-gray-600 text-sm ml-4">
                            <span class="w-2 h-2 bg-gray-500 rounded-full mr-2"></span>
                            Connecting...
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- Main Content Area (Scrollable) -->
        <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50 dark:bg-gray-900 p-6">
