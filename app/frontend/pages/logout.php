<?php
/**
 * Logout Handler
 * Clears JWT tokens and session data
 */

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/../lib/api_client.php';

// Clear JWT tokens
global $jwt_manager;
$jwt_manager->clearTokens();

// Clear session
session_destroy();

// Redirect to login
header('Location: login.php');
exit;
?>
