<?php
// Start session only if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/../lib/api_client.php';

// Get page parameter from URL
$page = $_GET['page'] ?? 'dashboard';

// If user is not logged in and not on login page, redirect to login
if (!isset($_SESSION['user']) && $page !== 'login') {
    header('Location: index.php?page=login');
    exit;
}

// Route to appropriate page
switch ($page) {
  case 'login':
    require __DIR__ . '/../pages/login.php';
    break;
  case 'dashboard':
    require __DIR__ . '/../pages/dashboard.php';
    break;
  case 'livestock':
    require __DIR__ . '/../pages/livestock.php';
    break;
  case 'breeding':
    require __DIR__ . '/../pages/breeding.php';
    break;
  case 'inventory':
    require __DIR__ . '/../pages/inventory.php';
    break;
  case 'suppliers':
    require __DIR__ . '/../pages/suppliers.php';
    break;
  case 'equipment':
    require __DIR__ . '/../pages/equipment.php';
    break;
  case 'fields':
    require __DIR__ . '/../pages/fields.php';
    break;
  case 'tasks':
    require __DIR__ . '/../pages/tasks.php';
    break;
  case 'timesheets':
    require __DIR__ . '/../pages/timesheets.php';
    break;
  case 'financial':
    require __DIR__ . '/../pages/financial.php';
    break;
  case 'payments':
    require __DIR__ . '/../pages/payments.php';
    break;
  case 'contracts':
    require __DIR__ . '/../pages/contracts.php';
    break;
  case 'marketplace':
    require __DIR__ . '/../pages/marketplace.php';
    break;
  case 'traceability':
    require __DIR__ . '/../pages/traceability.php';
    break;
  case 'feed':
    require __DIR__ . '/../pages/feed.php';
    break;
  case 'waste':
    require __DIR__ . '/../pages/waste.php';
    break;
  case 'compliance':
    require __DIR__ . '/../pages/compliance.php';
    break;
  case 'hr':
    require __DIR__ . '/../pages/hr.php';
    break;
  case 'iot':
    require __DIR__ . '/../pages/iot.php';
    break;
  case 'weather':
    require __DIR__ . '/../pages/weather.php';
    break;
  case 'analytics':
    require __DIR__ . '/../pages/analytics.php';
    break;
  case 'reports':
    require __DIR__ . '/../pages/reports.php';
    break;
  case 'users':
    require __DIR__ . '/../pages/users.php';
    break;
  case 'settings':
    require __DIR__ . '/../pages/settings.php';
    break;
  case 'notifications':
    require __DIR__ . '/../pages/notifications.php';
    break;
  case 'data_import':
    require __DIR__ . '/../pages/data_import.php';
    break;
  case 'biogas':
    require __DIR__ . '/../pages/biogas.php';
    break;
  case 'sales_crm':
    require __DIR__ . '/../pages/sales_crm.php';
    break;
  case 'production_management':
    require __DIR__ . '/../pages/production_management.php';
    break;
  case 'energy_management':
    require __DIR__ . '/../pages/energy_management.php';
    break;
  case 'waste_circularity':
    require __DIR__ . '/../pages/waste_circularity.php';
    break;
  case 'financial_analytics':
    require __DIR__ . '/../pages/financial_analytics.php';
    break;
  case 'predictive_maintenance':
    require __DIR__ . '/../pages/predictive_maintenance.php';
    break;
  case 'feed_formulation':
    require __DIR__ . '/../pages/feed_formulation.php';
    break;
  case 'weather_irrigation':
    require __DIR__ . '/../pages/weather_irrigation.php';
    break;
  case 'veterinary':
    require __DIR__ . '/../pages/veterinary.php';
    break;
  case 'qr_inventory':
    require __DIR__ . '/../pages/qr_inventory.php';
    break;
  case 'field_mode':
    require __DIR__ . '/../pages/field_mode.php';
    break;
  case 'logout':
    $_SESSION = [];
    session_destroy();
    header('Location: /farmos/begin_pyphp/frontend/public/index.php?page=login');
    exit;
  default:
    http_response_code(404);
    echo "<h1>404 Not Found</h1>";
}
?>
