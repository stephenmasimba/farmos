<?php
/**
 * Pure PHP Authentication
 */

// Start session if not already started
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

function authenticate_user_pure($email, $password) {
    global $pdo;
    
    try {
        $stmt = $pdo->prepare("SELECT id, name, email, hashed_password, role FROM users WHERE email = :email");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user && password_verify($password, $user['hashed_password'])) {
            // Update last login
            $update_stmt = $pdo->prepare("UPDATE users SET last_login = NOW() WHERE id = :id");
            $update_stmt->execute(['id' => $user['id']]);
            return $user;
        }
        return false;
    } catch(PDOException $e) {
        error_log("Authentication error: " . $e->getMessage());
        return false;
    }
}

function is_logged_in_pure() {
    return isset($_SESSION['user']);
}

function get_current_user_pure() {
    return $_SESSION['user'] ?? null;
}

function logout_pure() {
    session_destroy();
    header('Location: login.php');
    exit;
}

// Handle login request
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'login') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    $user = authenticate_user_pure($email, $password);
    
    if ($user) {
        $_SESSION['user'] = [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role']
        ];
        
        // Return JSON success response
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'user' => $_SESSION['user'],
            'message' => 'Login successful'
        ]);
        exit;
    } else {
        // Return JSON error response
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'error' => 'Invalid email or password'
        ]);
        exit;
    }
}

// Handle logout
if (isset($_GET['action']) && $_GET['action'] === 'logout') {
    logout_pure();
}
?>
