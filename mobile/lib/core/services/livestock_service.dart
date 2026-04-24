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

  Future<Map<String, dynamic>> getPlatformSnapshot() async {
    final health = await _api.getList(ApiEndpoints.livestockPlatformHealth);
    final reproduction =
        await _api.getList(ApiEndpoints.livestockPlatformReproduction);
    final production = await _api.getList(ApiEndpoints.livestockPlatformProduction);
    final vaccinations =
        await _api.getList(ApiEndpoints.livestockPlatformVaccinations);
    final alerts = await _safeGetMap(ApiEndpoints.livestockPlatformAlerts);

    int countByStatus(List<dynamic> list, String status) {
      return list.where((e) {
        if (e is! Map) return false;
        return (e['status']?.toString().toLowerCase() ?? '') == status;
      }).length;
    }

    return {
      'health_records': health.length,
      'reproduction_cycles': reproduction.length,
      'production_logs': production.length,
      'scheduled_vaccinations': countByStatus(vaccinations, 'scheduled'),
      'alerts': alerts,
    };
  }

  bool _shouldQueue(ApiException e) => e.statusCode == null;

  Future<Map<String, dynamic>> _safeGetMap(String path) async {
    try {
      final data = await _api.get(path);
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on ApiException {
      return <String, dynamic>{};
    }
  }

  Future<List<LivestockFeedLog>> listFeedLogs({
    int? livestockId,
    int? farmId,
  }) async {
    final params = <String, dynamic>{
      if (farmId != null) 'farm_id': farmId,
      if (livestockId != null) 'livestock_id': livestockId,
    };
    final list = await _api.getList(
      ApiEndpoints.livestockPlatformFeedLogs,
      params: params.isNotEmpty ? params : null,
    );
    return list
        .map((e) => LivestockFeedLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createFeedLog({
    required int farmId,
    required int livestockId,
    required String feedItem,
    required double feedQty,
    String unit = 'kg',
    double costTotal = 0,
    DateTime? logDate,
    String? notes,
    bool postToFinance = false,
    String? financeCategory,
  }) async {
    await _api.post(ApiEndpoints.livestockPlatformFeedLogs, data: {
      'farm_id': farmId,
      'livestock_id': livestockId,
      'feed_item': feedItem,
      'feed_qty': feedQty,
      'unit': unit,
      'cost_total': costTotal,
      'log_date': _formatDate(logDate ?? DateTime.now()),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (postToFinance) 'post_to_finance': 1,
      if (financeCategory != null && financeCategory.isNotEmpty)
        'finance_category': financeCategory,
    });
  }

  Future<List<LivestockTraceEvent>> listTraceEvents({
    int? livestockId,
    int? farmId,
  }) async {
    final params = <String, dynamic>{
      if (farmId != null) 'farm_id': farmId,
      if (livestockId != null) 'livestock_id': livestockId,
    };
    final list = await _api.getList(
      ApiEndpoints.livestockPlatformTrace,
      params: params.isNotEmpty ? params : null,
    );
    return list
        .map((e) => LivestockTraceEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTraceEvent({
    required int farmId,
    required int livestockId,
    required String eventType,
    DateTime? eventDate,
    String? location,
    double? latitude,
    double? longitude,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.livestockPlatformTrace, data: {
      'farm_id': farmId,
      'livestock_id': livestockId,
      'event_type': eventType,
      'event_date': _formatDateTime(eventDate ?? DateTime.now()),
      if (location != null && location.isNotEmpty) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (referenceType != null && referenceType.isNotEmpty)
        'reference_type': referenceType,
      if (referenceId != null && referenceId.isNotEmpty)
        'reference_id': referenceId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<List<LivestockBreedingPlan>> listBreedingPlans({
    int? farmId,
    int? damId,
    String? status,
  }) async {
    final params = <String, dynamic>{
      if (farmId != null) 'farm_id': farmId,
      if (damId != null) 'dam_id': damId,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final list = await _api.getList(
      ApiEndpoints.livestockPlatformBreedingPlans,
      params: params.isNotEmpty ? params : null,
    );
    return list
        .map((e) => LivestockBreedingPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBreedingPlan({
    required int farmId,
    required int damId,
    int? sireId,
    required DateTime plannedBreedingDate,
    String method = 'natural',
    DateTime? expectedBirthDate,
    String status = 'planned',
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.livestockPlatformBreedingPlans, data: {
      'farm_id': farmId,
      'dam_id': damId,
      if (sireId != null) 'sire_id': sireId,
      'planned_breeding_date': _formatDate(plannedBreedingDate),
      'method': method,
      if (expectedBirthDate != null)
        'expected_birth_date': _formatDate(expectedBirthDate),
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getPedigreeTree({
    required int farmId,
    required int livestockId,
    int generations = 3,
  }) async {
    return _api.get(
      ApiEndpoints.livestockPlatformPedigree,
      params: {
        'farm_id': farmId,
        'livestock_id': livestockId,
        'generations': generations,
      },
    );
  }

  Future<void> savePedigree({
    required int farmId,
    required int livestockId,
    int? sireId,
    int? damId,
    String? herdbookId,
    String? geneticLine,
    Map<String, dynamic>? pedigree,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.livestockPlatformPedigree, data: {
      'farm_id': farmId,
      'livestock_id': livestockId,
      if (sireId != null) 'sire_id': sireId,
      if (damId != null) 'dam_id': damId,
      if (herdbookId != null && herdbookId.isNotEmpty) 'herdbook_id': herdbookId,
      if (geneticLine != null && geneticLine.isNotEmpty) 'genetic_line': geneticLine,
      if (pedigree != null) 'pedigree': pedigree,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<List<LivestockGeneticTrait>> listGenetics({
    required int farmId,
    int? livestockId,
  }) async {
    final params = <String, dynamic>{
      'farm_id': farmId,
      if (livestockId != null) 'livestock_id': livestockId,
    };
    final list = await _api.getList(ApiEndpoints.livestockPlatformGenetics, params: params);
    return list
        .map((e) => LivestockGeneticTrait.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addGeneticTrait({
    required int farmId,
    required int livestockId,
    required String traitName,
    required String traitValue,
    DateTime? measuredOn,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.livestockPlatformGenetics, data: {
      'farm_id': farmId,
      'livestock_id': livestockId,
      'trait_name': traitName,
      'trait_value': traitValue,
      if (measuredOn != null) 'measured_on': _formatDate(measuredOn),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<LivestockLifecycleAnalytics> getLifecycleAnalytics({
    required int farmId,
    int? livestockId,
  }) async {
    final params = <String, dynamic>{
      'farm_id': farmId,
      if (livestockId != null) 'livestock_id': livestockId,
    };
    final data = await _api.get(
      ApiEndpoints.livestockPlatformLifecycleAnalytics,
      params: params,
    );
    return LivestockLifecycleAnalytics.fromJson(data);
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateTime(DateTime value) {
    final dt = value.toLocal();
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }

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
