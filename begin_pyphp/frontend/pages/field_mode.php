<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}
require_once __DIR__ . '/../lib/i18n.php';
$page_title = __('field_worker_mode');
$active_page = 'field_mode';
include __DIR__ . '/../components/header.php';
?>
<div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
  <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-6"><?php echo __('field_worker_mode'); ?></h1>
  <div class="grid grid-cols-2 gap-4 sm:grid-cols-3">
    <a class="flex items-center justify-center px-4 py-6 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm font-medium shadow-sm hover:shadow-md transition-shadow" href="?page=tasks">📋 <?php echo __('my_tasks'); ?></a>
    <a class="flex items-center justify-center px-4 py-6 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm font-medium shadow-sm hover:shadow-md transition-shadow" href="?page=equipment">📷 <?php echo __('scan_qr'); ?></a>
    <a class="flex items-center justify-center px-4 py-6 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm font-medium shadow-sm hover:shadow-md transition-shadow" href="?page=scouting">🐛 <?php echo __('scout_crop'); ?></a>
    <a class="flex items-center justify-center px-4 py-6 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm font-medium shadow-sm hover:shadow-md transition-shadow" href="?page=reports">🌾 <?php echo __('log_harvest'); ?></a>
    <a class="flex items-center justify-center px-4 py-6 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm font-medium shadow-sm hover:shadow-md transition-shadow" href="?page=fields">🗺️ <?php echo __('map_view'); ?></a>
    <a class="flex items-center justify-center px-4 py-6 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm font-medium shadow-sm hover:shadow-md transition-shadow" href="?page=notifications">🆘 <?php echo __('emergency'); ?></a>
  </div>

  <div class="mt-8 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-4 shadow-sm">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2"><?php echo __('offline_status'); ?></h3>
    <div id="offline-status" class="space-y-2 text-sm text-gray-700 dark:text-gray-300">
      <div>
        <span class="font-medium"><?php echo __('connection'); ?>:</span>
        <span id="conn-state" class="ml-1">...</span>
      </div>
      <div>
        <span class="font-medium"><?php echo __('last_sync'); ?>:</span>
        <span id="last-sync" class="ml-1">-</span>
      </div>
      <div>
        <span class="font-medium"><?php echo __('pending_sync'); ?>:</span>
        <span id="pending-sync" class="ml-1">0</span>
      </div>
      <button id="sync-now" class="mt-2 inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
        <?php echo __('sync_now'); ?>
      </button>
    </div>
  </div>
</div>
<script src="/farmos/begin_pyphp/frontend/public/js/offline.service.js"></script>
<script>
  function updateStatusUI(s) {
    document.getElementById('conn-state').textContent = s.isOnline ? 'Online' : 'Offline';
    document.getElementById('last-sync').textContent = s.lastSyncTime ? new Date(s.lastSyncTime).toLocaleString() : 'Never';
    document.getElementById('pending-sync').textContent = s.pendingSyncCount || 0;
  }
  window.addEventListener('load', async () => {
    const s = await window.OfflineService.getOfflineStatus();
    updateStatusUI(s);
    window.addEventListener('online', async () => updateStatusUI(await window.OfflineService.getOfflineStatus()));
    window.addEventListener('offline', async () => updateStatusUI(await window.OfflineService.getOfflineStatus()));
    document.getElementById('sync-now').addEventListener('click', async () => {
      try {
        await window.OfflineService.forceSync();
        updateStatusUI(await window.OfflineService.getOfflineStatus());
      } catch (e) {
        alert('Sync failed');
      }
    });
  });
</script>
<?php include __DIR__ . '/../components/footer.php'; ?>
