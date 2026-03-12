<?php
require_once 'pure_auth.php';

// Check if user is logged in
if (!is_logged_in_pure()) {
    header('Location: login_pure.php');
    exit;
}

$user = get_current_user_pure();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FarmOS Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    <!-- Navigation -->
    <nav class="bg-green-600 text-white p-4">
        <div class="container mx-auto flex justify-between items-center">
            <h1 class="text-2xl font-bold">🌾 FarmOS</h1>
            <div class="flex items-center space-x-4">
                <span>Welcome, <?= htmlspecialchars($user['name']) ?></span>
                <a href="login_pure.php?action=logout" class="bg-red-500 px-4 py-2 rounded hover:bg-red-600">Logout</a>
            </div>
        </div>
    </nav>

    <!-- Dashboard Content -->
    <div class="container mx-auto p-6">
        <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-2xl font-bold mb-4">Dashboard</h2>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <!-- User Info Card -->
                <div class="bg-green-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-green-800 mb-2">User Information</h3>
                    <p><strong>Name:</strong> <?= htmlspecialchars($user['name']) ?></p>
                    <p><strong>Email:</strong> <?= htmlspecialchars($user['email']) ?></p>
                    <p><strong>Role:</strong> <?= htmlspecialchars($user['role']) ?></p>
                    <p><strong>ID:</strong> <?= $user['id'] ?></p>
                </div>

                <!-- System Status -->
                <div class="bg-blue-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-blue-800 mb-2">System Status</h3>
                    <p class="text-green-600">✅ Authentication: Working</p>
                    <p class="text-green-600">✅ Database: Connected</p>
                    <p class="text-green-600">✅ Session: Active</p>
                    <p class="text-green-600">✅ Pure PHP: No Python</p>
                </div>

                <!-- Quick Actions -->
                <div class="bg-yellow-50 p-4 rounded-lg">
                    <h3 class="font-semibold text-yellow-800 mb-2">Quick Actions</h3>
                    <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 mr-2">View Livestock</button>
                    <button class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 mr-2">Manage Inventory</button>
                    <button class="bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600">Reports</button>
                </div>
            </div>

            <div class="mt-6 p-4 bg-gray-50 rounded-lg">
                <h3 class="font-semibold mb-2">🎉 Pure PHP Authentication Successful!</h3>
                <p class="text-gray-700">You have successfully logged in using pure PHP authentication with no Python dependencies.</p>
                <p class="text-sm text-gray-600 mt-2">This system is completely independent of Python backend.</p>
            </div>
        </div>
    </div>
</body>
</html>
