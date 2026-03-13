<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$report_types = [];
$res = call_api('/api/reports/types');
if ($res['status'] === 200) {
    $report_types = $res['data'];
}

$page_title = 'Reports - Begin Masimba';
$active_page = 'reports';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <h2 class="text-2xl font-bold text-gray-900 mb-6">Reports & Analytics</h2>

    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <?php foreach ($report_types as $type): ?>
        <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="px-4 py-5 sm:p-6">
                <h3 class="text-lg font-medium text-gray-900"><?php echo htmlspecialchars($type); ?> Report</h3>
                <p class="mt-1 text-sm text-gray-500">Generate detailed insights about <?php echo strtolower($type); ?>.</p>
                <div class="mt-4 flex space-x-3">
                    <button onclick="generateReport('<?php echo $type; ?>', 'pdf')" class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-gray-200 dark:border-gray-600 dark:hover:bg-gray-600">
                        View PDF
                    </button>
                    <button onclick="generateReport('<?php echo $type; ?>', 'csv')" class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-gray-200 dark:border-gray-600 dark:hover:bg-gray-600">
                        Export CSV
                    </button>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    </div>

    <div class="mt-8 bg-white dark:bg-gray-800 shadow sm:rounded-lg">
        <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">Custom Export</h3>
            <div class="mt-2 max-w-xl text-sm text-gray-500 dark:text-gray-400">
                <p>Select data range and type to export raw data.</p>
            </div>
            <div class="mt-5 sm:flex sm:items-center">
                <div class="w-full sm:max-w-xs">
                    <select id="export-type" name="export-type" class="block w-full pl-3 pr-10 py-2 text-base border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md">
                        <option>Financial Transactions</option>
                        <option>Inventory Logs</option>
                        <option>Livestock Events</option>
                    </select>
                </div>
                <button type="submit" class="mt-3 w-full inline-flex items-center justify-center px-4 py-2 border border-transparent shadow-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">
                    Export
                </button>
            </div>
        </div>
    </div>
</main>
<script>
async function generateReport(type, format) {
    const btn = event.currentTarget;
    const originalText = btn.innerText;
    
    // Only update button state if the event was triggered by a button click
    if (btn && btn.tagName === 'BUTTON') {
        btn.innerText = 'Generating...';
        btn.disabled = true;
    }

    const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
    const API_BASE_URL = '<?php echo api_base_url(); ?>';
    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'X-Tenant-ID': '1'
    };

    try {
        const response = await fetch(`${API_BASE_URL}/api/reports/generate`, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ type, format }),
        });

        if (response.ok) {
            const data = await response.json();
            if (data.url) {
                 const url = (data.url.startsWith('http://') || data.url.startsWith('https://')) ? data.url : `${API_BASE_URL}${data.url}`;
                 window.open(url, '_blank');
            } else {
                alert(data.message || 'Report generated');
            }
        } else {
            const errorData = await response.json().catch(() => ({}));
            alert('Failed to generate report: ' + (errorData.detail || response.statusText));
        }
    } catch (err) {
        console.error(err);
        alert('Error generating report');
    } finally {
        if (btn && btn.tagName === 'BUTTON') {
            btn.innerText = originalText;
            btn.disabled = false;
        }
    }
}
</script>
</body>
</html>
