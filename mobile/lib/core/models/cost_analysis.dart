import 'package:equatable/equatable.dart';

class AnimalCostAnalysis extends Equatable {
  const AnimalCostAnalysis({
    required this.livestockId,
    required this.animalTag,
    required this.feedCost,
    required this.veterinaryCost,
    required this.laborCost,
    required this.totalCost,
    required this.costPerDay,
    this.periodStart,
    this.periodEnd,
  });

  final int livestockId;
  final String animalTag;
  final double feedCost;
  final double veterinaryCost;
  final double laborCost;
  final double totalCost;
  final double costPerDay;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  factory AnimalCostAnalysis.fromJson(Map<String, dynamic> json) {
    return AnimalCostAnalysis(
      livestockId: int.tryParse((json['livestock_id'] ?? '0').toString()) ?? 0,
      animalTag: (json['animal_tag'] as String?) ?? '',
      feedCost: double.tryParse((json['feed_cost'] ?? '0').toString()) ?? 0.0,
      veterinaryCost:
          double.tryParse((json['veterinary_cost'] ?? '0').toString()) ?? 0.0,
      laborCost: double.tryParse((json['labor_cost'] ?? '0').toString()) ?? 0.0,
      totalCost: double.tryParse((json['total_cost'] ?? '0').toString()) ?? 0.0,
      costPerDay: double.tryParse((json['cost_per_day'] ?? '0').toString()) ?? 0.0,
      periodStart: json['period_start'] != null
          ? DateTime.tryParse(json['period_start'].toString())
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.tryParse(json['period_end'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'livestock_id': livestockId,
        'animal_tag': animalTag,
        'feed_cost': feedCost,
        'veterinary_cost': veterinaryCost,
        'labor_cost': laborCost,
        'period_start': periodStart?.toIso8601String(),
        'period_end': periodEnd?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        livestockId,
        animalTag,
        feedCost,
        veterinaryCost,
        laborCost,
        totalCost,
      ];
}

class BatchCostSummary extends Equatable {
  const BatchCostSummary({
    required this.batchId,
    required this.animalCount,
    required this.totalFeedCost,
    required this.totalVeterinaryCost,
    required this.totalLaborCost,
    required this.totalCost,
    required this.costPerAnimal,
    required this.costPerDay,
  });

  final int batchId;
  final int animalCount;
  final double totalFeedCost;
  final double totalVeterinaryCost;
  final double totalLaborCost;
  final double totalCost;
  final double costPerAnimal;
  final double costPerDay;

  factory BatchCostSummary.fromJson(Map<String, dynamic> json) {
    return BatchCostSummary(
      batchId: int.tryParse((json['batch_id'] ?? '0').toString()) ?? 0,
      animalCount: int.tryParse((json['animal_count'] ?? '0').toString()) ?? 0,
      totalFeedCost:
          double.tryParse((json['total_feed_cost'] ?? '0').toString()) ?? 0.0,
      totalVeterinaryCost: double.tryParse(
              (json['total_veterinary_cost'] ?? '0').toString()) ??
          0.0,
      totalLaborCost:
          double.tryParse((json['total_labor_cost'] ?? '0').toString()) ?? 0.0,
      totalCost: double.tryParse((json['total_cost'] ?? '0').toString()) ?? 0.0,
      costPerAnimal:
          double.tryParse((json['cost_per_animal'] ?? '0').toString()) ?? 0.0,
      costPerDay: double.tryParse((json['cost_per_day'] ?? '0').toString()) ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        batchId,
        animalCount,
        totalCost,
        costPerAnimal,
      ];
}
