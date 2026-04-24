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
          IconButton(
            icon: const Icon(Icons.auto_graph_rounded),
            tooltip: 'Advanced',
            onPressed: () => _openAdvanced(context, ref),
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

  Future<void> _openAdvanced(BuildContext context, WidgetRef ref) async {
    final farmId = ref.read(authProvider).user?.farmId;
    if (farmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No farm_id on this user session')),
      );
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const _AdvancedActionsSheet(),
    );
    if (action == null) return;

    switch (action) {
      case 'analytics':
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Lifecycle analytics'),
            content: FutureBuilder(
              future: ref
                  .read(livestockServiceProvider)
                  .getLifecycleAnalytics(farmId: farmId, livestockId: id),
              builder: (_, snap) {
                if (!snap.hasData) {
                  if (snap.hasError) return Text(snap.error.toString());
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final a = snap.data!;
                return SingleChildScrollView(
                  child: Text(
                    'Feed: ${a.feedCount} logs · ${a.feedCostTotal.toStringAsFixed(2)}\n'
                    'Health: ${a.healthCount} records · ${a.healthCostTotal.toStringAsFixed(2)}\n'
                    'Vaccinations: ${a.vaccinationCount} · ${a.vaccinationCostTotal.toStringAsFixed(2)}\n'
                    'Production metrics: ${a.production.length}\n'
                    'Trace events: ${a.traceability.length}',
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        break;
      case 'breeding_plan':
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _AddBreedingPlanSheet(farmId: farmId, damId: id),
        );
        break;
      case 'pedigree':
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _SavePedigreeSheet(farmId: farmId, livestockId: id),
        );
        break;
      case 'genetics':
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _AddGeneticTraitSheet(farmId: farmId, livestockId: id),
        );
        break;
      case 'feed_log':
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _AddFeedLogSheet(farmId: farmId, livestockId: id),
        );
        break;
      case 'trace':
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _AddTraceEventSheet(farmId: farmId, livestockId: id),
        );
        break;
    }
  }
}

class _AdvancedActionsSheet extends StatelessWidget {
  const _AdvancedActionsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const ListTile(
            title: Text('Advanced livestock'),
            subtitle: Text('Breeding, genetics, traceability, analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph_rounded),
            title: const Text('Lifecycle analytics'),
            onTap: () => Navigator.pop(context, 'analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_rounded),
            title: const Text('Breeding plan'),
            onTap: () => Navigator.pop(context, 'breeding_plan'),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_rounded),
            title: const Text('Pedigree'),
            onTap: () => Navigator.pop(context, 'pedigree'),
          ),
          ListTile(
            leading: const Icon(Icons.science_rounded),
            title: const Text('Genetic trait'),
            onTap: () => Navigator.pop(context, 'genetics'),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_rounded),
            title: const Text('Feed log'),
            onTap: () => Navigator.pop(context, 'feed_log'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_rounded),
            title: const Text('Trace event'),
            onTap: () => Navigator.pop(context, 'trace'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AddBreedingPlanSheet extends ConsumerStatefulWidget {
  const _AddBreedingPlanSheet({required this.farmId, required this.damId});
  final int farmId;
  final int damId;

  @override
  ConsumerState<_AddBreedingPlanSheet> createState() => _AddBreedingPlanSheetState();
}

class _AddBreedingPlanSheetState extends ConsumerState<_AddBreedingPlanSheet> {
  final _sireId = TextEditingController();
  DateTime _planned = DateTime.now();
  DateTime? _expectedBirth;
  String _method = 'natural';
  bool _busy = false;

  @override
  void dispose() {
    _sireId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Breeding plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _sireId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sire ID (optional)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _method,
            items: const [
              DropdownMenuItem(value: 'natural', child: Text('Natural')),
              DropdownMenuItem(value: 'ai', child: Text('AI')),
              DropdownMenuItem(value: 'embryo_transfer', child: Text('Embryo transfer')),
            ],
            onChanged: (v) => setState(() => _method = v ?? 'natural'),
            decoration: const InputDecoration(labelText: 'Method'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _planned,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setState(() => _planned = picked);
            },
            child: Text('Planned: ${_planned.toIso8601String().split('T').first}'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _expectedBirth ?? DateTime.now().add(const Duration(days: 280)),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setState(() => _expectedBirth = picked);
            },
            child: Text('Expected birth: ${_expectedBirth?.toIso8601String().split('T').first ?? '-'}'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final sireId = int.tryParse(_sireId.text.trim());
      await ref.read(livestockServiceProvider).createBreedingPlan(
            farmId: widget.farmId,
            damId: widget.damId,
            sireId: sireId != null && sireId > 0 ? sireId : null,
            plannedBreedingDate: _planned,
            method: _method,
            expectedBirthDate: _expectedBirth,
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

class _SavePedigreeSheet extends ConsumerStatefulWidget {
  const _SavePedigreeSheet({required this.farmId, required this.livestockId});
  final int farmId;
  final int livestockId;

  @override
  ConsumerState<_SavePedigreeSheet> createState() => _SavePedigreeSheetState();
}

class _SavePedigreeSheetState extends ConsumerState<_SavePedigreeSheet> {
  final _sireId = TextEditingController();
  final _damId = TextEditingController();
  final _herdbook = TextEditingController();
  final _line = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _sireId.dispose();
    _damId.dispose();
    _herdbook.dispose();
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Save pedigree', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _sireId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sire ID (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _damId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Dam ID (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _herdbook,
            decoration: const InputDecoration(labelText: 'Herdbook ID (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _line,
            decoration: const InputDecoration(labelText: 'Genetic line (optional)'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final sireId = int.tryParse(_sireId.text.trim());
      final damId = int.tryParse(_damId.text.trim());
      await ref.read(livestockServiceProvider).savePedigree(
            farmId: widget.farmId,
            livestockId: widget.livestockId,
            sireId: sireId != null && sireId > 0 ? sireId : null,
            damId: damId != null && damId > 0 ? damId : null,
            herdbookId: _herdbook.text.trim(),
            geneticLine: _line.text.trim(),
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

class _AddGeneticTraitSheet extends ConsumerStatefulWidget {
  const _AddGeneticTraitSheet({required this.farmId, required this.livestockId});
  final int farmId;
  final int livestockId;

  @override
  ConsumerState<_AddGeneticTraitSheet> createState() => _AddGeneticTraitSheetState();
}

class _AddGeneticTraitSheetState extends ConsumerState<_AddGeneticTraitSheet> {
  final _name = TextEditingController();
  final _value = TextEditingController();
  DateTime? _measuredOn;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add genetic trait', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Trait name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _value,
            decoration: const InputDecoration(labelText: 'Trait value'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _measuredOn ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setState(() => _measuredOn = picked);
            },
            child: Text('Measured: ${_measuredOn?.toIso8601String().split('T').first ?? '-'}'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _value.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(livestockServiceProvider).addGeneticTrait(
            farmId: widget.farmId,
            livestockId: widget.livestockId,
            traitName: _name.text.trim(),
            traitValue: _value.text.trim(),
            measuredOn: _measuredOn,
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

class _AddFeedLogSheet extends ConsumerStatefulWidget {
  const _AddFeedLogSheet({required this.farmId, required this.livestockId});
  final int farmId;
  final int livestockId;

  @override
  ConsumerState<_AddFeedLogSheet> createState() => _AddFeedLogSheetState();
}

class _AddFeedLogSheetState extends ConsumerState<_AddFeedLogSheet> {
  final _item = TextEditingController();
  final _qty = TextEditingController(text: '0');
  final _unit = TextEditingController(text: 'kg');
  final _cost = TextEditingController(text: '0');
  bool _postToFinance = false;
  bool _busy = false;

  @override
  void dispose() {
    _item.dispose();
    _qty.dispose();
    _unit.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Feed log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _item,
            decoration: const InputDecoration(labelText: 'Feed item'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _qty,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _unit,
            decoration: const InputDecoration(labelText: 'Unit'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cost,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Cost total'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _postToFinance,
            title: const Text('Post expense to finance'),
            onChanged: (v) => setState(() => _postToFinance = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_item.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(livestockServiceProvider).createFeedLog(
            farmId: widget.farmId,
            livestockId: widget.livestockId,
            feedItem: _item.text.trim(),
            feedQty: double.tryParse(_qty.text.trim()) ?? 0,
            unit: _unit.text.trim().isEmpty ? 'kg' : _unit.text.trim(),
            costTotal: double.tryParse(_cost.text.trim()) ?? 0,
            postToFinance: _postToFinance,
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

class _AddTraceEventSheet extends ConsumerStatefulWidget {
  const _AddTraceEventSheet({required this.farmId, required this.livestockId});
  final int farmId;
  final int livestockId;

  @override
  ConsumerState<_AddTraceEventSheet> createState() => _AddTraceEventSheetState();
}

class _AddTraceEventSheetState extends ConsumerState<_AddTraceEventSheet> {
  final _type = TextEditingController(text: 'move');
  final _location = TextEditingController();
  final _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _type.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trace event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _type,
            decoration: const InputDecoration(labelText: 'Event type'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _location,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_type.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(livestockServiceProvider).createTraceEvent(
            farmId: widget.farmId,
            livestockId: widget.livestockId,
            eventType: _type.text.trim(),
            location: _location.text.trim(),
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
