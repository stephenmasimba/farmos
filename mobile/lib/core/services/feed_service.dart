import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/feed.dart';

class FeedService {
  const FeedService(this._api);

  final ApiClient _api;

  Future<List<FeedIngredient>> listIngredients() async {
    final list = await _api.getList(ApiEndpoints.feedIngredients);
    return list
        .map((e) => FeedIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createIngredient({
    required String name,
    required double proteinContent,
    required double quantityKg,
    required double costPerKg,
  }) async {
    await _api.post(ApiEndpoints.feedIngredients, data: {
      'name': name,
      'protein_content': proteinContent,
      'quantity_kg': quantityKg,
      'cost_per_kg': costPerKg,
    });
  }

  Future<List<FeedMillingLog>> listMillingLogs() async {
    final list = await _api.getList(ApiEndpoints.feedMillingLogs);
    return list
        .map((e) => FeedMillingLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PearsonResult> calculatePearson({
    required int ingredient1Id,
    required int ingredient2Id,
    required double targetProtein,
    required double totalQuantityKg,
  }) async {
    final data = await _api.post(ApiEndpoints.feedCalculatePearson, data: {
      'ingredient_1_id': ingredient1Id,
      'ingredient_2_id': ingredient2Id,
      'target_protein': targetProtein,
      'total_quantity_kg': totalQuantityKg,
    });
    return PearsonResult.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> formulationIngredients() async {
    final list = await _api.getList(ApiEndpoints.feedFormulationIngredients);
    return list
        .map((e) => (e as Map).map((k, v) => MapEntry('$k', v)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> formulationRecent() async {
    final list = await _api.getList(ApiEndpoints.feedFormulationRecent);
    return list
        .map((e) => (e as Map).map((k, v) => MapEntry('$k', v)))
        .toList();
  }
}
