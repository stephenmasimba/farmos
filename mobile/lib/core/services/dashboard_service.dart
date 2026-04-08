import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/dashboard.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class DashboardService {
  const DashboardService(this._api, this._sync, this._cacheStatus);
  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const _overviewCacheKey = 'dashboard_overview';
  static const _alertsCacheKey = 'dashboard_alerts';
  static const _timelineCacheKey = 'dashboard_timeline';
  static const _healthCacheKey = 'dashboard_health';
  static const _forecastCacheKey = 'dashboard_forecast';
  static const overviewStatusKey = 'dashboard:overview';
  static const alertsStatusKey = 'dashboard:alerts';
  static const timelineStatusKey = 'dashboard:timeline';
  static const healthStatusKey = 'dashboard:health';
  static const forecastStatusKey = 'dashboard:forecast';

  Future<DashboardOverview> getOverview() async {
    try {
      final data = await _api.get(ApiEndpoints.dashboardOverview);
      final payload = data['overview'] as Map<String, dynamic>? ?? data;
      await _sync.cache(_overviewCacheKey, payload);
      _cacheStatus.markFresh(overviewStatusKey);
      return DashboardOverview.fromJson(payload);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_overviewCacheKey);
      if (cached != null) {
        _cacheStatus.markOffline(
          overviewStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return DashboardOverview.fromJson(cached.payload);
      }
      rethrow;
    }
  }

  Future<List<DashboardAlert>> getAlerts() async {
    try {
      final list = await _api.getList(ApiEndpoints.dashboardAlerts);
      await _sync.cache(_alertsCacheKey, {
        'items': list,
      });
      _cacheStatus.markFresh(alertsStatusKey);
      return list
          .map((e) => DashboardAlert.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_alertsCacheKey);
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          alertsStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => DashboardAlert.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<List<TimelineItem>> getTimeline() async {
    try {
      final list = await _api.getList(ApiEndpoints.dashboardTimeline);
      await _sync.cache(_timelineCacheKey, {
        'items': list,
      });
      _cacheStatus.markFresh(timelineStatusKey);
      return list
          .map((e) => TimelineItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_timelineCacheKey);
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          timelineStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => TimelineItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }
  
  Future<FarmHealthMetrics> getHealth() async {
    try {
      final data = await _api.get(ApiEndpoints.dashboardHealth);
      await _sync.cache(_healthCacheKey, data);
      _cacheStatus.markFresh(healthStatusKey);
      return FarmHealthMetrics.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_healthCacheKey);
      if (cached != null) {
        _cacheStatus.markOffline(
          healthStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return FarmHealthMetrics.fromJson(cached.payload);
      }
      rethrow;
    }
  }
  
  Future<FarmForecast> getForecast() async {
    try {
      final data = await _api.get(ApiEndpoints.dashboardForecast);
      await _sync.cache(_forecastCacheKey, data);
      _cacheStatus.markFresh(forecastStatusKey);
      return FarmForecast.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_forecastCacheKey);
      if (cached != null) {
        _cacheStatus.markOffline(
          forecastStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return FarmForecast.fromJson(cached.payload);
      }
      rethrow;
    }
  }
}
