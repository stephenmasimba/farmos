<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$biogas_logs = [];
$res_biogas = call_api('/api/waste/biogas', 'GET');
if ($res_biogas['status'] === 200) {
    $biogas_logs = $res_biogas['data'];
}

$compost_piles = [];
$res_compost = call_api('/api/waste/compost', 'GET');
if ($res_compost['status'] === 200) {
    $compost_piles = $res_compost['data'];
}

$manure_logs = [];
$res_manure = call_api('/api/waste/manure', 'GET');
if ($res_manure['status'] === 200) {
    $manure_logs = $res_manure['data'];
}

$page_title = 'Waste & Nutrient Cycling - Begin Masimba';
$active_page = 'waste';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-8">Waste & Nutrient Cycling</h2>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        
        <!-- Biogas Section -->
        <div>
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white">Biogas Production</h3>
                <button onclick="openBiogasModal()" class="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700 text-sm">Log Entry</button>
            </div>
            <div class="bg-white shadow overflow-hidden sm:rounded-lg dark:bg-gray-800 dark:border dark:border-gray-700">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700">
                        <tr>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Date</th>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Input (kg)</th>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Gas (m³)</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($biogas_logs as $log): ?>
                        <tr>
                            <td class="px-4 py-2 text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($log['date']); ?></td>
                            <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['feedstock_input_kg']); ?></td>
                            <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['estimated_gas_output_m3']); ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Compost Section -->
        <div>
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white">Compost Piles</h3>
                <button onclick="openCompostModal()" class="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700 text-sm">New Pile</button>
            </div>
            <div class="bg-white shadow overflow-hidden sm:rounded-lg dark:bg-gray-800 dark:border dark:border-gray-700">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700">
                        <tr>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Location</th>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Start Date</th>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($compost_piles as $pile): ?>
                        <tr>
                            <td class="px-4 py-2 text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($pile['location']); ?></td>
                            <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($pile['start_date']); ?></td>
                            <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-300">
                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                                    <?php echo htmlspecialchars($pile['status']); ?>
                                </span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Manure Section -->
        <div class="lg:col-span-2">
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white">Manure Collection</h3>
                <button onclick="openManureModal()" class="bg-yellow-600 text-white px-3 py-1 rounded hover:bg-yellow-700 text-sm">Log Collection</button>
            </div>
            <div class="bg-white shadow overflow-hidden sm:rounded-lg dark:bg-gray-800 dark:border dark:border-gray-700">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700">
                        <tr>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Date</th>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Source</th>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Quantity (kg)</th>
                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase dark:text-gray-300">Destination</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                        <?php foreach ($manure_logs as $log): ?>
                        <tr>
                            <td class="px-4 py-2 text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($log['date']); ?></td>
                            <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['source']); ?></td>
                            <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['quantity_kg']); ?></td>
                            <td class="px-4 py-2 text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['destination']); ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</main>

<!-- Biogas Modal -->
<div id="biogasModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden overflow-y-auto h-full w-full backdrop-blur-sm z-50 flex items-center justify-center">
    <div class="relative mx-auto p-5 border w-96 shadow-lg rounded-md bg-white dark:bg-gray-800 dark:border-gray-700">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">Log Biogas</h3>
        <form id="biogasForm" class="mt-4">
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Date</label>
                <input type="date" name="date" required class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Input (kg)</label>
                <input type="number" step="0.1" name="feedstock_input_kg" required class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Est. Gas (m³)</label>
                <input type="number" step="0.1" name="estimated_gas_output_m3" required class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
            </div>
            <div class="flex justify-end">
                <button type="button" onclick="closeBiogasModal()" class="mr-2 bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">Cancel</button>
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Compost Modal -->
<div id="compostModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden overflow-y-auto h-full w-full backdrop-blur-sm z-50 flex items-center justify-center">
    <div class="relative mx-auto p-5 border w-96 shadow-lg rounded-md bg-white dark:bg-gray-800 dark:border-gray-700">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">New Compost Pile</h3>
        <form id="compostForm" class="mt-4">
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Location</label>
                <input type="text" name="location" required class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Start Date</label>
                <input type="date" name="start_date" required class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
            </div>
            <div class="flex justify-end">
                <button type="button" onclick="closeCompostModal()" class="mr-2 bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">Cancel</button>
                <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Manure Modal -->
<div id="manureModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden overflow-y-auto h-full w-full backdrop-blur-sm z-50 flex items-center justify-center">
    <div class="relative mx-auto p-5 border w-96 shadow-lg rounded-md bg-white dark:bg-gray-800 dark:border-gray-700">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">Log Manure</h3>
        <form id="manureForm" class="mt-4">
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Date</label>
                <input type="date" name="date" required class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Source</label>
                <select name="source" required class="shadow border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
                    <option value="Piggery">Piggery</option>
                    <option value="Poultry">Poultry</option>
                    <option value="Cattle">Cattle</option>
                    <option value="Goats">Goats</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Quantity (kg)</label>
                <input type="number" step="0.1" name="quantity_kg" required class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 dark:text-gray-300 text-sm font-bold mb-2">Destination</label>
                <select name="destination" required class="shadow border rounded w-full py-2 px-3 text-gray-700 dark:bg-gray-700 dark:text-white dark:border-gray-600">
                    <option value="Biogas">Biogas Digester</option>
                    <option value="Compost">Compost Pile</option>
                    <option value="Field">Direct Field Application</option>
                </select>
            </div>
            <div class="flex justify-end">
                <button type="button" onclick="closeManureModal()" class="mr-2 bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">Cancel</button>
                <button type="submit" class="bg-yellow-600 text-white px-4 py-2 rounded hover:bg-yellow-700">Save</button>
            </div>
        </form>
    </div>
</div>

<script>
const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
const API_BASE_URL = '<?php echo api_base_url(); ?>';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'X-API-Key': 'local-dev-key',
    'X-Tenant-ID': '1'
};

// Biogas
function openBiogasModal() { document.getElementById('biogasModal').classList.remove('hidden'); }
function closeBiogasModal() { document.getElementById('biogasModal').classList.add('hidden'); }
document.getElementById('biogasForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.feedstock_input_kg = parseFloat(data.feedstock_input_kg);
    data.estimated_gas_output_m3 = parseFloat(data.estimated_gas_output_m3);
    
    if (await postData(`${API_BASE_URL}/api/waste/biogas`, data)) window.location.reload();
});

// Compost
function openCompostModal() { document.getElementById('compostModal').classList.remove('hidden'); }
function closeCompostModal() { document.getElementById('compostModal').classList.add('hidden'); }
document.getElementById('compostForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    if (await postData(`${API_BASE_URL}/api/waste/compost`, data)) window.location.reload();
});

// Manure
function openManureModal() { document.getElementById('manureModal').classList.remove('hidden'); }
function closeManureModal() { document.getElementById('manureModal').classList.add('hidden'); }
document.getElementById('manureForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.quantity_kg = parseFloat(data.quantity_kg);
    if (await postData(`${API_BASE_URL}/api/waste/manure`, data)) window.location.reload();
});

async function postData(url, data) {
    try {
        const response = await fetch(url, { method: 'POST', headers, body: JSON.stringify(data) });
        if (response.ok) return true;
        alert('Operation failed');
        return false;
    } catch (err) {
        console.error(err);
        alert('Error occurred');
        return false;
    }
}
</script>

<?php require __DIR__ . '/../components/footer.php'; ?>
