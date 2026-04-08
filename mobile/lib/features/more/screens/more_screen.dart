import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/theme/app_colors.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingSyncCount = ref.watch(pendingSyncCountProvider);
    final cacheDiagnostics = ref.watch(cacheDiagnosticsProvider);

    final items = <_Item>[
      _Item('Inventory', Icons.inventory_2_rounded, '/inventory'),
      _Item('Calendar', Icons.calendar_month_rounded, '/calendar'),
      _Item('Sync Center', Icons.cloud_sync_rounded, '/sync',
          badgeCount: pendingSyncCount.value ?? 0),
      _Item('Weather', Icons.cloud_rounded, '/weather'),
      _Item('IoT', Icons.sensors_rounded, '/iot'),
      _Item('Fields', Icons.grass_rounded, '/fields'),
      _Item('Reports', Icons.summarize_rounded, '/reports'),
      _Item('Analytics', Icons.analytics_rounded, '/analytics'),
      _Item('Users', Icons.group_rounded, '/users'),
      _Item('Settings', Icons.settings_rounded, '/settings'),
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
