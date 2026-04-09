import 'package:equatable/equatable.dart';

class VeterinaryLog extends Equatable {
  const VeterinaryLog({
    required this.id,
    required this.animalId,
    required this.animalType,
    required this.treatmentType,
    required this.medication,
    required this.dosage,
    required this.withdrawalPeriodDays,
    required this.withdrawalEndDate,
    required this.status,
    this.treatmentDate,
    this.notes,
  });

  final int id;
  final String animalId;
  final String animalType;
  final String treatmentType;
  final String medication;
  final String dosage;
  final int withdrawalPeriodDays;
  final DateTime? withdrawalEndDate;
  final String status;
  final DateTime? treatmentDate;
  final String? notes;

  factory VeterinaryLog.fromJson(Map<String, dynamic> json) {
    return VeterinaryLog(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      animalId: (json['animal_id'] as String?) ?? '',
      animalType: (json['animal_type'] as String?) ?? '',
      treatmentType: (json['treatment_type'] as String?) ?? '',
      medication: (json['medication'] as String?) ?? '',
      dosage: (json['dosage'] as String?) ?? '',
      withdrawalPeriodDays:
          int.tryParse((json['withdrawal_period_days'] ?? '0').toString()) ?? 0,
      withdrawalEndDate: json['withdrawal_end_date'] != null
          ? DateTime.tryParse(json['withdrawal_end_date'].toString())
          : null,
      status: (json['status'] as String?) ?? 'ACTIVE',
      treatmentDate: json['treatment_date'] != null
          ? DateTime.tryParse(json['treatment_date'].toString())
          : null,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, animalId, treatmentType, status, withdrawalEndDate, treatmentDate];
}

class VeterinaryVaccination extends Equatable {
  const VeterinaryVaccination({
    required this.id,
    required this.vaccineName,
    required this.batchId,
    required this.targetAgeDays,
    required this.scheduledDate,
    required this.status,
  });

  final int id;
  final String vaccineName;
  final String batchId;
  final int targetAgeDays;
  final DateTime scheduledDate;
  final String status;

  factory VeterinaryVaccination.fromJson(Map<String, dynamic> json) {
    return VeterinaryVaccination(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      vaccineName: (json['vaccine_name'] as String?) ?? '',
      batchId: (json['batch_id'] as String?) ?? '',
      targetAgeDays:
          int.tryParse((json['target_age_days'] ?? '0').toString()) ?? 0,
      scheduledDate:
          DateTime.tryParse((json['scheduled_date'] ?? '').toString()) ??
              DateTime.now(),
      status: (json['status'] as String?) ?? 'scheduled',
    );
  }

  @override
  List<Object?> get props => [id, vaccineName, batchId, scheduledDate, status];
}

class VeterinaryWithdrawal extends Equatable {
  const VeterinaryWithdrawal({
    required this.animalId,
    this.endDate,
    required this.daysRemaining,
  });

  final String animalId;
  final DateTime? endDate;
  final int daysRemaining;

  factory VeterinaryWithdrawal.fromJson(Map<String, dynamic> json) {
    return VeterinaryWithdrawal(
      animalId: (json['animal_id'] as String?) ?? '',
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      daysRemaining: int.tryParse((json['days_remaining'] ?? '0').toString()) ?? 0,
    );
  }

  @override
  List<Object?> get props => [animalId, endDate, daysRemaining];
}
