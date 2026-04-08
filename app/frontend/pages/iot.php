<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$devices = [];
$res = call_api('/api/iot/devices');
if ($res['status'] === 200) {
    $devices = $res['data'];
}

$water_logs = [];
$res_water = call_api('/api/iot/water-quality');
if ($res_water['status'] === 200) {
    $water_logs = $res_water['data'];
}

$page_title = 'IoT Devices - Begin Masimba';
$active_page = 'iot';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Live Dashboard & Alerts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <!-- Live Chart -->
        <div class="lg:col-span-2 bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Live Sensor Data</h3>
            <div class="relative h-64 w-full">
                <canvas id="liveSensorChart"></canvas>
            </div>
        </div>

        <!-- Active Alerts -->
        <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 p-6 overflow-y-auto" style="max-height: 24rem;">
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white">Active Alerts</h3>
                <span id="alertCount" class="bg-red-100 text-red-800 text-xs font-semibold px-2.5 py-0.5 rounded-full dark:bg-red-900/30 dark:text-red-300">0</span>
            </div>
            <ul id="alertsList" class="divide-y divide-gray-200 dark:divide-gray-700">
                <!-- Alerts injected via JS -->
                <li class="py-3 text-sm text-gray-500 dark:text-gray-400 text-center">Loading alerts...</li>
            </ul>
        </div>
    </div>

    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-8 gap-4">
        <div>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">IoT Devices</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Manage your connected sensors and actuators.</p>
        </div>
        <button onclick="openDeviceModal()" class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors w-full sm:w-auto">
            <svg class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
            Add Device
        </button>
    </div>

    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 mb-12">
        <?php if (empty($devices)): ?>
            <div class="col-span-full flex flex-col items-center justify-center p-12 bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 border-dashed">
                <div class="mx-auto h-12 w-12 text-gray-400">
                    <svg class="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" />
                    </svg>
                </div>
                <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-white">No devices</h3>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Get started by adding a new IoT device.</p>
                <div class="mt-6">
                    <button onclick="openDeviceModal()" class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
                        <svg class="-ml-1 mr-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                            <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
                        </svg>
                        Add Device
                    </button>
                </div>
            </div>
        <?php else: ?>
            <?php foreach ($devices as $device): ?>
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 transition-shadow hover:shadow-md">
                <div class="px-6 py-5">
                    <div class="flex items-center justify-between">
                        <h3 class="text-lg leading-6 font-bold text-gray-900 dark:text-white truncate"><?php echo htmlspecialchars($device['name']); ?></h3>
                        <span class="px-2.5 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-full <?php echo $device['status'] === 'online' ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300' : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'; ?>">
                            <?php echo htmlspecialchars(ucfirst($device['status'])); ?>
                        </span>
                    </div>
                    <div class="mt-4 space-y-2 text-sm text-gray-500 dark:text-gray-400">
                        <div class="flex items-center justify-between">
                            <span>Type:</span>
                            <span class="font-medium text-gray-900 dark:text-gray-200"><?php echo htmlspecialchars(ucfirst($device['type'])); ?></span>
                        </div>
                        <div class="flex items-center justify-between">
                            <span>Location:</span>
                            <span class="font-medium text-gray-900 dark:text-gray-200"><?php echo htmlspecialchars($device['location']); ?></span>
                        </div>
                        <div class="flex items-center justify-between">
                            <span>Last Seen:</span>
                            <span class="font-medium text-gray-900 dark:text-gray-200"><?php echo htmlspecialchars(date('M j, g:i a', strtotime($device['last_seen']))); ?></span>
                        </div>
                    </div>
                </div>
                <div class="bg-gray-50 dark:bg-gray-700/50 px-6 py-4 flex justify-between items-center border-t border-gray-100 dark:border-gray-700">
                    <button class="text-sm font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300 transition-colors">View Data</button>
                    <?php if ($device['type'] === 'actuator'): ?>
                        <button class="text-sm font-medium text-green-600 hover:text-green-500 dark:text-green-400 dark:hover:text-green-300 transition-colors">Control</button>
                    <?php endif; ?>
                </div>
            </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>

    <!-- Water Quality Section -->
    <div class="mt-12">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6 gap-4">
            <div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Water Quality Logs</h2>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Track pH, turbidity, and dissolved oxygen levels.</p>
            </div>
            <button onclick="openWaterModal()" class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors w-full sm:w-auto">
                <svg class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                Log Reading
            </button>
        </div>
        <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl overflow-hidden border border-gray-100 dark:border-gray-700">
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50 dark:bg-gray-700/50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400">Date</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400">Source</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400">pH</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400">DO (mg/L)</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400">Turbidity (NTU)</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider dark:text-gray-400">Notes</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200 dark:bg-gray-800 dark:divide-gray-700">
                        <?php if (empty($water_logs)): ?>
                            <tr>
                                <td colspan="6" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.384-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"></path>
                                    </svg>
                                    <p class="mt-2 text-sm">No water quality logs found.</p>
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($water_logs as $log): ?>
                            <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars(date('M j, Y', strtotime($log['date']))); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['source']); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium <?php echo ($log['ph'] < 6.5 || $log['ph'] > 8.5) ? 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300' : 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300'; ?>">
                                        <?php echo htmlspecialchars($log['ph']); ?>
                                    </span>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['dissolved_oxygen']); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['turbidity']); ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300"><?php echo htmlspecialchars($log['notes'] ?? '-'); ?></td>
                            </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- Device Modal -->
<div id="deviceModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Add IoT Device</h3>
            <button onclick="closeDeviceModal()" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <form id="deviceForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Device ID</label>
                <input type="text" name="id" required placeholder="e.g. dev_003" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
                <input type="text" name="name" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Type</label>
                <select name="type" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                    <option value="sensor">Sensor</option>
                    <option value="actuator">Actuator</option>
                </select>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Location</label>
                <input type="text" name="location" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
            </div>
            <input type="hidden" name="status" value="offline">
            <input type="hidden" name="last_seen" value="<?php echo date('c'); ?>">
            <div class="flex justify-end space-x-3 mt-6">
                <button type="button" onclick="closeDeviceModal()" class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors">Cancel</button>
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-primary-600 border border-transparent rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 shadow-sm transition-colors">Save Device</button>
            </div>
        </form>
    </div>
</div>

<!-- Water Quality Modal -->
<div id="waterModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Log Water Quality</h3>
            <button onclick="closeWaterModal()" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <form id="waterForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                <input type="date" name="date" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Source</label>
                <select name="source" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                    <option value="Borehole">Borehole</option>
                    <option value="Pond">Fish Pond</option>
                    <option value="Tank">Storage Tank</option>
                    <option value="River">River</option>
                </select>
            </div>
            <div class="grid grid-cols-2 gap-4">
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">pH</label>
                    <input type="number" step="0.1" name="ph" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">DO (mg/L)</label>
                    <input type="number" step="0.1" name="dissolved_oxygen" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Turbidity (NTU)</label>
                <input type="number" step="0.1" name="turbidity" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
            </div>
             <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Notes</label>
                <input type="text" name="notes" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
            </div>
            <div class="flex justify-end space-x-3 mt-6">
                <button type="button" onclick="closeWaterModal()" class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors">Cancel</button>
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-primary-600 border border-transparent rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 shadow-sm transition-colors">Save Reading</button>
            </div>
        </form>
    </div>
</div>

<script>
function openDeviceModal() { document.getElementById('deviceModal').classList.remove('hidden'); }
function closeDeviceModal() { document.getElementById('deviceModal').classList.add('hidden'); }
function openWaterModal() { document.getElementById('waterModal').classList.remove('hidden'); }
function closeWaterModal() { document.getElementById('waterModal').classList.add('hidden'); }

const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
const API_BASE_URL = '<?php echo api_base_url(); ?>';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'X-Tenant-ID': '1'
};

// Chart.js Initialization
    let liveChart = null;
    let lastTimestamp = null;

    async function fetchSensorData() {
        try {
            const response = await fetch(`${API_BASE_URL}/api/iot/sensors/latest?limit=20`, { headers });
            if (!response.ok) return [];
            return await response.json();
        } catch (e) {
            console.error('Fetch sensor error:', e);
            return [];
        }
    }

    async function initLiveChart() {
        const ctx = document.getElementById('liveSensorChart').getContext('2d');
        const isDark = document.documentElement.classList.contains('dark');
        
        // Initial fetch
        const readings = await fetchSensorData();
        // Sort by timestamp ascending for the chart
        readings.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        
        const labels = readings.map(r => new Date(r.timestamp).toLocaleTimeString());
        // For simplicity, we chart the first sensor type found or a specific one like 'temperature'
        // Ideally the UI should allow selecting the sensor. Let's default to 'temperature'.
        const tempReadings = readings.filter(r => r.type === 'temperature');
        
        const chartData = tempReadings.length > 0 
            ? tempReadings.map(r => r.value) 
            : Array.from({length: 10}, () => 0); // Fallback empty
            
        const chartLabels = tempReadings.length > 0
            ? tempReadings.map(r => new Date(r.timestamp).toLocaleTimeString())
            : Array.from({length: 10}, (_, i) => new Date(Date.now() - (9-i)*60000).toLocaleTimeString());

        if (tempReadings.length > 0) {
            lastTimestamp = tempReadings[tempReadings.length - 1].timestamp;
        }

        const config = {
            type: 'line',
            data: {
                labels: chartLabels,
                datasets: [{
                    label: 'Temperature (°C)',
                    data: chartData,
                    borderColor: '#10b981', // primary-500
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderWidth: 2,
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: false, // Disable animation for smoother live updates
                plugins: {
                    legend: {
                        labels: {
                            color: isDark ? '#9ca3af' : '#4b5563'
                        }
                    }
                },
                scales: {
                    y: {
                        grid: {
                            color: isDark ? '#374151' : '#e5e7eb'
                        },
                        ticks: {
                            color: isDark ? '#9ca3af' : '#4b5563'
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            color: isDark ? '#9ca3af' : '#4b5563'
                        }
                    }
                }
            }
        };

        liveChart = new Chart(ctx, config);

        // Live updates
        setInterval(async () => {
            const newReadings = await fetchSensorData();
            // Filter for new temperature readings
            const latestTemps = newReadings
                .filter(r => r.type === 'temperature')
                .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));

            if (latestTemps.length === 0) return;

            const newest = latestTemps[latestTemps.length - 1];
            
            // Only update if we have newer data
            if (lastTimestamp && new Date(newest.timestamp) <= new Date(lastTimestamp)) {
                return;
            }
            
            lastTimestamp = newest.timestamp;
            
            const data = liveChart.data;
            if (data.labels.length > 20) {
                data.labels.shift();
                data.datasets[0].data.shift();
            }
            
            data.labels.push(new Date(newest.timestamp).toLocaleTimeString());
            data.datasets[0].data.push(newest.value);
            liveChart.update('none');
        }, 3000);
    }

function fetchAlerts() {
    const list = document.getElementById('alertsList');
    const count = document.getElementById('alertCount');
    fetch(`${API_BASE_URL}/api/iot/alerts`, {
        method: 'GET',
        headers
    })
        .then(response => {
            if (!response.ok) {
                throw new Error('Failed to load alerts');
            }
            return response.json();
        })
        .then(alerts => {
            if (!Array.isArray(alerts) || alerts.length === 0) {
                list.innerHTML = '<li class="py-3 text-sm text-gray-500 dark:text-gray-400 text-center">No active alerts</li>';
                count.innerText = '0';
                return;
            }
            count.innerText = alerts.length;
            list.innerHTML = alerts
                .map(alert => `
                    <li class="py-3 flex items-start">
                        <div class="flex-shrink-0">
                            ${alert.type === 'critical' 
                                ? '<span class="h-2 w-2 mt-2 rounded-full bg-red-500 animate-pulse"></span>' 
                                : '<span class="h-2 w-2 mt-2 rounded-full bg-yellow-500"></span>'}
                        </div>
                        <div class="ml-3 w-0 flex-1 pt-0.5">
                            <p class="text-sm font-medium text-gray-900 dark:text-white">${alert.message}</p>
                            <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">${alert.time}</p>
                        </div>
                    </li>
                `)
                .join('');
        })
        .catch(() => {
            list.innerHTML = '<li class="py-3 text-sm text-gray-500 dark:text-gray-400 text-center">Unable to load alerts</li>';
            count.innerText = '0';
        });
}

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    initLiveChart();
    fetchAlerts();
});

// Update chart theme when dark mode toggles
const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
        if (mutation.attributeName === 'class') {
            const isDark = document.documentElement.classList.contains('dark');
            if (liveChart) {
                liveChart.options.plugins.legend.labels.color = isDark ? '#9ca3af' : '#4b5563';
                liveChart.options.scales.y.grid.color = isDark ? '#374151' : '#e5e7eb';
                liveChart.options.scales.y.ticks.color = isDark ? '#9ca3af' : '#4b5563';
                liveChart.options.scales.x.ticks.color = isDark ? '#9ca3af' : '#4b5563';
                liveChart.update();
            }
        }
    });
});
observer.observe(document.documentElement, { attributes: true });

document.getElementById('deviceForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/iot/devices`, {
            method: 'POST',
            headers,
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            window.location.reload();
        } else {
            alert('Failed to add device');
        }
    } catch (err) {
        console.error(err);
        alert('Error adding device');
    }
});

document.getElementById('waterForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    
    // Convert types
    data.ph = parseFloat(data.ph);
    data.dissolved_oxygen = parseFloat(data.dissolved_oxygen);
    data.turbidity = parseFloat(data.turbidity);
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/iot/water-quality`, {
            method: 'POST',
            headers,
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            window.location.reload();
        } else {
            alert('Failed to save log');
        }
    } catch (err) {
        console.error(err);
        alert('Error saving log');
    }
});
</script>
</body>
</html>
