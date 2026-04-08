<?php
require_once __DIR__ . '/../backend/config/env.php';

$appEnv = strtolower((string) (getenv('APP_ENV') ?: 'production'));
$remoteAddr = (string) ($_SERVER['REMOTE_ADDR'] ?? '');
if (in_array($appEnv, ['production', 'prod', 'staging'], true) || !in_array($remoteAddr, ['127.0.0.1', '::1'], true)) {
    http_response_code(404);
    exit;
}

$targetEmail = (string) (getenv('PASSWORD_RESET_EMAIL') ?: '');
$newPassword = (string) (getenv('PASSWORD_RESET_NEW_PASSWORD') ?: '');
if ($targetEmail === '' || $newPassword === '') {
    echo "<p style='color: orange;'>⚠️ Set PASSWORD_RESET_EMAIL and PASSWORD_RESET_NEW_PASSWORD to run this page.</p>";
    exit;
}

/**
 * Fix Manager Password with PHP Hash
 */

try {
    $pdo = new PDO((string) getenv('DATABASE_URL'), (string) getenv('DB_USER'), (string) getenv('DB_PASSWORD'));
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>🔧 Fix Manager Password</h2>";
    
    // Get current user info
    $stmt = $pdo->prepare("SELECT id, name, email, hashed_password FROM users WHERE email = :email");
    $stmt->execute(['email' => $targetEmail]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        echo "<h3>Current User Info:</h3>";
        echo "<p><strong>Name:</strong> " . htmlspecialchars($user['name']) . "</p>";
        echo "<p><strong>Email:</strong> " . htmlspecialchars($user['email']) . "</p>";
        echo "<p><strong>Current Hash:</strong> " . htmlspecialchars(substr($user['hashed_password'], 0, 30)) . "...</p>";
        
        // Create new PHP-compatible hash
        $new_hash = password_hash($newPassword, PASSWORD_DEFAULT);
        
        // Test the new hash
        if (password_verify($newPassword, $new_hash)) {
            echo "<p style='color: green;'>✅ New hash verified successfully!</p>";
        } else {
            echo "<p style='color: red;'>❌ New hash verification failed!</p>";
        }
        
        // Update the database
        if (isset($_GET['confirm']) && $_GET['confirm'] === 'yes') {
            $update_stmt = $pdo->prepare("UPDATE users SET hashed_password = :hash WHERE email = :email");
            $update_stmt->execute(['hash' => $new_hash, 'email' => $targetEmail]);
            
            echo "<p style='color: green; font-weight: bold;'>✅ Password updated successfully!</p>";
            echo "<p><a href='pages/login.php'>Go to Login Page</a></p>";
        } else {
            echo "<p><a href='fix_password.php?confirm=yes'>Click here to confirm password update</a></p>";
        }
        
    } else {
        echo "<p style='color: red;'>❌ Manager user not found!</p>";
    }
    
    // Test authentication after update
    if (isset($_GET['test'])) {
        echo "<h3>Testing Authentication:</h3>";
        
        require_once 'simple_auth.php';
        $test_user = authenticate_user($targetEmail, $newPassword);
        
        if ($test_user) {
            echo "<p style='color: green;'>✅ Authentication successful!</p>";
            echo "<p><strong>User:</strong> " . htmlspecialchars($test_user['name']) . "</p>";
        } else {
            echo "<p style='color: red;'>❌ Authentication failed!</p>";
        }
    }
    
    echo "<hr>";
    echo "<p><a href='fix_password.php?test=1'>Test Authentication</a> | ";
    echo "<a href='debug_auth.php'>Debug Authentication</a> | ";
    echo "<a href='pages/login.php'>Login Page</a></p>";
    
} catch(PDOException $e) {
    echo "<p style='color: red;'>❌ Database error: " . htmlspecialchars($e->getMessage()) . "</p>";
}
?>
