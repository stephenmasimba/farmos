import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/farm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sync_service.dart';
import 'cache_status_service.dart';

class FarmService {
  FarmService(this._client, this._sync, this._cache);

  final ApiClient _client;
  final SyncService _sync;
  final StateNotifierProvider<CacheStatusService, Map<String, CacheStatusRecord>> _cache;

  static const managedKey = 'farm_service_managed';
  static const ownedKey = 'farm_service_owned';

  Future<List<Farm>> listManagedFarms() async {
    final data =
        await _client.getList(ApiEndpoints.farms, params: {'type': 'managed'});
    return data.map((e) => Farm.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Farm>> listOwnedFarms() async {
    final data =
        await _client.getList(ApiEndpoints.farms, params: {'type': 'owned'});
    return data.map((e) => Farm.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Farm> createFarm(String name, {String? location, double? areaHa}) {
    return _sync.enqueue(
      label: 'Create farm: $name',
      operation: () async {
        final result = await _client.post(
          ApiEndpoints.farms,
          data: {
            'name': name,
            if (location != null) 'location': location,
            if (areaHa != null) 'total_area_ha': areaHa,
          },
        );
        return Farm.fromJson(result);
      },
    );
  }

  Future<Farm> updateFarmPreference(int farmId) {
    return _sync.enqueue(
      label: 'Switch to farm: $farmId',
      operation: () async {
        final result = await _client.put(
          '${ApiEndpoints.farms}/$farmId/preference',
          data: {'primary': true},
        );
        return Farm.fromJson(result);
      },
    );
  }
}

