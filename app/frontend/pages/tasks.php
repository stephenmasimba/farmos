<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

$tasks = [];

$page_title = 'Tasks - Begin Masimba';
$active_page = 'tasks';
require __DIR__ . '/../components/header.php';
?>

<div class="max-w-7xl mx-auto">
    <div class="flex justify-between items-center mb-6">
        <div>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Tasks</h2>
            <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">Manage and track farm activities.</p>
        </div>
        <button onclick="openAddTaskModal()" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm transition-colors flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
            Add Task
        </button>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-sm overflow-hidden sm:rounded-xl border border-gray-100 dark:border-gray-700">
        <ul role="list" class="divide-y divide-gray-200 dark:divide-gray-700">
            <?php if (empty($tasks)): ?>
                <li class="px-4 py-12 text-center">
                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path></svg>
                    <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-white">No tasks found</h3>
                    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Get started by creating a new task.</p>
                </li>
            <?php else: ?>
                <?php foreach ($tasks as $task): ?>
                <li class="px-4 py-4 sm:px-6 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <div class="flex items-center justify-between">
                        <div class="text-sm font-medium text-primary-600 dark:text-primary-400 truncate">
                            <?php echo htmlspecialchars($task['title']); ?>
                        </div>
                        <div class="ml-2 flex-shrink-0 flex">
                            <?php
                                $status = strtolower((string) ($task['status'] ?? ''));
                                switch ($status) {
                                    case 'completed':
                                        $statusColor = 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
                                        break;
                                    case 'in_progress':
                                    case 'ongoing':
                                        $statusColor = 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
                                        break;
                                    case 'pending':
                                        $statusColor = 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
                                        break;
                                    default:
                                        $statusColor = 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
                                        break;
                                }
                            ?>
                            <span class="px-2.5 py-0.5 inline-flex text-xs leading-5 font-medium rounded-full <?php echo $statusColor; ?>">
                                <?php echo htmlspecialchars($task['status']); ?>
                            </span>
                        </div>
                    </div>
                    <div class="mt-2 sm:flex sm:justify-between">
                        <div class="sm:flex">
                            <p class="flex items-center text-sm text-gray-500 dark:text-gray-400">
                                <svg class="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                                Due: <?php echo htmlspecialchars($task['due_date']); ?>
                            </p>
                        </div>
                        <div class="mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400 sm:mt-0">
                             <!-- Placeholder for actions if needed -->
                        </div>
                    </div>
                </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
    </div>
</div>

<!-- Add Task Modal -->
<div id="addTaskModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700">
        <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Add New Task</h3>
        <form id="addTaskForm">
            <input type="hidden" name="farm_id" value="1">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Title</label>
                <input type="text" name="title" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Description</label>
                <textarea name="description" rows="3" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm"></textarea>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Due Date</label>
                <input type="date" name="due_date" required class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
            </div>
            <div class="mb-6">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Priority</label>
                <select name="priority" class="block w-full rounded-md border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm">
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                </select>
            </div>
            <div class="flex justify-end space-x-3">
                <button type="button" onclick="document.getElementById('addTaskModal').classList.add('hidden')" class="bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-md border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600 shadow-sm text-sm font-medium">Cancel</button>
                <button type="submit" class="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 shadow-sm text-sm font-medium">Save Task</button>
            </div>
        </form>
    </div>
</div>

<script>
    const TENANT_ID = window.AppApi.tenantId;

    async function completeTask(taskId) {
        try {
            const result = await window.AppApi.write(`/api/tasks/${taskId}/complete`, { method: 'POST', data: null, showError: false });
            if (result?.queued) {
                alert('You are offline. Task completion has been queued for sync.');
                return;
            }
            window.location.reload();
        } catch (e) {
            alert('Failed to complete task');
        }
    }

    async function renderTasks(items) {
        const list = document.querySelector('ul[role="list"]');
        if (!items || items.length === 0) return;
        list.innerHTML = items.map(task => {
            const s = String(task.status || '').toLowerCase();
            const statusColor = s === 'completed' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' :
                               (s === 'in_progress' || s === 'ongoing') ? 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200' :
                               (s === 'pending') ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200' :
                               'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
            const showComplete = s !== 'completed' && s !== 'cancelled';
            return `
            <li class="px-4 py-4 sm:px-6 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                <div class="flex items-center justify-between">
                    <div class="text-sm font-medium text-primary-600 dark:text-primary-400 truncate">${task.title}</div>
                    <div class="ml-2 flex-shrink-0 flex items-center gap-2">
                        ${showComplete ? `<button type="button" onclick="completeTask(${task.id})" class="px-3 py-1 rounded-md bg-green-600 text-white text-xs font-medium hover:bg-green-700">Complete</button>` : ''}
                        <span class="px-2.5 py-0.5 inline-flex text-xs leading-5 font-medium rounded-full ${statusColor}">${task.status}</span>
                    </div>
                </div>
                <div class="mt-2 sm:flex sm:justify-between">
                    <div class="sm:flex">
                        <p class="flex items-center text-sm text-gray-500 dark:text-gray-400">Due: ${task.due_date}</p>
                    </div>
                </div>
            </li>`;
        }).join('');
    }

    document.addEventListener('DOMContentLoaded', async () => {
        try {
            const cached = await window.OfflineService.getCachedData('/tasks/', 'tasks');
            if (cached && cached.data) renderTasks(cached.data);
            if (navigator.onLine) {
                const payload = await window.AppApi.get(`/api/tasks?farm_id=${TENANT_ID}`, { showError: false });
                const tasks = payload?.tasks || [];
                renderTasks(tasks);
                if (Array.isArray(tasks)) {
                    for (const t of tasks) await window.OfflineService.storeData('tasks', t);
                }
            }
        } catch (e) {}
    });

    function openAddTaskModal() {
        document.getElementById('addTaskModal').classList.remove('hidden');
    }

    document.getElementById('addTaskForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = Object.fromEntries(formData.entries());
        
        try {
            const result = await window.AppApi.write('/api/tasks', { method: 'POST', data, showError: false });
            if (result?.queued) {
                document.getElementById('addTaskModal').classList.add('hidden');
                e.target.reset();
                alert('You are offline. Task has been queued for sync.');
            } else {
                window.location.reload();
            }
        } catch (error) {
            console.error('Error:', error);
            alert(error?.payload?.error?.message || error?.message || 'An error occurred');
        }
    });
</script>
<?php require __DIR__ . '/../components/footer.php'; ?>
