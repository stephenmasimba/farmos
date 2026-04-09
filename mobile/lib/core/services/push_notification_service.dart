import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService(this._apiClient);

  final ApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
    final StreamController<Map<String, dynamic>> _tapEventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _initialized = false;

    Stream<Map<String, dynamic>> get tapEvents => _tapEventsController.stream;

  Future<void> init() async {
    if (_initialized) return;

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic> && !_tapEventsController.isClosed) {
            _tapEventsController.add(decoded);
          }
        } catch (_) {
          // Ignore malformed payload taps.
        }
      },
    );

    const channel = AndroidNotificationChannel(
      'farmos_alerts',
      'Farm Alerts',
      description: 'Weather and operations alerts',
      importance: Importance.high,
    );

    final android = _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerDeviceToken(token);
    }

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenFromNotification);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenFromNotification(initialMessage);
    }

    _initialized = true;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'FarmOS';
    final body = message.notification?.body ?? '';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'farmos_alerts',
        'Farm Alerts',
        channelDescription: 'Weather and operations alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  void _handleOpenFromNotification(RemoteMessage message) {
    if (message.data.isNotEmpty && !_tapEventsController.isClosed) {
      _tapEventsController.add(message.data);
    }
  }

  Future<void> _registerDeviceToken(String token) async {
    try {
      await _apiClient.post(
        ApiEndpoints.notifications,
        data: {
          'device_token': token,
          'platform': 'mobile',
        },
      );
    } catch (_) {
      // Token registration failures are non-fatal.
    }
  }
}
