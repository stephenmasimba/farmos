import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  const InventoryItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    required this.costPerUnit,
    this.supplierId,
    this.supplierName,
  });

  final int id;
  final String itemName;
  final String category;
  final double quantity;
  final String unit;
  final double reorderLevel;
  final double costPerUnit;
  final int? supplierId;
  final String? supplierName;

  bool get isLowStock => quantity <= reorderLevel;

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
        id: j['id'] as int,
        itemName: j['item_name'] as String? ?? '',
        category: j['category'] as String? ?? '',
        quantity: _parseDouble(j['quantity']),
        unit: j['unit'] as String? ?? '',
        reorderLevel: _parseDouble(j['reorder_level']),
        costPerUnit: _parseDouble(j['cost_per_unit']),
        supplierId: j['supplier_id'] as int?,
        supplierName: j['supplier_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'item_name': itemName,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'reorder_level': reorderLevel,
        'cost_per_unit': costPerUnit,
        if (supplierId != null) 'supplier_id': supplierId,
      };

  @override
  List<Object?> get props => [id, itemName, quantity];
}

class InventoryStats extends Equatable {
  const InventoryStats({
    required this.totalItems,
    required this.totalValue,
    required this.lowStockCount,
  });

  final int totalItems;
  final double totalValue;
  final int lowStockCount;

  factory InventoryStats.fromJson(Map<String, dynamic> j) => InventoryStats(
        totalItems: _parseInt(j['total_items']),
        totalValue: _parseDouble(j['total_value']),
        lowStockCount: _parseInt(j['low_stock_count']),
      );

  @override
  List<Object?> get props => [totalItems, totalValue, lowStockCount];
}

class StockAdjustment {
  const StockAdjustment({
    required this.quantity,
    required this.reason,
    required this.type,
  });

  final double quantity;
  final String reason;
  final String type; // in | out | adjustment

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'reason': reason,
        'type': type,
      };
}

double _parseDouble(dynamic v) =>
    v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

int _parseInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
