<?php
/**
 * Test Login Directly
 */

// Start session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once 'simple_auth.php';

echo "<h2>🔑 Testing Login Process</h2>";

// Simulate login POST request
$_SERVER['REQUEST_METHOD'] = 'POST';
$_POST['email'] = 'manager@masimba.farm';
$_POST['password'] = 'manager123';

echo "<h3>Login Credentials:</h3>";
echo "<p><strong>Email:</strong> " . htmlspecialchars($_POST['email']) . "</p>";
echo "<p><strong>Password:</strong> " . htmlspecialchars($_POST['password']) . "</p>";

// Test authentication
$user = authenticate_user($_POST['email'], $_POST['password']);

if ($user) {
    echo "<p style='color: green; font-weight: bold;'>✅ Authentication successful!</p>";
    echo "<p><strong>User:</strong> " . htmlspecialchars($user['name']) . "</p>";
    echo "<p><strong>Email:</strong> " . htmlspecialchars($user['email']) . "</p>";
    echo "<p><strong>Role:</strong> " . htmlspecialchars($user['role']) . "</p>";
    echo "<p><strong>ID:</strong> " . $user['id'] . "</p>";
    
    // Set session like login page would
    $_SESSION['user'] = [
        'id' => $user['id'],
        'name' => $user['name'],
        'email' => $user['email'],
        'role' => $user['role']
    ];
    
    echo "<h3>Session Data:</h3>";
    echo "<pre>" . print_r($_SESSION, true) . "</pre>";
    
    echo "<h3>✅ Login Should Work!</h3>";
    echo "<p>The login process is working correctly.</p>";
    echo "<p><a href='pages/login.php'>Try the actual login page</a></p>";
    
} else {
    echo "<p style='color: red; font-weight: bold;'>❌ Authentication failed!</p>";
    echo "<p>There's still an issue with authentication.</p>";
}

echo "<hr>";
echo "<p><a href='debug_auth.php'>Debug Authentication</a> | ";
echo "<a href='pages/login.php'>Login Page</a> | ";
echo "<a href='public/index.php?page=dashboard'>Dashboard</a></p>";
?>
