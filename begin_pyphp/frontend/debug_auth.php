<?php
require_once 'simple_auth.php';

echo "<h2>🔍 Authentication Debug</h2>";

echo "<h3>Testing authentication...</h3>";
$user = authenticate_user('manager@masimba.farm', 'manager123');

if ($user) {
    echo "<p style='color: green;'>✅ Authentication successful!</p>";
    echo "<p><strong>User:</strong> " . htmlspecialchars($user['name']) . " (ID: " . $user['id'] . ")</p>";
    echo "<p><strong>Email:</strong> " . htmlspecialchars($user['email']) . "</p>";
    echo "<p><strong>Role:</strong> " . htmlspecialchars($user['role']) . "</p>";
} else {
    echo "<p style='color: red;'>❌ Authentication failed!</p>";
    
    echo "<h3>Checking database connection...</h3>";
    try {
        $pdo = new PDO('mysql:host=localhost;dbname=begin_masimba_farm;charset=utf8mb4', 'root', '');
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "<p style='color: green;'>✅ Database connected</p>";
        
        $stmt = $pdo->prepare('SELECT id, name, email, hashed_password, role FROM users WHERE email = :email');
        $stmt->execute(['email' => 'manager@masimba.farm']);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            echo "<p style='color: green;'>✅ User found: " . htmlspecialchars($user['name']) . "</p>";
            echo "<p><strong>Password hash exists:</strong> " . (!empty($user['hashed_password']) ? 'Yes' : 'No') . "</p>";
            echo "<p><strong>Password hash preview:</strong> " . htmlspecialchars(substr($user['hashed_password'], 0, 30)) . "...</p>";
            
            echo "<h3>Testing password verification...</h3>";
            
            // Test with password_verify (for PHP hashes)
            if (password_verify('manager123', $user['hashed_password'])) {
                echo "<p style='color: green;'>✅ password_verify() successful!</p>";
            } else {
                echo "<p style='color: orange;'>⚠️ password_verify() failed, trying bcrypt...</p>";
                
                // Test with bcrypt (for Python hashes)
                if (function_exists('password_verify')) {
                    // Try to detect if it's a bcrypt hash
                    if (substr($user['hashed_password'], 0, 4) === '$2y$' || substr($user['hashed_password'], 0, 4) === '$2b$') {
                        echo "<p style='color: blue;'>🔍 Detected bcrypt hash format</p>";
                        
                        // Try different password variants
                        $passwords = ['manager123', 'Admin123', 'admin123', 'password'];
                        foreach ($passwords as $pwd) {
                            if (password_verify($pwd, $user['hashed_password'])) {
                                echo "<p style='color: green;'>✅ Found working password: " . htmlspecialchars($pwd) . "</p>";
                                break;
                            }
                        }
                    }
                }
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
