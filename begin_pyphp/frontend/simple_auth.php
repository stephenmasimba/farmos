<?php
/**
 * Simple PHP Authentication for FarmOS
 * Bypasses Python backend for direct database authentication
 */

// Start session only if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Database configuration
$host = 'localhost';
$dbname = 'begin_masimba_farm';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
}

function authenticate_user($email, $password) {
    global $pdo;
    
    try {
        $stmt = $pdo->prepare("SELECT id, name, email, hashed_password, role FROM users WHERE email = :email");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            // Debug: Log what we're checking
            error_log("Auth attempt for: " . $email);
            error_log("User found: " . $user['name']);
            error_log("Password hash exists: " . (!empty($user['hashed_password']) ? 'Yes' : 'No'));
            
            // Try PHP's password_verify first (for PHP-generated hashes)
            if (password_verify($password, $user['hashed_password'])) {
                error_log("PHP password_verify successful");
                return $user;
            }
            
            // If that fails, try to detect and handle bcrypt hashes from Python
            $hash = $user['hashed_password'];
            
            // Check if it's a bcrypt hash
            if (substr($hash, 0, 4) === '$2y$' || substr($hash, 0, 4) === '$2b$' || substr($hash, 0, 4) === '$2a$') {
                error_log("Detected bcrypt hash, trying compatibility");
                
                // Try password_verify again (it should work with bcrypt)
                if (password_verify($password, $hash)) {
                    error_log("bcrypt password_verify successful");
                    return $user;
                }
                
                // If still failing, try to re-hash with PHP format
                $info = password_get_info($hash);
                if ($info && isset($info['algo']) && $info['algo'] === PASSWORD_BCRYPT) {
                    error_log("Valid bcrypt hash but verification failed - wrong password");
                }
            }
            
            error_log("Password verification failed for all methods");
        } else {
            error_log("User not found: " . $email);
        }
        return false;
    } catch(PDOException $e) {
        error_log("Authentication error: " . $e->getMessage());
        return false;
    }
}

// Handle login request (only if this is the actual login script)
if (basename($_SERVER['PHP_SELF']) === 'simple_auth.php' && $_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'login') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    $user = authenticate_user($email, $password);
    
    if ($user) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_name'] = $user['name'];
        $_SESSION['user_email'] = $user['email'];
        $_SESSION['user_role'] = $user['role'];
        $_SESSION['access_token'] = 'php_token_' . $user['id'];
        
        // Return success response
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'role' => $user['role']
            ]
        ]);
        exit;
    } else {
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'error' => 'Invalid credentials'
        ]);
        exit;
    }
}

// Handle logout
if (isset($_GET['action']) && $_GET['action'] === 'logout') {
    session_destroy();
    header('Location: index.php?page=login');
    exit;
}

// Check if user is logged in
function is_logged_in() {
    return isset($_SESSION['user_id']);
}

function get_current_user_data() {
    if (is_logged_in()) {
        return [
            'id' => $_SESSION['user_id'],
            'name' => $_SESSION['user_name'],
            'email' => $_SESSION['user_email'],
            'role' => $_SESSION['user_role']
        ];
    }
    return null;
}
?>
