<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$items = [];

$page_title = 'Inventory - Begin Masimba';
$active_page = 'inventory';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <div class="flex flex-col sm:flex-row justify-between items-center mb-6 gap-4">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Inventory Management</h2>
        <div class="flex w-full sm:w-auto gap-2">
            <button onclick="document.getElementById('addItemModal').classList.remove('hidden')" class="flex-1 sm:flex-none bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 border border-gray-300 dark:border-gray-600 px-4 py-2 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors shadow-sm font-medium">Add Item</button>
            <button onclick="document.getElementById('stockTransactionModal').classList.remove('hidden')" class="flex-1 sm:flex-none bg-primary-600 text-white px-4 py-2 rounded-xl hover:bg-primary-700 transition-colors shadow-sm font-medium flex items-center justify-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path></svg>
                Stock In/Out
            </button>
        </div>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden rounded-xl border border-gray-100 dark:border-gray-700">
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                    <tr>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Name</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Category</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Quantity</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Unit</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Location</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                    <?php if (empty($items)): ?>
                        <tr>
                            <td colspan="6" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path></svg>
                                <p class="mt-2 text-sm font-medium">No items found</p>
                                <p class="text-sm text-gray-500">Get started by adding inventory items.</p>
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($items as $item): ?>
                        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($item['name']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                                <span class="px-2 py-1 text-xs rounded-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300">
                                    <?php echo htmlspecialchars($item['category']); ?>
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                                <span class="<?php echo ($item['quantity'] < 10) ? 'text-red-600 dark:text-red-400 font-bold' : 'text-gray-900 dark:text-white'; ?>">
                                    <?php echo htmlspecialchars($item['quantity']); ?>
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($item['unit']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($item['location']); ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                <button onclick="editItem(<?php echo htmlspecialchars(json_encode($item)); ?>)" class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300 mr-3">Edit</button>
                                <button onclick="showQRCode('<?php echo $item['qr_code'] ?? 'INV-' . str_pad($item['id'], 6, '0', STR_PAD_LEFT); ?>', '<?php echo htmlspecialchars($item['name']); ?>')" class="text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white inline-flex items-center gap-1">
                                    <i class="fas fa-qrcode"></i> QR
                                </button>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Item Modal -->
<div id="addItemModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-lg w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white" id="modal-title">Add New Inventory Item</h3>
            <button onclick="closeAddItemModal()" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <form id="addItemForm">
            <input type="hidden" name="id" id="item_id">
            <div class="space-y-4">
                <div>
                    <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Item Name</label>
                    <input type="text" name="name" id="name" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                <div>
                    <label for="category" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Category</label>
                    <select name="category" id="category" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                        <option>Chemicals</option>
                        <option>Fuel</option>
                        <option>Seeds</option>
                        <option>Feed</option>
                        <option>Tools</option>
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="quantity" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Quantity</label>
                        <input type="number" name="quantity" id="quantity" step="0.01" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                    </div>
                    <div>
                        <label for="unit" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Unit</label>
                        <input type="text" name="unit" id="unit" placeholder="kg, L, pcs" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                    </div>
                </div>
                <div>
                    <label for="location" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Storage Location</label>
                    <input type="text" name="location" id="location" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-3">
                <button type="button" onclick="closeAddItemModal()" class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors">Cancel</button>
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-primary-600 border border-transparent rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 shadow-sm transition-colors">Save Item</button>
            </div>
        </form>
    </div>
</div>

<!-- Stock Transaction Modal -->
<div id="stockTransactionModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-lg w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Stock Transaction</h3>
            <button onclick="document.getElementById('stockTransactionModal').classList.add('hidden')" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <form id="stockTransactionForm">
            <div class="space-y-4">
                <div>
                    <label for="txn_item_id" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Item</label>
                    <select name="item_id" id="txn_item_id" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                        <?php foreach ($items as $item): ?>
                            <option value="<?php echo $item['id']; ?>"><?php echo htmlspecialchars($item['name']); ?> (Curr: <?php echo $item['quantity'] . $item['unit']; ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label for="txn_type" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Transaction Type</label>
                    <select name="type" id="txn_type" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                        <option value="in">Stock In (Purchase/Return)</option>
                        <option value="out">Stock Out (Usage/Loss)</option>
                    </select>
                </div>
                <div>
                    <label for="txn_quantity" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Quantity</label>
                    <input type="number" name="quantity" id="txn_quantity" step="0.01" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                <div>
                    <label for="txn_reason" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Reason / Notes</label>
                    <input type="text" name="reason" id="txn_reason" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                 <div>
                    <label for="txn_date" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date</label>
                    <input type="date" name="date" id="txn_date" value="<?php echo date('Y-m-d'); ?>" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-3">
                <button type="button" onclick="document.getElementById('stockTransactionModal').classList.add('hidden')" class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors">Cancel</button>
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-primary-600 border border-transparent rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 shadow-sm transition-colors">Submit</button>
            </div>
        </form>
    </div>
</div>

<!-- QR Code Modal -->
<div id="qrCodeModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-sm w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="text-center">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4" id="qrTitle">QR Code</h3>
            <div id="qrcode" class="flex justify-center mb-4 p-4 bg-white rounded-lg border border-gray-200"></div>
            <p class="text-sm text-gray-500 dark:text-gray-400" id="qrText"></p>
        </div>
        <div class="mt-6">
            <button type="button" onclick="document.getElementById('qrCodeModal').classList.add('hidden')" class="w-full inline-flex justify-center rounded-lg border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:text-sm">Close</button>
        </div>
    </div>
</div>

<script>
const token = '<?php echo $_SESSION['access_token'] ?? ''; ?>';
const API_BASE_URL = '<?php echo api_base_url(); ?>';
const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    'x-api-key': 'begin-api-key',
    'X-Tenant-ID': '1'
};

async function renderInventoryTable(items) {
    const tbody = document.querySelector('tbody');
    if (!items || items.length === 0) return;
    tbody.innerHTML = items.map(item => `
        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">${item.name}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                <span class="px-2 py-1 text-xs rounded-full bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300">${item.category}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                <span class="${(item.quantity < 10) ? 'text-red-600 dark:text-red-400 font-bold' : 'text-gray-900 dark:text-white'}">${item.quantity}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${item.unit}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">${item.location}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button onclick='editItem(${JSON.stringify(item)})' class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300 mr-3">Edit</button>
                <button onclick="showQRCode('${item.qr_code || ('INV-' + String(item.id).padStart(6,'0'))}', '${item.name}')" class="text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white inline-flex items-center gap-1">QR</button>
            </td>
        </tr>
    `).join('');
}

document.addEventListener('DOMContentLoaded', async () => {
    try {
        const res = await window.OfflineService.getCachedData('/inventory/items', 'inventory');
        if (res && res.data) renderInventoryTable(res.data);
        if (navigator.onLine) {
            const resp = await fetch(`${API_BASE_URL}/api/inventory/items`, { headers });
            if (resp.ok) {
                const data = await resp.json();
                renderInventoryTable(data);
                if (Array.isArray(data)) {
                    for (const it of data) await window.OfflineService.storeData('inventory', it);
                }
            }
        }
    } catch (e) {}
});

function showQRCode(text, name) {
    document.getElementById('qrTitle').innerText = name;
    document.getElementById('qrText').innerText = text;
    document.getElementById('qrcode').innerHTML = '';
    new QRCode(document.getElementById("qrcode"), {
        text: text,
        width: 128,
        height: 128
    });
    document.getElementById('qrCodeModal').classList.remove('hidden');
}

function closeAddItemModal() {
    document.getElementById('addItemModal').classList.add('hidden');
    document.getElementById('addItemForm').reset();
    document.getElementById('item_id').value = '';
    document.getElementById('modal-title').innerText = 'Add New Inventory Item';
}

function editItem(item) {
    document.getElementById('modal-title').innerText = 'Edit Inventory Item';
    document.getElementById('item_id').value = item.id;
    document.getElementById('name').value = item.name;
    document.getElementById('category').value = item.category;
    document.getElementById('quantity').value = item.quantity;
    document.getElementById('unit').value = item.unit;
    document.getElementById('location').value = item.location;
    document.getElementById('addItemModal').classList.remove('hidden');
}

// Add/Edit Item Submission
document.getElementById('addItemForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const data = Object.fromEntries(formData.entries());
    const id = document.getElementById('item_id').value;
    
    const url = id ? `${API_BASE_URL}/api/inventory/items/${id}` : `${API_BASE_URL}/api/inventory/items`;
    const method = id ? 'PUT' : 'POST';

    try {
        if (navigator.onLine) {
            const response = await fetch(url, { method, headers, body: JSON.stringify(data) });
            if (response.ok) {
                window.location.reload();
            } else {
                alert('Error saving item');
            }
        } else {
            await window.OfflineService.queueForSync({
                endpoint: '/inventory/items' + (id ? `/${id}` : ''),
                method,
                data
            });
            closeAddItemModal();
            alert('Queued for sync');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to connect to server');
    }
});

// Stock Transaction Submission
document.getElementById('stockTransactionForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const data = Object.fromEntries(formData.entries());
    
    try {
        if (navigator.onLine) {
            const response = await fetch(`${API_BASE_URL}/api/inventory/transactions`, { method: 'POST', headers, body: JSON.stringify(data) });
            if (response.ok) {
                window.location.reload();
            } else {
                alert('Error recording transaction');
            }
        } else {
            await window.OfflineService.queueForSync({
                endpoint: '/inventory/transactions',
                method: 'POST',
                data
            });
            document.getElementById('stockTransactionModal').classList.add('hidden');
            alert('Queued for sync');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Failed to connect to server');
    }
});
</script>
<?php require __DIR__ . '/../components/footer.php'; ?>
