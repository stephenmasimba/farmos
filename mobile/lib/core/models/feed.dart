import 'package:equatable/equatable.dart';

class FeedIngredient extends Equatable {
  const FeedIngredient({
    required this.id,
    required this.name,
    required this.proteinContent,
    required this.quantityKg,
    required this.costPerKg,
  });

  final int id;
  final String name;
  final double proteinContent;
  final double quantityKg;
  final double costPerKg;

  factory FeedIngredient.fromJson(Map<String, dynamic> json) {
    return FeedIngredient(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      name: (json['name'] as String?) ?? '',
      proteinContent:
          double.tryParse((json['protein_content'] ?? '0').toString()) ?? 0.0,
      quantityKg:
          double.tryParse((json['quantity_kg'] ?? '0').toString()) ?? 0.0,
      costPerKg:
          double.tryParse((json['cost_per_kg'] ?? '0').toString()) ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, name, proteinContent, quantityKg, costPerKg];
}

class FeedMillingLog extends Equatable {
  const FeedMillingLog({
    this.date,
    required this.batchName,
    required this.ingredients,
    required this.totalOutputKg,
  });

  final DateTime? date;
  final String batchName;
  final String ingredients;
  final double totalOutputKg;

  factory FeedMillingLog.fromJson(Map<String, dynamic> json) {
    return FeedMillingLog(
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      batchName: (json['batch_name'] as String?) ?? '',
      ingredients: (json['ingredients'] as String?) ?? '',
      totalOutputKg:
          double.tryParse((json['total_output_kg'] ?? '0').toString()) ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [date, batchName, ingredients, totalOutputKg];
}

class PearsonResult extends Equatable {
  const PearsonResult({
    required this.ingredient1Name,
    required this.ingredient1Qty,
    required this.ingredient2Name,
    required this.ingredient2Qty,
    required this.totalCost,
    this.notes,
  });

  final String ingredient1Name;
  final double ingredient1Qty;
  final String ingredient2Name;
  final double ingredient2Qty;
  final double totalCost;
  final String? notes;

  factory PearsonResult.fromJson(Map<String, dynamic> json) {
    final ing1 = (json['ingredient_1'] as Map<String, dynamic>?) ?? const {};
    final ing2 = (json['ingredient_2'] as Map<String, dynamic>?) ?? const {};
    return PearsonResult(
      ingredient1Name: (ing1['name'] as String?) ?? '',
      ingredient1Qty:
          double.tryParse((ing1['quantity_kg'] ?? '0').toString()) ?? 0.0,
      ingredient2Name: (ing2['name'] as String?) ?? '',
      ingredient2Qty:
          double.tryParse((ing2['quantity_kg'] ?? '0').toString()) ?? 0.0,
      totalCost: double.tryParse((json['total_cost'] ?? '0').toString()) ?? 0.0,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        ingredient1Name,
        ingredient1Qty,
        ingredient2Name,
        ingredient2Qty,
        totalCost,
        notes,
      ];
}
