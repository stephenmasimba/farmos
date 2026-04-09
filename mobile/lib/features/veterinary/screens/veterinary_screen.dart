import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/veterinary.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

final _logsProvider = FutureProvider.autoDispose<List<VeterinaryLog>>((ref) {
  return ref.read(veterinaryServiceProvider).listLogs();
});

final _vaccinationsProvider =
    FutureProvider.autoDispose<List<VeterinaryVaccination>>((ref) {
  return ref.read(veterinaryServiceProvider).listVaccinations();
});

final _withdrawalsProvider =
    FutureProvider.autoDispose<List<VeterinaryWithdrawal>>((ref) {
  return ref.read(veterinaryServiceProvider).listWithdrawals();
});

class VeterinaryScreen extends ConsumerStatefulWidget {
  const VeterinaryScreen({super.key});

  @override
  ConsumerState<VeterinaryScreen> createState() => _VeterinaryScreenState();
}

class _VeterinaryScreenState extends ConsumerState<VeterinaryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final canRead = user?.hasPermission('livestock.read') ?? false;
    final canWrite = user?.hasPermission('livestock.update') ?? false;

    if (!canRead) {
      return const Scaffold(
        appBar: AppBar(title: Text('Veterinary')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Access denied',
          subtitle: 'Your account does not have permission to view veterinary data.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinary'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Treatments'),
            Tab(text: 'Vaccinations'),
            Tab(text: 'Withdrawals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TreatmentsTab(canWrite: canWrite),
          _VaccinationsTab(canWrite: canWrite),
          const _WithdrawalsTab(),
        ],
      ),
    );
  }
}

class _TreatmentsTab extends ConsumerWidget {
  const _TreatmentsTab({required this.canWrite});

  final bool canWrite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(_logsProvider);
    return Column(
      children: [
        if (canWrite)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _AddTreatmentSheet(),
                  );
                  ref.invalidate(_logsProvider);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Treatment'),
              ),
            ),
          ),
        Expanded(
          child: logs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_logsProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.healing_rounded,
                  title: 'No treatment logs',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(_logsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TreatmentCard(
                    item: list[i],
                    canWrite: canWrite,
                    onStatus: (status) async {
                      await ref.read(veterinaryServiceProvider).updateLogStatus(
                            id: list[i].id,
                            status: status,
                          );
                      ref.invalidate(_logsProvider);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VaccinationsTab extends ConsumerWidget {
  const _VaccinationsTab({required this.canWrite});

  final bool canWrite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinations = ref.watch(_vaccinationsProvider);
    return Column(
      children: [
        if (canWrite)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _AddVaccinationSheet(),
                  );
                  ref.invalidate(_vaccinationsProvider);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Schedule Vaccination'),
              ),
            ),
          ),
        Expanded(
          child: vaccinations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_vaccinationsProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.vaccines_rounded,
                  title: 'No vaccinations scheduled',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(_vaccinationsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = list[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.vaccines_rounded),
                        title: Text(item.vaccineName),
                        subtitle: Text(
                          'Batch: ${item.batchId}\n'
                          'Target age: ${item.targetAgeDays} days',
                        ),
                        trailing: StatusBadge(status: item.status),
                        isThreeLine: true,
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

class _WithdrawalsTab extends ConsumerWidget {
  const _WithdrawalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawals = ref.watch(_withdrawalsProvider);
    return withdrawals.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_withdrawalsProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.event_available_rounded,
            title: 'No active withdrawal windows',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_withdrawalsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: Text('Animal: ${item.animalId}'),
                  subtitle: Text(
                    'End date: ${item.endDate?.toIso8601String().split('T').first ?? '-'}',
                  ),
                  trailing: Text(
                    '${item.daysRemaining}d',
                    style: TextStyle(
                      color: item.daysRemaining <= 2
                          ? AppColors.warning
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({
    required this.item,
    required this.canWrite,
    required this.onStatus,
  });

  final VeterinaryLog item;
  final bool canWrite;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.healing_rounded),
        title: Text('${item.animalId} · ${item.treatmentType}'),
        subtitle: Text(
          '${item.medication.isEmpty ? 'Medication n/a' : item.medication} '
          '${item.dosage.isEmpty ? '' : '(${item.dosage})'}\n'
          'Withdrawal: ${item.withdrawalPeriodDays} days',
        ),
        trailing: canWrite
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: onStatus,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'ACTIVE', child: Text('Set Active')),
                  PopupMenuItem(value: 'CLEARED', child: Text('Set Cleared')),
                  PopupMenuItem(value: 'CANCELLED', child: Text('Set Cancelled')),
                ],
              )
            : StatusBadge(status: item.status.toLowerCase()),
        isThreeLine: true,
      ),
    );
  }
}

class _AddTreatmentSheet extends ConsumerStatefulWidget {
  const _AddTreatmentSheet();

  @override
  ConsumerState<_AddTreatmentSheet> createState() => _AddTreatmentSheetState();
}

class _AddTreatmentSheetState extends ConsumerState<_AddTreatmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _animalIdCtrl = TextEditingController();
  final _animalTypeCtrl = TextEditingController();
  final _treatmentTypeCtrl = TextEditingController();
  final _medicationCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _withdrawalCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  DateTime _treatmentDate = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _animalIdCtrl.dispose();
    _animalTypeCtrl.dispose();
    _treatmentTypeCtrl.dispose();
    _medicationCtrl.dispose();
    _dosageCtrl.dispose();
    _withdrawalCtrl.dispose();
    _notesCtrl.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Treatment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _animalIdCtrl,
                decoration: const InputDecoration(labelText: 'Animal ID'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Animal ID required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _animalTypeCtrl,
                decoration: const InputDecoration(labelText: 'Animal Type (optional)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _treatmentTypeCtrl,
                decoration: const InputDecoration(labelText: 'Treatment Type'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Treatment type required'
                    : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_rounded),
                title: const Text('Treatment Date'),
                subtitle: Text(_treatmentDate.toIso8601String().split('T').first),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicationCtrl,
                decoration: const InputDecoration(labelText: 'Medication (optional)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(labelText: 'Dosage (optional)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _withdrawalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Withdrawal Period Days'),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n < 0) return 'Must be 0 or greater';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
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
                  label: Text(_busy ? 'Saving...' : 'Save Treatment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _treatmentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _treatmentDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(veterinaryServiceProvider).createLog(
            animalId: _animalIdCtrl.text.trim(),
            animalType: _animalTypeCtrl.text.trim(),
            treatmentType: _treatmentTypeCtrl.text.trim(),
            treatmentDate: _treatmentDate,
            medication: _medicationCtrl.text.trim(),
            dosage: _dosageCtrl.text.trim(),
            withdrawalPeriodDays: int.parse(_withdrawalCtrl.text.trim()),
            notes: _notesCtrl.text.trim(),
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

class _AddVaccinationSheet extends ConsumerStatefulWidget {
  const _AddVaccinationSheet();

  @override
  ConsumerState<_AddVaccinationSheet> createState() => _AddVaccinationSheetState();
}

class _AddVaccinationSheetState extends ConsumerState<_AddVaccinationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '0');
  DateTime _scheduledDate = DateTime.now();
  String _status = 'scheduled';
  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _batchCtrl.dispose();
    _ageCtrl.dispose();
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
            const Text('Schedule Vaccination',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Vaccine Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vaccine name required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _batchCtrl,
              decoration: const InputDecoration(labelText: 'Batch ID'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Batch ID required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Age Days'),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 0) return 'Must be 0 or greater';
                return null;
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_rounded),
              title: const Text('Scheduled Date'),
              subtitle: Text(_scheduledDate.toIso8601String().split('T').first),
              onTap: _pickDate,
            ),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'missed', child: Text('Missed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'scheduled'),
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
                label: Text(_busy ? 'Saving...' : 'Save Vaccination'),
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
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(veterinaryServiceProvider).createVaccination(
            vaccineName: _nameCtrl.text.trim(),
            batchId: _batchCtrl.text.trim(),
            targetAgeDays: int.parse(_ageCtrl.text.trim()),
            scheduledDate: _scheduledDate,
            status: _status,
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
