<?php
/**
 * Test Authentication Script
 */

// Start session only if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once 'simple_auth.php';

echo "<h2>🔐 FarmOS Authentication Test</h2>";

// Test login
echo "<h3>Testing Login:</h3>";
$user = authenticate_user('manager@masimba.farm', 'manager123');

if ($user) {
    echo "<p style='color: green;'>✅ Login successful!</p>";
    echo "<p><strong>User:</strong> " . htmlspecialchars($user['name']) . "</p>";
    echo "<p><strong>Email:</strong> " . htmlspecialchars($user['email']) . "</p>";
    echo "<p><strong>Role:</strong> " . htmlspecialchars($user['role']) . "</p>";
    echo "<p><strong>ID:</strong> " . $user['id'] . "</p>";
} else {
    echo "<p style='color: red;'>❌ Login failed!</p>";
}

// Test session functions
echo "<h3>Testing Session Functions:</h3>";
echo "<p><strong>is_logged_in():</strong> " . (is_logged_in() ? 'true' : 'false') . "</p>";

$current_user = get_current_user_data();
if ($current_user) {
    echo "<p><strong>Current User:</strong> " . htmlspecialchars($current_user['name']) . "</p>";
} else {
    echo "<p><strong>Current User:</strong> Not logged in</p>";
}

// Test database connection
echo "<h3>Testing Database:</h3>";
try {
    $pdo = new PDO("mysql:host=localhost;dbname=begin_masimba_farm;charset=utf8mb4", 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "<p style='color: green;'>✅ Database connected!</p>";
    echo "<p><strong>Total Users:</strong> " . $result['count'] . "</p>";
    
    // List users
    $stmt = $pdo->query("SELECT id, name, email, role FROM users ORDER BY id");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<h4>Available Users:</h4>";
    echo "<table border='1' cellpadding='5'>";
    echo "<tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th></tr>";
    foreach ($users as $user) {
        echo "<tr>";
        echo "<td>" . $user['id'] . "</td>";
        echo "<td>" . htmlspecialchars($user['name']) . "</td>";
        echo "<td>" . htmlspecialchars($user['email']) . "</td>";
        echo "<td>" . htmlspecialchars($user['role']) . "</td>";
        echo "</tr>";
    }
    echo "</table>";
    
} catch(PDOException $e) {
    echo "<p style='color: red;'>❌ Database error: " . htmlspecialchars($e->getMessage()) . "</p>";
}

echo "<hr>";
echo "<p><a href='pages/login.php'>Go to Login Page</a></p>";
echo "<p><a href='public/index.php?page=dashboard'>Go to Dashboard</a></p>";
?>
