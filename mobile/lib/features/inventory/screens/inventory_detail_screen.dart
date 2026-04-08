import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/inventory.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final _itemDetailProvider =
    FutureProvider.autoDispose.family<InventoryItem, int>((ref, id) {
  return ref.read(inventoryServiceProvider).getById(id);
});

class InventoryDetailScreen extends ConsumerWidget {
  const InventoryDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(_itemDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: item.whenOrNull(data: (d) => Text(d.itemName)) ??
            const Text('Item Detail'),
      ),
      body: item.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
        data: (inv) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(inv.itemName,
                            style: Theme.of(context).textTheme.headlineMedium),
                        if (inv.isLowStock)
                          const Chip(
                            label: Text('LOW STOCK',
                                style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                            backgroundColor: Color(0xFFFFEBEE),
                          ),
                      ],
                    ),
                    Text(inv.category,
                        style: const TextStyle(
                            color: AppColors.onSurfaceVariant)),
                    const Divider(height: 24),
                    _Row('Quantity',
                        '${inv.quantity.toStringAsFixed(2)} ${inv.unit}'),
                    _Row('Reorder Level',
                        '${inv.reorderLevel.toStringAsFixed(2)} ${inv.unit}'),
                    _Row('Cost per Unit', Fmt.currency(inv.costPerUnit)),
                    _Row(
                        'Total Value',
                        Fmt.currency(inv.quantity * inv.costPerUnit)),
                    if (inv.supplierName != null)
                      _Row('Supplier', inv.supplierName!),
                  ],
                ),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 13)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
