<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$timesheets = [];
$res = call_api('/api/timesheets/');
if ($res['status'] === 200) {
    $timesheets = $res['data'];
}

$stats = [];
$resStats = call_api('/api/timesheets/stats');
if ($resStats['status'] === 200) {
    $stats = $resStats['data'];
}

$page_title = 'Labor & Timesheets - Begin Masimba';
$active_page = 'timesheets';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Total Hours Logged</dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white"><?php echo htmlspecialchars($stats['total_hours'] ?? 0); ?></dd>
            </div>
        </div>
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Pending Approvals</dt>
                <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white"><?php echo htmlspecialchars($stats['pending_approvals'] ?? 0); ?></dd>
            </div>
        </div>
    </div>

    <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Timesheets</h2>
        <button onclick="document.getElementById('logHoursModal').classList.remove('hidden')" class="bg-primary-600 text-white px-4 py-2 rounded hover:bg-primary-700 shadow-sm transition-colors">Log Hours</button>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-lg border border-gray-100 dark:border-gray-700">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Employee</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Date</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Hours</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Task</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Status</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                <?php if (empty($timesheets)): ?>
                    <tr><td colspan="6" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">No timesheets found.</td></tr>
                <?php else: ?>
                    <?php foreach ($timesheets as $sheet): ?>
                    <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($sheet['employee_name']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($sheet['date']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($sheet['hours_worked']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($sheet['task_description']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <?php
                                $statusClass = match($sheet['status']) {
                                    'Approved' => 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
                                    'Pending' => 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
                                    'Rejected' => 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
                                    default => 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
                                };
                            ?>
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full <?php echo $statusClass; ?>">
                                <?php echo htmlspecialchars($sheet['status']); ?>
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <?php if ($sheet['status'] === 'Pending'): ?>
                                <button onclick="updateStatus('<?php echo $sheet['id']; ?>', 'Approved')" class="text-green-600 hover:text-green-900 dark:text-green-400 dark:hover:text-green-300 mr-2">Approve</button>
                                <button onclick="updateStatus('<?php echo $sheet['id']; ?>', 'Rejected')" class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300">Reject</button>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</main>

<!-- Log Hours Modal -->
<div id="logHoursModal" class="fixed inset-0 z-50 hidden overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 backdrop-blur-sm transition-opacity" aria-hidden="true" onclick="document.getElementById('logHoursModal').classList.add('hidden')"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full border border-gray-100 dark:border-gray-700">
            <form id="logHoursForm">
                <div class="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                    <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white" id="modal-title">Log Hours</h3>
                    <div class="mt-4 space-y-4">
                        <div>
                            <label for="date" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Date</label>
                            <input type="date" name="date" id="date" required class="mt-1 focus:ring-primary-500 focus:border-primary-500 block w-full shadow-sm sm:text-sm border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md">
                        </div>
                        <div>
                            <label for="hours_worked" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Hours Worked</label>
                            <input type="number" step="0.5" name="hours_worked" id="hours_worked" required class="mt-1 focus:ring-primary-500 focus:border-primary-500 block w-full shadow-sm sm:text-sm border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md">
                        </div>
                        <div>
                            <label for="task_description" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Task Description</label>
                            <textarea name="task_description" id="task_description" rows="3" required class="mt-1 focus:ring-primary-500 focus:border-primary-500 block w-full shadow-sm sm:text-sm border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md"></textarea>
                        </div>
                    </div>
                </div>
                <div class="bg-gray-50 dark:bg-gray-700 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                    <button type="submit" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-primary-600 text-base font-medium text-white hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:ml-3 sm:w-auto sm:text-sm">Save</button>
                    <button type="button" onclick="document.getElementById('logHoursModal').classList.add('hidden')" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'X-API-Key': 'local-dev-key',
    'X-Tenant-ID': '1'
};

document.getElementById('logHoursForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const data = Object.fromEntries(formData.entries());
    
    try {
        const response = await fetch('/api/timesheets/log', {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            window.location.reload();
        } else {
            alert('Error logging hours');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to connect to server');
    }
});

async function updateStatus(id, status) {
    if (!confirm(`Are you sure you want to mark this timesheet as ${status}?`)) return;

    try {
        const response = await fetch(`/api/timesheets/${id}/status`, {
            method: 'PUT',
            headers: headers,
            body: JSON.stringify({ status: status })
        });
        
        if (response.ok) {
            window.location.reload();
        } else {
            alert('Error updating status');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to connect to server');
    }
}
</script>
<?php require __DIR__ . '/../components/footer.php'; ?>
