<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

// Include translation function
require_once __DIR__ . '/../lib/i18n.php';

// Fetch Batches
$batches = [];
$res = call_api('/api/livestock/', 'GET');
if ($res && $res['status'] === 200) $batches = $res['data'];

// Fetch Breeding Records
$breeding = [];
$res_breeding = call_api('/api/livestock/breeding', 'GET');
if ($res_breeding['status'] === 200) $breeding = $res_breeding['data'];

$page_title = __('livestock') . ' - Begin Masimba';
$active_page = 'livestock';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto">
    <div class="mb-8 flex justify-between items-end">
        <div>
            <h1 class="text-3xl font-bold text-gray-900 dark:text-white"><?php echo __('livestock'); ?> Management</h1>
            <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">Manage your herd, track breeding, and monitor events.</p>
        </div>
        <div class="space-x-2">
            <button onclick="openAddModal()" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm transition-colors flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                <?php echo __('add_batch'); ?>
            </button>
        </div>
    </div>

    <!-- Tabs -->
    <div class="mb-6 border-b border-gray-200 dark:border-gray-700">
        <ul class="flex flex-wrap -mb-px text-sm font-medium text-center" id="livestockTabs" role="tablist">
            <li class="mr-2" role="presentation">
                <button class="inline-block p-4 rounded-t-lg border-b-2 border-primary-600 text-primary-600 dark:text-primary-500" id="batches-tab" data-tabs-target="#batches" type="button" role="tab" aria-selected="true">Batches</button>
            </li>
            <li class="mr-2" role="presentation">
                <button class="inline-block p-4 rounded-t-lg border-b-2 border-transparent hover:text-gray-600 hover:border-gray-300 dark:hover:text-gray-300 transition-colors" id="breeding-tab" data-tabs-target="#breeding" type="button" role="tab" aria-selected="false">Breeding & Genealogy</button>
            </li>
        </ul>
    </div>

    <div id="livestockTabContent">
        <!-- Batches Tab -->
        <div class="" id="batches" role="tabpanel">
            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/50">
                        <tr>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400"><?php echo __('batch_id'); ?></th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400"><?php echo __('type'); ?></th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400"><?php echo __('quantity'); ?></th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400"><?php echo __('status'); ?></th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400"><?php echo __('actions'); ?></th>
                        </tr>
                    </thead>
                    <tbody id="batchesList" class="bg-white divide-y divide-gray-200 dark:bg-gray-800 dark:divide-gray-700">
                        <?php if (empty($batches)): ?>
                            <tr><td colspan="5" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400"><?php echo __('no_batches'); ?></td></tr>
                        <?php else: ?>
                            <?php foreach ($batches as $batch): ?>
                            <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($batch['name']); ?> <span class="text-xs text-gray-500 ml-1">(#<?php echo $batch['id']; ?>)</span></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($batch['type']); ?> - <?php echo htmlspecialchars($batch['breed'] ?? ''); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($batch['quantity']); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <span class="px-2.5 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800 dark:bg-green-900/50 dark:text-green-200 border border-green-200 dark:border-green-800">
                                        <?php echo htmlspecialchars($batch['status']); ?>
                                    </span>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                    <button onclick="openManageModal(<?php echo htmlspecialchars(json_encode($batch)); ?>)" class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300 font-semibold transition-colors">Manage</button>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Breeding Tab -->
        <div class="hidden" id="breeding" role="tabpanel">
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white">Breeding Records</h3>
                <button onclick="openAddBreedingModal()" class="bg-purple-600 text-white px-4 py-2 rounded-md hover:bg-purple-700 shadow-sm transition-colors">New Record</button>
            </div>
            <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Date</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Dam (Mother)</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Sire (Father)</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Exp. Birth</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Notes</th>
                        </tr>
                    </thead>
                    <tbody id="breedingList" class="bg-white divide-y divide-gray-200 dark:bg-gray-800 dark:divide-gray-700">
                        <?php foreach ($breeding as $rec): ?>
                        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($rec['breeding_date']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">Batch #<?php echo htmlspecialchars($rec['dam_batch_id']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">Batch #<?php echo htmlspecialchars($rec['sire_batch_id']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($rec['expected_birth_date'] ?? '-'); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($rec['notes'] ?? ''); ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Batch Modal -->
<div id="addModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add New Batch</h3>
        <form id="addBatchForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
                <input type="text" name="name" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Type</label>
                <select name="type" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option value="Cattle">Cattle</option>
                    <option value="Poultry">Poultry</option>
                    <option value="Sheep">Sheep</option>
                    <option value="Goats">Goats</option>
                    <option value="Pigs">Pigs</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Breed</label>
                <input type="text" name="breed" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Count</label>
                <input type="number" name="count" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Birth Date</label>
                <input type="date" name="birth_date" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeAddModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Add Breeding Modal -->
<div id="addBreedingModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">New Breeding Record</h3>
        <form id="addBreedingForm">
            <div class="grid grid-cols-2 gap-4 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Dam Batch ID</label>
                    <input type="number" name="dam_batch_id" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Sire Batch ID</label>
                    <input type="number" name="sire_batch_id" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Breeding Date</label>
                <input type="date" name="breeding_date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Expected Birth</label>
                <input type="date" name="expected_birth_date" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Notes</label>
                <textarea name="notes" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm"></textarea>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="document.getElementById('addBreedingModal').classList.add('hidden')" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Manage Batch Modal -->
<div id="manageModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-2xl w-full p-6 border border-gray-100 dark:border-gray-700">
        <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white" id="manageModalTitle">Manage Batch</h3>
            <button onclick="closeManageModal()" class="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        
        <div class="mb-4 border-b border-gray-200 dark:border-gray-700">
            <ul class="flex flex-wrap -mb-px text-sm font-medium text-center">
                <li class="mr-2">
                    <button onclick="switchManageTab('events')" id="tab-events" class="inline-block p-4 rounded-t-lg border-b-2 border-primary-600 text-primary-600 dark:text-primary-500">Events</button>
                </li>
                <li class="mr-2">
                    <button onclick="switchManageTab('log')" id="tab-log" class="inline-block p-4 rounded-t-lg border-b-2 border-transparent text-gray-500 hover:text-gray-600 dark:text-gray-400 dark:hover:text-gray-300">Log Event</button>
                </li>
            </ul>
        </div>

        <div id="content-events">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Date</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Type</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Description</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-400">Cost</th>
                    </tr>
                </thead>
                <tbody id="eventsList" class="bg-white divide-y divide-gray-200 dark:bg-gray-800 dark:divide-gray-700"></tbody>
            </table>
        </div>

        <div id="content-log" class="hidden">
            <form id="logEventForm">
                <input type="hidden" name="batch_id" id="logBatchId">
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Event Type</label>
                    <select name="event_type" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                        <option value="vaccination">Vaccination</option>
                        <option value="treatment">Treatment</option>
                        <option value="weight">Weight Check</option>
                        <option value="mortality">Mortality</option>
                        <option value="feeding">Feeding</option>
                        <option value="breeding">Breeding/Heat</option>
                    </select>
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Description</label>
                    <input type="text" name="description" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                </div>
                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                        <input type="date" name="date" required value="<?php echo date('Y-m-d'); ?>" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Cost ($)</label>
                        <input type="number" step="0.01" name="cost" value="0" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    </div>
                </div>
                <div class="flex justify-end space-x-3">
                    <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save Log</button>
                </div>
            </form>
        </div>

        <div id="content-lineage" class="hidden">
            <div class="text-center p-4">
                <h4 class="text-md font-semibold mb-4 dark:text-white">Family Tree</h4>
                <div id="genealogy-tree" class="flex flex-col items-center">
                    <!-- Tree injected via JS -->
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* Simple Tree CSS */
.genealogy-node {
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    background-color: #fff;
    margin: 5px;
    display: inline-block;
    min-width: 100px;
    text-align: center;
}
.dark .genealogy-node {
    background-color: #374151;
    border-color: #4b5563;
    color: #fff;
}
.connector {
    width: 2px;
    height: 20px;
    background-color: #ccc;
    margin: 0 auto;
}
.parent-row {
    display: flex;
    justify-content: center;
    gap: 20px;
    margin-bottom: 5px;
}
</style>

<script>
// Tab Switching
document.addEventListener('DOMContentLoaded', () => {
    const tabs = [
        { button: document.getElementById('batches-tab'), content: document.getElementById('batches') },
        { button: document.getElementById('breeding-tab'), content: document.getElementById('breeding') }
    ];

    function switchTab(targetContent) {
        tabs.forEach(t => {
            if (t.content === targetContent) {
                t.content.classList.remove('hidden');
                t.button.classList.add('border-blue-600', 'text-blue-600');
                t.button.classList.remove('border-transparent', 'text-gray-500');
            } else {
                t.content.classList.add('hidden');
                t.button.classList.remove('border-blue-600', 'text-blue-600');
                t.button.classList.add('border-transparent', 'text-gray-500');
            }
        });
    }

    tabs.forEach(t => {
        t.button.addEventListener('click', () => switchTab(t.content));
    });
});

function openAddModal() { document.getElementById('addModal').classList.remove('hidden'); }
function closeAddModal() { document.getElementById('addModal').classList.add('hidden'); }
function openAddBreedingModal() { document.getElementById('addBreedingModal').classList.remove('hidden'); }

let currentBatchId = null;

function openManageModal(batch) {
    currentBatchId = batch.id;
    document.getElementById('manageModalTitle').innerText = 'Manage: ' + batch.name;
    document.getElementById('logBatchId').value = batch.id;
    document.getElementById('manageModal').classList.remove('hidden');
    loadEvents(batch.id);
    switchManageTab('events');
}

function closeManageModal() { document.getElementById('manageModal').classList.add('hidden'); }

function switchManageTab(tab) {
    document.getElementById('content-events').classList.add('hidden');
    document.getElementById('content-log').classList.add('hidden');
    document.getElementById('content-lineage').classList.add('hidden');
    document.getElementById('tab-events').classList.remove('border-blue-600', 'text-blue-600');
    document.getElementById('tab-events').classList.add('border-transparent', 'text-gray-500');
    document.getElementById('tab-log').classList.remove('border-blue-600', 'text-blue-600');
    document.getElementById('tab-log').classList.add('border-transparent', 'text-gray-500');
    document.getElementById('tab-lineage').classList.remove('border-blue-600', 'text-blue-600');
    document.getElementById('tab-lineage').classList.add('border-transparent', 'text-gray-500');

    if (tab === 'events') {
        document.getElementById('content-events').classList.remove('hidden');
        document.getElementById('tab-events').classList.add('border-blue-600', 'text-blue-600');
        document.getElementById('tab-events').classList.remove('border-transparent', 'text-gray-500');
    } else if (tab === 'log') {
        document.getElementById('content-log').classList.remove('hidden');
        document.getElementById('tab-log').classList.add('border-blue-600', 'text-blue-600');
        document.getElementById('tab-log').classList.remove('border-transparent', 'text-gray-500');
    } else if (tab === 'lineage') {
        document.getElementById('content-lineage').classList.remove('hidden');
        document.getElementById('tab-lineage').classList.add('border-blue-600', 'text-blue-600');
        document.getElementById('tab-lineage').classList.remove('border-transparent', 'text-gray-500');
        if (currentBatchId) loadLineage(currentBatchId);
    }
}

// Helper to get headers with Auth
const token = "<?php echo $_SESSION['access_token'] ?? ''; ?>";
const API_BASE_URL = 'http://localhost:8000';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'x-api-key': 'begin-api-key',
    'X-Tenant-ID': '1'
};

function renderBatches(list) {
    const tbody = document.getElementById('batchesList');
    if (!tbody) return;
    if (!list || list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">No batches</td></tr>';
        return;
    }
    tbody.innerHTML = list.map(batch => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">${batch.name} <span class="text-xs text-gray-500 ml-1">(#${batch.id})</span></td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${batch.type} - ${batch.breed || ''}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${batch.count}</td>
            <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2.5 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800 dark:bg-green-900/50 dark:text-green-200 border border-green-200 dark:border-green-800">
                    ${batch.status}
                </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button onclick='openManageModal(${JSON.stringify({id: batch.id, name: batch.name})})' class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300 font-semibold transition-colors">Manage</button>
            </td>
        </tr>
    `).join('');
}

function renderBreeding(list) {
    const tbody = document.getElementById('breedingList');
    if (!tbody) return;
    if (!list || list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">No records</td></tr>';
        return;
    }
    tbody.innerHTML = list.map(rec => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">${rec.breeding_date}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">Batch #${rec.dam_batch_id}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">Batch #${rec.sire_batch_id}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${rec.expected_birth_date || '-'}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${rec.notes || ''}</td>
        </tr>
    `).join('');
}

document.addEventListener('DOMContentLoaded', async () => {
    try {
        const resBatches = await window.OfflineService.getCachedData('/livestock/', 'livestock_batches');
        if (resBatches && resBatches.data) renderBatches(resBatches.data);
        if (navigator.onLine) {
            const resp = await fetch(`${API_BASE_URL}/api/livestock/`, { headers });
            if (resp.ok) {
                const data = await resp.json();
                renderBatches(data);
                if (Array.isArray(data)) {
                    for (const it of data) await window.OfflineService.storeData('livestock_batches', it);
                }
            }
        }
    } catch (e) {}
    try {
        const resBreed = await window.OfflineService.getCachedData('/livestock/breeding', 'breeding_records');
        if (resBreed && resBreed.data) renderBreeding(resBreed.data);
        if (navigator.onLine) {
            const resp = await fetch(`${API_BASE_URL}/api/livestock/breeding`, { headers });
            if (resp.ok) {
                const data = await resp.json();
                renderBreeding(data);
                if (Array.isArray(data)) {
                    for (const it of data) await window.OfflineService.storeData('breeding_records', it);
                }
            }
        }
    } catch (e) {}
});

async function loadEvents(batchId) {
    const tbody = document.getElementById('eventsList');
    tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-4 text-center">Loading...</td></tr>';
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/livestock/${batchId}/events`, { headers });
        const events = await response.json();
        
        tbody.innerHTML = '';
        if (events.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-4 text-center text-gray-500">No events recorded.</td></tr>';
        } else {
            events.forEach(e => {
                tbody.innerHTML += `
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">${e.date}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">${e.event_type}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">${e.description}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">$${e.cost || 0}</td>
                    </tr>
                `;
            });
        }
    } catch (err) {
        tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-4 text-center text-red-500">Error loading events.</td></tr>';
        console.error(err);
    }
}

async function fetchBatch(id) {
    if (!id) return null;
    try {
        const res = await fetch(`${API_BASE_URL}/api/livestock/${id}`, { headers });
        if (res.ok) return await res.json();
    } catch (e) { console.error(e); }
    return null;
}

async function loadLineage(batchId) {
    const container = document.getElementById('genealogy-tree');
    container.innerHTML = '<p class="text-gray-500">Loading tree...</p>';
    
    const self = await fetchBatch(batchId);
    if (!self) {
        container.innerHTML = '<p class="text-red-500">Error loading batch.</p>';
        return;
    }

    const [sire, dam] = await Promise.all([
        fetchBatch(self.sire_id),
        fetchBatch(self.dam_id)
    ]);

    const [sireSire, sireDam, damSire, damDam] = await Promise.all([
        fetchBatch(sire?.sire_id),
        fetchBatch(sire?.dam_id),
        fetchBatch(dam?.sire_id),
        fetchBatch(dam?.dam_id)
    ]);

    let html = '';
    
    const renderNode = (b, label) => {
        if (!b) return `<div class="genealogy-node opacity-50"><div class="text-xs text-gray-500">${label}</div>Unknown</div>`;
        // Pass partial object to openManageModal - ensure it works
        const safeName = b.name.replace(/'/g, "\\'");
        return `<div class="genealogy-node cursor-pointer hover:shadow-md" onclick="openManageModal({id: ${b.id}, name: '${safeName}'})">
                    <div class="text-xs text-gray-500 dark:text-gray-400">${label}</div>
                    <div class="font-bold text-gray-900 dark:text-white">${b.name}</div>
                    <div class="text-xs text-gray-500 dark:text-gray-400">#${b.id}</div>
                </div>`;
    };

    // Grandparents
    html += '<div class="parent-row">';
    html += renderNode(sireSire, 'Grand Sire (F)');
    html += renderNode(sireDam, 'Grand Dam (F)');
    html += '<div style="width: 20px;"></div>'; // Spacer
    html += renderNode(damSire, 'Grand Sire (M)');
    html += renderNode(damDam, 'Grand Dam (M)');
    html += '</div>';

    // Parents
    html += '<div class="parent-row">';
    html += '<div style="flex: 1; text-align: center;">';
    html += renderNode(sire, 'Sire (Father)');
    html += '</div>';
    html += '<div style="flex: 1; text-align: center;">';
    html += renderNode(dam, 'Dam (Mother)');
    html += '</div>';
    html += '</div>';

    html += '<div class="connector"></div>';

    // Self
    html += '<div class="parent-row">';
    html += renderNode(self, 'Self');
    html += '</div>';

    container.innerHTML = html;
}

// API Post Helper
async function postData(url, data) {
    try {
        const res = await fetch(`${API_BASE_URL}${url}`, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(data)
        });
        if (res.ok) {
            window.location.reload();
        } else {
            let message = 'Operation failed';
            try {
                const err = await res.json();
                if (err && err.detail) {
                    if (Array.isArray(err.detail) && err.detail.length > 0 && err.detail[0].msg) {
                        message = err.detail[0].msg;
                    } else if (typeof err.detail === 'string') {
                        message = err.detail;
                    }
                }
            } catch (parseError) {}
            alert(message);
            if (res.status === 401 || res.status === 403) {
                window.location.href = '../public/index.php?page=login';
            }
        }
    } catch (err) {
        console.error(err);
        alert('Error occurred');
    }
}

document.getElementById('addBatchForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.count = parseInt(data.count);
    if (navigator.onLine) {
        postData('/api/livestock/', data);
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/livestock/',
            method: 'POST',
            data
        });
        closeAddModal();
        alert('Queued for sync');
    }
});

document.getElementById('logEventForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.batch_id = parseInt(data.batch_id);
    data.cost = parseFloat(data.cost);
    if (navigator.onLine) {
        postData('/api/livestock/events', data);
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/livestock/events',
            method: 'POST',
            data
        });
        alert('Queued for sync');
    }
});

document.getElementById('addBreedingForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.dam_batch_id = parseInt(data.dam_batch_id);
    data.sire_batch_id = parseInt(data.sire_batch_id);
    if (navigator.onLine) {
        postData('/api/livestock/breeding', data);
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/livestock/breeding',
            method: 'POST',
            data
        });
        alert('Queued for sync');
    }
});
</script>

<?php require __DIR__ . '/../components/footer.php'; ?>
