<?php
require_once __DIR__ . '/../backend/config/env.php';

$appEnv = strtolower((string) (getenv('APP_ENV') ?: 'production'));
$remoteAddr = (string) ($_SERVER['REMOTE_ADDR'] ?? '');
if (in_array($appEnv, ['production', 'prod', 'staging'], true) || !in_array($remoteAddr, ['127.0.0.1', '::1'], true)) {
    http_response_code(404);
    exit;
}

require_once 'simple_auth.php';

$testEmail = (string) (getenv('TEST_AUTH_EMAIL') ?: '');
$testPassword = (string) (getenv('TEST_AUTH_PASSWORD') ?: '');
if ($testEmail === '' || $testPassword === '') {
    echo "<p style='color: orange;'>⚠️ Set TEST_AUTH_EMAIL and TEST_AUTH_PASSWORD to run this debug page.</p>";
    exit;
}

echo "<h2>🔍 Authentication Debug</h2>";

echo "<h3>Testing authentication...</h3>";
$user = authenticate_user($testEmail, $testPassword);

if ($user) {
    echo "<p style='color: green;'>✅ Authentication successful!</p>";
    echo "<p><strong>User:</strong> " . htmlspecialchars($user['name']) . " (ID: " . $user['id'] . ")</p>";
    echo "<p><strong>Email:</strong> " . htmlspecialchars($user['email']) . "</p>";
    echo "<p><strong>Role:</strong> " . htmlspecialchars($user['role']) . "</p>";
} else {
    echo "<p style='color: red;'>❌ Authentication failed!</p>";
    
    echo "<h3>Checking database connection...</h3>";
    try {
        $pdo = new PDO((string) getenv('DATABASE_URL'), (string) getenv('DB_USER'), (string) getenv('DB_PASSWORD'));
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "<p style='color: green;'>✅ Database connected</p>";
        
        $stmt = $pdo->prepare('SELECT id, name, email, hashed_password, role FROM users WHERE email = :email');
        $stmt->execute(['email' => $testEmail]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            echo "<p style='color: green;'>✅ User found: " . htmlspecialchars($user['name']) . "</p>";
            echo "<p><strong>Password hash exists:</strong> " . (!empty($user['hashed_password']) ? 'Yes' : 'No') . "</p>";
            echo "<p><strong>Password hash preview:</strong> " . htmlspecialchars(substr($user['hashed_password'], 0, 30)) . "...</p>";
            
            echo "<h3>Testing password verification...</h3>";
            
            // Test with password_verify
            if (password_verify($testPassword, $user['hashed_password'])) {
                echo "<p style='color: green;'>✅ password_verify() successful!</p>";
            } else {
                echo "<p style='color: orange;'>⚠️ password_verify() failed</p>";
            }
        } else {
            echo "<p style='color: red;'>❌ User not found!</p>";
        }
        
        // List all users
        echo "<h3>All users in database:</h3>";
        $stmt = $pdo->query('SELECT id, name, email, role FROM users ORDER BY id');
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
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
}

echo "<hr>";
echo "<h3>Session Status:</h3>";
echo "<p><strong>Session status:</strong> " . session_status() . "</p>";
echo "<p><strong>Session ID:</strong> " . session_id() . "</p>";

if (isset($_SESSION)) {
    echo "<p><strong>Session data:</strong></p>";
    echo "<pre>" . print_r($_SESSION, true) . "</pre>";
}

echo "<hr>";
echo "<p><a href='pages/login.php'>Go to Login Page</a></p>";
echo "<p><a href='public/index.php?page=dashboard'>Go to Dashboard</a></p>";
?>
