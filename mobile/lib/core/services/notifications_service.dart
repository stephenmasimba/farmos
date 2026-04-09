import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/notification_item.dart';

class NotificationsService {
  const NotificationsService(this._api);

  final ApiClient _api;

  Future<List<NotificationItem>> list() async {
    final list = await _api.getList(ApiEndpoints.notifications);
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    await _api.post(ApiEndpoints.notificationsMarkAllRead);
  }

  Future<void> markRead(int id) async {
    await _api.post(ApiEndpoints.notificationsMarkRead(id));
  }
}
