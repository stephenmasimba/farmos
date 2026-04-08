<?php
/**
 * Simple Working Login Page
 */

// Start session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once 'simple_auth.php';

$error = null;

// Check if user is already logged in
if (isset($_SESSION['user'])) {
    header('Location: public/index.php?page=dashboard');
    exit;
}

// Handle login
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    echo "<div style='background: #f0f0f0; padding: 10px; margin: 10px; border-radius: 5px;'>";
    echo "<strong>Debug:</strong> Processing login for " . htmlspecialchars($email) . "<br>";
    
    $user = authenticate_user($email, $password);
    
    if ($user) {
        echo "✅ Authentication successful!<br>";
        $_SESSION['user'] = [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role']
        ];
        echo "Session set. Redirecting to dashboard...<br>";
        header('Location: public/index.php?page=dashboard');
        exit;
    } else {
        echo "❌ Authentication failed!<br>";
        $error = 'Invalid email or password';
    }
    echo "</div>";
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>FarmOS Login</title>
    <style>
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #22c55e, #16a34a); margin: 0; padding: 20px; }
        .container { max-width: 400px; margin: 50px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #22c55e; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; }
        button:hover { background: #16a34a; }
        .error { color: red; margin-bottom: 15px; padding: 10px; background: #ffe6e6; border-radius: 5px; }
        .title { text-align: center; margin-bottom: 30px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="title">
            <h1>🌾 FarmOS</h1>
            <p>Smart Agriculture Platform</p>
        </div>
        
        <?php if ($error): ?>
            <div class="error"><?php echo htmlspecialchars($error); ?></div>
        <?php endif; ?>
        
        <form method="POST" action="">
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" value="manager@masimba.farm" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" value="manager123" required>
            </div>
            
            <button type="submit">Sign In</button>
        </form>
        
        <p style="text-align: center; margin-top: 20px; color: white;">
            <strong>Test Credentials:</strong><br>
            Email: manager@masimba.farm<br>
            Password: manager123
        </p>
    </div>
</body>
</html>
