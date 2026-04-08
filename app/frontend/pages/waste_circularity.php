<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$compost_res = call_api('/api/circularity/compost', 'GET');
$compost_data = $compost_res['data'] ?? $compost_res ?? [];
$piles = [];
if (is_array($compost_data)) {
    foreach ($compost_data as $item) {
        if (is_array($item)) {
            $piles[] = $item;
        }
    }
}

$carbon_res = call_api('/api/circularity/carbon', 'GET');
$carbon_data = $carbon_res['data'] ?? $carbon_res ?? [];
$carbon = is_array($carbon_data) ? $carbon_data : [];

if (empty($carbon)) {
    $carbon = [
        'monthly_co2e_avoided_tonnes' => 4.2,
        'yearly_projection' => 50.4,
        'potential_credit_value_usd' => 756.0,
        'breakdown' => [
            'biogas_methane_capture' => 2.8,
            'waste_diversion' => 0.9,
            'compost_soil_sequestration' => 0.5
        ],
        'calculation_period' => 'Last 30 days (Mock)'
    ];
}

$carbon_value = isset($carbon['potential_credit_value_usd']) ? (float)$carbon['potential_credit_value_usd'] : 0;
$carbon_projection = isset($carbon['yearly_projection']) ? $carbon['yearly_projection'] : 0;
$carbon_breakdown = $carbon['breakdown'] ?? [];
$biogas_capture = isset($carbon_breakdown['biogas_methane_capture']) ? $carbon_breakdown['biogas_methane_capture'] : 0;
$waste_diversion = isset($carbon_breakdown['waste_diversion']) ? $carbon_breakdown['waste_diversion'] : 0;

$bsf_res = call_api('/api/circularity/bsf', 'GET');
$bsf_data = $bsf_res['data'] ?? $bsf_res ?? [];
$bsf_cycles = [];
if (is_array($bsf_data)) {
    foreach ($bsf_data as $item) {
        if (is_array($item)) {
            $bsf_cycles[] = $item;
        }
    }
}

$page_title = 'Waste & Circularity - Begin Masimba';
$active_page = 'waste_circularity';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Waste & Circularity</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Converting waste into value and tracking carbon impact</p>
        </div>
    </div>

    <!-- Carbon Credit Card -->
    <div class="bg-emerald-600 rounded-2xl p-8 text-white mb-10 relative overflow-hidden shadow-lg">
        <div class="relative z-10 grid grid-cols-1 md:grid-cols-3 gap-8 items-center">
            <div>
                <p class="text-emerald-100 text-sm font-medium mb-1">Estimated Carbon Value</p>
                <h3 class="text-4xl font-bold">$<?php echo number_format($carbon_value, 2); ?></h3>
                <p class="text-emerald-100 text-xs mt-1">Based on <?php echo $carbon_projection; ?> tonnes CO2e projection</p>
            </div>
            <div class="space-y-3">
                <div class="flex justify-between text-sm">
                    <span class="text-emerald-100">Biogas Capture</span>
                    <span class="font-bold"><?php echo $biogas_capture; ?>t</span>
                </div>
                <div class="w-full bg-emerald-700/50 rounded-full h-1.5">
                    <div class="bg-white h-1.5 rounded-full" style="width: 65%"></div>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-emerald-100">Waste Diversion</span>
                    <span class="font-bold"><?php echo $waste_diversion; ?>t</span>
                </div>
                <div class="w-full bg-emerald-700/50 rounded-full h-1.5">
                    <div class="bg-white h-1.5 rounded-full" style="width: 25%"></div>
                </div>
            </div>
            <div class="flex justify-end">
                <button class="bg-white text-emerald-600 px-6 py-2.5 rounded-xl font-bold hover:bg-emerald-50 transition-colors">
                    Certify Credits
                </button>
            </div>
        </div>
        <!-- Decorative SVG background -->
        <svg class="absolute right-0 bottom-0 opacity-10 w-64 h-64 -mb-16 -mr-16" fill="currentColor" viewBox="0 0 20 20">
            <path d="M5 4a2 2 0 012-2h6a2 2 0 012 2v14l-5-2.5L5 18V4z" />
        </svg>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Compost Piles -->
        <div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Compost Monitoring</h3>
            <div class="space-y-4">
                <?php foreach ($piles as $pile): ?>
                <?php
                    if (!is_array($pile)) {
                        continue;
                    }
                    $pile_name = $pile['pile_name'] ?? 'Compost Pile';
                    $pile_type = $pile['type'] ?? 'Pile';
                    $days_active = isset($pile['days_active']) ? (int)$pile['days_active'] : 0;
                    $status = $pile['status'] ?? 'UNKNOWN';
                    $temperature = isset($pile['temperature_c']) ? $pile['temperature_c'] : null;
                    $moisture = isset($pile['moisture_pct']) ? $pile['moisture_pct'] : null;
                    $ph = isset($pile['ph']) ? $pile['ph'] : null;
                    $pathogen_kill = $pile['pathogen_kill'] ?? '';
                    $status_class = $status === 'OPTIMAL' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800';
                    $temp_high = $pathogen_kill === 'ACTIVE';
                ?>
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 border border-gray-100 dark:border-gray-700 shadow-sm">
                    <div class="flex justify-between items-start mb-4">
                        <div>
                            <h4 class="font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($pile_name); ?></h4>
                            <p class="text-xs text-gray-500"><?php echo htmlspecialchars($pile_type); ?> • Day <?php echo $days_active; ?></p>
                        </div>
                        <span class="px-2 py-1 text-[10px] font-bold rounded <?php 
                            echo $status_class; 
                        ?>">
                            <?php echo htmlspecialchars($status); ?>
                        </span>
                    </div>
                    <div class="grid grid-cols-3 gap-4 text-center">
                        <div class="bg-gray-50 dark:bg-gray-700/30 p-2 rounded-lg">
                            <p class="text-[10px] text-gray-500 uppercase">Temp</p>
                            <p class="text-lg font-bold <?php echo $temp_high ? 'text-red-500' : 'text-gray-900 dark:text-white'; ?>">
                                <?php echo $temperature !== null ? $temperature : 'N/A'; ?>°C
                            </p>
                        </div>
                        <div class="bg-gray-50 dark:bg-gray-700/30 p-2 rounded-lg">
                            <p class="text-[10px] text-gray-500 uppercase">Moisture</p>
                            <p class="text-lg font-bold text-blue-500"><?php echo $moisture !== null ? $moisture : 'N/A'; ?>%</p>
                        </div>
                        <div class="bg-gray-50 dark:bg-gray-700/30 p-2 rounded-lg">
                            <p class="text-[10px] text-gray-500 uppercase">pH</p>
                            <p class="text-lg font-bold text-emerald-500"><?php echo $ph !== null ? $ph : 'N/A'; ?></p>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        </div>

        <!-- BSF & Others -->
        <div>
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white">BSF Larvae Tracker</h3>
                <button onclick="openModal('bsfModal')" class="bg-amber-600 text-white px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-amber-700 shadow-sm flex items-center gap-1">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                    New Cycle
                </button>
            </div>
            <?php foreach ($bsf_cycles as $cycle): ?>
            <div class="bg-white dark:bg-gray-800 rounded-xl p-6 border border-gray-100 dark:border-gray-700 shadow-sm mb-4">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center">
                        <div class="w-10 h-10 bg-amber-100 dark:bg-amber-900/30 rounded-full flex items-center justify-center mr-3 text-amber-600">
                            🪰
                        </div>
                        <div>
                            <h4 class="font-bold text-gray-900 dark:text-white"><?php echo htmlspecialchars($cycle['cycle_name']); ?></h4>
                            <p class="text-xs text-gray-500">Started <?php echo $cycle['start_date']; ?></p>
                        </div>
                    </div>
                    <span class="text-sm font-bold text-primary-600"><?php echo $cycle['days_remaining']; ?> days left</span>
                </div>
                <div class="space-y-4">
                    <div>
                        <div class="flex justify-between text-xs mb-1">
                            <span class="text-gray-500">Waste Conversion Progress</span>
                            <span class="font-medium"><?php echo $cycle['waste_input_kg']; ?>kg input</span>
                        </div>
                        <div class="w-full bg-gray-100 dark:bg-gray-700 rounded-full h-2">
                            <div class="bg-amber-500 h-2 rounded-full" style="width: 75%"></div>
                        </div>
                    </div>
                    <div class="flex justify-between text-sm pt-2 border-t border-gray-50 dark:border-gray-700">
                        <span class="text-gray-500">Expected Protein Yield</span>
                        <span class="font-bold text-gray-900 dark:text-white"><?php echo $cycle['expected_yield_kg']; ?>kg</span>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</div>

<!-- New BSF Cycle Modal -->
<div id="bsfModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Start New BSF Cycle</h3>
        <form id="bsfForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Cycle Name</label>
                <input type="text" name="cycle_name" placeholder="e.g. Cycle-2026-03-A" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-amber-500 focus:ring-amber-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Waste Input (kg)</label>
                <input type="number" step="0.1" name="waste_input_kg" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-amber-500 focus:ring-amber-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Expected Yield (kg)</label>
                <input type="number" step="0.1" name="expected_yield_kg" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-amber-500 focus:ring-amber-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeModal('bsfModal')" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-amber-600 text-white px-4 py-2 rounded-md hover:bg-amber-700 shadow-sm text-sm font-medium">Start Cycle</button>
            </div>
        </form>
    </div>
</div>

<script>
function openModal(modalId) {
    document.getElementById(modalId).classList.remove('hidden');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.add('hidden');
}

const token = '<?php echo $_SESSION['access_token']; ?>';
const API_BASE_URL = '<?php echo api_base_url(); ?>';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'X-API-Key': 'local-dev-key',
    'X-Tenant-ID': '1'
};

document.getElementById('bsfForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    
    // Convert numeric fields
    data.waste_input_kg = parseFloat(data.waste_input_kg);
    data.expected_yield_kg = parseFloat(data.expected_yield_kg);

    try {
        const response = await fetch(`${API_BASE_URL}/api/circularity/bsf`, {
            method: 'POST',
            headers,
            body: JSON.stringify(data)
        });

        if (response.ok) {
            window.location.reload();
        } else {
            alert('Failed to create cycle');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred');
    }
});
</script>
