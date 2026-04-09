import 'package:equatable/equatable.dart';

class WeightRecord extends Equatable {
  const WeightRecord({
    required this.id,
    required this.livestockId,
    required this.weightKg,
    required this.date,
    this.notes,
  });

  final int id;
  final int livestockId;
  final double weightKg;
  final DateTime date;
  final String? notes;

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
        id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
        livestockId: int.tryParse((json['livestock_id'] ?? '0').toString()) ?? 0,
        weightKg: double.tryParse((json['weight_kg'] ?? '0').toString()) ?? 0.0,
        date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'livestock_id': livestockId,
        'weight_kg': weightKg,
        'date': date.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [id, livestockId, weightKg, date, notes];
}
