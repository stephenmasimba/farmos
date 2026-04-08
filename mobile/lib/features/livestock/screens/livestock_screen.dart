import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/livestock.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/services/cache_status_service.dart';
import '../../../core/services/livestock_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final livestockListProvider =
    FutureProvider.autoDispose.family<List<Livestock>, Map<String, dynamic>>(
  (ref, params) => ref.read(livestockServiceProvider).getAll(
        status: params['status'] as String?,
      ),
);

final livestockStatsProvider =
    FutureProvider.autoDispose<LivestockStats>((ref) {
  return ref.read(livestockServiceProvider).getStats();
});

class LivestockScreen extends ConsumerStatefulWidget {
  const LivestockScreen({super.key});

  @override
  ConsumerState<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends ConsumerState<LivestockScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _filters = ['all', 'active', 'sold', 'harvested'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(livestockStatsProvider);
    final pendingChanges =
        ref.watch(pendingModuleChangesProvider(ApiEndpoints.livestock));
    final cacheStatus = latestOfflineStatus(
      ref.watch(cacheStatusServiceProvider),
      const [
        LivestockService.listStatusKey,
        LivestockService.statsStatusKey,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestock'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _filters
              .map((f) => Tab(text: f[0].toUpperCase() + f.substring(1)))
              .toList(),
          onTap: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Stats',
            onPressed: () => _showStats(context, stats),
          ),
        ],
      ),
      body: Column(
        children: [
          if (cacheStatus != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OfflineDataBanner(
                lastUpdatedAt: cacheStatus.lastUpdatedAt,
              ),
            ),
          pendingChanges.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: UnsyncedChangesChip(
                      count: count,
                      onTap: () => context.push('/sync?module=livestock'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: _filters.map((f) {
                final params = f == 'all' ? <String, dynamic>{} : {'status': f};
                return _LivestockList(filterParams: params);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/livestock/add');
          ref.invalidate(livestockListProvider);
          ref.invalidate(livestockStatsProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Batch'),
      ),
    );
  }

  void _showStats(
      BuildContext context, AsyncValue<LivestockStats> stats) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: stats.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(e.toString()),
          data: (s) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Livestock Statistics',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    label: 'Total Batches',
                    value: s.totalBatches.toString(),
                    icon: Icons.folder_rounded,
                  ),
                  StatCard(
                    label: 'Total Animals',
                    value: Fmt.compact(s.totalAnimals),
                    icon: Icons.pets_rounded,
                    color: AppColors.primary,
                  ),
                  StatCard(
                    label: 'Active Batches',
                    value: s.activeBatches.toString(),
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                  StatCard(
                    label: 'Total Mortality',
                    value: s.totalMortality.toString(),
                    icon: Icons.warning_rounded,
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivestockList extends ConsumerWidget {
  const _LivestockList({required this.filterParams});

  final Map<String, dynamic> filterParams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestock = ref.watch(livestockListProvider(filterParams));

    return livestock.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(livestockListProvider(filterParams)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.pets_rounded,
            title: 'No livestock found',
            subtitle: 'Add your first batch to get started',
            action: ElevatedButton.icon(
              onPressed: () => context.push('/livestock/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Batch'),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(livestockListProvider(filterParams)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _LivestockCard(item: list[i]),
          ),
        );
      },
    );
  }
}

class _LivestockCard extends StatelessWidget {
  const _LivestockCard({required this.item});

  final Livestock item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/livestock/${item.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.batchCode,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${item.animalType} · ${item.breed}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 16),
              Row(
                children: [
                  _Stat(
                    label: 'Current',
                    value: item.currentQuantity.toString(),
                    icon: Icons.pets_rounded,
                  ),
                  const SizedBox(width: 16),
                  _Stat(
                    label: 'Initial',
                    value: item.initialQuantity.toString(),
                    icon: Icons.numbers_rounded,
                  ),
                  const Spacer(),
                  if (item.expectedHarvestDate != null)
                    _Stat(
                      label: 'Harvest',
                      value: Fmt.date(item.expectedHarvestDate),
                      icon: Icons.event_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
