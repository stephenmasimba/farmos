import '../api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_endpoints.dart';
import '../models/field_map.dart';
import 'sync_service.dart';
import 'cache_status_service.dart';

class FieldMapService {
  FieldMapService(this._client, this._sync, this._cache);

  final ApiClient _client;
  final SyncService _sync;
  final StateNotifierProvider<CacheStatusService, Map<String, CacheStatusRecord>> _cache;

  static const boundariesKey = 'field_map_service_boundaries';

  Future<FieldBoundary> getFieldBoundary(int fieldId) async {
    final result =
        await _client.get('/api/fields/$fieldId/boundary', params: {});
    return FieldBoundary.fromJson(result);
  }

  Future<List<GeoPoint>> listBoundaryPoints(int fieldId) async {
    final data = await _client.getList(
      '/api/fields/$fieldId/boundary-points',
      params: {'limit': 1000},
    );
    return data.map((e) => GeoPoint.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FieldBoundary> saveBoundary(int fieldId, List<GeoPoint> points) {
    return _sync.enqueue(
      label: 'Save field boundary',
      operation: () async {
        final result = await _client.post(
          '/api/fields/$fieldId/boundary',
          data: {
            'boundary_points': points.map((p) => p.toJson()).toList(),
          },
        );
        return FieldBoundary.fromJson(result);
      },
    );
  }

  Future<void> deleteFieldBoundary(int fieldId) {
    return _sync.enqueue(
      label: 'Delete field boundary',
      operation: () => _client.delete('/api/fields/$fieldId/boundary'),
    );
  }
}

