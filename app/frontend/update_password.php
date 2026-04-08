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
 * Update Manager Password Immediately
 */

echo "<h2>🔧 Updating Manager Password...</h2>";

try {
    $pdo = new PDO((string) getenv('DATABASE_URL'), (string) getenv('DB_USER'), (string) getenv('DB_PASSWORD'));
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Create new PHP-compatible hash
    $new_hash = password_hash($newPassword, PASSWORD_DEFAULT);
    
    // Update the database
    $update_stmt = $pdo->prepare("UPDATE users SET hashed_password = :hash WHERE email = :email");
    $result = $update_stmt->execute(['hash' => $new_hash, 'email' => $targetEmail]);
    
    if ($result) {
        echo "<p style='color: green; font-weight: bold;'>✅ Password updated successfully!</p>";
        
        // Verify the update
        $verify_stmt = $pdo->prepare("SELECT hashed_password FROM users WHERE email = :email");
        $verify_stmt->execute(['email' => $targetEmail]);
        $stored_hash = $verify_stmt->fetchColumn();
        
        if (is_string($stored_hash) && password_verify($newPassword, $stored_hash)) {
            echo "<p style='color: green;'>✅ Password verification successful!</p>";
        } else {
            echo "<p style='color: red;'>❌ Password verification failed!</p>";
        }
        
    } else {
        echo "<p style='color: red;'>❌ Failed to update password!</p>";
    }
    
} catch(PDOException $e) {
    echo "<p style='color: red;'>❌ Database error: " . htmlspecialchars($e->getMessage()) . "</p>";
}

echo "<hr>";
echo "<p><a href='debug_auth.php'>Debug Authentication</a> | ";
echo "<a href='pages/login.php'>Go to Login</a></p>";
?>
