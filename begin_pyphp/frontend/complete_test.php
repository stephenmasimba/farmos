<?php
/**
 * Complete Login Flow Test
 */

echo "<h2>🔧 Complete Login Flow Test</h2>";

// Test 1: Database Connection
echo "<h3>1. Database Connection:</h3>";
try {
    $pdo = new PDO("mysql:host=localhost;dbname=begin_masimba_farm;charset=utf8mb4", 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<p style='color: green;'>✅ Database connected</p>";
} catch(PDOException $e) {
    echo "<p style='color: red;'>❌ Database error: " . htmlspecialchars($e->getMessage()) . "</p>";
    exit;
}

// Test 2: User Exists
echo "<h3>2. User Check:</h3>";
$stmt = $pdo->prepare("SELECT id, name, email, hashed_password, role FROM users WHERE email = :email");
$stmt->execute(['email' => 'manager@masimba.farm']);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    echo "<p style='color: green;'>✅ User found: " . htmlspecialchars($user['name']) . "</p>";
    echo "<p><strong>Hash format:</strong> " . htmlspecialchars(substr($user['hashed_password'], 0, 10)) . "...</p>";
} else {
    echo "<p style='color: red;'>❌ User not found</p>";
    exit;
}

// Test 3: Password Verification
echo "<h3>3. Password Verification:</h3>";
if (password_verify('manager123', $user['hashed_password'])) {
    echo "<p style='color: green;'>✅ Password verified successfully</p>";
} else {
    echo "<p style='color: red;'>❌ Password verification failed</p>";
}

// Test 4: Authentication Function
echo "<h3>4. Authentication Function:</h3>";
require_once 'simple_auth.php';
$auth_user = authenticate_user('manager@masimba.farm', 'manager123');

if ($auth_user) {
    echo "<p style='color: green;'>✅ Authentication function works</p>";
    echo "<p><strong>Auth user:</strong> " . htmlspecialchars($auth_user['name']) . "</p>";
} else {
    echo "<p style='color: red;'>❌ Authentication function failed</p>";
}

// Test 5: Session Management
echo "<h3>5. Session Management:</h3>";
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$_SESSION['user'] = [
    'id' => $auth_user['id'],
    'name' => $auth_user['name'],
    'email' => $auth_user['email'],
    'role' => $auth_user['role']
];

echo "<p style='color: green;'>✅ Session data set</p>";
echo "<pre>" . print_r($_SESSION, true) . "</pre>";

// Test 6: Dashboard Access
echo "<h3>6. Dashboard Access Test:</h3>";
if (isset($_SESSION['user'])) {
    echo "<p style='color: green;'>✅ User logged in, can access dashboard</p>";
    echo "<p><a href='public/index.php?page=dashboard' target='_blank'>Open Dashboard</a></p>";
} else {
    echo "<p style='color: red;'>❌ User not logged in</p>";
}

echo "<hr>";
echo "<h3>🎯 Summary:</h3>";
echo "<p>If all tests show ✅, then login should work perfectly.</p>";
echo "<p>If any test shows ❌, that's the issue to fix.</p>";

echo "<hr>";
echo "<p><strong>Next Steps:</strong></p>";
echo "<p>1. <a href='pages/login.php'>Try Login Page</a></p>";
echo "<p>2. <a href='public/index.php?page=dashboard'>Go to Dashboard</a></p>";
echo "<p>3. <a href='check_login.php'>Check Current Status</a></p>";
?>
