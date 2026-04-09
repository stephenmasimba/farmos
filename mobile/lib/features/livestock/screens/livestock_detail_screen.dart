import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/livestock.dart';
import '../../../core/models/weight_record.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../widgets/weight_chart.dart';
import 'livestock_screen.dart';

final _detailProvider =
    FutureProvider.autoDispose.family<Livestock, int>((ref, id) {
  return ref.read(livestockServiceProvider).getById(id);
});

final _eventsProvider =
    FutureProvider.autoDispose.family<List<LivestockEvent>, int>((ref, id) {
  return ref.read(livestockServiceProvider).getEvents(id);
});

final _weightRecordsProvider =
    FutureProvider.autoDispose.family<List<WeightRecord>, int>((ref, id) {
  return ref.read(weightTrackingServiceProvider).getRecords(id);
});

class LivestockDetailScreen extends ConsumerWidget {
  const LivestockDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_detailProvider(id));
    final events = ref.watch(_eventsProvider(id));
    final weights = ref.watch(_weightRecordsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: detail.whenOrNull(data: (d) => Text(d.batchCode)) ??
            const Text('Livestock Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Event',
            onPressed: () => _addEvent(context, ref),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
        data: (livestock) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_detailProvider(id));
            ref.invalidate(_eventsProvider(id));
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _DetailCard(livestock: livestock),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Events',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      events.whenOrNull(
                              data: (e) => Text('${e.length} total',
                                  style: const TextStyle(
                                      color: AppColors.onSurfaceVariant))) ??
                          const SizedBox(),
                    ],
                  ),
                ),
              ),
              events.when(
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(
                    child: ErrorView(message: e.toString(), onRetry: null)),
                data: (list) {
                  if (list.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.event_note_rounded,
                        title: 'No events recorded',
                        subtitle: 'Tap + to add the first event',
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final e = list[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: _EventTile(event: e),
                        );
                      },
                      childCount: list.length,
                    ),
                  );
                },
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: weights.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Weight tracking error: $e'),
                    data: (records) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: WeightChart(records: records),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addWeight(context, ref),
        icon: const Icon(Icons.monitor_weight_rounded),
        label: const Text('Log Weight'),
      ),
    );
  }

  Future<void> _addEvent(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddEventSheet(batchId: id),
    );
    if (result == true) {
      ref.invalidate(_eventsProvider(id));
    }
  }

  Future<void> _addWeight(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final notesCtrl = TextEditingController();

    final weight = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(controller.text.trim());
              if (w != null) {
                Navigator.pop(context, w);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (weight != null) {
      await ref.read(weightTrackingServiceProvider).addRecord(
            id,
            weight,
            notes: notesCtrl.text,
          );
      ref.invalidate(_weightRecordsProvider(id));
    }
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.livestock});

  final Livestock livestock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(livestock.animalType,
                    style: Theme.of(context).textTheme.headlineMedium),
                StatusBadge(status: livestock.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(livestock.breed,
                style: const TextStyle(color: AppColors.onSurfaceVariant)),
            const Divider(height: 24),
            _Row('Batch Code', livestock.batchCode),
            _Row('Current Count', livestock.currentQuantity.toString()),
            _Row('Initial Count', livestock.initialQuantity.toString()),
            if (livestock.birthDate != null)
              _Row('Birth Date', Fmt.date(livestock.birthDate)),
            if (livestock.acquisitionDate != null)
              _Row('Acquired', Fmt.date(livestock.acquisitionDate)),
            if (livestock.expectedHarvestDate != null)
              _Row('Expected Harvest', Fmt.date(livestock.expectedHarvestDate)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final LivestockEvent event;

  static IconData _icon(String type) => switch (type.toLowerCase()) {
        'vaccination' => Icons.vaccines_rounded,
        'mortality' => Icons.warning_rounded,
        'feeding' => Icons.restaurant_rounded,
        'weighing' => Icons.monitor_weight_rounded,
        _ => Icons.event_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withAlpha(30),
          child: Icon(_icon(event.eventType),
              color: AppColors.primary, size: 20),
        ),
        title: Text(
          event.eventType[0].toUpperCase() + event.eventType.substring(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(event.description ?? '',
            maxLines: 2, style: const TextStyle(fontSize: 12)),
        trailing: Text(Fmt.date(event.eventDate),
            style: const TextStyle(
                fontSize: 11, color: AppColors.onSurfaceVariant)),
      ),
    );
  }
}

class _AddEventSheet extends ConsumerStatefulWidget {
  const _AddEventSheet({required this.batchId});

  final int batchId;

  @override
  ConsumerState<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<_AddEventSheet> {
  final _form = GlobalKey<FormState>();
  String _eventType = 'vaccination';
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(livestockServiceProvider).addEvent(widget.batchId, {
        'event_type': _eventType,
        'description': _descCtrl.text,
        'event_date': _date.toIso8601String(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Event',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _eventType,
              decoration: const InputDecoration(labelText: 'Event Type'),
              items: ['vaccination', 'mortality', 'feeding', 'weighing', 'other']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _eventType = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                  labelText: 'Description', hintText: 'Optional details'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text('Date: ${Fmt.date(_date)}'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
