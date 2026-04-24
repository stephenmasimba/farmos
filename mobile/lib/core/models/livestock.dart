import 'package:equatable/equatable.dart';

class Livestock extends Equatable {
  const Livestock({
    required this.id,
    required this.batchCode,
    required this.animalType,
    required this.breed,
    required this.initialQuantity,
    required this.currentQuantity,
    required this.status,
    this.birthDate,
    this.acquisitionDate,
    this.expectedHarvestDate,
    this.farmId,
    this.species,
  });

  final int id;
  final String batchCode;
  final String animalType;
  final String breed;
  final int initialQuantity;
  final int currentQuantity;
  final String status; // active | sold | harvested | deceased
  final DateTime? birthDate;
  final DateTime? acquisitionDate;
  final DateTime? expectedHarvestDate;
  final int? farmId;
  final String? species;

  factory Livestock.fromJson(Map<String, dynamic> j) => Livestock(
        id: j['id'] as int,
        batchCode: j['batch_code'] as String? ?? '',
        animalType: j['animal_type'] as String? ?? '',
        breed: j['breed'] as String? ?? '',
        initialQuantity: _parseInt(j['initial_quantity']),
        currentQuantity: _parseInt(j['current_quantity']),
        status: j['status'] as String? ?? 'active',
        birthDate: _parseDate(j['birth_date']),
        acquisitionDate: _parseDate(j['acquisition_date']),
        expectedHarvestDate: _parseDate(j['expected_harvest_date']),
        farmId: j['farm_id'] as int?,
        species: j['species'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'batch_code': batchCode,
        'animal_type': animalType,
        'breed': breed,
        'initial_quantity': initialQuantity,
        'current_quantity': currentQuantity,
        'status': status,
        if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
        if (acquisitionDate != null)
          'acquisition_date': acquisitionDate!.toIso8601String(),
        if (expectedHarvestDate != null)
          'expected_harvest_date': expectedHarvestDate!.toIso8601String(),
        if (farmId != null) 'farm_id': farmId,
      };

  @override
  List<Object?> get props => [id, batchCode, status];
}

class LivestockEvent extends Equatable {
  const LivestockEvent({
    required this.id,
    required this.batchId,
    required this.eventType,
    required this.eventDate,
    this.description,
    this.performedBy,
  });

  final int id;
  final int batchId;
  final String eventType; // vaccination | mortality | weighing | feeding
  final DateTime eventDate;
  final String? description;
  final String? performedBy;

  factory LivestockEvent.fromJson(Map<String, dynamic> j) => LivestockEvent(
        id: j['id'] as int,
        batchId: j['batch_id'] as int,
        eventType: j['event_type'] as String? ?? '',
        eventDate: _parseDate(j['event_date']) ?? DateTime.now(),
        description: j['description'] as String?,
        performedBy: j['performed_by'] as String?,
      );

  @override
  List<Object?> get props => [id, batchId, eventType];
}

class LivestockStats extends Equatable {
  const LivestockStats({
    required this.totalBatches,
    required this.totalAnimals,
    required this.activeBatches,
    required this.totalMortality,
  });

  final int totalBatches;
  final int totalAnimals;
  final int activeBatches;
  final int totalMortality;

  factory LivestockStats.fromJson(Map<String, dynamic> j) => LivestockStats(
        totalBatches: _parseInt(j['total_batches']),
        totalAnimals: _parseInt(j['total_animals']),
        activeBatches: _parseInt(j['active_batches']),
        totalMortality: _parseInt(j['total_mortality']),
      );

  @override
  List<Object?> get props => [totalBatches, totalAnimals];
}

int _parseInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
DateTime? _parseDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

class LivestockHealthRecord extends Equatable {
  const LivestockHealthRecord({
    required this.id,
    required this.livestockId,
    this.recordDate,
    required this.conditionName,
    this.treatment,
    this.medicine,
    this.dosage,
    this.veterinarian,
    this.nextFollowupDate,
    required this.status,
    required this.costTotal,
  });

  final int id;
  final int livestockId;
  final DateTime? recordDate;
  final String conditionName;
  final String? treatment;
  final String? medicine;
  final String? dosage;
  final String? veterinarian;
  final DateTime? nextFollowupDate;
  final String status;
  final double costTotal;

  factory LivestockHealthRecord.fromJson(Map<String, dynamic> j) =>
      LivestockHealthRecord(
        id: _parseInt(j['id']),
        livestockId: _parseInt(j['livestock_id']),
        recordDate: _parseDate(j['record_date']),
        conditionName: j['condition_name'] as String? ?? '',
        treatment: j['treatment'] as String?,
        medicine: j['medicine'] as String?,
        dosage: j['dosage'] as String?,
        veterinarian: j['veterinarian'] as String?,
        nextFollowupDate: _parseDate(j['next_followup_date']),
        status: j['status'] as String? ?? 'open',
        costTotal: double.tryParse((j['cost_total'] ?? '0').toString()) ?? 0.0,
      );

  @override
  List<Object?> get props => [id, livestockId, recordDate, conditionName, status];
}

class LivestockReproductionCycle extends Equatable {
  const LivestockReproductionCycle({
    required this.id,
    required this.damId,
    this.sireId,
    this.heatDate,
    this.inseminationDate,
    this.pregnancyCheckDate,
    this.expectedCalvingDate,
    this.actualCalvingDate,
    required this.outcome,
    this.notes,
  });

  final int id;
  final int damId;
  final int? sireId;
  final DateTime? heatDate;
  final DateTime? inseminationDate;
  final DateTime? pregnancyCheckDate;
  final DateTime? expectedCalvingDate;
  final DateTime? actualCalvingDate;
  final String outcome;
  final String? notes;

  factory LivestockReproductionCycle.fromJson(Map<String, dynamic> j) =>
      LivestockReproductionCycle(
        id: _parseInt(j['id']),
        damId: _parseInt(j['dam_id']),
        sireId: int.tryParse((j['sire_id'] ?? '').toString()),
        heatDate: _parseDate(j['heat_date']),
        inseminationDate: _parseDate(j['insemination_date']),
        pregnancyCheckDate: _parseDate(j['pregnancy_check_date']),
        expectedCalvingDate: _parseDate(j['expected_calving_date']),
        actualCalvingDate: _parseDate(j['actual_calving_date']),
        outcome: j['outcome'] as String? ?? 'pending',
        notes: j['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, damId, sireId, outcome];
}

class LivestockProductionLog extends Equatable {
  const LivestockProductionLog({
    required this.id,
    required this.livestockId,
    this.logDate,
    required this.metric,
    required this.value,
    required this.unit,
    this.notes,
  });

  final int id;
  final int livestockId;
  final DateTime? logDate;
  final String metric;
  final double value;
  final String unit;
  final String? notes;

  factory LivestockProductionLog.fromJson(Map<String, dynamic> j) =>
      LivestockProductionLog(
        id: _parseInt(j['id']),
        livestockId: _parseInt(j['livestock_id']),
        logDate: _parseDate(j['log_date']),
        metric: j['metric'] as String? ?? '',
        value: double.tryParse((j['value'] ?? '0').toString()) ?? 0.0,
        unit: j['unit'] as String? ?? '',
        notes: j['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, livestockId, logDate, metric, value];
}

class LivestockVaccinationScheduleItem extends Equatable {
  const LivestockVaccinationScheduleItem({
    required this.id,
    required this.livestockId,
    required this.vaccineName,
    this.scheduledDate,
    this.administeredDate,
    required this.status,
    this.batchNo,
    this.notes,
    required this.seriesId,
    required this.recurrenceDays,
    required this.reminderDaysBefore,
    required this.costTotal,
  });

  final int id;
  final int livestockId;
  final String vaccineName;
  final DateTime? scheduledDate;
  final DateTime? administeredDate;
  final String status;
  final String? batchNo;
  final String? notes;
  final int seriesId;
  final int recurrenceDays;
  final int reminderDaysBefore;
  final double costTotal;

  factory LivestockVaccinationScheduleItem.fromJson(Map<String, dynamic> j) =>
      LivestockVaccinationScheduleItem(
        id: _parseInt(j['id']),
        livestockId: _parseInt(j['livestock_id']),
        vaccineName: j['vaccine_name'] as String? ?? '',
        scheduledDate: _parseDate(j['scheduled_date']),
        administeredDate: _parseDate(j['administered_date']),
        status: j['status'] as String? ?? 'scheduled',
        batchNo: j['batch_no'] as String?,
        notes: j['notes'] as String?,
        seriesId: _parseInt(j['series_id']),
        recurrenceDays: _parseInt(j['recurrence_days']),
        reminderDaysBefore: _parseInt(j['reminder_days_before']),
        costTotal: double.tryParse((j['cost_total'] ?? '0').toString()) ?? 0.0,
      );

  @override
  List<Object?> get props => [id, livestockId, vaccineName, scheduledDate, status];
}

class LivestockFeedLog extends Equatable {
  const LivestockFeedLog({
    required this.id,
    required this.livestockId,
    required this.feedItem,
    required this.feedQty,
    required this.unit,
    required this.costTotal,
    this.logDate,
    this.notes,
  });

  final int id;
  final int livestockId;
  final String feedItem;
  final double feedQty;
  final String unit;
  final double costTotal;
  final DateTime? logDate;
  final String? notes;

  factory LivestockFeedLog.fromJson(Map<String, dynamic> j) => LivestockFeedLog(
        id: _parseInt(j['id']),
        livestockId: _parseInt(j['livestock_id']),
        feedItem: j['feed_item'] as String? ?? '',
        feedQty: double.tryParse((j['feed_qty'] ?? '0').toString()) ?? 0.0,
        unit: j['unit'] as String? ?? 'kg',
        costTotal: double.tryParse((j['cost_total'] ?? '0').toString()) ?? 0.0,
        logDate: _parseDate(j['log_date']),
        notes: j['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, livestockId, logDate, feedItem, feedQty];
}

class LivestockTraceEvent extends Equatable {
  const LivestockTraceEvent({
    required this.id,
    required this.livestockId,
    required this.eventType,
    this.eventDate,
    this.location,
    this.latitude,
    this.longitude,
    this.referenceType,
    this.referenceId,
    this.notes,
  });

  final int id;
  final int livestockId;
  final String eventType;
  final DateTime? eventDate;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? referenceType;
  final String? referenceId;
  final String? notes;

  factory LivestockTraceEvent.fromJson(Map<String, dynamic> j) =>
      LivestockTraceEvent(
        id: _parseInt(j['id']),
        livestockId: _parseInt(j['livestock_id']),
        eventType: j['event_type'] as String? ?? '',
        eventDate: _parseDate(j['event_date']),
        location: j['location'] as String?,
        latitude: j['latitude'] != null
            ? double.tryParse(j['latitude'].toString())
            : null,
        longitude: j['longitude'] != null
            ? double.tryParse(j['longitude'].toString())
            : null,
        referenceType: j['reference_type'] as String?,
        referenceId: j['reference_id'] as String?,
        notes: j['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, livestockId, eventType, eventDate];
}

class LivestockBreedingPlan extends Equatable {
  const LivestockBreedingPlan({
    required this.id,
    required this.damId,
    this.sireId,
    this.plannedBreedingDate,
    required this.method,
    this.expectedBirthDate,
    required this.status,
    this.notes,
  });

  final int id;
  final int damId;
  final int? sireId;
  final DateTime? plannedBreedingDate;
  final String method;
  final DateTime? expectedBirthDate;
  final String status;
  final String? notes;

  factory LivestockBreedingPlan.fromJson(Map<String, dynamic> j) =>
      LivestockBreedingPlan(
        id: _parseInt(j['id']),
        damId: _parseInt(j['dam_id']),
        sireId: int.tryParse((j['sire_id'] ?? '').toString()),
        plannedBreedingDate: _parseDate(j['planned_breeding_date']),
        method: j['method'] as String? ?? 'natural',
        expectedBirthDate: _parseDate(j['expected_birth_date']),
        status: j['status'] as String? ?? 'planned',
        notes: j['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, damId, sireId, plannedBreedingDate, status];
}

class LivestockGeneticTrait extends Equatable {
  const LivestockGeneticTrait({
    required this.id,
    required this.livestockId,
    required this.traitName,
    required this.traitValue,
    this.measuredOn,
    this.notes,
  });

  final int id;
  final int livestockId;
  final String traitName;
  final String traitValue;
  final DateTime? measuredOn;
  final String? notes;

  factory LivestockGeneticTrait.fromJson(Map<String, dynamic> j) =>
      LivestockGeneticTrait(
        id: _parseInt(j['id']),
        livestockId: _parseInt(j['livestock_id']),
        traitName: j['trait_name'] as String? ?? '',
        traitValue: j['trait_value'] as String? ?? '',
        measuredOn: _parseDate(j['measured_on']),
        notes: j['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, livestockId, traitName, traitValue];
}

class LivestockLifecycleAnalytics extends Equatable {
  const LivestockLifecycleAnalytics({
    required this.feedCount,
    required this.feedCostTotal,
    required this.healthCount,
    required this.healthCostTotal,
    required this.vaccinationCount,
    required this.vaccinationCostTotal,
    required this.production,
    required this.reproductionOutcomes,
    required this.traceability,
  });

  final int feedCount;
  final double feedCostTotal;
  final int healthCount;
  final double healthCostTotal;
  final int vaccinationCount;
  final double vaccinationCostTotal;
  final List<Map<String, dynamic>> production;
  final List<Map<String, dynamic>> reproductionOutcomes;
  final List<Map<String, dynamic>> traceability;

  factory LivestockLifecycleAnalytics.fromJson(Map<String, dynamic> j) {
    final feed = j['feed'] as Map<String, dynamic>? ?? {};
    final health = j['health'] as Map<String, dynamic>? ?? {};
    final vax = j['vaccinations'] as Map<String, dynamic>? ?? {};
    return LivestockLifecycleAnalytics(
      feedCount: _parseInt(feed['count']),
      feedCostTotal:
          double.tryParse((feed['cost_total'] ?? '0').toString()) ?? 0.0,
      healthCount: _parseInt(health['count']),
      healthCostTotal:
          double.tryParse((health['cost_total'] ?? '0').toString()) ?? 0.0,
      vaccinationCount: _parseInt(vax['count']),
      vaccinationCostTotal:
          double.tryParse((vax['cost_total'] ?? '0').toString()) ?? 0.0,
      production: ((j['production'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      reproductionOutcomes:
          ((j['reproduction_outcomes'] as List<dynamic>?) ?? const <dynamic>[])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
      traceability:
          ((j['traceability'] as List<dynamic>?) ?? const <dynamic>[])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
    );
  }

  @override
  List<Object?> get props => [
        feedCount,
        feedCostTotal,
        healthCount,
        healthCostTotal,
        vaccinationCount,
        vaccinationCostTotal,
      ];
}
