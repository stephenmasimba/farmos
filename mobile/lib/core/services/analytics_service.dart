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
      final data = await _api.get(ApiEndpoints.financialAnalyticsForecast);

      final scenarios = (data['forecast_scenarios'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final realistic =
          (scenarios['Realistic'] as List<dynamic>?) ?? const <dynamic>[];

      final revenue = <int>[];
      for (final entry in realistic.take(7)) {
        if (entry is! Map) continue;
        final projected =
            int.tryParse((entry['projected_revenue'] ?? '0').toString()) ?? 0;
        revenue.add(projected);
      }

      final burnRate =
          double.tryParse((data['burn_rate'] ?? '0').toString()) ?? 0.0;
      final runwayMonths =
          int.tryParse((data['runway_months'] ?? '0').toString()) ?? 0;

      final mapped = <String, dynamic>{
        'active_tasks': runwayMonths,
        'critical_alerts': burnRate > 0 ? 1 : 0,
        'daily_revenue': revenue,
      };

      await _sync.cache(_dashboardCacheKey, mapped);
      _cacheStatus.markFresh(dashboardStatusKey);
      return AnalyticsDashboard.fromJson(mapped);
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
