import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/task.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import 'task_activity_feed.dart';

final _taskDetailProvider =
    FutureProvider.autoDispose.family<Task, int>((ref, id) {
  return ref.read(taskServiceProvider).getById(id);
});

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final int taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _working = false;

  Future<void> _complete() async {
    setState(() => _working = true);
    try {
      await ref.read(taskServiceProvider).complete(widget.taskId);
      ref.invalidate(_taskDetailProvider(widget.taskId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(_taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: taskAsync.whenOrNull(data: (t) => Text(t.title)) ??
            const Text('Task'),
        leading: const BackButton(),
        actions: [
          taskAsync.whenOrNull(
            data: (task) {
              if (task.status == 'completed' || task.status == 'cancelled') {
                return const SizedBox.shrink();
              }
              return _working
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: _complete,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Complete'),
                    );
            },
          ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_taskDetailProvider(widget.taskId)),
        ),
        data: (task) => _TaskDetailBody(task: task),
      ),
    );
  }
}

class _TaskDetailBody extends StatelessWidget {
  const _TaskDetailBody({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(task: task),
          const SizedBox(height: 16),
          TaskActivityFeed(task: task),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: task.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                PriorityBadge(priority: task.priority),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: task.isOverdue
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Fmt.date(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: task.isOverdue
                          ? AppColors.error
                          : AppColors.onSurfaceVariant,
                      fontWeight: task.isOverdue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                task.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
            if (task.assigneeName != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.person_rounded,
                      size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Assigned to ${task.assigneeName}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
            if (task.createdAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Created ${Fmt.dateTime(task.createdAt!)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
