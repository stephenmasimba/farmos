import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/dashboard.dart';

class DashboardService {
  const DashboardService(this._api);
  final ApiClient _api;

  Future<DashboardOverview> getOverview() async {
    final data = await _api.get(ApiEndpoints.dashboardOverview);
    return DashboardOverview.fromJson(
        data['overview'] as Map<String, dynamic>? ?? data);
  }

  Future<List<DashboardAlert>> getAlerts() async {
    final list = await _api.getList(ApiEndpoints.dashboardAlerts);
    return list
        .map((e) => DashboardAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TimelineItem>> getTimeline() async {
    final list = await _api.getList(ApiEndpoints.dashboardTimeline);
    return list
        .map((e) => TimelineItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
