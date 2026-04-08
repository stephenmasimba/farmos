import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/livestock.dart';

class LivestockService {
  const LivestockService(this._api);
  final ApiClient _api;

  Future<List<Livestock>> getAll({
    int page = 1,
    int perPage = 20,
    String? status,
    String? species,
    int? farmId,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (status != null) 'status': status,
      if (species != null) 'species': species,
      if (farmId != null) 'farm_id': farmId,
    };
    final list = await _api.getList(ApiEndpoints.livestock, params: params);
    return list.map((e) => Livestock.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Livestock> getById(int id) async {
    final data = await _api.get(ApiEndpoints.livestockById(id));
    return Livestock.fromJson(data['livestock'] as Map<String, dynamic>? ?? data);
  }

  Future<Livestock> create(Map<String, dynamic> body) async {
    final data = await _api.post(ApiEndpoints.livestock, data: body);
    return Livestock.fromJson(data['livestock'] as Map<String, dynamic>? ?? data);
  }

  Future<Livestock> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put(ApiEndpoints.livestockById(id), data: body);
    return Livestock.fromJson(data['livestock'] as Map<String, dynamic>? ?? data);
  }

  Future<void> delete(int id) => _api.delete(ApiEndpoints.livestockById(id));

  Future<LivestockStats> getStats() async {
    final data = await _api.get(ApiEndpoints.livestockStats);
    return LivestockStats.fromJson(data);
  }

  Future<List<LivestockEvent>> getEvents(int batchId) async {
    final list = await _api.getList(ApiEndpoints.livestockEvents(batchId));
    return list
        .map((e) => LivestockEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LivestockEvent> addEvent(int batchId, Map<String, dynamic> body) async {
    final data = await _api.post(ApiEndpoints.livestockEvents(batchId), data: body);
    return LivestockEvent.fromJson(
        data['event'] as Map<String, dynamic>? ?? data);
  }
}
