import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/inventory.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class InventoryService {
  const InventoryService(this._api, this._sync, this._cacheStatus);
  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const listStatusKey = 'inventory:list';
  static const statsStatusKey = 'inventory:stats';
  static const alertsStatusKey = 'inventory:alerts';

  String _listCacheKey(String? category) => 'inventory_list_${category ?? 'all'}';
  String _detailCacheKey(int id) => 'inventory_detail_$id';
  String _statsCacheKey() => 'inventory_stats';
  String _alertsCacheKey() => 'inventory_alerts';

  Future<List<InventoryItem>> getAll({
    int page = 1,
    int perPage = 20,
    String? category,
  }) async {
    final path = category != null
        ? ApiEndpoints.inventoryByCategory(category)
        : ApiEndpoints.inventory;
    try {
      final list = await _api.getList(path,
          params: {'page': page, 'per_page': perPage});
      await _sync.cache(_listCacheKey(category), {'items': list});
      _cacheStatus.markFresh(listStatusKey);
        final base = list
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
        return _applyQueuedChanges(base, category: category);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_listCacheKey(category));
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          listStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        final base = items
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return _applyQueuedChanges(base, category: category);
      }
      rethrow;
    }
  }

  Future<InventoryItem> getById(int id) async {
    try {
      final data = await _api.get(ApiEndpoints.inventoryById(id));
      final payload = data['item'] as Map<String, dynamic>? ?? data;
      await _sync.cache(_detailCacheKey(id), payload);
      return InventoryItem.fromJson(payload);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCache(_detailCacheKey(id));
      if (cached != null) return InventoryItem.fromJson(cached);
      rethrow;
    }
  }

  Future<InventoryItem> create(Map<String, dynamic> body) async {
    try {
      final data = await _api.post(ApiEndpoints.inventory, data: body);
      return InventoryItem.fromJson(
          data['item'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.inventory,
        body: body,
      );
      return _optimisticItem(body);
    }
  }

  Future<InventoryItem> update(int id, Map<String, dynamic> body) async {
    try {
      final data = await _api.put(ApiEndpoints.inventoryById(id), data: body);
      return InventoryItem.fromJson(
          data['item'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'PUT',
        path: ApiEndpoints.inventoryById(id),
        body: body,
      );
      return _optimisticItem(body, fallbackId: id);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.delete(ApiEndpoints.inventoryById(id));
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'DELETE',
        path: ApiEndpoints.inventoryById(id),
      );
    }
  }

  Future<InventoryStats> getStats() async {
    try {
      final data = await _api.get(ApiEndpoints.inventoryStats);
      await _sync.cache(_statsCacheKey(), data);
      _cacheStatus.markFresh(statsStatusKey);
      return InventoryStats.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_statsCacheKey());
      if (cached != null) {
        _cacheStatus.markOffline(
          statsStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return InventoryStats.fromJson(cached.payload);
      }
      rethrow;
    }
  }

  Future<List<InventoryItem>> getLowStockAlerts() async {
    try {
      final list = await _api.getList(ApiEndpoints.inventoryAlerts);
      await _sync.cache(_alertsCacheKey(), {'items': list});
      _cacheStatus.markFresh(alertsStatusKey);
      return list
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_alertsCacheKey());
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          alertsStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlatformSnapshot() async {
    final warehouses = await _api.getList(ApiEndpoints.inventoryPlatformWarehouses);
    final valuation = await _api.get(ApiEndpoints.inventoryPlatformValuation);
    final reorder = await _api.get(ApiEndpoints.inventoryPlatformReorder);

    final recommendations =
        (reorder['reorder_recommendations'] as List<dynamic>?) ??
            const <dynamic>[];

    return {
      'warehouse_count': warehouses.length,
      'total_inventory_value':
          double.tryParse((valuation['total_inventory_value'] ?? '0').toString()) ??
              0.0,
      'reorder_count': recommendations.length,
    };
  }

  Future<InventoryItem> adjustStock(int id, StockAdjustment adj) async {
    try {
      final data = await _api.post(ApiEndpoints.inventoryAdjust(id),
          data: adj.toJson());
      return InventoryItem.fromJson(
          data['item'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.inventoryAdjust(id),
        body: adj.toJson(),
      );
      return InventoryItem(
        id: id,
        itemName: 'Pending Sync',
        category: 'Adjustment',
        quantity: 0,
        unit: '',
        reorderLevel: 0,
        costPerUnit: 0,
      );
    }
  }

  bool _shouldQueue(ApiException e) => e.statusCode == null;

  Future<List<InventoryItem>> _applyQueuedChanges(
    List<InventoryItem> base, {
    String? category,
  }) async {
    final queue = await _sync.getPendingItemsByPathPrefix(ApiEndpoints.inventory);
    var list = List<InventoryItem>.from(base);

    for (final item in queue) {
      final body = item.body;
      final id = _extractId(item.path);

      if (item.method == 'POST' && item.path == ApiEndpoints.inventory && body != null) {
        list.insert(0, _optimisticItem(body, localId: -item.id));
        continue;
      }

      if (item.method == 'PUT' && id != null && body != null) {
        final index = list.indexWhere((entry) => entry.id == id);
        final optimistic = _optimisticItem(body, fallbackId: id);
        if (index >= 0) {
          list[index] = optimistic;
        } else {
          list.insert(0, optimistic);
        }
        continue;
      }

      if (item.method == 'POST' && item.path.endsWith('/adjust') && id != null && body != null) {
        final index = list.indexWhere((entry) => entry.id == id);
        if (index >= 0) {
          final current = list[index];
          final qty = double.tryParse((body['quantity'] ?? '').toString()) ?? 0;
          final type = (body['type'] as String?) ?? 'adjustment';
          final nextQty = switch (type) {
            'in' => current.quantity + qty,
            'out' => current.quantity - qty,
            _ => qty,
          };
          list[index] = InventoryItem(
            id: current.id,
            itemName: current.itemName,
            category: current.category,
            quantity: nextQty,
            unit: current.unit,
            reorderLevel: current.reorderLevel,
            costPerUnit: current.costPerUnit,
            supplierId: current.supplierId,
            supplierName: current.supplierName,
          );
        }
        continue;
      }

      if (item.method == 'DELETE' && id != null) {
        list.removeWhere((entry) => entry.id == id);
      }
    }

    return list.where((entry) {
      if (category != null && entry.category != category) return false;
      return true;
    }).toList();
  }

  int? _extractId(String path) {
    final match = RegExp(r'^/api/inventory/(\d+)').firstMatch(path);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  InventoryItem _optimisticItem(
    Map<String, dynamic> body, {
    int? fallbackId,
    int? localId,
  }) {
    double toDouble(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    return InventoryItem(
      id: fallbackId ?? localId ?? -DateTime.now().millisecondsSinceEpoch,
      itemName: (body['item_name'] as String?) ?? 'Pending Item',
      category: (body['category'] as String?) ?? 'Other',
      quantity: toDouble(body['quantity']),
      unit: (body['unit'] as String?) ?? '',
      reorderLevel: toDouble(body['reorder_level']),
      costPerUnit: toDouble(body['cost_per_unit']),
      supplierId: body['supplier_id'] as int?,
    );
  }
}
