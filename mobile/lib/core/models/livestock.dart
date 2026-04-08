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
