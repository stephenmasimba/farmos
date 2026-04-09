import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/timesheet.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

final _timesheetsProvider = FutureProvider.autoDispose<List<Timesheet>>((ref) {
  return ref.read(timesheetsServiceProvider).list();
});

final _timesheetStatsProvider = FutureProvider.autoDispose<TimesheetStats>((ref) {
  return ref.read(timesheetsServiceProvider).stats();
});

class TimesheetsScreen extends ConsumerWidget {
  const TimesheetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final canRead = user?.hasPermission('tasks.read') ?? false;

    if (!canRead) {
      return const Scaffold(
        appBar: AppBar(title: Text('Timesheets')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Access denied',
          subtitle: 'Your account does not have permission to view timesheets.',
        ),
      );
    }

    final list = ref.watch(_timesheetsProvider);
    final stats = ref.watch(_timesheetStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Log hours',
            onPressed: () => _openLogHoursDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_timesheetsProvider);
          ref.invalidate(_timesheetStatsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            stats.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (s) => Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total Hours',
                      value: s.totalHours.toStringAsFixed(1),
                      icon: Icons.schedule_rounded,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Pending',
                      value: s.pendingApprovals.toString(),
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(_timesheetsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.timelapse_rounded,
                    title: 'No timesheets logged',
                  );
                }

                return Column(
                  children: items
                      .map(
                        (item) => _TimesheetCard(
                          item: item,
                          canUpdate: user?.hasPermission('tasks.update') ?? false,
                          onUpdateStatus: (status) => _updateStatus(
                            context,
                            ref,
                            item.id,
                            status,
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
    );
  }

  Future<void> _openLogHoursDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _LogHoursSheet(),
    );
    ref.invalidate(_timesheetsProvider);
    ref.invalidate(_timesheetStatsProvider);
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    int id,
    String status,
  ) async {
    try {
      await ref.read(timesheetsServiceProvider).updateStatus(
            timesheetId: id,
            status: status,
          );
      ref.invalidate(_timesheetsProvider);
      ref.invalidate(_timesheetStatsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }
}

class _TimesheetCard extends StatelessWidget {
  const _TimesheetCard({
    required this.item,
    required this.canUpdate,
    required this.onUpdateStatus,
  });

  final Timesheet item;
  final bool canUpdate;
  final ValueChanged<String> onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').format(item.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.assignment_turned_in_rounded),
        title: Text('${item.employeeName} · ${item.hoursWorked.toStringAsFixed(1)}h'),
        subtitle: Text('$date\n${item.taskDescription}'),
        isThreeLine: true,
        trailing: canUpdate && item.isPending
            ? PopupMenuButton<String>(
                onSelected: onUpdateStatus,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'approved', child: Text('Approve')),
                  PopupMenuItem(value: 'rejected', child: Text('Reject')),
                ],
                icon: const Icon(Icons.more_horiz_rounded),
              )
            : StatusBadge(status: item.status.toLowerCase()),
      ),
    );
  }
}

class _LogHoursSheet extends ConsumerStatefulWidget {
  const _LogHoursSheet();

  @override
  ConsumerState<_LogHoursSheet> createState() => _LogHoursSheetState();
}

class _LogHoursSheetState extends ConsumerState<_LogHoursSheet> {
  final _formKey = GlobalKey<FormState>();
  final _hoursCtrl = TextEditingController();
  final _taskCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _taskCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_rounded),
              title: const Text('Work Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
              onTap: _pickDate,
            ),
            TextFormField(
              controller: _hoursCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Hours worked'),
              validator: (v) {
                final value = double.tryParse((v ?? '').trim());
                if (value == null || value <= 0) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _taskCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Task description'),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Task description is required';
                return null;
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_busy ? 'Saving...' : 'Log Hours'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      await ref.read(timesheetsServiceProvider).logHours(
            date: _date,
            hoursWorked: double.parse(_hoursCtrl.text.trim()),
            taskDescription: _taskCtrl.text.trim(),
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
