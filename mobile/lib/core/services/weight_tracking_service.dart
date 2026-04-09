import '../api/api_client.dart';
import '../models/weight_record.dart';

class WeightTrackingService {
  const WeightTrackingService(this._api);

  final ApiClient _api;

  Future<List<WeightRecord>> getRecords(int livestockId) async {
    final list = await _api.getList('/api/livestock/$livestockId/weights');
    return list
        .map((e) => WeightRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeightRecord> addRecord(
    int livestockId,
    double weightKg, {
    String? notes,
  }) async {
    final data = await _api.post(
      '/api/livestock/$livestockId/weights',
      data: {
        'weight_kg': weightKg,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes,
      },
    );

    final record = data['record'] as Map<String, dynamic>? ?? data;
    return WeightRecord.fromJson(record);
  }
}
