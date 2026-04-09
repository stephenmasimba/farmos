import '../api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_endpoints.dart';
import '../models/cost_analysis.dart';
import 'sync_service.dart';
import 'cache_status_service.dart';

class CostAnalysisService {
  CostAnalysisService(this._client, this._sync, this._cache);

  final ApiClient _client;
  final SyncService _sync;
  final StateNotifierProvider<CacheStatusService, Map<String, CacheStatusRecord>> _cache;

  static const animalCostsKey = 'cost_analysis_service_animals';
  static const batchCostsKey = 'cost_analysis_service_batches';

  Future<AnimalCostAnalysis> getAnimalCosts(int livestockId) async {
    final result = await _client.get(
      '/api/livestock/$livestockId/cost-analysis',
      params: {},
    );
    return AnimalCostAnalysis.fromJson(result);
  }

  Future<BatchCostSummary> getBatchCostsummary(int batchId) async {
    final result = await _client.get(
      '/api/livestock/batch/$batchId/cost-summary',
      params: {},
    );
    return BatchCostSummary.fromJson(result);
  }

  Future<List<AnimalCostAnalysis>> getHerdCosts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _client.getList(
      '/api/livestock/costs',
      params: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'limit': 100,
      },
    );
    return data
        .map((e) => AnimalCostAnalysis.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, double>> calculateMonthlyBreakdown(int livestockId) async {
    final result = await _client.get(
      '/api/livestock/$livestockId/monthly-breakdown',
      params: {},
    );
    return Map<String, double>.from(
      result.map((k, v) => MapEntry(k as String, double.tryParse(v.toString()) ?? 0.0)),
    );
  }
}

