<?php
/**
 * Check Login Issue
 */

// Start session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

echo "<h2>🔍 Checking Login Issue</h2>";

echo "<h3>Current Status:</h3>";
echo "<p><strong>Request Method:</strong> " . htmlspecialchars($_SERVER['REQUEST_METHOD']) . "</p>";
echo "<p><strong>Request URI:</strong> " . htmlspecialchars($_SERVER['REQUEST_URI']) . "</p>";
echo "<p><strong>Script Name:</strong> " . htmlspecialchars($_SERVER['SCRIPT_NAME']) . "</p>";

echo "<h3>POST Data:</h3>";
if ($_POST) {
    echo "<pre>" . print_r($_POST, true) . "</pre>";
} else {
    echo "<p>No POST data received</p>";
}

echo "<h3>Session Data:</h3>";
if (isset($_SESSION)) {
    echo "<pre>" . print_r($_SESSION, true) . "</pre>";
} else {
    echo "<p>No session data</p>";
}

// Test authentication directly
require_once 'simple_auth.php';
echo "<h3>Direct Auth Test:</h3>";
$test_user = authenticate_user('manager@masimba.farm', 'manager123');
if ($test_user) {
    echo "<p style='color: green;'>✅ Direct auth works</p>";
    echo "<p>User: " . htmlspecialchars($test_user['name']) . "</p>";
} else {
    echo "<p style='color: red;'>❌ Direct auth failed</p>";
}

// Check if we're on login page
echo "<h3>Page Check:</h3>";
if (strpos($_SERVER['REQUEST_URI'], 'login.php') !== false) {
    echo "<p>✅ We are on login page</p>";
} else {
    echo "<p>❌ Not on login page</p>";
}

// Check if user should be redirected
if (isset($_SESSION['user'])) {
    echo "<p style='color: green;'>✅ User is logged in</p>";
    echo "<p>Should redirect to dashboard</p>";
} else {
    echo "<p style='color: orange;'>⚠️ User not logged in</p>";
}

echo "<hr>";
echo "<p><a href='pages/login.php'>Go to Login Page</a> | ";
echo "<a href='public/index.php?page=dashboard'>Go to Dashboard</a></p>";
?>
