import 'package:equatable/equatable.dart';

class Farm extends Equatable {
  const Farm({
    required this.id,
    required this.name,
    required this.ownerId,
    this.location,
    this.totalAreaHa,
    this.description,
    this.createdAt,
  });

  final int id;
  final String name;
  final int ownerId;
  final String? location;
  final double? totalAreaHa;
  final String? description;
  final DateTime? createdAt;

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      name: (json['name'] as String?) ?? '',
      ownerId: int.tryParse((json['owner_id'] ?? '0').toString()) ?? 0,
      location: json['location'] as String?,
      totalAreaHa: double.tryParse((json['total_area_ha'] ?? '0').toString()),
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        if (totalAreaHa != null) 'total_area_ha': totalAreaHa,
        'description': description,
      };

  @override
  List<Object?> get props => [id, name, ownerId];
}
