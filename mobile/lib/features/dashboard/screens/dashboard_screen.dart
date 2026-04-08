import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/dashboard.dart';
import '../../../core/models/livestock.dart';
import '../../../core/models/task.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/cache_status_service.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

// --------------- providers ---------------

final _overviewProvider = FutureProvider.autoDispose<DashboardOverview>((ref) {
  return ref.read(dashboardServiceProvider).getOverview();
});

final _alertsProvider =
    FutureProvider.autoDispose<List<DashboardAlert>>((ref) {
  return ref.read(dashboardServiceProvider).getAlerts();
});

final _timelineProvider =
    FutureProvider.autoDispose<List<TimelineItem>>((ref) {
  return ref.read(dashboardServiceProvider).getTimeline();
});

final _livestockStatsProvider =
    FutureProvider.autoDispose<LivestockStats>((ref) {
  return ref.read(livestockServiceProvider).getStats();
});

final _taskStatsProvider = FutureProvider.autoDispose<TaskStats>((ref) {
  return ref.read(taskServiceProvider).getStats();
});

// --------------- screen ---------------

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final overview = ref.watch(_overviewProvider);
    final alerts = ref.watch(_alertsProvider);
    final timeline = ref.watch(_timelineProvider);
    final cacheStatus = _latestOfflineStatus(
      ref.watch(cacheStatusServiceProvider),
      const [
        DashboardService.overviewStatusKey,
        DashboardService.alertsStatusKey,
        DashboardService.timelineStatusKey,
      ],
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_overviewProvider);
          ref.invalidate(_alertsProvider);
          ref.invalidate(_timelineProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ---- App bar ----
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.primary,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 56, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Good ${_greeting()}, ${user?.name ?? user?.email ?? 'Farmer'}!',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      Text(
                        Fmt.date(DateTime.now()),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () => context.push('/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),

            if (cacheStatus != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: OfflineDataBanner(
                    lastUpdatedAt: cacheStatus.lastUpdatedAt,
                  ),
                ),
              ),

            // ---- KPI cards ----
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: overview.when(
                  loading: () => const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(_overviewProvider),
                  ),
                  data: (ov) => _KpiGrid(overview: ov),
                ),
              ),
            ),

            // ---- Active alerts ----
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: SliverToBoxAdapter(
                child: alerts.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) {
                    if (list.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Active Alerts',
                          action: TextButton(
                            onPressed: () {},
                            child: Text('${list.length} total'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...list.take(3).map((a) => _AlertTile(alert: a)),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ---- Quick actions ----
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    _QuickActions(),
                  ],
                ),
              ),
            ),

            // ---- Recent activity ----
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Recent Activity'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            timeline.when(
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
              data: (items) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _TimelineTile(item: items[i]),
                  ),
                  childCount: items.length.clamp(0, 8),
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.overview});

  final DashboardOverview overview;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        StatCard(
          label: 'Total Animals',
          value: Fmt.compact(overview.totalAnimals),
          icon: Icons.pets_rounded,
          color: AppColors.primary,
        ),
        StatCard(
          label: 'Net Profit',
          value: Fmt.currency(overview.netProfit),
          icon: Icons.trending_up_rounded,
          color: overview.netProfit >= 0 ? AppColors.success : AppColors.error,
        ),
        StatCard(
          label: 'Pending Tasks',
          value: overview.pendingTasks.toString(),
          icon: Icons.task_alt_rounded,
          color: AppColors.warning,
          subtitle: '${overview.totalTasks} total',
        ),
        StatCard(
          label: 'Low Stock Items',
          value: overview.lowStockItems.toString(),
          icon: Icons.inventory_2_outlined,
          color: overview.lowStockItems > 0
              ? AppColors.error
              : AppColors.success,
        ),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final DashboardAlert alert;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (alert.severity) {
      'critical' || 'error' => (AppColors.error, Icons.error_outline),
      'warning' => (AppColors.warning, Icons.warning_amber_rounded),
      _ => (AppColors.info, Icons.info_outline),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(alert.message,
            style: const TextStyle(fontSize: 13), maxLines: 2),
        subtitle: alert.createdAt != null
            ? Text(Fmt.timeAgo(alert.createdAt),
                style: const TextStyle(fontSize: 11))
            : null,
        trailing: StatusBadge(status: alert.severity),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_circle_rounded, 'Add Animal', '/livestock/add',
          AppColors.primary),
      (Icons.add_task_rounded, 'New Task', '/tasks/add', AppColors.warning),
      (Icons.attach_money_rounded, 'Record Sale', '/financial/add',
          AppColors.success),
      (Icons.cloud_rounded, 'Log Weather', '/weather', AppColors.info),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _QuickActionButton(
                    icon: a.$1,
                    label: a.$2,
                    path: a.$3,
                    color: a.$4,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.path,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String path;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.push(path),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style:
                    TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item});

  final TimelineItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.surfaceVariant,
        child: Text(
          (item.userName ?? '?')[0].toUpperCase(),
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
      ),
      title: Text(item.description,
          style: const TextStyle(fontSize: 13), maxLines: 2),
      subtitle: Text(Fmt.timeAgo(item.timestamp),
          style: const TextStyle(fontSize: 11)),
    );
  }
}
