import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

class SyncCenterScreen extends ConsumerWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleFilter = _normalizeModuleFilter(
      GoRouterState.of(context).uri.queryParameters['module'],
    );
    final count = ref.watch(pendingSyncCountProvider);
    final items = ref.watch(pendingSyncItemsProvider);
    final cacheDiagnostics = ref.watch(cacheDiagnosticsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sync Center'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Conflicts'),
              Tab(text: 'Failed'),
              Tab(text: 'Pending'),
              Tab(text: 'Cache'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Cache Actions',
              icon: const Icon(Icons.storage_rounded),
              onSelected: (value) async {
                if (value == 'clear-stale') {
                  await _clearStaleCache(context, ref);
                }
                if (value == 'clear-all') {
                  await _clearAllCache(context, ref);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'clear-stale',
                  child: Text('Clear stale cache'),
                ),
                PopupMenuItem(
                  value: 'clear-all',
                  child: Text('Clear all cache'),
                ),
              ],
            ),
            IconButton(
              tooltip: 'Export Conflict Report',
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () => _exportConflictReport(context, ref),
            ),
            IconButton(
              tooltip: 'Retry All',
              icon: const Icon(Icons.sync_rounded),
              onPressed: () => _retryAll(context, ref),
            ),
            IconButton(
              tooltip: 'Clear Queue',
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => _clearQueue(context, ref),
            ),
          ],
        ),
        body: Column(
          children: [
            if (moduleFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _ModuleFilterBanner(
                  module: moduleFilter,
                  onClear: () => context.go('/sync'),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                const Text('Pending Offline Operations',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                count.when(
                                  loading: () => const Text('Loading...'),
                                  error: (e, _) => Text(e.toString(),
                                      style: const TextStyle(color: AppColors.error)),
                                  data: (n) => Text(
                                    n == 0
                                        ? 'All synced successfully'
                                        : '$n operation(s) waiting to sync',
                                    style: const TextStyle(
                                        color: AppColors.onSurfaceVariant, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFF6F3E8),
                            child: Icon(Icons.storage_rounded, color: AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Offline Cache Snapshots',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                cacheDiagnostics.when(
                                  loading: () => const Text('Loading...'),
                                  error: (e, _) => Text(
                                    e.toString(),
                                    style: const TextStyle(color: AppColors.error),
                                  ),
                                  data: (entries) {
                                    final stale = entries.where((e) => e.isStale).length;
                                    return Text(
                                      entries.isEmpty
                                          ? 'No cached snapshots stored yet'
                                          : '${entries.length} snapshot(s) stored · $stale stale',
                                      style: const TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
                data: (list) {
                  final filtered = moduleFilter == null
                      ? list
                      : list.where((i) => _matchesModule(i.path, moduleFilter)).toList();
                  final conflicts =
                      filtered.where((i) => i.status == 'conflict').toList();
                  final failed = filtered.where((i) => i.status == 'failed').toList();
                  final pending = filtered.where((i) => i.status == 'pending').toList();

                  return TabBarView(
                    children: [
                      _QueueList(items: conflicts, onRefresh: () => _refresh(ref)),
                      _QueueList(items: failed, onRefresh: () => _refresh(ref)),
                      _QueueList(items: pending, onRefresh: () => _refresh(ref)),
                      _CacheDiagnosticsTab(
                        diagnostics: cacheDiagnostics,
                        onRefresh: () => _refresh(ref),
                        moduleFilter: moduleFilter,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(pendingSyncCountProvider);
    ref.invalidate(pendingSyncItemsProvider);
    ref.invalidate(cacheDiagnosticsProvider);
  }

  Future<void> _retryAll(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(syncServiceProvider).retryAllPending();
    await _refresh(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'All pending operations synced.'
              : 'Some items failed. Remaining items stayed in queue.'),
          backgroundColor: ok ? AppColors.success : AppColors.warning,
        ),
      );
    }
  }

  Future<void> _clearQueue(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Sync Queue?'),
        content: const Text(
            'This removes all pending offline operations. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(syncServiceProvider).clearPendingQueue();
    await _refresh(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync queue cleared.')),
      );
    }
  }

  Future<void> _exportConflictReport(BuildContext context, WidgetRef ref) async {
    final list = await ref.read(pendingSyncItemsProvider.future);
    final conflicts = list.where((i) => i.status == 'conflict').toList();

    if (conflicts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No conflicts to export.')),
        );
      }
      return;
    }

    final csv = _toCsv(conflicts);
    await Clipboard.setData(ClipboardData(text: csv));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conflict report copied (${conflicts.length} items).')),
      );
    }
  }

  Future<void> _clearStaleCache(BuildContext context, WidgetRef ref) async {
    final entries = await ref.read(cacheDiagnosticsProvider.future);
    final stale = entries.where((entry) => entry.isStale).toList();

    if (stale.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stale cache snapshots found.')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Stale Cache?'),
        content: Text(
          'Remove ${stale.length} stale cached snapshot(s) older than 24 hours? Queued offline writes will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear stale'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final removed = await ref.read(syncServiceProvider).clearStaleCache();
    await _refresh(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed $removed stale cache snapshot(s).')),
      );
    }
  }

  Future<void> _clearAllCache(BuildContext context, WidgetRef ref) async {
    final entries = await ref.read(cacheDiagnosticsProvider.future);
    if (entries.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cached snapshots to clear.')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Cache?'),
        content: Text(
          'Remove all ${entries.length} cached snapshot(s)? Queued offline writes will remain in the sync queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(syncServiceProvider).clearCache();
    await _refresh(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cleared ${entries.length} cached snapshot(s).')),
      );
    }
  }

  String _toCsv(List<SyncQueueItem> items) {
    String esc(String value) => '"${value.replaceAll('"', '""')}"';

    final rows = <String>[
      'id,method,path,status,retry_count,created_at,last_error'
    ];

    for (final i in items) {
      rows.add([
        i.id.toString(),
        esc(i.method),
        esc(i.path),
        esc(i.status),
        i.retryCount.toString(),
        esc(i.createdAt.toIso8601String()),
        esc(i.lastError ?? ''),
      ].join(','));
    }

    return rows.join('\n');
  }

  String? _normalizeModuleFilter(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toLowerCase();
    const allowed = {
      'dashboard',
      'livestock',
      'inventory',
      'tasks',
      'financial',
      'weather',
      'iot',
    };
    return allowed.contains(normalized) ? normalized : null;
  }

  bool _matchesModule(String path, String module) {
    return path.startsWith('/api/$module');
  }
}

class _ModuleFilterBanner extends StatelessWidget {
  const _ModuleFilterBanner({
    required this.module,
    required this.onClear,
  });

  final String module;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = '${module[0].toUpperCase()}${module.substring(1)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withAlpha(90)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_rounded, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing $label module only',
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _CacheDiagnosticsTab extends ConsumerWidget {
  const _CacheDiagnosticsTab({
    required this.diagnostics,
    required this.onRefresh,
    this.moduleFilter,
  });

  final AsyncValue<List<CacheDiagnosticItem>> diagnostics;
  final Future<void> Function() onRefresh;
  final String? moduleFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return diagnostics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(cacheDiagnosticsProvider),
      ),
      data: (entries) {
        final filtered = moduleFilter == null
            ? entries
            : entries
                .where((entry) => entry.module.toLowerCase() == moduleFilter)
                .toList();
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (filtered.isEmpty)
                const EmptyState(
                  icon: Icons.storage_rounded,
                  title: 'No cache snapshots',
                  subtitle: 'Cached API responses will appear here after the app loads data.',
                )
              else
                ...filtered.map((entry) => _CacheDiagnosticTile(entry: entry)),
            ],
          ),
        );
      },
    );
  }
}

class _CacheDiagnosticTile extends ConsumerWidget {
  const _CacheDiagnosticTile({required this.entry});

  final CacheDiagnosticItem entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = entry.isStale ? AppColors.error : AppColors.warning;
    final ageLabel = entry.isStale ? 'STALE' : 'RECENT';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(20),
          child: Icon(
            entry.isStale ? Icons.schedule_rounded : Icons.cloud_done_rounded,
            color: color,
          ),
        ),
        title: Text(
          '${entry.module} · ${entry.label}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text('Updated ${Fmt.timeAgo(entry.updatedAt)}'),
            Text(
              '${Fmt.dateTime(entry.updatedAt)} · ${_formatBytes(entry.payloadBytes)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              entry.key,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'clear') {
              await ref.read(syncServiceProvider).clearCache(key: entry.key);
              ref.invalidate(cacheDiagnosticsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed cached snapshot for ${entry.module}.')),
                );
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'clear', child: Text('Remove snapshot')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              ageLabel,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _QueueList extends StatelessWidget {
  const _QueueList({required this.items, required this.onRefresh});

  final List<SyncQueueItem> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.inbox_rounded,
              title: 'No items in this bucket',
            )
          else
            ...items.map((item) => _QueueTile(item: item)),
        ],
      ),
    );
  }
}

class _QueueTile extends ConsumerWidget {
  const _QueueTile({required this.item});

  final SyncQueueItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (item.method) {
      'DELETE' => AppColors.error,
      'PUT' => AppColors.warning,
      _ => AppColors.info,
    };

    final (statusColor, statusLabel) = switch (item.status) {
      'conflict' => (AppColors.error, 'CONFLICT'),
      'failed' => (AppColors.warning, 'FAILED'),
      _ => (AppColors.info, 'PENDING'),
    };

    final route = _resolveRoute(item.path);
    final nextRetry = _nextRetryAt(item);
    final retryInText = nextRetry == null
        ? null
        : 'Auto retry in ${_timeUntil(nextRetry)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Text(item.method,
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
        title: Text(item.path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Retries: ${item.retryCount}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text('Queued ${Fmt.timeAgo(item.createdAt)}'),
            if (retryInText != null)
              Text(
                retryInText,
                style: const TextStyle(fontSize: 11, color: AppColors.info),
              ),
            if (item.lastError != null && item.lastError!.isNotEmpty)
              Text(
                item.lastError!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.error),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'open' && route != null) {
              if (context.mounted) context.push(route);
            }
            if (v == 'resolve') {
              await _openResolveWizard(context, ref);
            }
            if (v == 'retry') {
              final ok = await ref.read(syncServiceProvider).retryPendingItem(item.id);
              ref.invalidate(pendingSyncCountProvider);
              ref.invalidate(pendingSyncItemsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Item synced.' : 'Sync failed, kept in queue.'),
                    backgroundColor: ok ? AppColors.success : AppColors.warning,
                  ),
                );
              }
            }
            if (v == 'remove') {
              await ref.read(syncServiceProvider).removePendingItem(item.id);
              ref.invalidate(pendingSyncCountProvider);
              ref.invalidate(pendingSyncItemsProvider);
            }
          },
          itemBuilder: (_) => [
            if (route != null)
              const PopupMenuItem(value: 'open', child: Text('Open module')),
            if (item.body != null)
              const PopupMenuItem(value: 'resolve', child: Text('Resolve payload')),
            const PopupMenuItem(value: 'retry', child: Text('Retry now')),
            const PopupMenuItem(value: 'remove', child: Text('Remove item')),
          ],
        ),
      ),
    );
  }

  DateTime? _nextRetryAt(SyncQueueItem item) {
    if (item.status != 'failed' || item.lastAttemptAt == null) return null;
    final safe = item.retryCount <= 0 ? 1 : item.retryCount;
    final minutes = 1 << (safe - 1);
    final capped = minutes > 30 ? 30 : minutes;
    return item.lastAttemptAt!.add(Duration(minutes: capped));
  }

  String _timeUntil(DateTime next) {
    final diff = next.difference(DateTime.now());
    if (diff.isNegative) return 'now';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }

  String? _resolveRoute(String path) {
    if (path.startsWith('/api/livestock')) return '/livestock';
    if (path.startsWith('/api/inventory')) return '/inventory';
    if (path.startsWith('/api/tasks')) return '/tasks';
    if (path.startsWith('/api/financial')) return '/financial';
    if (path.startsWith('/api/weather')) return '/weather';
    if (path.startsWith('/api/iot')) return '/iot';
    if (path.startsWith('/api/reports')) return '/reports';
    if (path.startsWith('/api/analytics')) return '/analytics';
    if (path.startsWith('/api/dashboard')) return '/dashboard';
    return null;
  }

  Future<void> _openResolveWizard(BuildContext context, WidgetRef ref) async {
    final encoder = const JsonEncoder.withIndent('  ');
    final initialPayload = item.body ?? <String, dynamic>{};
    final ctrl = TextEditingController(text: encoder.convert(initialPayload));
    String? error;
    final template = _templateFor(item.path, item.method);
    final requiredFields = _requiredFieldsFor(item.path, item.method);
    final fieldSpecs = _fieldSpecsFor(item.path, item.method);
    var showAdvanced = fieldSpecs.isEmpty;

    List<String> missingFields(Map<String, dynamic> payload) {
      return requiredFields.where((f) => !payload.containsKey(f)).toList();
    }

    Map<String, dynamic> mergeTemplate(Map<String, dynamic> payload) {
      return {
        ...template,
        ...payload,
      };
    }

    Future<bool> validateAndSave({required bool retryAfter}) async {
      try {
        final decoded = jsonDecode(ctrl.text.trim());
        if (decoded is! Map<String, dynamic>) {
          error = 'Payload must be a JSON object.';
          return false;
        }

        final missing = missingFields(decoded);
        if (missing.isNotEmpty) {
          error = 'Missing required fields: ${missing.join(', ')}';
          return false;
        }

        final typedIssues = _typedValidationErrors(item.path, item.method, decoded);
        if (typedIssues.isNotEmpty) {
          error = typedIssues.first;
          return false;
        }

        await ref.read(syncServiceProvider).updatePendingItemBody(
              item.id,
              decoded,
              resetStatus: true,
            );

        if (retryAfter) {
          await ref.read(syncServiceProvider).retryPendingItem(item.id);
        }

        ref.invalidate(pendingSyncCountProvider);
        ref.invalidate(pendingSyncItemsProvider);
        return true;
      } catch (e) {
        error = 'Invalid JSON: $e';
        return false;
      }
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Map<String, dynamic>? parsed;
            List<String> missing = const [];
            List<String> typedIssues = const [];
            try {
              final decoded = jsonDecode(ctrl.text.trim());
              if (decoded is Map<String, dynamic>) {
                parsed = decoded;
                missing = missingFields(decoded);
                typedIssues =
                    _typedValidationErrors(item.path, item.method, decoded);
              }
            } catch (_) {}

            return AlertDialog(
              title: const Text('Resolve Queued Payload'),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.method} ${item.path}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (item.lastError != null && item.lastError!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last error: ${item.lastError!}',
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (fieldSpecs.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  showAdvanced = !showAdvanced;
                                });
                              },
                              icon: Icon(
                                showAdvanced
                                    ? Icons.tune_rounded
                                    : Icons.code_rounded,
                                size: 16,
                              ),
                              label: Text(
                                showAdvanced ? 'Guided Mode' : 'Advanced JSON',
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: () {
                              final current = parsed ?? <String, dynamic>{};
                              final merged = mergeTemplate(current);
                              ctrl.text = encoder.convert(merged);
                              setState(() {
                                error = null;
                              });
                            },
                            icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                            label: const Text('Apply Template'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              ctrl.text = encoder.convert(initialPayload);
                              setState(() {
                                error = null;
                              });
                            },
                            icon: const Icon(Icons.restore_rounded, size: 16),
                            label: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (!showAdvanced && fieldSpecs.isNotEmpty)
                        _GuidedFieldsCard(
                          payload: parsed ?? <String, dynamic>{},
                          specs: fieldSpecs,
                          onChanged: (updatedPayload) {
                            ctrl.text = encoder.convert(updatedPayload);
                            setState(() {
                              error = null;
                            });
                          },
                        )
                      else
                        TextField(
                          controller: ctrl,
                          maxLines: 14,
                          onChanged: (_) => setState(() {
                            error = null;
                          }),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '{\n  "key": "value"\n}',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (requiredFields.isNotEmpty)
                        Text(
                          'Required fields: ${requiredFields.join(', ')}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant),
                        ),
                      if (parsed == null)
                        const Text(
                          'Validation: invalid JSON',
                          style: TextStyle(fontSize: 11, color: AppColors.error),
                        )
                      else if (missing.isNotEmpty)
                        Text(
                          'Validation: missing ${missing.join(', ')}',
                          style: const TextStyle(fontSize: 11, color: AppColors.warning),
                        )
                      else if (typedIssues.isNotEmpty)
                        Text(
                          'Validation: ${typedIssues.first}',
                          style: const TextStyle(fontSize: 11, color: AppColors.warning),
                        )
                      else
                        const Text(
                          'Validation: looks good',
                          style: TextStyle(fontSize: 11, color: AppColors.success),
                        ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final ok = await validateAndSave(retryAfter: false);
                    if (ok && dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payload updated.')),
                        );
                      }
                    } else {
                      setState(() {});
                    }
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await validateAndSave(retryAfter: true);
                    if (ok && dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payload saved and retry triggered.')),
                        );
                      }
                    } else {
                      setState(() {});
                    }
                  },
                  child: const Text('Save & Retry'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _requiredFieldsFor(String path, String method) {
    final m = method.toUpperCase();
    if (path.startsWith('/api/tasks') && m == 'POST') {
      return const ['title', 'status', 'priority'];
    }
    if (path.startsWith('/api/livestock') && m == 'POST') {
      return const ['batch_code', 'animal_type', 'breed', 'initial_quantity'];
    }
    if (path.startsWith('/api/inventory') && m == 'POST') {
      return const ['item_name', 'category', 'quantity', 'unit'];
    }
    if (path.startsWith('/api/financial/records') && m == 'POST') {
      return const ['transaction_type', 'category', 'amount', 'transaction_date'];
    }
    if (path.startsWith('/api/weather/observation') && m == 'POST') {
      return const ['temperature_c', 'humidity_percent'];
    }
    if (path.startsWith('/api/iot/devices') && m == 'POST') {
      return const ['name', 'device_type'];
    }
    return const [];
  }

  Map<String, dynamic> _templateFor(String path, String method) {
    final m = method.toUpperCase();
    if (path.startsWith('/api/tasks') && m == 'POST') {
      return {
        'title': 'Sample task',
        'description': 'Task details',
        'status': 'pending',
        'priority': 'medium',
      };
    }
    if (path.startsWith('/api/livestock') && m == 'POST') {
      return {
        'batch_code': 'BATCH-001',
        'animal_type': 'broiler',
        'breed': 'hybrid',
        'initial_quantity': 100,
        'current_quantity': 100,
        'status': 'active',
      };
    }
    if (path.startsWith('/api/inventory') && m == 'POST') {
      return {
        'item_name': 'Feed',
        'category': 'Feed',
        'quantity': 0,
        'unit': 'kg',
        'reorder_level': 10,
        'cost_per_unit': 0,
      };
    }
    if (path.startsWith('/api/financial/records') && m == 'POST') {
      return {
        'transaction_type': 'expense',
        'category': 'Other',
        'amount': 0,
        'transaction_date': DateTime.now().toIso8601String(),
      };
    }
    if (path.startsWith('/api/weather/observation') && m == 'POST') {
      return {
        'temperature_c': 0,
        'humidity_percent': 0,
        'rainfall_mm': 0,
        'wind_speed_kph': 0,
      };
    }
    if (path.startsWith('/api/iot/devices') && m == 'POST') {
      return {
        'name': 'Device Name',
        'device_type': 'sensor',
        'location': 'Farm Zone',
        'status': 'online',
      };
    }
    return <String, dynamic>{};
  }

  List<_FieldSpec> _fieldSpecsFor(String path, String method) {
    final m = method.toUpperCase();

    if (path.startsWith('/api/tasks') && m == 'POST') {
      return const [
        _FieldSpec('title', 'Title', _FieldType.text),
        _FieldSpec('description', 'Description', _FieldType.text),
        _FieldSpec('status', 'Status', _FieldType.choice,
            options: ['pending', 'in_progress', 'completed', 'cancelled']),
        _FieldSpec('priority', 'Priority', _FieldType.choice,
            options: ['low', 'medium', 'high', 'urgent']),
        _FieldSpec('due_date', 'Due Date', _FieldType.dateTime),
      ];
    }

    if (path.startsWith('/api/livestock') && m == 'POST') {
      return const [
        _FieldSpec('batch_code', 'Batch Code', _FieldType.text),
        _FieldSpec('animal_type', 'Animal Type', _FieldType.text),
        _FieldSpec('breed', 'Breed', _FieldType.text),
        _FieldSpec('initial_quantity', 'Initial Quantity', _FieldType.number),
        _FieldSpec('current_quantity', 'Current Quantity', _FieldType.number),
        _FieldSpec('status', 'Status', _FieldType.choice,
            options: ['active', 'sold', 'harvested', 'deceased']),
      ];
    }

    if (path.startsWith('/api/inventory') && m == 'POST') {
      return const [
        _FieldSpec('item_name', 'Item Name', _FieldType.text),
        _FieldSpec('category', 'Category', _FieldType.text),
        _FieldSpec('quantity', 'Quantity', _FieldType.number),
        _FieldSpec('unit', 'Unit', _FieldType.text),
        _FieldSpec('reorder_level', 'Reorder Level', _FieldType.number),
        _FieldSpec('cost_per_unit', 'Cost / Unit', _FieldType.number),
      ];
    }

    if (path.startsWith('/api/financial/records') && m == 'POST') {
      return const [
        _FieldSpec('transaction_type', 'Transaction Type', _FieldType.choice,
            options: ['income', 'expense']),
        _FieldSpec('category', 'Category', _FieldType.text),
        _FieldSpec('amount', 'Amount', _FieldType.number),
        _FieldSpec('transaction_date', 'Transaction Date', _FieldType.dateTime),
        _FieldSpec('description', 'Description', _FieldType.text),
      ];
    }

    if (path.startsWith('/api/weather/observation') && m == 'POST') {
      return const [
        _FieldSpec('temperature_c', 'Temperature (C)', _FieldType.number),
        _FieldSpec('humidity_percent', 'Humidity %', _FieldType.number),
        _FieldSpec('rainfall_mm', 'Rainfall (mm)', _FieldType.number),
        _FieldSpec('wind_speed_kph', 'Wind Speed (kph)', _FieldType.number),
        _FieldSpec('conditions', 'Conditions', _FieldType.text),
      ];
    }

    if (path.startsWith('/api/iot/devices') && m == 'POST') {
      return const [
        _FieldSpec('name', 'Device Name', _FieldType.text),
        _FieldSpec('device_type', 'Device Type', _FieldType.text),
        _FieldSpec('location', 'Location', _FieldType.text),
        _FieldSpec('status', 'Status', _FieldType.choice,
            options: ['online', 'offline', 'error']),
      ];
    }

    return const [];
  }

  List<String> _typedValidationErrors(
    String path,
    String method,
    Map<String, dynamic> payload,
  ) {
    final issues = <String>[];

    bool isNumField(String k) => payload[k] is num;
    double asDouble(String k) => (payload[k] as num).toDouble();
    int asInt(String k) => (payload[k] as num).toInt();

    final m = method.toUpperCase();

    if (path.startsWith('/api/tasks') && (m == 'POST' || m == 'PUT')) {
      if (payload['title'] != null &&
          (payload['title'] is! String ||
              (payload['title'] as String).trim().isEmpty)) {
        issues.add('title must be a non-empty string');
      }

      final status = payload['status'];
      if (status != null &&
          !['pending', 'in_progress', 'completed', 'cancelled']
              .contains(status.toString())) {
        issues.add('status must be one of: pending, in_progress, completed, cancelled');
      }

      final priority = payload['priority'];
      if (priority != null &&
          !['low', 'medium', 'high', 'urgent'].contains(priority.toString())) {
        issues.add('priority must be one of: low, medium, high, urgent');
      }

      if (payload['due_date'] != null &&
          DateTime.tryParse(payload['due_date'].toString()) == null) {
        issues.add('due_date must be a valid ISO date/time');
      }
    }

    if (path.startsWith('/api/livestock') && (m == 'POST' || m == 'PUT')) {
      for (final f in ['initial_quantity', 'current_quantity']) {
        if (payload[f] != null) {
          if (!isNumField(f)) {
            issues.add('$f must be numeric');
          } else if (asInt(f) < 0) {
            issues.add('$f cannot be negative');
          }
        }
      }

      final status = payload['status'];
      if (status != null &&
          !['active', 'sold', 'harvested', 'deceased'].contains(status.toString())) {
        issues.add('status must be one of: active, sold, harvested, deceased');
      }
    }

    if (path.startsWith('/api/inventory') && (m == 'POST' || m == 'PUT')) {
      for (final f in ['quantity', 'reorder_level', 'cost_per_unit']) {
        if (payload[f] != null) {
          if (!isNumField(f)) {
            issues.add('$f must be numeric');
          } else if (asDouble(f) < 0) {
            issues.add('$f cannot be negative');
          }
        }
      }
    }

    if (path.startsWith('/api/financial/records') && (m == 'POST' || m == 'PUT')) {
      final type = payload['transaction_type'];
      if (type != null && !['income', 'expense'].contains(type.toString())) {
        issues.add('transaction_type must be either income or expense');
      }

      if (payload['amount'] != null) {
        if (!isNumField('amount')) {
          issues.add('amount must be numeric');
        } else if (asDouble('amount') < 0) {
          issues.add('amount cannot be negative');
        }
      }

      if (payload['transaction_date'] != null &&
          DateTime.tryParse(payload['transaction_date'].toString()) == null) {
        issues.add('transaction_date must be a valid ISO date/time');
      }
    }

    if (path.startsWith('/api/weather/observation') && (m == 'POST' || m == 'PUT')) {
      if (payload['temperature_c'] != null) {
        if (!isNumField('temperature_c')) {
          issues.add('temperature_c must be numeric');
        } else {
          final t = asDouble('temperature_c');
          if (t < -50 || t > 80) {
            issues.add('temperature_c out of realistic range (-50 to 80)');
          }
        }
      }

      if (payload['humidity_percent'] != null) {
        if (!isNumField('humidity_percent')) {
          issues.add('humidity_percent must be numeric');
        } else {
          final h = asDouble('humidity_percent');
          if (h < 0 || h > 100) {
            issues.add('humidity_percent must be between 0 and 100');
          }
        }
      }
    }

    if (path.startsWith('/api/iot/devices') && (m == 'POST' || m == 'PUT')) {
      for (final f in ['name', 'device_type']) {
        if (payload[f] != null &&
            (payload[f] is! String || payload[f].toString().trim().isEmpty)) {
          issues.add('$f must be a non-empty string');
        }
      }

      final status = payload['status'];
      if (status != null && !['online', 'offline', 'error'].contains(status.toString())) {
        issues.add('status must be one of: online, offline, error');
      }
    }

    return issues;
  }
}

enum _FieldType { text, number, choice, dateTime }

class _FieldSpec {
  const _FieldSpec(this.key, this.label, this.type, {this.options = const []});

  final String key;
  final String label;
  final _FieldType type;
  final List<String> options;
}

class _GuidedFieldsCard extends StatelessWidget {
  const _GuidedFieldsCard({
    required this.payload,
    required this.specs,
    required this.onChanged,
  });

  final Map<String, dynamic> payload;
  final List<_FieldSpec> specs;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: specs.map((spec) {
          final value = payload[spec.key];
          return ListTile(
            title: Text(spec.label),
            subtitle: Text(_displayValue(value), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.edit_rounded, size: 18),
            onTap: () async {
              final result = await _editFieldValue(context, spec, value);
              if (result == null) return;
              final next = Map<String, dynamic>.from(payload);
              next[spec.key] = result;
              onChanged(next);
            },
          );
        }).toList(),
      ),
    );
  }

  static String _displayValue(dynamic value) {
    if (value == null) return 'Not set';
    return value.toString();
  }

  static Future<dynamic> _editFieldValue(
    BuildContext context,
    _FieldSpec spec,
    dynamic currentValue,
  ) async {
    if (spec.type == _FieldType.choice) {
      String selected = (currentValue?.toString().isNotEmpty ?? false)
          ? currentValue.toString()
          : spec.options.first;

      return showDialog<dynamic>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(spec.label),
          content: StatefulBuilder(
            builder: (_, setState) => DropdownButtonFormField<String>(
              value: selected,
              items: spec.options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => setState(() => selected = v ?? selected),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, selected),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
    }

    final controller = TextEditingController(text: currentValue?.toString() ?? '');
    return showDialog<dynamic>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(spec.label),
        content: TextField(
          controller: controller,
          keyboardType: spec.type == _FieldType.number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: spec.type == _FieldType.dateTime
                ? DateTime.now().toIso8601String()
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final raw = controller.text.trim();
              dynamic value = raw;
              if (spec.type == _FieldType.number) {
                value = num.tryParse(raw) ?? raw;
              }
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
