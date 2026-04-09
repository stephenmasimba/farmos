import 'package:equatable/equatable.dart';

class BarcodeItem extends Equatable {
  const BarcodeItem({
    required this.barcode,
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.sku,
  });

  final String barcode;
  final int itemId;
  final String itemName;
  final String category;
  final double quantity;
  final String unit;
  final String? sku;

  factory BarcodeItem.fromJson(Map<String, dynamic> json) {
    return BarcodeItem(
      barcode: (json['barcode'] as String?) ?? '',
      itemId: int.tryParse((json['item_id'] ?? '0').toString()) ?? 0,
      itemName: (json['item_name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      quantity: double.tryParse((json['quantity'] ?? '0').toString()) ?? 0.0,
      unit: (json['unit'] as String?) ?? '',
      sku: json['sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'item_id': itemId,
        'item_name': itemName,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        if (sku != null) 'sku': sku,
      };

  @override
  List<Object?> get props => [barcode, itemId, itemName];
}

class ScannedInventoryAdjustment extends Equatable {
  const ScannedInventoryAdjustment({
    required this.itemId,
    required this.scannedQuantity,
    required this.reason,
    this.notes,
  });

  final int itemId;
  final double scannedQuantity;
  final String reason; // restock, count, damage, expired, found
  final String? notes;

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': scannedQuantity,
        'reason': reason,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [itemId, scannedQuantity, reason];
}
