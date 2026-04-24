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

final _attendanceProvider = FutureProvider.autoDispose<List<HrAttendance>>((ref) {
  final user = ref.watch(authProvider).user;
  final farmId = user?.farmId;
  if (farmId == null) return Future.value(const <HrAttendance>[]);
  return ref
      .read(hrServiceProvider)
      .listAttendance(farmId: farmId, userId: user?.id);
});

final _compensationProvider = FutureProvider.autoDispose<List<HrCompensation>>((ref) {
  final user = ref.watch(authProvider).user;
  final farmId = user?.farmId;
  if (farmId == null) return Future.value(const <HrCompensation>[]);
  return ref.read(hrServiceProvider).listCompensation(farmId: farmId);
});

final _enrollmentsProvider =
    FutureProvider.autoDispose<List<HrBenefitEnrollment>>((ref) {
  final user = ref.watch(authProvider).user;
  final farmId = user?.farmId;
  if (farmId == null) return Future.value(const <HrBenefitEnrollment>[]);
  return ref.read(hrServiceProvider).listBenefitEnrollments(farmId: farmId);
});

final _contractorLogsProvider =
    FutureProvider.autoDispose<List<HrContractorLog>>((ref) {
  final user = ref.watch(authProvider).user;
  final farmId = user?.farmId;
  if (farmId == null) return Future.value(const <HrContractorLog>[]);
  return ref.read(hrServiceProvider).listContractorLogs(farmId: farmId);
});

final _trainingCoursesProvider =
    FutureProvider.autoDispose<List<HrTrainingCourse>>((ref) {
  final user = ref.watch(authProvider).user;
  final farmId = user?.farmId;
  if (farmId == null) return Future.value(const <HrTrainingCourse>[]);
  return ref.read(hrServiceProvider).listTrainingCourses(farmId: farmId);
});

final _trainingRecordsProvider =
    FutureProvider.autoDispose<List<HrTrainingRecord>>((ref) {
  final user = ref.watch(authProvider).user;
  final farmId = user?.farmId;
  if (farmId == null) return Future.value(const <HrTrainingRecord>[]);
  return ref.read(hrServiceProvider).listTrainingRecords(farmId: farmId);
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
    _tabs = TabController(length: 5, vsync: this);
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
            Tab(text: 'Workforce'),
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
          _WorkforceTab(canManage: canCreate),
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

class _WorkforceTab extends ConsumerWidget {
  const _WorkforceTab({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final farmId = user?.farmId;
    if (farmId == null) {
      return const EmptyState(
        icon: Icons.agriculture_rounded,
        title: 'No farm selected',
        subtitle: 'Your account does not have a farm_id assigned.',
      );
    }

    final attendance = ref.watch(_attendanceProvider);
    final compensation = ref.watch(_compensationProvider);
    final enrollments = ref.watch(_enrollmentsProvider);
    final contractorLogs = ref.watch(_contractorLogsProvider);
    final courses = ref.watch(_trainingCoursesProvider);
    final records = ref.watch(_trainingRecordsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_attendanceProvider);
        ref.invalidate(_compensationProvider);
        ref.invalidate(_enrollmentsProvider);
        ref.invalidate(_contractorLogsProvider);
        ref.invalidate(_trainingCoursesProvider);
        ref.invalidate(_trainingRecordsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Attendance',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await ref.read(hrServiceProvider).clockIn(
                                farmId: farmId,
                                userId: user?.id,
                              );
                          ref.invalidate(_attendanceProvider);
                        },
                        child: const Text('Clock in'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await ref.read(hrServiceProvider).clockOut(
                                farmId: farmId,
                                userId: user?.id,
                              );
                          ref.invalidate(_attendanceProvider);
                        },
                        child: const Text('Clock out'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  attendance.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(e.toString()),
                    data: (list) {
                      if (list.isEmpty) {
                        return const Text('No attendance records yet.');
                      }
                      final recent = list.take(5).toList();
                      return Column(
                        children: recent
                            .map(
                              (a) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.access_time_rounded),
                                title: Text(
                                  a.clockIn?.toLocal().toString() ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Out: ${a.clockOut?.toLocal().toString() ?? '-'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Payroll',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () async {
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => _RunPayrollSheet(farmId: farmId),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Run'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: compensation.when(
                          loading: () => const Text('Compensation: ...'),
                          error: (e, _) => Text('Compensation: $e'),
                          data: (list) => Text('Compensation setups: ${list.length}'),
                        ),
                      ),
                      if (canManage)
                        OutlinedButton(
                          onPressed: () async {
                            await showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => _SaveCompensationSheet(farmId: farmId),
                            );
                            ref.invalidate(_compensationProvider);
                          },
                          child: const Text('Set pay'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: enrollments.when(
                          loading: () => const Text('Benefits: ...'),
                          error: (e, _) => Text('Benefits: $e'),
                          data: (list) => Text('Benefit enrollments: ${list.length}'),
                        ),
                      ),
                      if (canManage)
                        OutlinedButton(
                          onPressed: () async {
                            await showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => _EnrollBenefitSheet(farmId: farmId),
                            );
                            ref.invalidate(_enrollmentsProvider);
                          },
                          child: const Text('Enroll'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Training & Competency',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (canManage)
                        OutlinedButton(
                          onPressed: () async {
                            await showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => _AddTrainingCourseSheet(farmId: farmId),
                            );
                            ref.invalidate(_trainingCoursesProvider);
                          },
                          child: const Text('Add course'),
                        ),
                      const SizedBox(width: 8),
                      if (canManage)
                        FilledButton(
                          onPressed: () async {
                            await showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => _AddTrainingRecordSheet(farmId: farmId),
                            );
                            ref.invalidate(_trainingRecordsProvider);
                          },
                          child: const Text('Record'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  courses.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(e.toString()),
                    data: (list) => Text('Courses: ${list.length}'),
                  ),
                  const SizedBox(height: 6),
                  records.when(
                    loading: () => const Text('Records: ...'),
                    error: (e, _) => Text('Records: $e'),
                    data: (list) {
                      final recent = list.take(5).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Records: ${list.length}'),
                          const SizedBox(height: 8),
                          if (recent.isNotEmpty)
                            ...recent.map(
                              (r) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.school_rounded),
                                title: Text('Course ${r.courseId} · Employee ${r.employeeId}'),
                                subtitle: Text(
                                  'Status: ${r.status} · Expiry: ${r.expiryDate?.toIso8601String().split('T').first ?? '-'}',
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Contractor labor',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (canManage)
                        FilledButton.icon(
                          onPressed: () async {
                            await showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => _AddContractorLogSheet(farmId: farmId),
                            );
                            ref.invalidate(_contractorLogsProvider);
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Log'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  contractorLogs.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(e.toString()),
                    data: (list) {
                      if (list.isEmpty) return const Text('No contractor logs yet.');
                      final recent = list.take(5).toList();
                      return Column(
                        children: recent
                            .map(
                              (l) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.engineering_rounded),
                                title: Text('Contractor ${l.contractorId} · ${l.hours}h'),
                                subtitle: Text(
                                  '${l.workDate?.toIso8601String().split('T').first ?? '-'} · ${l.status} · ${l.totalCost.toStringAsFixed(2)}',
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunPayrollSheet extends ConsumerStatefulWidget {
  const _RunPayrollSheet({required this.farmId});
  final int farmId;

  @override
  ConsumerState<_RunPayrollSheet> createState() => _RunPayrollSheetState();
}

class _RunPayrollSheetState extends ConsumerState<_RunPayrollSheet> {
  DateTime _start = DateTime.now().subtract(const Duration(days: 14));
  DateTime _end = DateTime.now();
  final _taxRate = TextEditingController(text: '0');
  bool _busy = false;

  @override
  void dispose() {
    _taxRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Run Payroll',
      busy: _busy,
      onSubmit: _run,
      submitLabel: 'Run',
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _start,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked == null) return;
                  setState(() => _start = picked);
                },
                child: Text('Start: ${_start.toIso8601String().split('T').first}'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _end,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked == null) return;
                  setState(() => _end = picked);
                },
                child: Text('End: ${_end.toIso8601String().split('T').first}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _taxRate,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Tax rate (0..1)'),
        ),
      ],
    );
  }

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      final tax = double.tryParse(_taxRate.text.trim()) ?? 0;
      final res = await ref.read(hrServiceProvider).runPayroll(
            farmId: widget.farmId,
            periodStart: _start,
            periodEnd: _end,
            taxRate: tax,
          );
      if (!mounted) return;
      Navigator.pop(context);
      final runId = res['run_id']?.toString() ?? '-';
      final net = res['totals']?['net_pay']?.toString() ?? '-';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payroll run $runId completed. Net pay: $net')),
      );
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

class _SaveCompensationSheet extends ConsumerStatefulWidget {
  const _SaveCompensationSheet({required this.farmId});
  final int farmId;

  @override
  ConsumerState<_SaveCompensationSheet> createState() =>
      _SaveCompensationSheetState();
}

class _SaveCompensationSheetState extends ConsumerState<_SaveCompensationSheet> {
  final _employeeId = TextEditingController();
  String _payType = 'hourly';
  final _hourly = TextEditingController(text: '0');
  final _salary = TextEditingController(text: '0');
  final _currency = TextEditingController(text: 'USD');
  bool _busy = false;

  @override
  void dispose() {
    _employeeId.dispose();
    _hourly.dispose();
    _salary.dispose();
    _currency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Set Compensation',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Save',
      children: [
        TextField(
          controller: _employeeId,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Employee ID'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _payType,
          items: const [
            DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
            DropdownMenuItem(value: 'salary', child: Text('Salary')),
          ],
          onChanged: (v) => setState(() => _payType = v ?? 'hourly'),
          decoration: const InputDecoration(labelText: 'Pay type'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _hourly,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Hourly rate'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _salary,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Salary amount'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _currency,
          decoration: const InputDecoration(labelText: 'Currency'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final employeeId = int.tryParse(_employeeId.text.trim()) ?? 0;
    if (employeeId <= 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).saveCompensation(
            farmId: widget.farmId,
            employeeId: employeeId,
            payType: _payType,
            hourlyRate: double.tryParse(_hourly.text.trim()) ?? 0,
            salaryAmount: double.tryParse(_salary.text.trim()) ?? 0,
            currency: _currency.text.trim().isEmpty ? 'USD' : _currency.text.trim(),
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

class _EnrollBenefitSheet extends ConsumerStatefulWidget {
  const _EnrollBenefitSheet({required this.farmId});
  final int farmId;

  @override
  ConsumerState<_EnrollBenefitSheet> createState() => _EnrollBenefitSheetState();
}

class _EnrollBenefitSheetState extends ConsumerState<_EnrollBenefitSheet> {
  final _benefitId = TextEditingController();
  final _employeeId = TextEditingController();
  final _employeeDeduction = TextEditingController(text: '0');
  final _employerContribution = TextEditingController(text: '0');
  bool _busy = false;

  @override
  void dispose() {
    _benefitId.dispose();
    _employeeId.dispose();
    _employeeDeduction.dispose();
    _employerContribution.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Enroll Benefit',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Enroll',
      children: [
        TextField(
          controller: _benefitId,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Benefit ID'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _employeeId,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Employee ID'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _employeeDeduction,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Employee deduction'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _employerContribution,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Employer contribution'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final benefitId = int.tryParse(_benefitId.text.trim()) ?? 0;
    final employeeId = int.tryParse(_employeeId.text.trim()) ?? 0;
    if (benefitId <= 0 || employeeId <= 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).enrollBenefit(
            farmId: widget.farmId,
            benefitId: benefitId,
            employeeId: employeeId,
            employeeDeduction: double.tryParse(_employeeDeduction.text.trim()) ?? 0,
            employerContribution:
                double.tryParse(_employerContribution.text.trim()) ?? 0,
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

class _AddTrainingCourseSheet extends ConsumerStatefulWidget {
  const _AddTrainingCourseSheet({required this.farmId});
  final int farmId;

  @override
  ConsumerState<_AddTrainingCourseSheet> createState() =>
      _AddTrainingCourseSheetState();
}

class _AddTrainingCourseSheetState extends ConsumerState<_AddTrainingCourseSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _competency = TextEditingController();
  final _recurrence = TextEditingController(text: '0');
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _competency.dispose();
    _recurrence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Add Training Course',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Save',
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _competency,
          decoration: const InputDecoration(labelText: 'Competency area'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _recurrence,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Recurrence days (0 = none)'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).createTrainingCourse(
            farmId: widget.farmId,
            title: _title.text.trim(),
            description: _description.text.trim(),
            competencyArea: _competency.text.trim(),
            recurrenceDays: int.tryParse(_recurrence.text.trim()) ?? 0,
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

class _AddTrainingRecordSheet extends ConsumerStatefulWidget {
  const _AddTrainingRecordSheet({required this.farmId});
  final int farmId;

  @override
  ConsumerState<_AddTrainingRecordSheet> createState() =>
      _AddTrainingRecordSheetState();
}

class _AddTrainingRecordSheetState extends ConsumerState<_AddTrainingRecordSheet> {
  final _courseId = TextEditingController();
  final _employeeId = TextEditingController();
  DateTime _completedOn = DateTime.now();
  DateTime? _expiry;
  final _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _courseId.dispose();
    _employeeId.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Add Training Record',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Save',
      children: [
        TextField(
          controller: _courseId,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Course ID'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _employeeId,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Employee ID'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _completedOn,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked == null) return;
            setState(() => _completedOn = picked);
          },
          child: Text('Completed: ${_completedOn.toIso8601String().split('T').first}'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _expiry ?? DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked == null) return;
            setState(() => _expiry = picked);
          },
          child: Text('Expiry: ${_expiry?.toIso8601String().split('T').first ?? '-'}'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Notes'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final courseId = int.tryParse(_courseId.text.trim()) ?? 0;
    final employeeId = int.tryParse(_employeeId.text.trim()) ?? 0;
    if (courseId <= 0 || employeeId <= 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).createTrainingRecord(
            farmId: widget.farmId,
            courseId: courseId,
            employeeId: employeeId,
            completedOn: _completedOn,
            expiryDate: _expiry,
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

class _AddContractorLogSheet extends ConsumerStatefulWidget {
  const _AddContractorLogSheet({required this.farmId});
  final int farmId;

  @override
  ConsumerState<_AddContractorLogSheet> createState() =>
      _AddContractorLogSheetState();
}

class _AddContractorLogSheetState extends ConsumerState<_AddContractorLogSheet> {
  final _contractorId = TextEditingController();
  DateTime _workDate = DateTime.now();
  final _hours = TextEditingController(text: '0');
  final _rate = TextEditingController(text: '0');
  final _desc = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _contractorId.dispose();
    _hours.dispose();
    _rate.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: 'Add Contractor Log',
      busy: _busy,
      onSubmit: _save,
      submitLabel: 'Save',
      children: [
        TextField(
          controller: _contractorId,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Contractor ID'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _workDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked == null) return;
            setState(() => _workDate = picked);
          },
          child: Text('Work date: ${_workDate.toIso8601String().split('T').first}'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _hours,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Hours'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _rate,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Hourly rate'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _desc,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final contractorId = int.tryParse(_contractorId.text.trim()) ?? 0;
    if (contractorId <= 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(hrServiceProvider).createContractorLog(
            farmId: widget.farmId,
            contractorId: contractorId,
            workDate: _workDate,
            hours: double.tryParse(_hours.text.trim()) ?? 0,
            hourlyRate: double.tryParse(_rate.text.trim()) ?? 0,
            description: _desc.text.trim(),
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
