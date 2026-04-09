<?php
if (empty($_SESSION['user'])) {
    header('Location: ../public/index.php?page=login');
    exit;
}

// Ensure user is admin (simple check, backend enforces too)
// In a real app, check role from JWT or session
// For now, we assume if they can access the page, they see what the API returns.

$users = [];
$res = call_api('/api/users');
if ($res['status'] === 200) {
    $users = $res['data'];
} elseif ($res['status'] === 403) {
    $error = "You are not authorized to view this page.";
}

$page_title = 'User Management - Begin Masimba';
$active_page = 'users';
require __DIR__ . '/../components/header.php';
?>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="sm:flex sm:items-center sm:justify-between mb-8">
        <div>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">User Management</h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Manage system users, roles, and access permissions.</p>
        </div>
        <div class="mt-4 sm:mt-0">
            <button onclick="openAddUserModal()" class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors w-full sm:w-auto">
                <svg class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                Invite User
            </button>
        </div>
    </div>

    <?php if (isset($error)): ?>
        <div class="bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-300 px-4 py-3 rounded-lg relative mb-6" role="alert">
            <span class="block sm:inline"><?php echo htmlspecialchars($error); ?></span>
        </div>
    <?php else: ?>
    <div class="bg-white dark:bg-gray-800 shadow-sm rounded-xl overflow-hidden border border-gray-100 dark:border-gray-700">
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead class="bg-gray-50 dark:bg-gray-700/50">
                    <tr>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Name</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Email</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Role</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Status</th>
                        <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                    <?php if (empty($users)): ?>
                        <tr>
                            <td colspan="5" class="px-6 py-12 text-center">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
                                </svg>
                                <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">No users found. Invite someone to get started.</p>
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($users as $user): ?>
                        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900 dark:text-white"><?php echo htmlspecialchars($user['name']); ?></div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm text-gray-500 dark:text-gray-400"><?php echo htmlspecialchars($user['email']); ?></div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 py-1 text-xs rounded-full bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300">
                                    <?php echo htmlspecialchars(ucfirst($user['role'])); ?>
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <?php
                                $statusClass = 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300';
                                switch ($user['status']) {
                                    case 'active':
                                        $statusClass = 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300';
                                        break;
                                    case 'inactive':
                                        $statusClass = 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300';
                                        break;
                                    case 'suspended':
                                        $statusClass = 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300';
                                        break;
                                }
                                ?>
                                <span class="px-2 py-1 text-xs rounded-full <?php echo $statusClass; ?>">
                                    <?php echo htmlspecialchars(ucfirst($user['status'])); ?>
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                <button onclick="openAccessModal(<?php echo htmlspecialchars(json_encode($user)); ?>)" class="text-indigo-600 hover:text-indigo-900 dark:text-indigo-400 dark:hover:text-indigo-300 mr-3">Access</button>
                                <button onclick="openEditUserModal(<?php echo htmlspecialchars(json_encode($user)); ?>)" class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300 mr-3">Edit</button>
                                <button onclick="deleteUser(<?php echo $user['id']; ?>)" class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300">Delete</button>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
    <?php endif; ?>
</main>

<!-- User Modal -->
<div id="userModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full p-6 border border-gray-100 dark:border-gray-700 m-4">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white" id="modalTitle">Add User</h3>
            <button onclick="closeUserModal()" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <form id="userForm">
            <input type="hidden" name="id" id="userId">
            <div class="space-y-4">
                <div>
                    <label for="userName" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Name</label>
                    <input type="text" name="name" id="userName" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                <div>
                    <label for="userEmail" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Email</label>
                    <input type="email" name="email" id="userEmail" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
                <div>
                    <label for="userRole" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Role</label>
                    <select name="role" id="userRole" required class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                        <option value="super_admin">Super Admin</option>
                        <option value="admin">Admin</option>
                        <option value="manager">Manager</option>
                        <option value="finance_manager">Finance Manager</option>
                        <option value="inventory_manager">Inventory Manager</option>
                        <option value="livestock_manager">Livestock Manager</option>
                        <option value="auditor">Auditor</option>
                        <option value="worker">Worker</option>
                        <option value="field_worker">Field Worker</option>
                        <option value="user">User</option>
                    </select>
                </div>
                <div>
                    <label for="userStatus" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Status</label>
                    <select name="status" id="userStatus" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                        <option value="suspended">Suspended</option>
                    </select>
                </div>
                <div>
                    <label for="userPassword" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                        Password 
                        <span id="passwordHint" class="text-xs text-gray-500 dark:text-gray-400 font-normal hidden">(Leave blank to keep current)</span>
                    </label>
                    <input type="password" name="password" id="userPassword" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-3">
                <button type="button" onclick="closeUserModal()" class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors">Cancel</button>
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-primary-600 border border-transparent rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 shadow-sm transition-colors">Save User</button>
            </div>
        </form>
    </div>
</div>

<!-- Access Modal -->
<div id="accessModal" class="fixed inset-0 z-50 hidden overflow-y-auto bg-gray-900 bg-opacity-50 backdrop-blur-sm flex items-center justify-center" aria-labelledby="access-modal-title" role="dialog" aria-modal="true">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-3xl w-full p-6 border border-gray-100 dark:border-gray-700 m-4 max-h-[90vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-6">
            <div>
                <h3 class="text-lg font-bold text-gray-900 dark:text-white" id="access-modal-title">Manage Access</h3>
                <p id="accessUserMeta" class="text-sm text-gray-500 dark:text-gray-400"></p>
            </div>
            <button onclick="closeAccessModal()" class="text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>

        <form id="accessForm">
            <input type="hidden" id="accessUserId">
            <div class="mb-4">
                <label for="accessRole" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Role</label>
                <select id="accessRole" class="block w-full rounded-lg border-gray-300 dark:border-gray-600 shadow-sm dark:bg-gray-700 dark:text-white sm:text-sm p-2.5">
                    <option value="super_admin">Super Admin</option>
                    <option value="admin">Admin</option>
                    <option value="manager">Manager</option>
                    <option value="finance_manager">Finance Manager</option>
                    <option value="inventory_manager">Inventory Manager</option>
                    <option value="livestock_manager">Livestock Manager</option>
                    <option value="auditor">Auditor</option>
                    <option value="worker">Worker</option>
                    <option value="field_worker">Field Worker</option>
                    <option value="user">User</option>
                </select>
            </div>

            <div>
                <div class="flex items-center justify-between mb-2">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Permission Overrides</label>
                    <span class="text-xs text-gray-500 dark:text-gray-400">Allow or deny specific permissions for this user</span>
                </div>
                <div id="permissionOverrides" class="grid grid-cols-1 md:grid-cols-2 gap-2 max-h-80 overflow-y-auto border border-gray-200 dark:border-gray-700 rounded-lg p-3">
                </div>
            </div>

            <div class="mt-6 flex justify-end gap-3">
                <button type="button" onclick="closeAccessModal()" class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700">Cancel</button>
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-lg hover:bg-indigo-700">Save Access</button>
            </div>
        </form>
    </div>
</div>

<script>
const token = "<?php echo $_SESSION['access_token'] ?? ''; ?>";
const API_BASE_URL = window.AppApi.baseUrl;
const headers = window.AppApi.jsonHeaders();

let accessCatalogCache = null;

function openAddUserModal() {
    document.getElementById('modalTitle').innerText = 'Add User';
    document.getElementById('userForm').reset();
    document.getElementById('userId').value = '';
    document.getElementById('passwordHint').classList.add('hidden');
    document.getElementById('userPassword').required = true;
    document.getElementById('userModal').classList.remove('hidden');
}

function openEditUserModal(user) {
    document.getElementById('modalTitle').innerText = 'Edit User';
    document.getElementById('userId').value = user.id;
    document.getElementById('userName').value = user.name;
    document.getElementById('userEmail').value = user.email;
    document.getElementById('userRole').value = user.role;
    document.getElementById('userStatus').value = user.status;
    document.getElementById('passwordHint').classList.remove('hidden');
    document.getElementById('userPassword').required = false;
    document.getElementById('userModal').classList.remove('hidden');
}

function closeUserModal() {
    document.getElementById('userModal').classList.add('hidden');
}

function closeAccessModal() {
    document.getElementById('accessModal').classList.add('hidden');
}

async function loadAccessCatalog() {
    if (accessCatalogCache) return accessCatalogCache;
    const res = await fetch(`${API_BASE_URL}/api/access/catalog`, { headers });
    if (!res.ok) {
        throw new Error('Failed to load access catalog');
    }
    accessCatalogCache = await res.json();
    return accessCatalogCache;
}

function renderPermissionOverrides(catalog, rolePermissions, effectivePermissions) {
    const wrapper = document.getElementById('permissionOverrides');
    wrapper.innerHTML = '';

    const roleSet = new Set(rolePermissions || []);
    const effectiveSet = new Set(effectivePermissions || []);

    (catalog || []).forEach((permission) => {
        const row = document.createElement('div');
        row.className = 'flex items-center justify-between rounded-md border border-gray-200 dark:border-gray-700 px-3 py-2';

        const inherited = roleSet.has(permission);
        const effective = effectiveSet.has(permission);

        row.innerHTML = `
            <div>
                <p class="text-xs font-medium text-gray-900 dark:text-white">${permission}</p>
                <p class="text-xs text-gray-500 dark:text-gray-400">${inherited ? 'Inherited from role' : 'Not in role template'}</p>
            </div>
            <select class="permission-effect rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white text-xs" data-permission="${permission}">
                <option value="">Inherit</option>
                <option value="allow" ${effective && !inherited ? 'selected' : ''}>Allow</option>
                <option value="deny" ${!effective && inherited ? 'selected' : ''}>Deny</option>
            </select>
        `;
        wrapper.appendChild(row);
    });
}

async function openAccessModal(user) {
    try {
        const catalogPayload = await loadAccessCatalog();
        const profileRes = await fetch(`${API_BASE_URL}/api/users/${user.id}/access`, { headers });
        if (!profileRes.ok) {
            alert('Failed to load user access profile');
            return;
        }
        const profilePayload = await profileRes.json();

        const profile = profilePayload || {};
        const rolePermissions = profile.role_permissions || [];
        const effectivePermissions = profile.effective_permissions || [];

        document.getElementById('accessUserId').value = String(user.id);
        document.getElementById('accessRole').value = user.role || 'user';
        document.getElementById('accessUserMeta').innerText = `${user.name} (${user.email})`;

        renderPermissionOverrides(
            catalogPayload.permissions || [],
            rolePermissions,
            effectivePermissions
        );

        document.getElementById('accessModal').classList.remove('hidden');
    } catch (err) {
        console.error(err);
        alert('Failed to load access data');
    }
}

async function deleteUser(id) {
    if (!confirm('Are you sure you want to delete this user?')) return;
    
    try {
        const res = await fetch(`${API_BASE_URL}/api/users/${id}`, {
            method: 'DELETE',
            headers: headers
        });
        if (res.ok || res.status === 204) {
            window.location.reload();
        } else {
            alert('Failed to delete user');
        }
    } catch (err) {
        console.error(err);
        alert('Error deleting user');
    }
}

document.getElementById('userForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('userId').value;
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    
    // Remove empty password if editing
    if (id && !data.password) {
        delete data.password;
    }
    
    const url = id ? `${API_BASE_URL}/api/users/${id}` : `${API_BASE_URL}/api/users/`;
    const method = id ? 'PUT' : 'POST';
    
    try {
        const res = await fetch(url, {
            method: method,
            headers: headers,
            body: JSON.stringify(data)
        });
        
        if (res.ok) {
            window.location.reload();
        } else {
            const err = await res.json();
            alert('Error: ' + (err.detail || 'Operation failed'));
        }
    } catch (err) {
        console.error(err);
        alert('Error saving user');
    }
});

document.getElementById('accessForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const userId = document.getElementById('accessUserId').value;
    const role = document.getElementById('accessRole').value;

    const roleRes = await fetch(`${API_BASE_URL}/api/users/${userId}/role`, {
        method: 'PUT',
        headers,
        body: JSON.stringify({ role })
    });

    if (!roleRes.ok) {
        let msg = 'Failed to update role';
        try {
            const err = await roleRes.json();
            msg = err?.error?.message || msg;
        } catch (parseErr) {}
        alert(msg);
        return;
    }

    const permissions = Array.from(document.querySelectorAll('.permission-effect'))
        .map((el) => ({ permission: el.dataset.permission, effect: el.value }))
        .filter((it) => it.effect === 'allow' || it.effect === 'deny');

    const permRes = await fetch(`${API_BASE_URL}/api/users/${userId}/permissions`, {
        method: 'PUT',
        headers,
        body: JSON.stringify({ permissions })
    });

    if (!permRes.ok) {
        let msg = 'Failed to update permission overrides';
        try {
            const err = await permRes.json();
            msg = err?.error?.message || msg;
        } catch (parseErr) {}
        alert(msg);
        return;
    }

    window.location.reload();
});
</script>
</body>
</html>
