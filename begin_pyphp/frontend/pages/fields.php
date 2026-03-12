<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$fields = [];
$res = call_api('/api/fields/');
if ($res['status'] === 200) {
    $fields = $res['data'];
}

$page_title = 'Fields - Begin Masimba';
$active_page = 'fields';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto">
    <div class="flex justify-between items-center mb-6">
        <div>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Fields Management</h2>
            <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">Monitor and manage your field operations.</p>
        </div>
        <button onclick="openAddFieldModal()" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm transition-colors flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
            Add Field
        </button>
    </div>

    <div id="fieldsGrid" class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <?php if (empty($fields)): ?>
            <div class="col-span-full text-center py-12 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-white">No fields found</h3>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Get started by creating a new field.</p>
                <div class="mt-6">
                    <button onclick="openAddFieldModal()" class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
                        <svg class="-ml-1 mr-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                        Add Field
                    </button>
                </div>
            </div>
        <?php else: ?>
            <?php foreach ($fields as $field): ?>
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 hover:shadow-md transition-shadow">
                <div class="px-4 py-5 sm:p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($field['name']); ?></h3>
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <?php echo $field['status'] === 'Active' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'; ?>">
                            <?php echo htmlspecialchars($field['status']); ?>
                        </span>
                    </div>
                    <div class="mt-2 space-y-2 text-sm text-gray-500 dark:text-gray-400">
                        <div class="flex justify-between">
                            <span>Area:</span>
                            <span class="font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($field['area']); ?> acres</span>
                        </div>
                        <div class="flex justify-between">
                            <span>Current Crop:</span>
                            <span class="font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($field['crop'] ?? 'None'); ?></span>
                        </div>
                    </div>
                    <button onclick='openManageFieldModal(<?php echo json_encode($field); ?>)' class="mt-6 w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-white px-4 py-2 rounded-md hover:bg-gray-50 dark:hover:bg-gray-600 transition-colors text-sm font-medium shadow-sm">
                        Manage Details
                    </button>
                </div>
            </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
</div>

<!-- Add Field Modal -->
<div id="addFieldModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add New Field</h3>
        <form id="addFieldForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Field Name</label>
                <input type="text" name="name" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Area (acres)</label>
                <input type="number" step="0.1" name="area" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Current Crop</label>
                <input type="text" name="crop" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-6">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Status</label>
                <select name="status" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option value="Active">Active</option>
                    <option value="Fallow">Fallow</option>
                    <option value="Inactive">Inactive</option>
                </select>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeAddFieldModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save Field</button>
            </div>
        </form>
    </div>
</div>

<!-- Manage Field Modal -->
<div id="manageFieldModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="relative w-full max-w-4xl mx-auto p-4">
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl border border-gray-100 dark:border-gray-700 flex flex-col max-h-[90vh]">
            <div class="flex justify-between items-center p-6 border-b border-gray-200 dark:border-gray-700">
                <h3 id="modalFieldName" class="text-xl font-bold text-gray-900 dark:text-white">Manage Field</h3>
                <button onclick="closeManageFieldModal()" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                    <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>
            
            <!-- Tabs -->
            <div class="border-b border-gray-200 dark:border-gray-700">
                <nav class="-mb-px flex space-x-8 px-6" aria-label="Tabs" id="fieldTabs">
                    <button role="tab" class="border-primary-500 text-primary-600 dark:text-primary-400 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" id="history-tab" data-tabs-target="#history">History</button>
                    <button role="tab" class="border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" id="soil-tab" data-tabs-target="#soil">Soil Health</button>
                    <button role="tab" class="border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" id="harvest-tab" data-tabs-target="#harvest">Harvest</button>
                    <button role="tab" class="border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" id="rotation-tab" data-tabs-target="#rotation">Rotation</button>
                </nav>
            </div>

            <!-- Tab Content -->
            <div class="p-6 overflow-y-auto" id="fieldTabContent">
                <!-- History Tab -->
                <div class="space-y-4" id="history" role="tabpanel">
                    <div class="flex justify-between items-center">
                        <h4 class="text-lg font-medium text-gray-900 dark:text-white">Field History</h4>
                        <button onclick="openAddHistoryModal()" class="bg-primary-600 text-white px-3 py-1.5 rounded-md text-sm hover:bg-primary-700 shadow-sm">Add Event</button>
                    </div>
                    <ul id="historyList" class="divide-y divide-gray-200 dark:divide-gray-700">
                        <li class="py-3 text-sm text-gray-500 dark:text-gray-400">Loading...</li>
                    </ul>
                </div>

                <!-- Soil Tab -->
                <div class="hidden space-y-4" id="soil" role="tabpanel">
                    <div class="flex justify-between items-center">
                        <h4 class="text-lg font-medium text-gray-900 dark:text-white">Soil Health Logs</h4>
                        <button onclick="openAddSoilModal()" class="bg-primary-600 text-white px-3 py-1.5 rounded-md text-sm hover:bg-primary-700 shadow-sm">Log Soil Data</button>
                    </div>
                    <ul id="soilList" class="divide-y divide-gray-200 dark:divide-gray-700">
                        <li class="py-3 text-sm text-gray-500 dark:text-gray-400">Loading...</li>
                    </ul>
                </div>

                <!-- Harvest Tab -->
                <div class="hidden space-y-4" id="harvest" role="tabpanel">
                    <div class="flex justify-between items-center">
                        <h4 class="text-lg font-medium text-gray-900 dark:text-white">Harvest Logs</h4>
                        <button onclick="openAddHarvestModal()" class="bg-primary-600 text-white px-3 py-1.5 rounded-md text-sm hover:bg-primary-700 shadow-sm">Log Harvest</button>
                    </div>
                    <ul id="harvestList" class="divide-y divide-gray-200 dark:divide-gray-700">
                        <li class="py-3 text-sm text-gray-500 dark:text-gray-400">Loading...</li>
                    </ul>
                </div>

                <!-- Rotation Tab -->
                <div class="hidden space-y-4" id="rotation" role="tabpanel">
                    <div class="flex justify-between items-center">
                        <h4 class="text-lg font-medium text-gray-900 dark:text-white">Rotation Plan (4-Year)</h4>
                        <button onclick="openAddRotationModal()" class="bg-primary-600 text-white px-3 py-1.5 rounded-md text-sm hover:bg-primary-700 shadow-sm">Add Plan</button>
                    </div>
                    <ul id="rotationList" class="divide-y divide-gray-200 dark:divide-gray-700">
                        <li class="py-3 text-sm text-gray-500 dark:text-gray-400">Loading...</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add History Modal (Nested) -->
<div id="addHistoryModal" class="fixed inset-0 z-[60] hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-sm w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add History Event</h3>
        <form id="addHistoryForm">
            <input type="hidden" name="field_id" id="historyFieldId">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                <input type="date" name="date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Action</label>
                <input type="text" name="action" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Details</label>
                <textarea name="details" required rows="3" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm"></textarea>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="document.getElementById('addHistoryModal').classList.add('hidden')" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Add Soil Modal -->
<div id="addSoilModal" class="fixed inset-0 z-[60] hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-sm w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Log Soil Health</h3>
        <form id="addSoilForm">
            <input type="hidden" name="field_id" id="soilFieldId">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                <input type="date" name="date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Organic Matter (%)</label>
                <input type="number" step="0.1" name="organic_matter_percent" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">pH</label>
                <input type="number" step="0.1" name="ph" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Notes</label>
                <input type="text" name="notes" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="document.getElementById('addSoilModal').classList.add('hidden')" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Add Harvest Modal -->
<div id="addHarvestModal" class="fixed inset-0 z-[60] hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-sm w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Log Harvest</h3>
        <form id="addHarvestForm">
            <input type="hidden" name="field_id" id="harvestFieldId">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                <input type="date" name="date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Crop</label>
                <input type="text" name="crop" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Yield</label>
                <input type="number" step="0.1" name="yield_amount" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Unit</label>
                <input type="text" name="unit" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm" placeholder="kg, tons">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Target Yield</label>
                <input type="number" step="0.1" name="target_yield" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="document.getElementById('addHarvestModal').classList.add('hidden')" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Add Rotation Modal -->
<div id="addRotationModal" class="fixed inset-0 z-[60] hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-sm w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add Rotation Plan</h3>
        <form id="addRotationForm">
            <input type="hidden" name="field_id" id="rotationFieldId">
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Year</label>
                <input type="number" name="year" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm" value="<?php echo date('Y'); ?>">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Season</label>
                <input type="text" name="season" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm" placeholder="e.g. Summer, Winter">
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Planned Crop</label>
                <input type="text" name="planned_crop" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Notes</label>
                <textarea name="notes" rows="3" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm"></textarea>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="document.getElementById('addRotationModal').classList.add('hidden')" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<script>
let currentFieldId = null;
const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
const API_BASE_URL = 'http://localhost:8000';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'x-api-key': 'begin-api-key',
    'X-Tenant-ID': '1'
};

function openAddFieldModal() { document.getElementById('addFieldModal').classList.remove('hidden'); }
function closeAddFieldModal() { document.getElementById('addFieldModal').classList.add('hidden'); }

function openManageFieldModal(field) {
    currentFieldId = field.id;
    document.getElementById('modalFieldName').innerText = field.name;
    document.getElementById('manageFieldModal').classList.remove('hidden');
    document.getElementById('historyFieldId').value = field.id;
    document.getElementById('soilFieldId').value = field.id;
    document.getElementById('harvestFieldId').value = field.id;
    document.getElementById('rotationFieldId').value = field.id;
    
    fetchFieldData(field.id);
}

function closeManageFieldModal() {
    document.getElementById('manageFieldModal').classList.add('hidden');
}

function renderFields(list) {
    const grid = document.getElementById('fieldsGrid');
    if (!grid) return;
    if (!list || list.length === 0) {
        grid.innerHTML = `<div class="col-span-full text-center py-12 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-white">No fields found</h3>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Get started by creating a new field.</p>
        </div>`;
        return;
    }
    grid.innerHTML = list.map(field => `
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 hover:shadow-md transition-shadow">
            <div class="px-4 py-5 sm:p-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">${field.name}</h3>
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${field.status === 'Active' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'}">
                        ${field.status}
                    </span>
                </div>
                <div class="mt-2 space-y-2 text-sm text-gray-500 dark:text-gray-400">
                    <div class="flex justify-between">
                        <span>Area:</span>
                        <span class="font-medium text-gray-900 dark:text-white">${field.area} acres</span>
                    </div>
                    <div class="flex justify-between">
                        <span>Current Crop:</span>
                        <span class="font-medium text-gray-900 dark:text-white">${field.crop || 'None'}</span>
                    </div>
                </div>
                <button onclick='openManageFieldModal(${JSON.stringify({id: field.id, name: field.name})})' class="mt-6 w-full bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-white px-4 py-2 rounded-md hover:bg-gray-50 dark:hover:bg-gray-600 transition-colors text-sm font-medium shadow-sm">
                    Manage Details
                </button>
            </div>
        </div>
    `).join('');
}

document.addEventListener('DOMContentLoaded', async () => {
    try {
        const res = await window.OfflineService.getCachedData('/fields/', 'fields');
        if (res && res.data) renderFields(res.data);
        if (navigator.onLine) {
            const resp = await fetch(`${API_BASE_URL}/api/fields/`, { headers });
            if (resp.ok) {
                const data = await resp.json();
                renderFields(data);
                if (Array.isArray(data)) {
                    for (const it of data) await window.OfflineService.storeData('fields', it);
                }
            }
        }
    } catch (e) {}
});

async function fetchFieldData(id) {
    let history = [];
    try {
        const cached = await window.OfflineService.getData('field_history');
        history = (cached || []).filter(h => h.field_id === id);
        if (history.length === 0 && navigator.onLine) {
            const res = await fetch(`${API_BASE_URL}/api/fields/${id}/history`, { headers });
            if (res.ok) {
                history = await res.json();
                if (Array.isArray(history)) {
                    for (const it of history) await window.OfflineService.storeData('field_history', it);
                }
            }
        }
    } catch (e) {}
    const historyList = document.getElementById('historyList');
    historyList.innerHTML = history.length ? history.map(h => `<li class="border-b py-2"><strong>${h.date}</strong>: ${h.action} - ${h.details}</li>`).join('') : '<li>No history found.</li>';
    
    let soil = [];
    try {
        const cached = await window.OfflineService.getData('field_soil');
        soil = (cached || []).filter(s => s.field_id === id);
        if (soil.length === 0 && navigator.onLine) {
            const res = await fetch(`${API_BASE_URL}/api/fields/${id}/soil`, { headers });
            if (res.ok) {
                soil = await res.json();
                if (Array.isArray(soil)) {
                    for (const it of soil) await window.OfflineService.storeData('field_soil', it);
                }
            }
        }
    } catch (e) {}
    const soilList = document.getElementById('soilList');
    soilList.innerHTML = soil.length ? soil.map(s => `<li class="border-b py-2"><strong>${s.date}</strong>: pH ${s.ph}, OM ${s.organic_matter_percent}% (${s.notes || ''})</li>`).join('') : '<li>No soil data.</li>';
    
    let harvest = [];
    try {
        const cached = await window.OfflineService.getData('field_harvest');
        harvest = (cached || []).filter(h => h.field_id === id);
        if (harvest.length === 0 && navigator.onLine) {
            const res = await fetch(`${API_BASE_URL}/api/fields/${id}/harvest`, { headers });
            if (res.ok) {
                harvest = await res.json();
                if (Array.isArray(harvest)) {
                    for (const it of harvest) await window.OfflineService.storeData('field_harvest', it);
                }
            }
        }
    } catch (e) {}
    const harvestList = document.getElementById('harvestList');
    harvestList.innerHTML = harvest.length ? harvest.map(h => `<li class="border-b py-2"><strong>${h.date}</strong>: ${h.crop} - ${h.yield_amount}${h.unit} (Target: ${h.target_yield || '-'})</li>`).join('') : '<li>No harvest logs.</li>';

    let rotation = [];
    try {
        const cached = await window.OfflineService.getData('field_rotation');
        rotation = (cached || []).filter(r => r.field_id === id);
        if (rotation.length === 0 && navigator.onLine) {
            const res = await fetch(`${API_BASE_URL}/api/fields/${id}/rotation`, { headers });
            if (res.ok) {
                rotation = await res.json();
                if (Array.isArray(rotation)) {
                    for (const it of rotation) await window.OfflineService.storeData('field_rotation', it);
                }
            }
        }
    } catch (e) {}
    const rotationList = document.getElementById('rotationList');
    rotationList.innerHTML = rotation.length ? rotation.map(r => `<li class="border-b py-2"><strong>${r.year} ${r.season}</strong>: ${r.planned_crop} (${r.notes || ''})</li>`).join('') : '<li>No rotation plan.</li>';
}

// Tab Switching
document.querySelectorAll('[data-tabs-target]').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('[role="tabpanel"]').forEach(p => p.classList.add('hidden'));
        document.querySelector(tab.dataset.tabsTarget).classList.remove('hidden');
        
        document.querySelectorAll('[role="tab"]').forEach(t => {
            t.classList.remove('text-primary-600', 'border-primary-600', 'dark:text-primary-400', 'dark:border-primary-400');
            t.classList.add('border-transparent');
        });
        tab.classList.add('text-primary-600', 'border-primary-600', 'dark:text-primary-400', 'dark:border-primary-400');
        tab.classList.remove('border-transparent');
    });
});

// Modals
function openAddHistoryModal() { document.getElementById('addHistoryModal').classList.remove('hidden'); }
function openAddSoilModal() { document.getElementById('addSoilModal').classList.remove('hidden'); }
function openAddHarvestModal() { document.getElementById('addHarvestModal').classList.remove('hidden'); }
function openAddRotationModal() { document.getElementById('addRotationModal').classList.remove('hidden'); }

// Forms
document.getElementById('addFieldForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.area = parseFloat(data.area);
    if (navigator.onLine) {
        if(await postJson(`${API_BASE_URL}/api/fields/`, data)) {
            window.location.reload();
        }
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/fields/',
            method: 'POST',
            data
        });
        closeAddFieldModal();
        alert('Queued for sync');
    }
});

document.getElementById('addHistoryForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    if (navigator.onLine) {
        if(await postData(`${API_BASE_URL}/api/fields/history`, new FormData(e.target))) {
            document.getElementById('addHistoryModal').classList.add('hidden');
            fetchFieldData(currentFieldId);
        }
    } else {
        const data = Object.fromEntries(new FormData(e.target).entries());
        data.field_id = parseInt(data.field_id);
        await window.OfflineService.queueForSync({
            endpoint: '/fields/history',
            method: 'POST',
            data
        });
        document.getElementById('addHistoryModal').classList.add('hidden');
        alert('Queued for sync');
    }
});

document.getElementById('addRotationForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.field_id = parseInt(data.field_id);
    data.year = parseInt(data.year);
    if (navigator.onLine) {
        if(await postJson(`${API_BASE_URL}/api/fields/rotation`, data)) {
            document.getElementById('addRotationModal').classList.add('hidden');
            fetchFieldData(currentFieldId);
        }
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/fields/rotation',
            method: 'POST',
            data
        });
        document.getElementById('addRotationModal').classList.add('hidden');
        alert('Queued for sync');
    }
});

document.getElementById('addSoilForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.field_id = parseInt(data.field_id);
    data.organic_matter_percent = parseFloat(data.organic_matter_percent);
    data.ph = parseFloat(data.ph);
    if (navigator.onLine) {
        if(await postJson(`${API_BASE_URL}/api/fields/soil`, data)) {
            document.getElementById('addSoilModal').classList.add('hidden');
            fetchFieldData(currentFieldId);
        }
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/fields/soil',
            method: 'POST',
            data
        });
        document.getElementById('addSoilModal').classList.add('hidden');
        alert('Queued for sync');
    }
});

document.getElementById('addHarvestForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.field_id = parseInt(data.field_id);
    data.yield_amount = parseFloat(data.yield_amount);
    if(data.target_yield) data.target_yield = parseFloat(data.target_yield);
    else delete data.target_yield;
    if (navigator.onLine) {
        if(await postJson(`${API_BASE_URL}/api/fields/harvest`, data)) {
            document.getElementById('addHarvestModal').classList.add('hidden');
            fetchFieldData(currentFieldId);
        }
    } else {
        await window.OfflineService.queueForSync({
            endpoint: '/fields/harvest',
            method: 'POST',
            data
        });
        document.getElementById('addHarvestModal').classList.add('hidden');
        alert('Queued for sync');
    }
});

async function postData(endpoint, formData) {
    const data = Object.fromEntries(formData.entries());
    data.field_id = parseInt(data.field_id);
    return postJson(endpoint, data);
}

async function postJson(endpoint, data) {
    try {
        // endpoint is a full URL or path. If it starts with http, use it as is.
        // If it starts with /, append to API_BASE_URL if not already included.
        let url = endpoint;
        if (!endpoint.startsWith('http')) {
             url = `${API_BASE_URL}${endpoint}`;
        }

        const res = await fetch(url, {
            method: 'POST',
            headers,
            body: JSON.stringify(data)
        });
        if(res.ok) return true;
        alert('Operation failed'); return false;
    } catch(e) { console.error(e); alert('Error occurred'); return false; }
}
</script>
<?php require __DIR__ . '/../components/footer.php'; ?>
