import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/theme/app_colors.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final canViewUsers = user?.hasAnyPermission(const [
          'users.view',
          'users.permissions.manage',
        ]) ??
        false;
    final canViewReports = user?.hasAnyPermission(const [
          'reports.read',
          'reports.generate',
        ]) ??
        false;
    final canViewAnalytics = user?.hasPermission('analytics.read') ?? false;
    final canViewSettings = user?.hasPermission('settings.read') ?? false;
    final canViewNotifications = user?.hasAnyPermission(const [
          'tasks.read',
          'reports.read',
          'users.view',
        ]) ??
        false;
    final canViewTimesheets = user?.hasPermission('tasks.read') ?? false;
    final canViewVeterinary = user?.hasPermission('livestock.read') ?? false;
    final canViewHr = user?.hasPermission('tasks.read') ?? false;
    final canViewFeed = user?.hasPermission('inventory.read') ?? false;

    final pendingSyncCount = ref.watch(pendingSyncCountProvider);
        final canUseBarcodeScanner = user?.hasPermission('inventory.create') ?? false;
        final canViewCostAnalysis = user?.hasAnyPermission(const [
              'livestock.read',
              'reports.read',
            ]) ??
            false;
    final cacheDiagnostics = ref.watch(cacheDiagnosticsProvider);

    final items = <_Item>[
      _Item('Inventory', Icons.inventory_2_rounded, '/inventory'),
      _Item('Calendar', Icons.calendar_month_rounded, '/calendar'),
      if (canViewTimesheets)
        _Item('Timesheets', Icons.schedule_rounded, '/timesheets'),
      _Item('Sync Center', Icons.cloud_sync_rounded, '/sync',
          badgeCount: pendingSyncCount.value ?? 0),
      _Item('Weather', Icons.cloud_rounded, '/weather'),
      _Item('IoT', Icons.sensors_rounded, '/iot'),
      if (canViewVeterinary)
        _Item('Veterinary', Icons.health_and_safety_rounded, '/veterinary'),
      if (canViewHr) _Item('HR', Icons.badge_rounded, '/hr'),
      if (canViewFeed) _Item('Feed', Icons.set_meal_rounded, '/feed'),
      _Item('Fields', Icons.grass_rounded, '/fields'),
            _Item('Weather Alerts', Icons.warning_rounded, '/weather-alerts'),
            if (canUseBarcodeScanner)
              _Item('Barcode Scanner', Icons.qr_code_scanner_rounded, '/barcode-scanner'),
            if (canViewCostAnalysis)
              _Item('Cost Analysis', Icons.trending_down_rounded, '/cost-analysis'),
      if (canViewReports) _Item('Reports', Icons.summarize_rounded, '/reports'),
      if (canViewAnalytics)
        _Item('Analytics', Icons.analytics_rounded, '/analytics'),
      if (canViewUsers) _Item('Users', Icons.group_rounded, '/users'),
      if (canViewSettings) _Item('Settings', Icons.settings_rounded, '/settings'),
      if (canViewNotifications)
        _Item('Notifications', Icons.notifications_rounded, '/notifications'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More Modules')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SyncHealthCard(
            pendingCount: pendingSyncCount.value ?? 0,
            staleCacheCount: cacheDiagnostics.valueOrNull
                    ?.where((e) => e.isStale)
                    .length ??
                0,
            totalCacheCount: cacheDiagnostics.valueOrNull?.length ?? 0,
            onOpenSync: () => context.push('/sync'),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, i) {
              final item = items[i];
              return Card(
                child: InkWell(
                  onTap: () => context.push(item.path),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(item.icon, size: 30),
                          if ((item.badgeCount ?? 0) > 0)
                            Positioned(
                              right: -10,
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  (item.badgeCount! > 99)
                                      ? '99+'
                                      : item.badgeCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(item.label,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SyncHealthCard extends StatelessWidget {
  const _SyncHealthCard({
    required this.pendingCount,
    required this.staleCacheCount,
    required this.totalCacheCount,
    required this.onOpenSync,
  });

  final int pendingCount;
  final int staleCacheCount;
  final int totalCacheCount;
  final VoidCallback onOpenSync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpenSync,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEFF6FF),
                child: Icon(Icons.cloud_sync_rounded, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sync Health',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '$pendingCount pending · $staleCacheCount stale cache · $totalCacheCount snapshots',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item {
  const _Item(this.label, this.icon, this.path, {this.badgeCount});

  final String label;
  final IconData icon;
  final String path;
  final int? badgeCount;
}
