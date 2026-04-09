import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';
import 'core/services/background_sync.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/vaccination_reminder_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background scheduler before app bootstrap.
  await BackgroundSync.init();

  runApp(const ProviderScope(child: FarmOSMobileApp()));
}

class FarmOSMobileApp extends ConsumerStatefulWidget {
  const FarmOSMobileApp({super.key});

  @override
  ConsumerState<FarmOSMobileApp> createState() => _FarmOSMobileAppState();
}

class _FarmOSMobileAppState extends ConsumerState<FarmOSMobileApp>
    with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<SyncNotice>? _syncNoticeSub;
  StreamSubscription<Map<String, dynamic>>? _pushTapSub;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize push notifications once app UI is mounted.
    Future<void>.microtask(() async {
      final push = ref.read(pushNotificationServiceProvider);
      await push.init();
      await VaccinationReminderService.init();
      _pushTapSub = push.tapEvents.listen(_handlePushNavigation);
    });

    // Attempt to flush queued writes immediately after app starts.
    Future<void>.microtask(_syncPending);

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) return;
      _syncPending();
    });

    _syncNoticeSub = SyncService.notices.listen((notice) {
      final bg = switch (notice.type) {
        SyncNoticeType.queued => const Color(0xFF1976D2),
        SyncNoticeType.synced => const Color(0xFF2E7D32),
        SyncNoticeType.failed => const Color(0xFFF57C00),
      };
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(notice.message),
          backgroundColor: bg,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    _syncNoticeSub?.cancel();
    _pushTapSub?.cancel();
    super.dispose();
  }

  void _handlePushNavigation(Map<String, dynamic> data) {
    final router = ref.read(routerProvider);
    final route = _resolvePushRoute(data);
    if (route == null || route.isEmpty) return;

    const allowedRoutes = <String>{
      '/dashboard',
      '/tasks',
      '/notifications',
      '/weather',
      '/weather-alerts',
      '/inventory',
      '/livestock',
      '/financial',
      '/sync',
    };

    final isDetailRoute =
        route.startsWith('/inventory/') || route.startsWith('/livestock/');
    if (!allowedRoutes.contains(route) && !isDetailRoute) return;
    if (isDetailRoute) {
      router.push(route);
      return;
    }
    router.go(route);
  }

  String? _resolvePushRoute(Map<String, dynamic> data) {
    final direct = (data['route'] ?? data['path'])?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final module = (data['module'] ?? data['entity'] ?? data['type'])
        ?.toString()
        .toLowerCase();
    final idRaw = data['id'] ?? data['entity_id'] ?? data['item_id'];
    final id = int.tryParse((idRaw ?? '').toString());

    switch (module) {
      case 'inventory':
        return id != null ? '/inventory/$id' : '/inventory';
      case 'livestock':
        return id != null ? '/livestock/$id' : '/livestock';
      case 'task':
      case 'tasks':
        return '/tasks';
      case 'weather':
      case 'weather_alert':
      case 'weather-alert':
        return '/weather-alerts';
      case 'notification':
      case 'notifications':
        return '/notifications';
      case 'sync':
        return '/sync';
      default:
        return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPending();
    }
  }

  Future<void> _syncPending() async {
    try {
      await ref.read(syncServiceProvider).syncPending();
    } catch (_) {
      // Sync failures are non-fatal; queue remains for next retry.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'FarmOS Mobile',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
