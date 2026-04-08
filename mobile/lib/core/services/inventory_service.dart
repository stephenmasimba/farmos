import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/inventory.dart';

class InventoryService {
  const InventoryService(this._api);
  final ApiClient _api;

  Future<List<InventoryItem>> getAll({
    int page = 1,
    int perPage = 20,
    String? category,
  }) async {
    final path = category != null
        ? ApiEndpoints.inventoryByCategory(category)
        : ApiEndpoints.inventory;
    final list = await _api.getList(path,
        params: {'page': page, 'per_page': perPage});
    return list
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InventoryItem> getById(int id) async {
    final data = await _api.get(ApiEndpoints.inventoryById(id));
    return InventoryItem.fromJson(
        data['item'] as Map<String, dynamic>? ?? data);
  }

  Future<InventoryItem> create(Map<String, dynamic> body) async {
    final data = await _api.post(ApiEndpoints.inventory, data: body);
    return InventoryItem.fromJson(
        data['item'] as Map<String, dynamic>? ?? data);
  }

  Future<InventoryItem> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put(ApiEndpoints.inventoryById(id), data: body);
    return InventoryItem.fromJson(
        data['item'] as Map<String, dynamic>? ?? data);
  }

  Future<void> delete(int id) => _api.delete(ApiEndpoints.inventoryById(id));

  Future<InventoryStats> getStats() async {
    final data = await _api.get(ApiEndpoints.inventoryStats);
    return InventoryStats.fromJson(data);
  }

  Future<List<InventoryItem>> getLowStockAlerts() async {
    final list = await _api.getList(ApiEndpoints.inventoryAlerts);
    return list
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InventoryItem> adjustStock(int id, StockAdjustment adj) async {
    final data = await _api.post(ApiEndpoints.inventoryAdjust(id),
        data: adj.toJson());
    return InventoryItem.fromJson(
        data['item'] as Map<String, dynamic>? ?? data);
  }
}
