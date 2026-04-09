import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/feed.dart';
import '../../../core/models/inventory.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final _ingredientsProvider = FutureProvider.autoDispose<List<FeedIngredient>>((ref) {
  return ref.read(feedServiceProvider).listIngredients();
});

final _millingProvider = FutureProvider.autoDispose<List<FeedMillingLog>>((ref) {
  return ref.read(feedServiceProvider).listMillingLogs();
});

final _inventoryItemsProvider =
    FutureProvider.autoDispose<List<InventoryItem>>((ref) {
  return ref.read(inventoryServiceProvider).getAll(
        perPage: 200,
        category: 'Feed',
      );
});

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
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
    final canRead = user?.hasPermission('inventory.read') ?? false;
    final canCreate = user?.hasPermission('inventory.create') ?? false;

    if (!canRead) {
      return const Scaffold(
        appBar: AppBar(title: Text('Feed')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Access denied',
          subtitle: 'Your account does not have permission to view feed data.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Operations'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Ingredients'),
            Tab(text: 'Milling'),
            Tab(text: 'Pearson'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _IngredientsTab(canCreate: canCreate),
          const _MillingTab(),
          const _PearsonTab(),
        ],
      ),
    );
  }
}

class _IngredientsTab extends ConsumerWidget {
  const _IngredientsTab({required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = ref.watch(_ingredientsProvider);
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
                    builder: (_) => const _AddIngredientSheet(),
                  );
                  ref.invalidate(_ingredientsProvider);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Ingredient'),
              ),
            ),
          ),
        Expanded(
          child: ingredients.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(_ingredientsProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.set_meal_rounded,
                  title: 'No feed ingredients',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(_ingredientsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = list[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.grain_rounded),
                        title: Text(item.name),
                        subtitle: Text(
                          'Protein: ${item.proteinContent.toStringAsFixed(1)}% · '
                          'Qty: ${item.quantityKg.toStringAsFixed(1)}kg',
                        ),
                        trailing: Text(Fmt.currency(item.costPerKg)),
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

class _MillingTab extends ConsumerWidget {
  const _MillingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(_millingProvider);
    return logs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_millingProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.factory_rounded,
            title: 'No milling logs',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_millingProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.precision_manufacturing_rounded),
                  title: Text(item.batchName),
                  subtitle: Text(
                    '${item.date?.toIso8601String().split('T').first ?? '-'}\n'
                    '${item.ingredients}',
                  ),
                  trailing: Text('${item.totalOutputKg.toStringAsFixed(1)}kg'),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PearsonTab extends ConsumerStatefulWidget {
  const _PearsonTab();

  @override
  ConsumerState<_PearsonTab> createState() => _PearsonTabState();
}

class _PearsonTabState extends ConsumerState<_PearsonTab> {
  final _target = TextEditingController();
  final _qty = TextEditingController(text: '100');
  int? _ingredient1;
  int? _ingredient2;
  PearsonResult? _result;
  bool _busy = false;

  @override
  void dispose() {
    _target.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(_ingredientsProvider);
    return ingredients.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_ingredientsProvider),
      ),
      data: (list) {
        if (list.length < 2) {
          return const EmptyState(
            icon: Icons.calculate_rounded,
            title: 'Need at least 2 ingredients',
            subtitle: 'Add more feed ingredients to run Pearson calculations.',
          );
        }

        _ingredient1 ??= list.first.id;
        _ingredient2 ??= list.length > 1 ? list[1].id : list.first.id;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _ingredient1,
              decoration: const InputDecoration(labelText: 'Ingredient 1'),
              items: list
                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                  .toList(),
              onChanged: (v) => setState(() => _ingredient1 = v),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _ingredient2,
              decoration: const InputDecoration(labelText: 'Ingredient 2'),
              items: list
                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                  .toList(),
              onChanged: (v) => setState(() => _ingredient2 = v),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Target Protein %'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _qty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Total Quantity (kg)'),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _busy ? null : _calculate,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calculate_rounded),
              label: Text(_busy ? 'Calculating...' : 'Calculate Pearson'),
            ),
            const SizedBox(height: 16),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Result', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('${_result!.ingredient1Name}: ${_result!.ingredient1Qty.toStringAsFixed(2)} kg'),
                      Text('${_result!.ingredient2Name}: ${_result!.ingredient2Qty.toStringAsFixed(2)} kg'),
                      Text('Total Cost: ${Fmt.currency(_result!.totalCost)}'),
                      if ((_result!.notes ?? '').isNotEmpty)
                        Text('Notes: ${_result!.notes!}'),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _calculate() async {
    final ing1 = _ingredient1;
    final ing2 = _ingredient2;
    final target = double.tryParse(_target.text.trim());
    final qty = double.tryParse(_qty.text.trim());

    if (ing1 == null || ing2 == null || target == null || qty == null) return;
    if (ing1 == ing2) return;

    setState(() => _busy = true);
    try {
      final ingredients = await ref.read(_ingredientsProvider.future);
      final inventory = await ref.read(_inventoryItemsProvider.future);

      final ing1Obj = ingredients.where((e) => e.id == ing1).first;
      final ing2Obj = ingredients.where((e) => e.id == ing2).first;

      final result = await ref.read(feedServiceProvider).calculatePearson(
            ingredient1Id: ing1,
            ingredient2Id: ing2,
            targetProtein: target,
            totalQuantityKg: qty,
          );

      final stock1 = _findStock(inventory, ing1Obj.name);
      final stock2 = _findStock(inventory, ing2Obj.name);

      if (stock1 != null && stock1.quantity < result.ingredient1Qty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient stock of ${ing1Obj.name}. '
              'Available: ${stock1.quantity.toStringAsFixed(1)} kg',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (stock2 != null && stock2.quantity < result.ingredient2Qty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient stock of ${ing2Obj.name}. '
              'Available: ${stock2.quantity.toStringAsFixed(1)} kg',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InventoryItem? _findStock(List<InventoryItem> list, String ingredientName) {
    final normalized = ingredientName.trim().toLowerCase();
    for (final item in list) {
      if (item.itemName.trim().toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

class _AddIngredientSheet extends ConsumerStatefulWidget {
  const _AddIngredientSheet();

  @override
  ConsumerState<_AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends ConsumerState<_AddIngredientSheet> {
  final _name = TextEditingController();
  final _protein = TextEditingController();
  final _qty = TextEditingController();
  final _cost = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _protein.dispose();
    _qty.dispose();
    _cost.dispose();
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
            const Text('Add Ingredient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(
              controller: _protein,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Protein Content %'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _qty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity (kg)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cost,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cost per kg'),
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
                label: Text(_busy ? 'Saving...' : 'Save Ingredient'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final protein = double.tryParse(_protein.text.trim());
    final qty = double.tryParse(_qty.text.trim());
    final cost = double.tryParse(_cost.text.trim());
    if (_name.text.trim().isEmpty || protein == null || qty == null || cost == null) {
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(feedServiceProvider).createIngredient(
            name: _name.text.trim(),
            proteinContent: protein,
            quantityKg: qty,
            costPerKg: cost,
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
