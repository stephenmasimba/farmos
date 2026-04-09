import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/field.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

final _fieldsProvider = FutureProvider.autoDispose<List<Field>>((ref) {
  return ref.read(fieldsServiceProvider).list();
});

class FieldsScreen extends ConsumerWidget {
  const FieldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final canCreate = user?.hasAnyPermission(const [
          'inventory.create',
          'tasks.create',
        ]) ??
        false;

    final fields = ref.watch(_fieldsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fields & Crops'),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add field',
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const _AddFieldSheet(),
                );
                ref.invalidate(_fieldsProvider);
              },
            ),
        ],
      ),
      body: fields.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_fieldsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.grass_rounded,
              title: 'No fields available',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_fieldsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final field = list[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.agriculture_rounded),
                    title: Text(field.name),
                    subtitle: Text(
                      'Area: ${(field.areaSizeHa ?? 0).toStringAsFixed(2)} ha\n'
                      'Crop: ${field.currentCrop?.isNotEmpty == true ? field.currentCrop : '-'}',
                    ),
                    trailing: StatusBadge(status: field.status.toLowerCase()),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AddFieldSheet extends ConsumerStatefulWidget {
  const _AddFieldSheet();

  @override
  ConsumerState<_AddFieldSheet> createState() => _AddFieldSheetState();
}

class _AddFieldSheetState extends ConsumerState<_AddFieldSheet> {
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _crop = TextEditingController();
  final _notes = TextEditingController();
  String _status = 'Active';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    _crop.dispose();
    _notes.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Field', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Field name')),
            const SizedBox(height: 8),
            TextField(
              controller: _area,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Area (ha)'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _crop, decoration: const InputDecoration(labelText: 'Current crop (optional)')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Fallow', child: Text('Fallow')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'Active'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_busy ? 'Saving...' : 'Save Field'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final area = double.tryParse(_area.text.trim());
    if (_name.text.trim().isEmpty || area == null) return;

    setState(() => _busy = true);
    try {
      await ref.read(fieldsServiceProvider).create(
            name: _name.text.trim(),
            area: area,
            crop: _crop.text.trim(),
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
