import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/iot.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class IoTService {
  const IoTService(this._api, this._sync, this._cacheStatus);
  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const devicesStatusKey = 'iot:devices';
  static const readingsStatusKey = 'iot:readings';
  static const alertsStatusKey = 'iot:alerts';
  static const waterQualityStatusKey = 'iot:water_quality';

  String _devicesCacheKey() => 'iot_devices';
  String _readingsCacheKey() => 'iot_readings_latest';
  String _alertsCacheKey() => 'iot_alerts';
  String _waterQualityCacheKey() => 'iot_water_quality';

  Future<List<IoTDevice>> getDevices() async {
    try {
      final list = await _api.getList(ApiEndpoints.iotDevices);
      await _sync.cache(_devicesCacheKey(), {'items': list});
      _cacheStatus.markFresh(devicesStatusKey);
      return list
          .map((e) => IoTDevice.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_devicesCacheKey());
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          devicesStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => IoTDevice.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<IoTDevice> registerDevice(Map<String, dynamic> body) async {
    try {
      final data = await _api.post(ApiEndpoints.iotDevices, data: body);
      return IoTDevice.fromJson(data['device'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.iotDevices,
        body: body,
      );
      return IoTDevice(
        id: -DateTime.now().millisecondsSinceEpoch,
        name: (body['name'] as String?) ?? 'Pending Device',
        deviceType: (body['device_type'] as String?) ?? 'sensor',
        status: (body['status'] as String?) ?? 'offline',
        location: body['location'] as String?,
      );
    }
  }

  Future<List<SensorReading>> getLatestReadings() async {
    try {
      final list = await _api.getList(ApiEndpoints.iotSensorsLatest);
      await _sync.cache(_readingsCacheKey(), {'items': list});
      _cacheStatus.markFresh(readingsStatusKey);
      return list
          .map((e) => SensorReading.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_readingsCacheKey());
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          readingsStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => SensorReading.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<List<IoTAlert>> getAlerts() async {
    try {
      final list = await _api.getList(ApiEndpoints.iotAlerts);
      await _sync.cache(_alertsCacheKey(), {'items': list});
      _cacheStatus.markFresh(alertsStatusKey);
      return list
          .map((e) => IoTAlert.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_alertsCacheKey());
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          alertsStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => IoTAlert.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<void> ingestReading(Map<String, dynamic> body) async {
    try {
      await _api.post(ApiEndpoints.iotSensors, data: body);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.iotSensors,
        body: body,
      );
    }
  }

  Future<List<WaterQualityLog>> getWaterQuality() async {
    try {
      final list = await _api.getList(ApiEndpoints.iotWaterQuality);
      await _sync.cache(_waterQualityCacheKey(), {'items': list});
      _cacheStatus.markFresh(waterQualityStatusKey);
      return list
          .map((e) => WaterQualityLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_waterQualityCacheKey());
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          waterQualityStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => WaterQualityLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<void> addWaterQuality(Map<String, dynamic> body) async {
    try {
      await _api.post(ApiEndpoints.iotWaterQuality, data: body);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.iotWaterQuality,
        body: body,
      );
    }
  }
}
  }
