<?php
/**
 * Update Manager Password Immediately
 */

echo "<h2>🔧 Updating Manager Password...</h2>";

// Database connection
$host = 'localhost';
$dbname = 'begin_masimba_farm';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Create new PHP-compatible hash
    $new_password = 'manager123';
    $new_hash = password_hash($new_password, PASSWORD_DEFAULT);
    
    echo "<h3>New Password Hash:</h3>";
    echo "<p><strong>Password:</strong> " . htmlspecialchars($new_password) . "</p>";
    echo "<p><strong>Hash:</strong> " . htmlspecialchars($new_hash) . "</p>";
    
    // Update the database
    $update_stmt = $pdo->prepare("UPDATE users SET hashed_password = :hash WHERE email = :email");
    $result = $update_stmt->execute(['hash' => $new_hash, 'email' => 'manager@masimba.farm']);
    
    if ($result) {
        echo "<p style='color: green; font-weight: bold;'>✅ Password updated successfully!</p>";
        
        // Verify the update
        $verify_stmt = $pdo->prepare("SELECT hashed_password FROM users WHERE email = :email");
        $verify_stmt->execute(['email' => 'manager@masimba.farm']);
        $stored_hash = $verify_stmt->fetchColumn();
        
        if (password_verify($new_password, $stored_hash)) {
            echo "<p style='color: green;'>✅ Password verification successful!</p>";
        } else {
            echo "<p style='color: red;'>❌ Password verification failed!</p>";
        }
        
        // Test authentication
        require_once 'simple_auth.php';
        $test_user = authenticate_user('manager@masimba.farm', $new_password);
        
        if ($test_user) {
            echo "<p style='color: green; font-weight: bold;'>✅ Authentication test successful!</p>";
            echo "<p><strong>User:</strong> " . htmlspecialchars($test_user['name']) . "</p>";
            echo "<p><strong>Email:</strong> " . htmlspecialchars($test_user['email']) . "</p>";
            echo "<p><strong>Role:</strong> " . htmlspecialchars($test_user['role']) . "</p>";
            
            echo "<hr>";
            echo "<h3>🎉 Ready to Login!</h3>";
            echo "<p><strong>Login URL:</strong> <a href='pages/login.php'>Login Page</a></p>";
            echo "<p><strong>Email:</strong> manager@masimba.farm</p>";
            echo "<p><strong>Password:</strong> manager123</p>";
            
        } else {
            echo "<p style='color: red;'>❌ Authentication test failed!</p>";
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
