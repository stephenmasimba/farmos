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

  // Tasks
  static const String tasks = '/api/tasks';
  static const String taskStats = '/api/tasks/stats';
  static String taskById(int id) => '/api/tasks/$id';
  static String taskAssign(int id) => '/api/tasks/$id/assign';
  static String taskComplete(int id) => '/api/tasks/$id/complete';

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
}
