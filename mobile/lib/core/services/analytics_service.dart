import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/analytics.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class AnalyticsService {
  const AnalyticsService(this._api, this._sync, this._cacheStatus);

  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const dashboardStatusKey = 'analytics:dashboard';
  static const _dashboardCacheKey = 'analytics_dashboard';

  Future<AnalyticsDashboard> getDashboard() async {
    try {
      final data = await _api.get(ApiEndpoints.analyticsDashboard);
      await _sync.cache(_dashboardCacheKey, data);
      _cacheStatus.markFresh(dashboardStatusKey);
      return AnalyticsDashboard.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_dashboardCacheKey);
      if (cached != null) {
        _cacheStatus.markOffline(
          dashboardStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return AnalyticsDashboard.fromJson(cached.payload);
      }
      rethrow;
    }
  }
}
