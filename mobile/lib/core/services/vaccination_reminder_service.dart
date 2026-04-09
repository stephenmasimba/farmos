import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class VaccinationReminderService {
  VaccinationReminderService(this._api);

  final ApiClient _api;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<VaccinationReminderService> create() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final apiClient = ApiClient(storage: storage);
    return VaccinationReminderService(apiClient);
  }

  Future<void> checkAndSendReminders() async {
    final vaccinations = await _api.getList(ApiEndpoints.veterinaryVaccinations);
    final now = DateTime.now();

    for (final entry in vaccinations) {
      final v = entry as Map<String, dynamic>;
      final scheduled = DateTime.tryParse((v['scheduled_date'] ?? '').toString());
      if (scheduled == null) continue;

      final diff = DateTime(
        scheduled.year,
        scheduled.month,
        scheduled.day,
      ).difference(DateTime(now.year, now.month, now.day)).inDays;

      if (diff == 1) {
        await _sendNotification(
          title: 'Vaccination Tomorrow',
          body:
              '${v['vaccine_name'] ?? 'Vaccine'} for batch ${v['batch_id'] ?? '-'} is due tomorrow.',
        );
      } else if (diff == 0 && (v['status'] ?? '').toString() == 'scheduled') {
        await _sendNotification(
          title: 'Vaccination Today',
          body:
              '${v['vaccine_name'] ?? 'Vaccine'} for batch ${v['batch_id'] ?? '-'} is scheduled today.',
        );
      }
    }
  }

  Future<void> _sendNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'vaccination_channel',
      'Vaccination Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }
}
