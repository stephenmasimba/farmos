import '../api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_endpoints.dart';
import '../models/barcode_item.dart';
import 'sync_service.dart';
import 'cache_status_service.dart';

class BarcodeService {
  BarcodeService(this._client, this._sync, this._cache);

  final ApiClient _client;
  final SyncService _sync;
  final StateNotifierProvider<CacheStatusService, Map<String, CacheStatusRecord>> _cache;

  static const itemsKey = 'barcode_service_items';

  Future<BarcodeItem> lookupBarcode(String barcode) async {
    final result = await _client.get(
      ApiEndpoints.barcodeLookup,
      params: {'barcode': barcode},
    );
    return BarcodeItem.fromJson(result);
  }

  Future<List<BarcodeItem>> searchByBarcode(String query) async {
    final data = await _client.getList(
      ApiEndpoints.barcodeSearch,
      params: {'query': query, 'limit': 20},
    );
    return data.map((e) => BarcodeItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> recordInventoryAdjustment(
    ScannedInventoryAdjustment adjustment,
  ) {
    return _sync.enqueue(
      label: 'Record scanned inventory: ${adjustment.itemId}',
      operation: () => _client.post(
        ApiEndpoints.inventoryAdjust(adjustment.itemId),
        data: {
          'amount': adjustment.scannedQuantity,
          'reason': adjustment.reason,
          if (adjustment.notes != null) 'notes': adjustment.notes,
        },
      ),
    );
  }

  Future<void> recordBulkAdjustments(
    List<ScannedInventoryAdjustment> adjustments,
  ) {
    return _sync.enqueue(
      label: 'Bulk barcode scan: ${adjustments.length} items',
      operation: () => _client.post(
        ApiEndpoints.bulkAdjust,
        data: {
          'adjustments': adjustments.map((a) => a.toJson()).toList(),
        },
      ),
    );
  }
}

