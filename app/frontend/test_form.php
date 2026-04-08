<?php
/**
 * Test Form Submission
 */

// Start session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once 'simple_auth.php';

echo "<h2>📝 Testing Form Submission</h2>";

// Check if form was submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    echo "<h3>Form Submitted:</h3>";
    echo "<p><strong>Email:</strong> " . htmlspecialchars($email) . "</p>";
    echo "<p><strong>Password:</strong> " . str_repeat('*', strlen($password)) . "</p>";
    echo "<p><strong>Password Length:</strong> " . strlen($password) . "</p>";
    
    // Test authentication
    $user = authenticate_user($email, $password);
    
    if ($user) {
        echo "<p style='color: green; font-weight: bold;'>✅ Login successful!</p>";
        echo "<p><strong>User:</strong> " . htmlspecialchars($user['name']) . "</p>";
        
        // Set session
        $_SESSION['user'] = [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role']
        ];
        
        echo "<p><strong>Session Set:</strong> Yes</p>";
        echo "<p><a href='public/index.php?page=dashboard'>Go to Dashboard</a></p>";
        
    } else {
        echo "<p style='color: red; font-weight: bold;'>❌ Login failed!</p>";
        echo "<p>Invalid credentials</p>";
    }
} else {
    echo "<h3>Submit the form to test:</h3>";
}

?>

<form method="POST" action="" style="max-width: 400px; margin: 20px 0; padding: 20px; border: 1px solid #ccc; border-radius: 5px;">
    <div style="margin-bottom: 15px;">
        <label for="email" style="display: block; margin-bottom: 5px;">Email:</label>
        <input type="email" id="email" name="email" value="manager@masimba.farm" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;">
    </div>
    
    <div style="margin-bottom: 15px;">
        <label for="password" style="display: block; margin-bottom: 5px;">Password:</label>
        <input type="password" id="password" name="password" value="manager123" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px;">
    </div>
    
    <button type="submit" style="background: #007cba; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer;">Test Login</button>
</form>

<hr>
<p><a href='pages/login.php'>Actual Login Page</a> | <a href='debug_auth.php'>Debug Auth</a></p>
