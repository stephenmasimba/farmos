import '../api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_endpoints.dart';
import '../models/weather_alert.dart';
import 'sync_service.dart';
import 'cache_status_service.dart';

class WeatherAlertService {
  WeatherAlertService(this._client, this._sync, this._cache);

  final ApiClient _client;
  final SyncService _sync;
  final StateNotifierProvider<CacheStatusService, Map<String, CacheStatusRecord>> _cache;

  static const alertsKey = 'weather_alert_service_alerts';
  static const frostKey = 'weather_alert_service_frost';
  static const rainKey = 'weather_alert_service_rain';

  Future<List<WeatherAlert>> getActiveAlerts() async {
    final data = await _client.getList(
      '/api/weather/alerts',
      params: {'status': 'active', 'limit': 50},
    );
    return data.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WeatherAlert>> getAlertsByType(String type) async {
    final data = await _client.getList(
      '/api/weather/alerts',
      params: {'type': type, 'limit': 30},
    );
    return data.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> acknowledgeAlert(int alertId) {
    return _sync.enqueue(
      label: 'Acknowledge weather alert',
      operation: () => _client.put(
        '/api/weather/alerts/$alertId',
        data: {'acknowledged': true},
      ),
    );
  }

  Future<List<WeatherAlert>> getFrostAlerts() => getAlertsByType('frost');

  Future<List<WeatherAlert>> getHeavyRainAlerts() => getAlertsByType('heavy_rain');

  Future<List<WeatherAlert>> getHighWindAlerts() => getAlertsByType('high_wind');

  Future<List<WeatherAlert>> getHeatWaveAlerts() => getAlertsByType('heat_wave');
}

