import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';
import '../services/cache_status_service.dart';
import '../services/storage_service.dart';
import '../services/livestock_service.dart';
import '../services/inventory_service.dart';
import '../services/task_service.dart';
import '../services/financial_service.dart';
import '../services/dashboard_service.dart';
import '../services/weather_service.dart';
import '../services/iot_service.dart';
import '../services/sync_service.dart';
import '../services/analytics_service.dart';
import '../services/reports_service.dart';
import '../services/user_access_service.dart';
import '../services/notifications_service.dart';
import '../services/timesheets_service.dart';
import '../services/veterinary_service.dart';
import '../services/hr_service.dart';
import '../services/feed_service.dart';
import '../services/fields_service.dart';
import '../services/farm_service.dart';
import '../services/file_upload_service.dart';
import '../services/activity_service.dart';
import '../services/weather_alert_service.dart';
import '../services/field_map_service.dart';
import '../services/cost_analysis_service.dart';
import '../services/barcode_service.dart';
import '../services/push_notification_service.dart';
import '../services/weight_tracking_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.read(secureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.read(secureStorageProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    apiClient: ref.read(apiClientProvider),
    storage: ref.read(storageServiceProvider),
  );
});

final cacheStatusServiceProvider =
    StateNotifierProvider<CacheStatusService, Map<String, CacheStatusRecord>>(
  (ref) => CacheStatusService(),
);

final livestockServiceProvider = Provider<LivestockService>((ref) {
  return LivestockService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final financialServiceProvider = Provider<FinancialService>((ref) {
  return FinancialService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final iotServiceProvider = Provider<IoTService>((ref) {
  return IoTService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.read(apiClientProvider));
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(ref.read(apiClientProvider));
});

final userAccessServiceProvider = Provider<UserAccessService>((ref) {
  return UserAccessService(ref.read(apiClientProvider));
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(ref.read(apiClientProvider));
});

final timesheetsServiceProvider = Provider<TimesheetsService>((ref) {
  return TimesheetsService(ref.read(apiClientProvider));
});

final veterinaryServiceProvider = Provider<VeterinaryService>((ref) {
  return VeterinaryService(ref.read(apiClientProvider));
});

final hrServiceProvider = Provider<HrService>((ref) {
  return HrService(ref.read(apiClientProvider));
});

final feedServiceProvider = Provider<FeedService>((ref) {
  return FeedService(ref.read(apiClientProvider));
});

final fieldsServiceProvider = Provider<FieldsService>((ref) {
  return FieldsService(ref.read(apiClientProvider));
});

final farmServiceProvider = Provider<FarmService>((ref) {
  return FarmService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return FileUploadService(ref.read(apiClientProvider));
});

final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final weatherAlertServiceProvider = Provider<WeatherAlertService>((ref) {
  return WeatherAlertService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final fieldMapServiceProvider = Provider<FieldMapService>((ref) {
  return FieldMapService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final costAnalysisServiceProvider = Provider<CostAnalysisService>((ref) {
  return CostAnalysisService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final barcodeServiceProvider = Provider<BarcodeService>((ref) {
  return BarcodeService(
    ref.read(apiClientProvider),
    ref.read(syncServiceProvider),
    ref.read(cacheStatusServiceProvider.notifier),
  );
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.read(apiClientProvider));
});

final weightTrackingServiceProvider = Provider<WeightTrackingService>((ref) {
  return WeightTrackingService(ref.read(apiClientProvider));
});
