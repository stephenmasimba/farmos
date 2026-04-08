<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$methods = [];
$res = call_api('/api/payments/methods');
if ($res['status'] === 200) {
    $methods = $res['data'];
}

$page_title = 'Payments - Begin Masimba';
$active_page = 'payments';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Payment Methods</h2>
        <button class="bg-primary-600 text-white px-4 py-2 rounded hover:bg-primary-700">Add Method</button>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-lg mb-8 border border-gray-200 dark:border-gray-700">
        <ul role="list" class="divide-y divide-gray-200 dark:divide-gray-700">
            <?php if (empty($methods)): ?>
                <li class="px-4 py-4 sm:px-6 text-center text-gray-500 dark:text-gray-400">No payment methods found.</li>
            <?php else: ?>
                <?php foreach ($methods as $method): ?>
                <li class="px-4 py-4 sm:px-6 flex items-center justify-between hover:bg-gray-50 dark:hover:bg-gray-700">
                    <div class="flex items-center">
                        <div class="flex-shrink-0 h-10 w-10 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center">
                            <svg class="h-6 w-6 text-gray-500 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
                        </div>
                        <div class="ml-4">
                            <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars(ucfirst($method['brand'])); ?> ending in <?php echo htmlspecialchars($method['last4']); ?></div>
                            <div class="text-sm text-gray-500 dark:text-gray-400">Expires 12/2026</div>
                        </div>
                    </div>
                    <button class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300 text-sm font-medium">Remove</button>
                </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow sm:rounded-lg border border-gray-200 dark:border-gray-700">
        <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">Process Payment</h3>
            <div class="mt-2 max-w-xl text-sm text-gray-500 dark:text-gray-400">
                <p>Create a new payment for services or products.</p>
            </div>
            <form id="processPaymentForm" class="mt-5 sm:flex sm:items-center">
                <div class="w-full sm:max-w-xs">
                    <label for="amount" class="sr-only">Amount</label>
                    <input type="number" name="amount" id="amount" class="shadow-sm focus:ring-primary-500 focus:border-primary-500 block w-full sm:text-sm border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md p-2 border" placeholder="Amount (USD)">
                </div>
                <button type="submit" class="mt-3 w-full inline-flex items-center justify-center px-4 py-2 border border-transparent shadow-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">
                    Process
                </button>
            </form>
        </div>
    </div>
</main>

<script>
document.getElementById('processPaymentForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const amount = document.getElementById('amount').value;
    const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
    const API_BASE_URL = '<?php echo api_base_url(); ?>';
    
    // Centralized API headers
    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'X-API-Key': 'local-dev-key',
        'X-Tenant-ID': '1'
    };
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/payments/process`, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ amount: parseFloat(amount) })
        });
        
        if (response.ok) {
            alert('Payment processed successfully!');
            document.getElementById('amount').value = '';
        } else {
            alert('Payment failed.');
        }
    } catch (err) {
        console.error(err);
        alert('Error processing payment.');
    }
});
</script>
</body>
</html>
