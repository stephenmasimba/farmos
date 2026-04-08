import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/livestock.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class LivestockService {
  const LivestockService(this._api, this._sync, this._cacheStatus);
  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const listStatusKey = 'livestock:list';
  static const statsStatusKey = 'livestock:stats';

  String _listCacheKey({String? status, String? species, int? farmId}) =>
      'livestock_list_${status ?? 'all'}_${species ?? 'all'}_${farmId ?? 'all'}';

  String _detailCacheKey(int id) => 'livestock_detail_$id';
  String _statsCacheKey() => 'livestock_stats';
  String _eventsCacheKey(int batchId) => 'livestock_events_$batchId';

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
    try {
      final list = await _api.getList(ApiEndpoints.livestock, params: params);
      await _sync.cache(_listCacheKey(status: status, species: species, farmId: farmId), {
        'items': list,
      });
      _cacheStatus.markFresh(listStatusKey);
      final base = list
          .map((e) => Livestock.fromJson(e as Map<String, dynamic>))
          .toList();
      return _applyQueuedChanges(
        base,
        status: status,
        species: species,
      );
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(
        _listCacheKey(status: status, species: species, farmId: farmId),
      );
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          listStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        final base = items
            .map((e) => Livestock.fromJson(e as Map<String, dynamic>))
            .toList();
        return _applyQueuedChanges(
          base,
          status: status,
          species: species,
        );
      }
      rethrow;
    }
  }

  Future<Livestock> getById(int id) async {
    try {
      final data = await _api.get(ApiEndpoints.livestockById(id));
      final payload = data['livestock'] as Map<String, dynamic>? ?? data;
      await _sync.cache(_detailCacheKey(id), payload);
      return Livestock.fromJson(payload);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCache(_detailCacheKey(id));
      if (cached != null) return Livestock.fromJson(cached);
      rethrow;
    }
  }

  Future<Livestock> create(Map<String, dynamic> body) async {
    try {
      final data = await _api.post(ApiEndpoints.livestock, data: body);
      return Livestock.fromJson(data['livestock'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.livestock,
        body: body,
      );
      return _optimisticLivestock(body);
    }
  }

  Future<Livestock> update(int id, Map<String, dynamic> body) async {
    try {
      final data = await _api.put(ApiEndpoints.livestockById(id), data: body);
      return Livestock.fromJson(data['livestock'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'PUT',
        path: ApiEndpoints.livestockById(id),
        body: body,
      );
      return _optimisticLivestock(body, fallbackId: id);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.delete(ApiEndpoints.livestockById(id));
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'DELETE',
        path: ApiEndpoints.livestockById(id),
      );
    }
  }

  Future<LivestockStats> getStats() async {
    try {
      final data = await _api.get(ApiEndpoints.livestockStats);
      await _sync.cache(_statsCacheKey(), data);
      _cacheStatus.markFresh(statsStatusKey);
      return LivestockStats.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_statsCacheKey());
      if (cached != null) {
        _cacheStatus.markOffline(
          statsStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return LivestockStats.fromJson(cached.payload);
      }
      rethrow;
    }
  }

  Future<List<LivestockEvent>> getEvents(int batchId) async {
    try {
      final list = await _api.getList(ApiEndpoints.livestockEvents(batchId));
      await _sync.cache(_eventsCacheKey(batchId), {'items': list});
      return list
          .map((e) => LivestockEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCache(_eventsCacheKey(batchId));
      final items = cached?['items'] as List<dynamic>?;
      if (items != null) {
        return items
            .map((e) => LivestockEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<LivestockEvent> addEvent(int batchId, Map<String, dynamic> body) async {
    try {
      final data = await _api.post(ApiEndpoints.livestockEvents(batchId), data: body);
      return LivestockEvent.fromJson(
          data['event'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.livestockEvents(batchId),
        body: body,
      );
      return LivestockEvent(
        id: -DateTime.now().millisecondsSinceEpoch,
        batchId: batchId,
        eventType: (body['event_type'] as String?) ?? 'event',
        eventDate: DateTime.tryParse((body['event_date'] ?? '').toString()) ??
            DateTime.now(),
        description: body['description'] as String?,
      );
    }
  }

  bool _shouldQueue(ApiException e) => e.statusCode == null;

  Future<List<Livestock>> _applyQueuedChanges(
    List<Livestock> base, {
    String? status,
    String? species,
  }) async {
    final queue = await _sync.getPendingItemsByPathPrefix(ApiEndpoints.livestock);
    var list = List<Livestock>.from(base);

    for (final item in queue) {
      final body = item.body;
      final id = _extractId(item.path);

      if (item.method == 'POST' && item.path == ApiEndpoints.livestock && body != null) {
        final optimistic = _optimisticLivestock(body, localId: -item.id);
        list.insert(0, optimistic);
        continue;
      }

      if (item.method == 'PUT' && id != null && body != null) {
        final index = list.indexWhere((entry) => entry.id == id);
        final optimistic = _optimisticLivestock(body, fallbackId: id);
        if (index >= 0) {
          list[index] = optimistic;
        } else {
          list.insert(0, optimistic);
        }
        continue;
      }

      if (item.method == 'DELETE' && id != null) {
        list.removeWhere((entry) => entry.id == id);
      }
    }

    return list.where((entry) {
      if (status != null && entry.status != status) return false;
      if (species != null && entry.species != null && entry.species != species) {
        return false;
      }
      return true;
    }).toList();
  }

  int? _extractId(String path) {
    final match = RegExp(r'^/api/livestock/(\d+)').firstMatch(path);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  Livestock _optimisticLivestock(
    Map<String, dynamic> body, {
    int? fallbackId,
    int? localId,
  }) {
    int toInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
    DateTime? toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return Livestock(
      id: fallbackId ?? localId ?? -DateTime.now().millisecondsSinceEpoch,
      batchCode: (body['batch_code'] as String?) ?? 'PENDING_BATCH',
      animalType: (body['animal_type'] as String?) ?? 'Unknown',
      breed: (body['breed'] as String?) ?? 'Unknown',
      initialQuantity: toInt(body['initial_quantity']),
      currentQuantity: toInt(body['current_quantity'] ?? body['initial_quantity']),
      status: (body['status'] as String?) ?? 'active',
      birthDate: toDate(body['birth_date']),
      acquisitionDate: toDate(body['acquisition_date']),
      expectedHarvestDate: toDate(body['expected_harvest_date']),
      farmId: body['farm_id'] as int?,
    );
  }
}
