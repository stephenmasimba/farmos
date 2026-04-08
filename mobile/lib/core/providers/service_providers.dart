import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/livestock_service.dart';
import '../services/inventory_service.dart';
import '../services/task_service.dart';
import '../services/financial_service.dart';
import '../services/dashboard_service.dart';
import '../services/weather_service.dart';
import '../services/iot_service.dart';

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

final livestockServiceProvider = Provider<LivestockService>((ref) {
  return LivestockService(ref.read(apiClientProvider));
});

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(ref.read(apiClientProvider));
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.read(apiClientProvider));
});

final financialServiceProvider = Provider<FinancialService>((ref) {
  return FinancialService(ref.read(apiClientProvider));
});

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.read(apiClientProvider));
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(ref.read(apiClientProvider));
});

final iotServiceProvider = Provider<IoTService>((ref) {
  return IoTService(ref.read(apiClientProvider));
});
