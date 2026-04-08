import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/weather.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class WeatherService {
  const WeatherService(this._api, this._sync, this._cacheStatus);
  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const currentStatusKey = 'weather:current';
  static const historyStatusKey = 'weather:history';

  String _currentCacheKey() => 'weather_current';
  String _historyCacheKey(int? limit) => 'weather_history_${limit ?? 'all'}';

  Future<CurrentWeather> getCurrent() async {
    try {
      final data = await _api.get(ApiEndpoints.weatherCurrent);
      final payload = data['weather'] as Map<String, dynamic>? ?? data;
      await _sync.cache(_currentCacheKey(), payload);
      _cacheStatus.markFresh(currentStatusKey);
      return CurrentWeather.fromJson(payload);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_currentCacheKey());
      if (cached != null) {
        _cacheStatus.markOffline(
          currentStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return CurrentWeather.fromJson(cached.payload);
      }
      rethrow;
    }
  }

  Future<List<WeatherLog>> getHistory({int? limit}) async {
    try {
      final list = await _api.getList(ApiEndpoints.weatherHistory,
          params: {if (limit != null) 'limit': limit});
      await _sync.cache(_historyCacheKey(limit), {'items': list});
      _cacheStatus.markFresh(historyStatusKey);
      return list
          .map((e) => WeatherLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_historyCacheKey(limit));
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          historyStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => WeatherLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<WeatherLog> addObservation(Map<String, dynamic> body) async {
    try {
      final data = await _api.post(ApiEndpoints.weatherObservation, data: body);
      return WeatherLog.fromJson(
          data['observation'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.weatherObservation,
        body: body,
      );
      return WeatherLog(
        id: -DateTime.now().millisecondsSinceEpoch,
        logDate: DateTime.now(),
        temperatureC: _toDouble(body['temperature_c']),
        humidityPercent: _toDouble(body['humidity_percent']),
        rainfallMm: _toDouble(body['rainfall_mm']),
        windSpeedKph: _toDouble(body['wind_speed_kph']),
        conditions: body['conditions'] as String?,
        notes: body['notes'] as String?,
      );
    }
  }

  double? _toDouble(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());
}
