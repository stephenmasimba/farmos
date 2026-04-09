import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/hr.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

final _sopsProvider = FutureProvider.autoDispose<List<HrSop>>((ref) {
  return ref.read(hrServiceProvider).listSops();
});

final _tasksProvider = FutureProvider.autoDispose<List<HrTask>>((ref) {
  return ref.read(hrServiceProvider).listTasks();
});

final _schedulesProvider = FutureProvider.autoDispose<List<HrSchedule>>((ref) {
  return ref.read(hrServiceProvider).listSchedules();
});

final _executionsProvider = FutureProvider.autoDispose<List<HrSopExecution>>((ref) {
  return ref.read(hrServiceProvider).listExecutions();
});

class HrScreen extends ConsumerStatefulWidget {
  const HrScreen({super.key});

  @override
  ConsumerState<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends ConsumerState<HrScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final canRead = user?.hasPermission('tasks.read') ?? false;
    final canCreate = user?.hasPermission('tasks.create') ?? false;
    final canComplete = user?.hasPermission('tasks.complete') ?? false;

    if (!canRead) {
      return const Scaffold(
        appBar: AppBar(title: Text('HR')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Access denied',
          subtitle: 'Your account does not have permission to view HR data.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Operations'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'SOPs'),
            Tab(text: 'Tasks'),
            Tab(text: 'Schedules'),
            Tab(text: 'Runs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _SopsTab(canCreate: canCreate, canRun: canComplete),
          _TasksTab(canCreate: canCreate),
          _SchedulesTab(canCreate: canCreate),
          const _RunsTab(),
        ],
      ),
    );
  }
}

class _SopsTab extends ConsumerWidget {
  const _SopsTab({required this.canCreate, required this.canRun});

  final bool canCreate;
  final bool canRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sops = ref.watch(_sopsProvider);
    return Column(
      children: [
        if (canCreate)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _AddSopSheet(),
                  );
                  ref.invalidate(_sopsProvider);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add SOP'),
              ),
            ),
          ),
        Expanded(
          child: sops.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_sopsProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'No SOPs available',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(_sopsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = list[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.description_rounded),
                        title: Text(item.title),
                        subtitle: Text('Role: ${item.role}\n${item.content}'),
                        isThreeLine: true,
                        trailing: canRun
                            ? IconButton(
                                icon: const Icon(Icons.play_arrow_rounded),
                                tooltip: 'Run SOP',
                                onPressed: () async {
                                  await showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => _RunSopSheet(sopId: item.id),
                                  );
                                  ref.invalidate(_executionsProvider);
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TasksTab extends ConsumerWidget {
  const _TasksTab({required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(_tasksProvider);
    return Column(
      children: [
        if (canCreate)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _AddHrTaskSheet(),
                  );
                  ref.invalidate(_tasksProvider);
                },
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Add HR Task'),
              ),
            ),
          ),
        Expanded(
          child: tasks.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_tasksProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.task_alt_rounded,
                  title: 'No HR tasks',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = list[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.task_rounded),
                      title: Text(item.title),
                      subtitle: Text(
                        'Due: ${item.dueDate?.toIso8601String().split('T').first ?? '-'}\n'
                        'Assigned: ${item.assignedTo?.toString() ?? '-'}',
                      ),
                      trailing: StatusBadge(status: item.status),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SchedulesTab extends ConsumerWidget {
  const _SchedulesTab({required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(_schedulesProvider);
    return Column(
      children: [
        if (canCreate)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _AddScheduleSheet(),
                  );
                  ref.invalidate(_schedulesProvider);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Schedule'),
              ),
            ),
          ),
        Expanded(
          child: schedules.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_schedulesProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_note_rounded,
                  title: 'No schedules',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = list[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.badge_rounded),
                      title: Text('User ${item.userId} · ${item.role}'),
                      subtitle: Text(
                        '${item.startTime?.toIso8601String() ?? '-'}\n'
                        '${item.endTime?.toIso8601String() ?? '-'}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RunsTab extends ConsumerWidget {
  const _RunsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(_executionsProvider);
    return runs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_executionsProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No SOP run history',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final item = list[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.play_circle_outline_rounded),
                title: Text('SOP ${item.sopId}'),
                subtitle: Text(item.notes?.isNotEmpty == true ? item.notes! : '-'),
                trailing: StatusBadge(status: item.status),
              ),
            );
          },
        );
      },
    );
  }
}

class _AddSopSheet extends ConsumerStatefulWidget {
  const _AddSopSheet();

  @override
  ConsumerState<_AddSopSheet> createState() => _AddSopSheetState();
}

class _AddSopSheetState extends ConsumerState<_AddSopSheet> {
  final _title = TextEditingController();
  final _role = TextEditingController();
  final _content = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _role.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Add SOP',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Save SOP',
      children: [
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
        const SizedBox(height: 8),
        TextField(controller: _role, decoration: const InputDecoration(labelText: 'Role')),
        const SizedBox(height: 8),
        TextField(
          controller: _content,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _role.text.trim().isEmpty || _content.text.trim().isEmpty) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).createSop(
            title: _title.text.trim(),
            role: _role.text.trim(),
            content: _content.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _AddHrTaskSheet extends ConsumerStatefulWidget {
  const _AddHrTaskSheet();

  @override
  ConsumerState<_AddHrTaskSheet> createState() => _AddHrTaskSheetState();
}

class _AddHrTaskSheetState extends ConsumerState<_AddHrTaskSheet> {
  final _title = TextEditingController();
  final _assignedTo = TextEditingController();
  DateTime _dueDate = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _assignedTo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Add HR Task',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Save Task',
      children: [
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
        const SizedBox(height: 8),
        TextField(
          controller: _assignedTo,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Assigned User ID (optional)'),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_rounded),
          title: const Text('Due Date'),
          subtitle: Text(_dueDate.toIso8601String().split('T').first),
          onTap: _pickDate,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).createTask(
            title: _title.text.trim(),
            dueDate: _dueDate,
            assignedTo: int.tryParse(_assignedTo.text.trim()),
          );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _AddScheduleSheet extends ConsumerStatefulWidget {
  const _AddScheduleSheet();

  @override
  ConsumerState<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends ConsumerState<_AddScheduleSheet> {
  final _userId = TextEditingController();
  final _role = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 8));
  bool _busy = false;

  @override
  void dispose() {
    _userId.dispose();
    _role.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Add Schedule',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Save Schedule',
      children: [
        TextField(
          controller: _userId,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'User ID'),
        ),
        const SizedBox(height: 8),
        TextField(controller: _role, decoration: const InputDecoration(labelText: 'Role')),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule_rounded),
          title: const Text('Start'),
          subtitle: Text(_start.toIso8601String()),
          onTap: () => _pickDateTime(isStart: true),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule_send_rounded),
          title: const Text('End'),
          subtitle: Text(_end.toIso8601String()),
          onTap: () => _pickDateTime(isStart: false),
        ),
      ],
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final base = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _start = dt;
      } else {
        _end = dt;
      }
    });
  }

  Future<void> _save() async {
    final uid = int.tryParse(_userId.text.trim());
    if (uid == null || uid <= 0 || _role.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).createSchedule(
            userId: uid,
            role: _role.text.trim(),
            startTime: _start,
            endTime: _end,
          );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _RunSopSheet extends ConsumerStatefulWidget {
  const _RunSopSheet({required this.sopId});

  final int sopId;

  @override
  ConsumerState<_RunSopSheet> createState() => _RunSopSheetState();
}

class _RunSopSheetState extends ConsumerState<_RunSopSheet> {
  final _notes = TextEditingController();
  String _status = 'completed';
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Run SOP #${widget.sopId}',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Submit Run',
      children: [
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: const [
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'failed', child: Text('Failed')),
          ],
          onChanged: (v) => setState(() => _status = v ?? 'completed'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Notes (optional)'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).runSop(
            sopId: widget.sopId,
            status: _status,
            notes: _notes.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({
    required this.title,
    required this.busy,
    required this.onSubmit,
    required this.submitLabel,
    required this.children,
  });

  final String title;
  final bool busy;
  final Future<void> Function() onSubmit;
  final String submitLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...children,
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : onSubmit,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(busy ? 'Saving...' : submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
