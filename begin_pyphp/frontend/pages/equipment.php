<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$equipment = [];
$res = call_api('/api/equipment/');
if ($res['status'] === 200) {
    $equipment = $res['data'];
}

$page_title = 'Equipment - Begin Masimba';
$active_page = 'equipment';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto">
    <div class="flex flex-col sm:flex-row justify-between items-center mb-6 gap-4">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Equipment Management</h2>
        <button onclick="document.getElementById('addEquipmentModal').classList.remove('hidden')" class="w-full sm:w-auto bg-primary-600 text-white px-4 py-2 rounded-xl hover:bg-primary-700 shadow-sm transition-colors flex items-center justify-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
            Add Equipment
        </button>
    </div>

    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <?php if (empty($equipment)): ?>
            <div class="col-span-full flex flex-col items-center justify-center py-12 px-4 text-center bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <div class="bg-gray-100 dark:bg-gray-700 rounded-full p-4 mb-4">
                    <svg class="w-8 h-8 text-gray-400 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.384-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"></path></svg>
                </div>
                <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-1">No equipment found</h3>
                <p class="text-gray-500 dark:text-gray-400 mb-6 max-w-sm">Get started by adding your tractors, harvesters, and other machinery to track maintenance and usage.</p>
                <button onclick="document.getElementById('addEquipmentModal').classList.remove('hidden')" class="text-primary-600 hover:text-primary-700 dark:text-primary-500 font-medium flex items-center gap-2">
                    Add your first equipment
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"></path></svg>
                </button>
            </div>
        <?php else: ?>
            <?php foreach ($equipment as $item): ?>
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm hover:shadow-md transition-shadow rounded-xl border border-gray-100 dark:border-gray-700 flex flex-col h-full">
                <div class="p-6 flex-1">
                    <div class="flex justify-between items-start mb-4">
                        <div>
                            <h3 class="text-lg font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($item['name']); ?></h3>
                            <p class="text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($item['type']); ?></p>
                        </div>
                        <span class="px-2.5 py-0.5 text-xs font-semibold rounded-full <?php echo $item['status'] === 'Operational' ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'; ?>">
                            <?php echo htmlspecialchars($item['status']); ?>
                        </span>
                    </div>
                    <div class="space-y-2">
                        <div class="flex items-center text-sm text-gray-600 dark:text-gray-300">
                            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                            Purchased: <?php echo htmlspecialchars($item['purchase_date']); ?>
                        </div>
                    </div>
                </div>
                <div class="bg-gray-50 dark:bg-gray-700/30 px-6 py-3 border-t border-gray-100 dark:border-gray-700 flex justify-between items-center">
                    <button class="text-sm font-medium text-primary-600 hover:text-primary-700 dark:text-primary-500 transition-colors">View Details</button>
                    <button class="text-sm font-medium text-gray-600 hover:text-gray-800 dark:text-gray-400 dark:hover:text-gray-200 transition-colors">Maintenance Logs</button>
                </div>
            </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
</div>

<!-- Add Equipment Modal -->
<div id="addEquipmentModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white" id="modal-title">Add Equipment</h3>
            <button onclick="document.getElementById('addEquipmentModal').classList.add('hidden')" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <form id="addEquipmentForm">
            <div class="space-y-4">
                <div>
                    <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Equipment Name</label>
                    <input type="text" name="name" id="name" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                <div>
                    <label for="type" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Type</label>
                    <select name="type" id="type" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                        <option>Tractor</option>
                        <option>Harvester</option>
                        <option>Plow</option>
                        <option>Seeder</option>
                        <option>Irrigation Pump</option>
                        <option>Vehicle</option>
                        <option>Tool</option>
                    </select>
                </div>
                <div>
                    <label for="purchase_date" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Purchase Date</label>
                    <input type="date" name="purchase_date" id="purchase_date" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                <div>
                    <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Status</label>
                    <select name="status" id="status" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                        <option value="Operational">Operational</option>
                        <option value="Maintenance">Maintenance</option>
                        <option value="Broken">Broken</option>
                        <option value="Sold">Sold</option>
                    </select>
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-3">
                <button type="button" onclick="document.getElementById('addEquipmentModal').classList.add('hidden')" class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors">Cancel</button>
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-primary-600 border border-transparent rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 shadow-sm transition-colors">Save Equipment</button>
            </div>
        </form>
    </div>
</div>

<script>
const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
const API_BASE_URL = 'http://localhost:8000';
const API_KEY = '<?php echo getenv('API_KEY') ?: 'local-dev-key'; ?>';
const TENANT_ID = '<?php echo getenv('TENANT_ID') ?: '1'; ?>';

const headers = {
    'Content-Type': 'application/json',
    'x-api-key': API_KEY,
    'X-Tenant-ID': TENANT_ID
};
if (token) {
    headers['Authorization'] = `Bearer ${token}`;
}

document.getElementById('addEquipmentForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    const data = Object.fromEntries(formData.entries());
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/equipment`, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(data)
        });

        if (response.ok) {
            window.location.reload();
        } else {
            console.error('Failed to add equipment');
            let message = 'Failed to add equipment. Please try again.';
            try {
                const err = await response.json();
                if (err && err.detail) {
                    if (Array.isArray(err.detail) && err.detail.length > 0 && err.detail[0].msg) {
                        message = err.detail[0].msg;
                    } else if (typeof err.detail === 'string') {
                        message = err.detail;
                    }
                }
            } catch (e) {}
            alert(message);
            if (response.status === 401 || response.status === 403) {
                window.location.href = '../public/index.php?page=login';
            }
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred. Please try again.');
    }
});
</script>

<?php require __DIR__ . '/../components/footer.php'; ?>
