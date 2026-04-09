import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/veterinary.dart';

class VeterinaryService {
  const VeterinaryService(this._api);

  final ApiClient _api;

  Future<List<VeterinaryLog>> listLogs() async {
    final list = await _api.getList(ApiEndpoints.veterinaryLogs);
    return list
        .map((e) => VeterinaryLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createLog({
    required String animalId,
    required String treatmentType,
    required DateTime treatmentDate,
    String? animalType,
    String? medication,
    String? dosage,
    int withdrawalPeriodDays = 0,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.veterinaryLogs, data: {
      'animal_id': animalId,
      if (animalType != null && animalType.isNotEmpty) 'animal_type': animalType,
      'treatment_type': treatmentType,
      'treatment_date': _formatDate(treatmentDate),
      if (medication != null && medication.isNotEmpty) 'medication': medication,
      if (dosage != null && dosage.isNotEmpty) 'dosage': dosage,
      'withdrawal_period_days': withdrawalPeriodDays,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<void> updateLogStatus({
    required int id,
    required String status,
  }) async {
    await _api.put(ApiEndpoints.veterinaryLogStatus(id), data: {
      'status': status,
    });
  }

  Future<List<VeterinaryVaccination>> listVaccinations() async {
    final list = await _api.getList(ApiEndpoints.veterinaryVaccinations);
    return list
        .map((e) => VeterinaryVaccination.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createVaccination({
    required String vaccineName,
    required String batchId,
    required DateTime scheduledDate,
    int targetAgeDays = 0,
    String status = 'scheduled',
  }) async {
    await _api.post(ApiEndpoints.veterinaryVaccinations, data: {
      'vaccine_name': vaccineName,
      'batch_id': batchId,
      'target_age_days': targetAgeDays,
      'scheduled_date': _formatDate(scheduledDate),
      'status': status,
    });
  }

  Future<List<VeterinaryWithdrawal>> listWithdrawals() async {
    final list = await _api.getList(ApiEndpoints.veterinaryWithdrawals);
    return list
        .map((e) => VeterinaryWithdrawal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
