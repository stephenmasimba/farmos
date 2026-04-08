import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    super.dispose();
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
