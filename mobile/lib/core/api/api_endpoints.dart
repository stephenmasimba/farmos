import '../config/app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get base => AppConfig.baseUrl;

  // Health
  static const String health = '/health';

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';

  // Users + Access Control
  static const String users = '/api/users';
  static String userById(int id) => '/api/users/$id';
  static const String accessCatalog = '/api/access/catalog';
  static const String accessAudit = '/api/access/audit';
  static String userAccess(int id) => '/api/users/$id/access';
  static String userRole(int id) => '/api/users/$id/role';
  static String userPermissions(int id) => '/api/users/$id/permissions';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String notificationsMarkAllRead = '/api/notifications/mark-all-read';
  static String notificationsMarkRead(int id) => '/api/notifications/$id/mark-read';

  // Dashboard
  static const String dashboardOverview = '/api/dashboard/overview';
  static const String dashboardAlerts = '/api/dashboard/alerts';
  static const String dashboardTimeline = '/api/dashboard/timeline';
  static const String dashboardForecast = '/api/dashboard/forecast';
  static const String dashboardHealth = '/api/dashboard/health';

  // Livestock
  static const String livestock = '/api/livestock';
  static const String livestockStats = '/api/livestock/stats';
  static String livestockById(int id) => '/api/livestock/$id';
  static String livestockEvents(int id) => '/api/livestock/$id/events';

  // Inventory
  static const String inventory = '/api/inventory';
  static const String inventoryAlerts = '/api/inventory/alerts';
  static const String inventoryStats = '/api/inventory/stats';
  static String inventoryById(int id) => '/api/inventory/$id';
  static String inventoryAdjust(int id) => '/api/inventory/$id/adjust';
  static String inventoryByCategory(String category) =>
      '/api/inventory/category/$category';

  // Financial
  static const String financialRecords = '/api/financial/records';
  static const String financialSummary = '/api/financial/summary';
  static const String financialMonthly = '/api/financial/report/monthly';
  static const String financialYearly = '/api/financial/report/yearly';
  static const String financialCategories = '/api/financial/categories';
  static String financialRecordById(int id) => '/api/financial/records/$id';

  // Accounting platform
  static const String accountingAccounts = '/api/accounting/accounts';
  static const String accountingJournalEntries = '/api/accounting/journal-entries';
  static const String accountingTrialBalance = '/api/accounting/trial-balance';
  static const String accountingReceivables = '/api/accounting/receivables';
  static const String accountingPayables = '/api/accounting/payables';

  // Inventory platform
  static const String inventoryPlatformWarehouses = '/api/inventory-platform/warehouses';
  static const String inventoryPlatformMovements = '/api/inventory-platform/movements';
  static const String inventoryPlatformTransfers = '/api/inventory-platform/transfers';
  static const String inventoryPlatformValuation = '/api/inventory-platform/valuation';
  static const String inventoryPlatformReorder = '/api/inventory-platform/reorder';

  // Livestock platform
  static const String livestockPlatformHealth = '/api/livestock-platform/health';
  static const String livestockPlatformReproduction = '/api/livestock-platform/reproduction';
  static const String livestockPlatformProduction = '/api/livestock-platform/production';
  static const String livestockPlatformVaccinations = '/api/livestock-platform/vaccinations';

  // Tasks
  static const String tasks = '/api/tasks';
  static const String taskStats = '/api/tasks/stats';
  static String taskById(int id) => '/api/tasks/$id';
  static String taskAssign(int id) => '/api/tasks/$id/assign';
  static String taskComplete(int id) => '/api/tasks/$id/complete';

  // Timesheets
  static const String timesheets = '/api/timesheets';
  static const String timesheetsStats = '/api/timesheets/stats';
  static const String timesheetsLog = '/api/timesheets/log';
  static String timesheetStatus(int id) => '/api/timesheets/$id/status';

  // Veterinary
  static const String veterinaryLogs = '/api/veterinary/logs';
  static const String veterinaryVaccinations = '/api/veterinary/vaccinations';
  static const String veterinaryWithdrawals = '/api/veterinary/withdrawals';
  static String veterinaryLogStatus(int id) => '/api/veterinary/logs/$id/status';

  // HR
  static const String hrSops = '/api/hr/sops';
  static const String hrTasks = '/api/hr/tasks';
  static const String hrSchedules = '/api/hr/schedules';
  static const String hrSopExecutions = '/api/hr/sops/executions';
  static const String hrSopRun = '/api/hr/sops/run';

  // Feed
  static const String feedIngredients = '/api/feed/ingredients';
  static const String feedMillingLogs = '/api/feed/milling-logs';
  static const String feedCalculatePearson = '/api/feed/calculate-pearson';
  static const String feedFormulationIngredients = '/api/feed-formulation/ingredients';
  static const String feedFormulationRecent = '/api/feed-formulation/recent';
  static const String feedFormulationCalculate = '/api/feed-formulation/calculate';

  // Fields
  static const String fields = '/api/fields';

  // Weather
  static const String weatherCurrent = '/api/weather/current';
  static const String weatherHistory = '/api/weather/history';
  static const String weatherStats = '/api/weather/stats';
  static const String weatherForecast = '/api/weather/forecast';
  static const String weatherObservation = '/api/weather/observation';

  // IoT
  static const String iotDevices = '/api/iot/devices';
  static const String iotSensors = '/api/iot/sensors';
  static const String iotSensorsLatest = '/api/iot/sensors/latest';
  static const String iotAlerts = '/api/iot/alerts';
  static const String iotWaterQuality = '/api/iot/water-quality';

  // Reports
  static const String reportTypes = '/api/reports/types';
  static const String reportGenerate = '/api/reports/generate';
  static const String reportDownload = '/api/reports/download';

  // Analytics
  static const String analyticsDashboard = '/api/analytics/dashboard';
  static const String financialAnalyticsForecast = '/api/financial-analytics/forecast';
  static const String financialAnalyticsAssets = '/api/financial-analytics/assets';
  static const String financialAnalyticsRoi = '/api/financial-analytics/roi';

  // Multi-farm support
  static const String farms = '/api/farms';
  static String farmById(int id) => '/api/farms/$id';
  static String farmPreference(int id) => '/api/farms/$id/preference';

  // Expense attachments
  static const String attachments = '/api/attachments';
  static String transactionAttachments(int id) => '/api/financial/records/$id/attachments';

  // Task comments and activity feed
  static const String taskComments = '/api/tasks/comments';
  static String taskCommentsForTask(int id) => '/api/tasks/$id/comments';

  // Weather alerts
  static const String weatherAlerts = '/api/weather/alerts';
  static String weatherAlertById(int id) => '/api/weather/alerts/$id';

  // Field mapping and boundaries
  static const String fieldBoundaries = '/api/fields/boundaries';
  static String fieldBoundary(int id) => '/api/fields/$id/boundary';
  static String fieldBoundaryPoints(int id) => '/api/fields/$id/boundary-points';

  // Cost analysis
  static const String costAnalysis = '/api/livestock/cost-analysis';
  static String animalCostAnalysis(int id) => '/api/livestock/$id/cost-analysis';
  static String batchCostSummary(int id) => '/api/livestock/batch/$id/cost-summary';
  static const String livestockCosts = '/api/livestock/costs';
  static String monthlyBreakdown(int id) => '/api/livestock/$id/monthly-breakdown';

  // Barcode scanning
  static const String barcodeSearch = '/api/inventory/barcode/search';
  static const String barcodeLookup = '/api/inventory/barcode/lookup';
  static const String bulkAdjust = '/api/inventory/bulk-adjust';
}
