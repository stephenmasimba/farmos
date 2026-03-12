<?php
/**
 * Fix Manager Password with PHP Hash
 */

// Database connection
$host = 'localhost';
$dbname = 'begin_masimba_farm';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>🔧 Fix Manager Password</h2>";
    
    // Get current user info
    $stmt = $pdo->prepare("SELECT id, name, email, hashed_password FROM users WHERE email = :email");
    $stmt->execute(['email' => 'manager@masimba.farm']);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        echo "<h3>Current User Info:</h3>";
        echo "<p><strong>Name:</strong> " . htmlspecialchars($user['name']) . "</p>";
        echo "<p><strong>Email:</strong> " . htmlspecialchars($user['email']) . "</p>";
        echo "<p><strong>Current Hash:</strong> " . htmlspecialchars(substr($user['hashed_password'], 0, 30)) . "...</p>";
        
        // Create new PHP-compatible hash
        $new_password = 'manager123';
        $new_hash = password_hash($new_password, PASSWORD_DEFAULT);
        
        echo "<h3>New PHP Hash:</h3>";
        echo "<p><strong>Password:</strong> " . htmlspecialchars($new_password) . "</p>";
        echo "<p><strong>New Hash:</strong> " . htmlspecialchars($new_hash) . "</p>";
        
        // Test the new hash
        if (password_verify($new_password, $new_hash)) {
            echo "<p style='color: green;'>✅ New hash verified successfully!</p>";
        } else {
            echo "<p style='color: red;'>❌ New hash verification failed!</p>";
        }
        
        // Update the database
        if (isset($_GET['confirm']) && $_GET['confirm'] === 'yes') {
            $update_stmt = $pdo->prepare("UPDATE users SET hashed_password = :hash WHERE email = :email");
            $update_stmt->execute(['hash' => $new_hash, 'email' => 'manager@masimba.farm']);
            
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
        $test_user = authenticate_user('manager@masimba.farm', 'manager123');
        
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
