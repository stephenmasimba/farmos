<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$scans_res = call_api('/api/qr/history', 'GET');
$scans_data = $scans_res['data'] ?? [];
$scans = [];
if (is_array($scans_data)) {
    foreach ($scans_data as $item) {
        if (is_array($item)) {
            $scans[] = $item;
        }
    }
}

$page_title = 'QR Inventory - Begin Masimba';
$active_page = 'qr_inventory';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">QR Inventory & Assets</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Mobile scanning for stock movements and equipment tracking</p>
        </div>
        <div class="flex space-x-3">
            <button class="bg-primary-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-primary-700 flex items-center">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" />
                </svg>
                Generate QR Codes
            </button>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Scanner Simulation/Instructions -->
        <div class="lg:col-span-1 space-y-6">
            <div class="bg-gray-900 rounded-2xl p-8 text-white aspect-[3/4] flex flex-col items-center justify-center relative overflow-hidden shadow-2xl">
                <div class="absolute inset-0 border-[20px] border-white/5 pointer-events-none"></div>
                <div class="w-48 h-48 border-2 border-primary-500 rounded-2xl flex items-center justify-center relative">
                    <div class="absolute inset-0 bg-primary-500/10 animate-pulse"></div>
                    <svg class="w-24 h-24 text-primary-500 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" />
                    </svg>
                    <!-- Scanning line animation -->
                    <div class="absolute top-0 left-0 w-full h-0.5 bg-primary-400 shadow-[0_0_15px_rgba(74,222,128,0.8)] animate-[scan_2s_infinite]"></div>
                </div>
                <h4 class="mt-8 font-bold text-lg text-center">Mobile Scanner Active</h4>
                <p class="text-xs text-white/60 text-center mt-2 px-4">Point your mobile camera at a Begin Masimba QR code to perform instant actions.</p>
                <button class="mt-8 w-full bg-white text-gray-900 py-3 rounded-xl font-bold hover:bg-gray-100 transition-colors">
                    Open Camera
                </button>
            </div>

            <style>
                @keyframes scan {
                    0% { top: 0; }
                    100% { top: 100%; }
                }
            </style>
        </div>

        <!-- Recent Scan History -->
        <div class="lg:col-span-2 space-y-6">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Recent Scan Activity</h3>
            <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/30">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Item / Asset</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Action</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Details</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Time</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($scans as $scan): ?>
                        <?php
                            $itemType = isset($scan['item_type']) ? $scan['item_type'] : (isset($scan['scan_type']) ? $scan['scan_type'] : 'unknown');
                            $itemId = isset($scan['item_id']) ? $scan['item_id'] : (isset($scan['batch_id']) ? $scan['batch_id'] : null);
                            $action = isset($scan['scan_type']) ? $scan['scan_type'] : (isset($scan['action']) ? $scan['action'] : 'scan');
                            $timestamp = isset($scan['timestamp']) ? $scan['timestamp'] : (isset($scan['scan_time']) ? $scan['scan_time'] : null);
                            $userId = isset($scan['user_id']) ? $scan['user_id'] : (isset($scan['performed_by']) ? $scan['performed_by'] : null);
                        ?>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="flex items-center">
                                    <div class="w-8 h-8 rounded bg-gray-100 dark:bg-gray-700 flex items-center justify-center mr-3 text-xs font-bold text-gray-500">
                                        <?php echo strtoupper(substr((string)$itemType, 0, 1)); ?>
                                    </div>
                                    <div>
                                        <div class="text-sm font-medium text-gray-900 dark:text-white">
                                            <?php 
                                                if ($itemId !== null) {
                                                    echo htmlspecialchars('Item #' . $itemId);
                                                } else {
                                                    echo 'QR Scan';
                                                }
                                            ?>
                                        </div>
                                        <div class="text-[10px] text-gray-500 uppercase"><?php echo htmlspecialchars((string)$itemType); ?></div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <?php
                                    $isStockOut = is_string($action) && strtoupper($action) === 'STOCK_OUT';
                                    $badgeClass = $isStockOut ? 'bg-amber-100 text-amber-800' : 'bg-blue-100 text-blue-800';
                                ?>
                                <span class="px-2 py-1 text-[10px] font-bold rounded <?php echo $badgeClass; ?>">
                                    <?php echo htmlspecialchars(str_replace('_', ' ', (string)$action)); ?>
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                <?php if (isset($scan['quantity'])): ?>
                                    <?php echo htmlspecialchars((string)$scan['quantity']); ?> <?php echo htmlspecialchars((string)($scan['unit'] ?? '')); ?>
                                <?php elseif (isset($scan['status'])): ?>
                                    Status: <?php echo htmlspecialchars((string)$scan['status']); ?>
                                <?php elseif ($itemId !== null): ?>
                                    ID: <?php echo htmlspecialchars((string)$itemId); ?>
                                <?php else: ?>
                                    -
                                <?php endif; ?>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-xs text-gray-500">
                                <?php
                                    $timeStr = '-';
                                    if ($timestamp) {
                                        $ts = strtotime($timestamp);
                                        if ($ts !== false) {
                                            $timeStr = date('H:i', $ts);
                                        }
                                    }
                                ?>
                                <?php echo $timeStr; ?>
                                <span class="block text-[10px] opacity-60">
                                    by
                                    <?php
                                        if ($userId === null) {
                                            echo 'System';
                                        } elseif (is_numeric($userId)) {
                                            echo 'User #' . htmlspecialchars((string)$userId);
                                        } else {
                                            echo htmlspecialchars((string)$userId);
                                        }
                                    ?>
                                </span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <!-- Printing Tools -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="bg-white dark:bg-gray-800 p-6 rounded-xl border border-gray-100 dark:border-gray-700">
                    <h4 class="font-bold text-gray-900 dark:text-white mb-2">Bulk Label Export</h4>
                    <p class="text-xs text-gray-500 mb-4">Export all new inventory items to a 4x6 label PDF for thermal printing.</p>
                    <button class="text-sm font-bold text-primary-600 hover:text-primary-700">Prepare Print Job →</button>
                </div>
                <div class="bg-white dark:bg-gray-800 p-6 rounded-xl border border-gray-100 dark:border-gray-700">
                    <h4 class="font-bold text-gray-900 dark:text-white mb-2">QR API Access</h4>
                    <p class="text-xs text-gray-500 mb-4">Integrate 3rd party scanners using our secure QR data endpoints.</p>
                    <button class="text-sm font-bold text-primary-600 hover:text-primary-700">View Documentation →</button>
                </div>
            </div>
        </div>
    </div>
</div>
