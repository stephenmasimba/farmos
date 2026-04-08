<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Set language from query parameter
if (isset($_GET['lang']) && in_array($_GET['lang'], ['en', 'sn', 'nd'])) {
    $_SESSION['lang'] = $_GET['lang'];
}

// Default language
$lang_code = $_SESSION['lang'] ?? 'en';

// Load language file
$lang_file = __DIR__ . "/../lang/{$lang_code}.php";
$translations = file_exists($lang_file) ? require $lang_file : require __DIR__ . "/../lang/en.php";

// Translation function
function __($key) {
    global $translations;
    return $translations[$key] ?? $key;
}
?>
