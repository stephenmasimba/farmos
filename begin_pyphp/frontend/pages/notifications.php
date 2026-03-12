<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$notifications = [];
$res = call_api('/api/notifications/');
if ($res['status'] === 200) {
    $notifications = $res['data'];
}

$page_title = 'Notifications - Begin Masimba';
$active_page = 'notifications';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Notifications</h2>
        <button id="markAllReadBtn" class="text-sm text-primary-600 hover:text-primary-800 dark:text-primary-400 dark:hover:text-primary-300 font-medium">Mark all as read</button>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-md border border-gray-200 dark:border-gray-700">
        <ul role="list" class="divide-y divide-gray-200 dark:divide-gray-700" id="notificationList">
            <?php if (empty($notifications)): ?>
                <li class="px-4 py-4 sm:px-6 text-center text-gray-500 dark:text-gray-400">No notifications.</li>
            <?php else: ?>
                <?php foreach ($notifications as $notification): ?>
                <li class="px-4 py-4 sm:px-6 hover:bg-gray-50 dark:hover:bg-gray-700 <?php echo $notification['read'] ? 'bg-gray-50 dark:bg-gray-900' : 'bg-white dark:bg-gray-800'; ?>" data-id="<?php echo $notification['id']; ?>">
                    <div class="flex items-center justify-between">
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center">
                                <?php if ($notification['type'] === 'warning'): ?>
                                    <span class="flex-shrink-0 h-2.5 w-2.5 rounded-full bg-red-400" aria-hidden="true"></span>
                                <?php elseif ($notification['type'] === 'success'): ?>
                                    <span class="flex-shrink-0 h-2.5 w-2.5 rounded-full bg-green-400" aria-hidden="true"></span>
                                <?php else: ?>
                                    <span class="flex-shrink-0 h-2.5 w-2.5 rounded-full bg-blue-400" aria-hidden="true"></span>
                                <?php endif; ?>
                                <p class="ml-2 text-sm font-medium text-primary-600 dark:text-primary-400 truncate"><?php echo htmlspecialchars($notification['message']); ?></p>
                            </div>
                            <div class="mt-2 flex">
                                <p class="text-xs text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($notification['timestamp']); ?></p>
                            </div>
                        </div>
                        <?php if (!$notification['read']): ?>
                        <div class="ml-4 flex-shrink-0">
                            <button class="mark-read-btn font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300 text-sm">Mark read</button>
                        </div>
                        <?php endif; ?>
                    </div>
                </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
    </div>
</main>

<script>
    const API_BASE_URL = 'http://localhost:8000';
    const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
    
    // Centralized API headers
    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'X-API-Key': 'local-dev-key',
        'X-Tenant-ID': '1'
    };

    document.getElementById('markAllReadBtn').addEventListener('click', async () => {
        try {
            const response = await fetch(`${API_BASE_URL}/api/notifications/mark-all-read`, {
                method: 'POST',
                headers: headers
            });
            if (response.ok) {
                window.location.reload();
            } else {
                alert('Failed to mark all as read');
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred');
        }
    });

    document.querySelectorAll('.mark-read-btn').forEach(btn => {
        btn.addEventListener('click', async (e) => {
            const li = e.target.closest('li');
            const id = li.dataset.id;
            try {
                const response = await fetch(`${API_BASE_URL}/api/notifications/${id}/mark-read`, {
                    method: 'POST',
                    headers: headers
                });
                if (response.ok) {
                    window.location.reload();
                } else {
                    alert('Failed to mark as read');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred');
            }
        });
    });
</script>
</body>
</html>
