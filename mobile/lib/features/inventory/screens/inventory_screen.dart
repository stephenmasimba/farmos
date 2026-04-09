import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/inventory.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/services/cache_status_service.dart';
import '../../../core/services/inventory_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final _inventoryProvider =
    FutureProvider.autoDispose<List<InventoryItem>>((ref) {
  return ref.read(inventoryServiceProvider).getAll(perPage: 50);
});

final _inventoryStatsProvider =
    FutureProvider.autoDispose<InventoryStats>((ref) {
  return ref.read(inventoryServiceProvider).getStats();
});

final _lowStockProvider =
    FutureProvider.autoDispose<List<InventoryItem>>((ref) {
  return ref.read(inventoryServiceProvider).getLowStockAlerts();
});

final _inventoryPlatformProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.read(inventoryServiceProvider).getPlatformSnapshot();
});

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
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
        title: const Text('Delete items?'),
        content: Text('Delete ${_selectedIds.length} item(s)? This cannot be undone.'),
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

    final service = ref.read(inventoryServiceProvider);
    for (final id in _selectedIds) {
      await service.delete(id);
    }
    _exitSelectionMode();
    ref.invalidate(_inventoryProvider);
    ref.invalidate(_inventoryStatsProvider);
    ref.invalidate(_lowStockProvider);
  }

  Future<void> _batchAdjustStock({required double delta}) async {
    if (_selectedIds.isEmpty) return;
    final service = ref.read(inventoryServiceProvider);
    for (final id in _selectedIds) {
      final item = await service.getById(id);
      final newQty = item.quantity + delta;
      if (newQty < 0) continue;
      await service.update(id, {'quantity': newQty});
    }
    _exitSelectionMode();
    ref.invalidate(_inventoryProvider);
    ref.invalidate(_inventoryStatsProvider);
    ref.invalidate(_lowStockProvider);
  }

  Future<void> _batchSetReorderLevel(double level) async {
    if (_selectedIds.isEmpty) return;
    final service = ref.read(inventoryServiceProvider);
    for (final id in _selectedIds) {
      await service.update(id, {'reorder_level': level});
    }
    _exitSelectionMode();
    ref.invalidate(_inventoryProvider);
    ref.invalidate(_inventoryStatsProvider);
    ref.invalidate(_lowStockProvider);
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(_inventoryStatsProvider);
    final platform = ref.watch(_inventoryPlatformProvider);
    final pendingChanges =
        ref.watch(pendingModuleChangesProvider(ApiEndpoints.inventory));
    final cacheStatus = latestOfflineStatus(
      ref.watch(cacheStatusServiceProvider),
      const [
        InventoryService.listStatusKey,
        InventoryService.statsStatusKey,
        InventoryService.alertsStatusKey,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(text: 'All Items'),
            Tab(
              child: stats.whenOrNull(
                    data: (s) => s.lowStockCount > 0
                        ? Badge(
                            label: Text('${s.lowStockCount}'),
                            child: const Text('Low Stock'),
                          )
                        : const Text('Low Stock'),
                  ) ??
                  const Text('Low Stock'),
            ),
          ],
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
                      onTap: () => context.push('/sync?module=inventory'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          platform.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (snapshot) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.warehouse_rounded),
                  title: const Text('Inventory Platform'),
                  subtitle: Text(
                    'Warehouses: ${snapshot['warehouse_count']} · '
                    'Reorder: ${snapshot['reorder_count']} · '
                    'Value: ${Fmt.currency((snapshot['total_inventory_value'] as num?)?.toDouble() ?? 0)}',
                  ),
                ),
              ),
            ),
          ),
          if (_selectionMode && _selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _batchAdjustStock(delta: 10),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('+10 Qty'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _batchAdjustStock(delta: -10),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('-10 Qty'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final level = await _showReorderLevelDialog();
                      if (level != null) {
                        await _batchSetReorderLevel(level);
                      }
                    },
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Set Reorder Level'),
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
              children: [
                _AllInventory(
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
                ),
                _LowStockList(selectionMode: _selectionMode),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await _showAddDialog(context, ref);
                ref.invalidate(_inventoryProvider);
                ref.invalidate(_inventoryStatsProvider);
                ref.invalidate(_lowStockProvider);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddInventorySheet(),
    );
  }

  Future<double?> _showReorderLevelDialog() async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set reorder level'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Reorder level',
            hintText: 'e.g., 10',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null) Navigator.pop(context, value);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _AllInventory extends ConsumerWidget {
  const _AllInventory({
    required this.selectionMode,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final bool selectionMode;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_inventoryProvider);

    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_inventoryProvider)),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.inventory_2_rounded,
            title: 'No inventory items',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_inventoryProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _InventoryCard(
              item: list[i],
              selectionMode: selectionMode,
              isSelected: selectedIds.contains(list[i].id),
              onToggle: (selected) => onSelectionChanged(list[i].id, selected),
              onAdjust: () => _adjustStock(context, ref, list[i]),
            ),
          ),
        );
      },
    );
  }

  Future<void> _adjustStock(
      BuildContext context, WidgetRef ref, InventoryItem item) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AdjustStockSheet(item: item),
    );
    ref.invalidate(_inventoryProvider);
    ref.invalidate(_inventoryStatsProvider);
    ref.invalidate(_lowStockProvider);
  }
}

class _LowStockList extends ConsumerWidget {
  const _LowStockList({required this.selectionMode});

  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_lowStockProvider);

    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.check_circle_rounded,
            title: 'All stock levels OK',
            subtitle: 'No items below reorder level',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _InventoryCard(
            item: list[i],
            selectionMode: false,
            isSelected: false,
            onToggle: (_) {},
            onAdjust: () {},
            highlight: true,
          ),
        );
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggle,
    required this.onAdjust,
    this.highlight = false,
  });

  final InventoryItem item;
  final bool selectionMode;
  final bool isSelected;
  final void Function(bool) onToggle;
  final VoidCallback onAdjust;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: highlight
            ? const BorderSide(color: AppColors.error, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: selectionMode
            ? () => onToggle(!isSelected)
            : () => context.push('/inventory/${item.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => onToggle(v ?? false),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(item.category,
                        style: const TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Pill(
                          label:
                              '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                          color: item.isLowStock
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reorder: ${item.reorderLevel} ${item.unit}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(Fmt.currency(item.costPerUnit),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const Text('per unit',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 10)),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: onAdjust,
                    tooltip: 'Adjust Stock',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _AdjustStockSheet extends ConsumerStatefulWidget {
  const _AdjustStockSheet({required this.item});

  final InventoryItem item;

  @override
  ConsumerState<_AdjustStockSheet> createState() => _AdjustStockSheetState();
}

class _AdjustStockSheetState extends ConsumerState<_AdjustStockSheet> {
  final _form = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String _type = 'in';
  bool _loading = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(inventoryServiceProvider).adjustStock(
            widget.item.id,
            StockAdjustment(
              quantity: double.parse(_qtyCtrl.text.trim()),
              reason: _reasonCtrl.text.trim(),
              type: _type,
            ),
          );
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
            Text('Adjust: ${widget.item.itemName}',
                style: Theme.of(context).textTheme.titleMedium),
            Text(
              'Current: ${widget.item.quantity} ${widget.item.unit}',
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                DropdownMenuItem(value: 'in', child: const Text('Stock In')),
                DropdownMenuItem(value: 'out', child: const Text('Stock Out')),
                DropdownMenuItem(
                    value: 'adjustment', child: const Text('Adjustment')),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qtyCtrl,
              decoration: InputDecoration(
                  labelText: 'Quantity (${widget.item.unit})'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Apply Adjustment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddInventorySheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddInventorySheet> createState() => _AddInventorySheetState();
}

class _AddInventorySheetState extends ConsumerState<_AddInventorySheet> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _reorderCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String _category = 'Feed';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    _reorderCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(inventoryServiceProvider).create({
        'item_name': _nameCtrl.text.trim(),
        'category': _category,
        'quantity': double.parse(_qtyCtrl.text.trim()),
        'unit': _unitCtrl.text.trim(),
        'reorder_level': double.parse(_reorderCtrl.text.trim()),
        'cost_per_unit': double.parse(_costCtrl.text.trim()),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Item', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Item name *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Feed', 'Medicine', 'Seeds', 'Fertilizer', 'Tools',
                    'Fuel', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Quantity *'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: 'Unit *'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _reorderCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Reorder Level *'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Cost/unit *'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
