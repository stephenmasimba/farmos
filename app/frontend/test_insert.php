<?php
require_once __DIR__ . '/../lib/api_client.php';

if (empty($_SESSION['user'])) {
    header('Location: ../pages/login.php');
    exit;
}

$message = '';
$error = '';

// Handle form submissions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    switch ($action) {
        case 'add_livestock':
            $data = [
                'batch_code' => $_POST['batch_code'] ?? '',
                'animal_type' => $_POST['animal_type'] ?? 'Cattle',
                'quantity' => (int)($_POST['quantity'] ?? 0),
                'weight_avg' => (float)($_POST['weight_avg'] ?? 0),
                'health_status' => $_POST['health_status'] ?? 'HEALTHY',
                'entry_date' => $_POST['entry_date'] ?? date('Y-m-d'),
                'estimated_exit_date' => $_POST['estimated_exit_date'] ?? null,
                'notes' => $_POST['notes'] ?? ''
            ];
            
            $response = call_api('/api/livestock/add', 'POST', $data);
            if ($response['status'] === 200) {
                $message = '✅ Livestock batch added successfully!';
            } else {
                $error = '❌ Failed to add livestock batch: ' . ($response['error'] ?? 'Unknown error');
            }
            break;
            
        case 'add_inventory':
            $data = [
                'item_name' => $_POST['item_name'] ?? '',
                'category' => $_POST['category'] ?? 'Feed',
                'quantity' => (int)($_POST['quantity'] ?? 0),
                'unit' => $_POST['unit'] ?? 'kg',
                'unit_cost' => (float)($_POST['unit_cost'] ?? 0),
                'total_cost' => (float)($_POST['total_cost'] ?? 0),
                'min_stock_level' => (int)($_POST['min_stock_level'] ?? 0),
                'location' => $_POST['location'] ?? 'Main Storage',
                'supplier_id' => (int)($_POST['supplier_id'] ?? 1),
                'notes' => $_POST['notes'] ?? ''
            ];
            
            $response = call_api('/api/inventory/add', 'POST', $data);
            if ($response['status'] === 200) {
                $message = '✅ Inventory item added successfully!';
            } else {
                $error = '❌ Failed to add inventory item: ' . ($response['error'] ?? 'Unknown error');
            }
            break;
            
        case 'add_equipment':
            $data = [
                'equipment_name' => $_POST['equipment_name'] ?? '',
                'equipment_type' => $_POST['equipment_type'] ?? 'Machinery',
                'purchase_date' => $_POST['purchase_date'] ?? date('Y-m-d'),
                'purchase_cost' => (float)($_POST['purchase_cost'] ?? 0),
                'current_value' => (float)($_POST['current_value'] ?? 0),
                'status' => $_POST['status'] ?? 'OPERATIONAL',
                'location' => $_POST['location'] ?? 'Main Farm',
                'maintenance_interval' => (int)($_POST['maintenance_interval'] ?? 30),
                'last_maintenance' => $_POST['last_maintenance'] ?? null,
                'notes' => $_POST['notes'] ?? ''
            ];
            
            $response = call_api('/api/equipment/add', 'POST', $data);
            if ($response['status'] === 200) {
                $message = '✅ Equipment added successfully!';
            } else {
                $error = '❌ Failed to add equipment: ' . ($response['error'] ?? 'Unknown error');
            }
            break;
            
        case 'add_task':
            $data = [
                'task_title' => $_POST['task_title'] ?? '',
                'description' => $_POST['description'] ?? '',
                'priority' => $_POST['priority'] ?? 'MEDIUM',
                'status' => $_POST['status'] ?? 'PENDING',
                'assigned_to' => (int)($_POST['assigned_to'] ?? 1),
                'due_date' => $_POST['due_date'] ?? date('Y-m-d'),
                'created_by' => $_SESSION['user']['id'] ?? 1
            ];
            
            $response = call_api('/api/tasks/add', 'POST', $data);
            if ($response['status'] === 200) {
                $message = '✅ Task added successfully!';
            } else {
                $error = '❌ Failed to add task: ' . ($response['error'] ?? 'Unknown error');
            }
            break;
            
        case 'add_transaction':
            $data = [
                'transaction_type' => $_POST['transaction_type'] ?? 'EXPENSE',
                'amount' => (float)($_POST['amount'] ?? 0),
                'description' => $_POST['description'] ?? '',
                'category' => $_POST['category'] ?? 'OPERATION',
                'reference_id' => $_POST['reference_id'] ?? null,
                'transaction_date' => $_POST['transaction_date'] ?? date('Y-m-d'),
                'created_by' => $_SESSION['user']['id'] ?? 1
            ];
            
            $response = call_api('/api/financial/transactions/add', 'POST', $data);
            if ($response['status'] === 200) {
                $message = '✅ Financial transaction added successfully!';
            } else {
                $error = '❌ Failed to add transaction: ' . ($response['error'] ?? 'Unknown error');
            }
            break;
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>FarmOS - Test INSERT Operations</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-8">
    <div class="max-w-4xl mx-auto">
        <h1 class="text-3xl font-bold mb-8">🧪 FarmOS INSERT Operations Test</h1>
        
        <?php if ($message): ?>
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-6">
                <?php echo $message; ?>
            </div>
        <?php endif; ?>
        
        <?php if ($error): ?>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
                <?php echo $error; ?>
            </div>
        <?php endif; ?>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            
            <!-- Add Livestock Batch -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-bold mb-4">🐄 Add Livestock Batch</h2>
                <form method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="add_livestock">
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Batch Code</label>
                        <input type="text" name="batch_code" class="w-full border rounded px-3 py-2" 
                               value="<?php echo 'BATCH-' . time(); ?>" readonly>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Animal Type</label>
                        <select name="animal_type" class="w-full border rounded px-3 py-2">
                            <option value="Cattle">Cattle</option>
                            <option value="Poultry">Poultry</option>
                            <option value="Goats">Goats</option>
                            <option value="Sheep">Sheep</option>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Quantity</label>
                        <input type="number" name="quantity" class="w-full border rounded px-3 py-2" required>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Weight Avg (kg)</label>
                        <input type="number" step="0.1" name="weight_avg" class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Health Status</label>
                        <select name="health_status" class="w-full border rounded px-3 py-2">
                            <option value="HEALTHY">Healthy</option>
                            <option value="SICK">Sick</option>
                            <option value="QUARANTINE">Quarantine</option>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Entry Date</label>
                        <input type="date" name="entry_date" class="w-full border rounded px-3 py-2" 
                               value="<?php echo date('Y-m-d'); ?>">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Notes</label>
                        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3"></textarea>
                    </div>
                    
                    <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
                        Add Livestock Batch
                    </button>
                </form>
            </div>
            
            <!-- Add Inventory Item -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-bold mb-4">📦 Add Inventory Item</h2>
                <form method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="add_inventory">
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Item Name</label>
                        <input type="text" name="item_name" class="w-full border rounded px-3 py-2" required>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Category</label>
                        <select name="category" class="w-full border rounded px-3 py-2">
                            <option value="Feed">Feed</option>
                            <option value="Medicine">Medicine</option>
                            <option value="Equipment">Equipment</option>
                            <option value="Supplies">Supplies</option>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Quantity</label>
                        <input type="number" name="quantity" class="w-full border rounded px-3 py-2" required>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Unit</label>
                        <input type="text" name="unit" class="w-full border rounded px-3 py-2" value="kg">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Unit Cost ($)</label>
                        <input type="number" step="0.01" name="unit_cost" class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Min Stock Level</label>
                        <input type="number" name="min_stock_level" class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                        Add Inventory Item
                    </button>
                </form>
            </div>
            
            <!-- Add Equipment -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-bold mb-4">🔧 Add Equipment</h2>
                <form method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="add_equipment">
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Equipment Name</label>
                        <input type="text" name="equipment_name" class="w-full border rounded px-3 py-2" required>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Equipment Type</label>
                        <select name="equipment_type" class="w-full border rounded px-3 py-2">
                            <option value="Machinery">Machinery</option>
                            <option value="Vehicle">Vehicle</option>
                            <option value="Building">Building</option>
                            <option value="Tool">Tools</option>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Purchase Cost ($)</label>
                        <input type="number" step="0.01" name="purchase_cost" class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Status</label>
                        <select name="status" class="w-full border rounded px-3 py-2">
                            <option value="OPERATIONAL">Operational</option>
                            <option value="MAINTENANCE">Maintenance</option>
                            <option value="REPAIR">Repair</option>
                            <option value="RETIRED">Retired</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700">
                        Add Equipment
                    </button>
                </form>
            </div>
            
            <!-- Add Task -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-bold mb-4">📋 Add Task</h2>
                <form method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="add_task">
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Task Title</label>
                        <input type="text" name="task_title" class="w-full border rounded px-3 py-2" required>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Description</label>
                        <textarea name="description" class="w-full border rounded px-3 py-2" rows="3"></textarea>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Priority</label>
                        <select name="priority" class="w-full border rounded px-3 py-2">
                            <option value="HIGH">High</option>
                            <option value="MEDIUM">Medium</option>
                            <option value="LOW">Low</option>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Due Date</label>
                        <input type="date" name="due_date" class="w-full border rounded px-3 py-2" 
                               value="<?php echo date('Y-m-d', strtotime('+1 week')); ?>">
                    </div>
                    
                    <button type="submit" class="bg-orange-600 text-white px-4 py-2 rounded hover:bg-orange-700">
                        Add Task
                    </button>
                </form>
            </div>
            
            <!-- Add Financial Transaction -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-bold mb-4">💰 Add Financial Transaction</h2>
                <form method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="add_transaction">
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Transaction Type</label>
                        <select name="transaction_type" class="w-full border rounded px-3 py-2">
                            <option value="INCOME">Income</option>
                            <option value="EXPENSE">Expense</option>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Amount ($)</label>
                        <input type="number" step="0.01" name="amount" class="w-full border rounded px-3 py-2" required>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Description</label>
                        <input type="text" name="description" class="w-full border rounded px-3 py-2" required>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium mb-1">Category</label>
                        <select name="category" class="w-full border rounded px-3 py-2">
                            <option value="OPERATION">Operation</option>
                            <option value="MAINTENANCE">Maintenance</option>
                            <option value="FEED">Feed</option>
                            <option value="MEDICINE">Medicine</option>
                            <option value="EQUIPMENT">Equipment</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
                        Add Transaction
                    </button>
                </form>
            </div>
        </div>
        
        <div class="mt-8 text-center">
            <a href="../public/index.php?page=dashboard" class="bg-gray-600 text-white px-6 py-2 rounded hover:bg-gray-700">
                ← Back to Dashboard
            </a>
        </div>
    </div>
</body>
</html>
