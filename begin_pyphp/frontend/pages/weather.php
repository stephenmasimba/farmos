<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$current_weather = [];
$res = call_api('/api/weather/current');
if ($res['status'] === 200) {
    $current_weather = $res['data'];
}

$logs = [];
$resLogs = call_api('/api/weather/logs');
if ($resLogs['status'] === 200) {
    $logs = $resLogs['data'];
}

$page_title = 'Weather - Begin Masimba';
$active_page = 'weather';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Current Weather Card -->
    <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm rounded-xl border border-gray-100 dark:border-gray-700 mb-8">
        <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white mb-4">Current Weather</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div>
                    <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Temperature</dt>
                    <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white"><?php echo $current_weather['temperature'] ?? '--'; ?>°C</dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Humidity</dt>
                    <dd class="mt-1 text-3xl font-semibold text-gray-900 dark:text-white"><?php echo $current_weather['humidity'] ?? '--'; ?>%</dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Conditions</dt>
                    <dd class="mt-1 text-xl font-semibold text-gray-900 dark:text-white"><?php echo $current_weather['conditions'] ?? '--'; ?></dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Wind Speed</dt>
                    <dd class="mt-1 text-xl font-semibold text-gray-900 dark:text-white"><?php echo $current_weather['wind_speed'] ?? '--'; ?> km/h</dd>
                </div>
            </div>
        </div>
    </div>

    <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Weather Logs</h2>
        <button onclick="openWeatherModal()" class="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 shadow-sm transition-colors flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
            Add Log
        </button>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700/50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Date/Time</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Temp (°C)</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Humidity (%)</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Conditions</th>
                </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                <?php if (empty($logs)): ?>
                    <tr><td colspan="4" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No logs found.</td></tr>
                <?php else: ?>
                    <?php foreach ($logs as $log): ?>
                    <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($log['timestamp']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($log['temperature']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($log['humidity']); ?></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"><?php echo htmlspecialchars($log['conditions']); ?></td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</main>

<!-- Add Weather Log Modal -->
<div id="weatherModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add Weather Log</h3>
        <form id="weatherForm">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Temperature (°C)</label>
                <input type="number" step="0.1" name="temperature" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Humidity (%)</label>
                <input type="number" step="1" name="humidity" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Conditions</label>
                <select name="conditions" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option>Sunny</option>
                    <option>Cloudy</option>
                    <option>Rainy</option>
                    <option>Stormy</option>
                    <option>Windy</option>
                </select>
            </div>
             <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Wind Speed (km/h)</label>
                <input type="number" step="0.1" name="wind_speed" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeWeatherModal()" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save</button>
            </div>
        </form>
    </div>
</div>

<script>
const token = "<?php echo $_SESSION['access_token'] ?? ''; ?>";
const API_BASE_URL = 'http://localhost:8000';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'X-API-Key': 'local-dev-key',
    'X-Tenant-ID': '1'
};

function openWeatherModal() { document.getElementById('weatherModal').classList.remove('hidden'); }
function closeWeatherModal() { document.getElementById('weatherModal').classList.add('hidden'); }

document.getElementById('weatherForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = Object.fromEntries(new FormData(e.target));
    data.temperature = parseFloat(data.temperature);
    data.humidity = parseFloat(data.humidity);
    if(data.wind_speed) data.wind_speed = parseFloat(data.wind_speed);
    
    // Auto-fill timestamp if not provided (backend handles it usually, but good to be explicit or let backend do it)
    // Here we let backend handle it or send current time
    // data.timestamp = new Date().toISOString(); 

    try {
        const res = await fetch(`${API_BASE_URL}/api/weather/logs`, {
            method: 'POST',
            headers,
            body: JSON.stringify(data)
        });
        if (res.ok) {
            window.location.reload();
        } else {
            alert('Failed to add log');
        }
    } catch (e) {
        console.error(e);
        alert('Error adding log');
    }
});
</script>
<?php require __DIR__ . '/../components/footer.php'; ?>
