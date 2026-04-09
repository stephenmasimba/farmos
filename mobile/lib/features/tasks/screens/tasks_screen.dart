import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/task.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/services/cache_status_service.dart';
import '../../../core/services/task_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../widgets/task_comments_sheet.dart';

final _tasksProvider =
    FutureProvider.autoDispose.family<List<Task>, String?>((ref, status) {
  return ref.read(taskServiceProvider).getAll(status: status);
});

final _taskStatsProvider = FutureProvider.autoDispose<TaskStats>((ref) {
  return ref.read(taskServiceProvider).getStats();
});

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _statuses = [null, 'pending', 'in_progress', 'completed'];
  final _labels = ['All', 'Pending', 'In Progress', 'Done'];
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _batchDelete() async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete tasks?'),
        content: Text('Delete ${_selectedIds.length} task(s)? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final service = ref.read(taskServiceProvider);
    for (final id in _selectedIds) {
      await service.delete(id);
    }
    _exitSelectionMode();
    for (final s in _statuses) {
      ref.invalidate(_tasksProvider(s));
    }
    ref.invalidate(_taskStatsProvider);
  }

  Future<void> _batchComplete() async {
    if (_selectedIds.isEmpty) return;
    final service = ref.read(taskServiceProvider);
    for (final id in _selectedIds) {
      await service.complete(id);
    }
    _exitSelectionMode();
    for (final s in _statuses) {
      ref.invalidate(_tasksProvider(s));
    }
    ref.invalidate(_taskStatsProvider);
  }

  Future<void> _batchChangePriority(String priority) async {
    if (_selectedIds.isEmpty) return;
    final service = ref.read(taskServiceProvider);
    for (final id in _selectedIds) {
      await service.update(id, {'priority': priority});
    }
    _exitSelectionMode();
    for (final s in _statuses) {
      ref.invalidate(_tasksProvider(s));
    }
    ref.invalidate(_taskStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(_taskStatsProvider);
    final pendingChanges =
        ref.watch(pendingModuleChangesProvider(ApiEndpoints.tasks));
    final cacheStatus = latestOfflineStatus(
      ref.watch(cacheStatusServiceProvider),
      const [
        TaskService.listStatusKey,
        TaskService.statsStatusKey,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: List.generate(_labels.length, (i) {
            final label = _labels[i];
            return Tab(text: label);
          }),
        ),
        actions: [
          IconButton(
            icon: Icon(_selectionMode ? Icons.close : Icons.checklist_rounded),
            tooltip: _selectionMode ? 'Exit selection' : 'Select multiple',
            onPressed: () {
              setState(() {
                if (_selectionMode) {
                  _selectionMode = false;
                  _selectedIds.clear();
                } else {
                  _selectionMode = true;
                }
              });
            },
          ),
          if (!_selectionMode)
            stats.whenOrNull(
                  data: (s) => s.overdue > 0
                      ? IconButton(
                          icon: Badge(
                            label: Text('${s.overdue}'),
                            child: const Icon(Icons.warning_amber_rounded),
                          ),
                          onPressed: () {},
                        )
                      : null,
                ) ??
                const SizedBox(),
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
                      onTap: () => context.push('/sync?module=tasks'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (_selectionMode && _selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _batchComplete,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text('Complete (${_selectedIds.length})'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _batchChangePriority('low'),
                    icon: const Icon(Icons.arrow_downward_rounded),
                    label: const Text('Set Low'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _batchChangePriority('medium'),
                    icon: const Icon(Icons.remove_rounded),
                    label: const Text('Set Medium'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _batchChangePriority('high'),
                    icon: const Icon(Icons.arrow_upward_rounded),
                    label: const Text('Set High'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _batchDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text('Delete (${_selectedIds.length})'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: _statuses
                  .map((s) => _TaskList(
                        status: s,
                        selectionMode: _selectionMode,
                        selectedIds: _selectedIds,
                        onSelectionChanged: (id, selected) {
                          setState(() {
                            if (selected) {
                              _selectedIds.add(id);
                            } else {
                              _selectedIds.remove(id);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/tasks/add');
                for (final s in _statuses) {
                  ref.invalidate(_tasksProvider(s));
                }
                ref.invalidate(_taskStatsProvider);
              },
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
            ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({
    required this.status,
    required this.selectionMode,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final String? status;
  final bool selectionMode;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(_tasksProvider(status));

    return tasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_tasksProvider(status)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No tasks',
            subtitle: 'Tap + to create a new task',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_tasksProvider(status)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _TaskCard(
              task: list[i],
              selectionMode: selectionMode,
              isSelected: selectedIds.contains(list[i].id),
              onToggle: (selected) => onSelectionChanged(list[i].id, selected),
              onComplete: () async {
                await ref.read(taskServiceProvider).complete(list[i].id);
                ref.invalidate(_tasksProvider(status));
              },
            ),
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggle,
    required this.onComplete,
  });

  final Task task;
  final bool selectionMode;
  final bool isSelected;
  final void Function(bool) onToggle;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tasks/${task.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (selectionMode)
              Checkbox(
                value: isSelected,
                onChanged: (v) => onToggle(v ?? false),
              ),
            if (!selectionMode && task.status != 'completed')
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              )
            else if (!selectionMode)
              const Padding(
                padding: EdgeInsets.only(right: 12, top: 2),
                child: Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 22),
              ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: task.status == 'completed'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 4),
                    Text(task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      PriorityBadge(priority: task.priority),
                      const SizedBox(width: 12),
                      if (task.dueDate != null) ...[
                        Icon(
                          Icons.event_rounded,
                          size: 12,
                          color: task.isOverdue
                              ? AppColors.error
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Fmt.date(task.dueDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: task.isOverdue
                                ? AppColors.error
                                : AppColors.onSurfaceVariant,
                            fontWeight: task.isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.comment_rounded, size: 18),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => TaskCommentsSheet(
                            taskId: task.id,
                            taskTitle: task.title,
                          ),
                        ),
                      ),
                      StatusBadge(status: task.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
