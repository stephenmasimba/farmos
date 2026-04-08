import 'package:equatable/equatable.dart';

class Field extends Equatable {
  const Field({
    required this.id,
    required this.name,
    required this.status,
    this.areaSizeHa,
    this.locationCoordinates,
    this.currentCrop,
    this.plantingDate,
    this.expectedHarvestDate,
    this.soilType,
  });

  final int id;
  final String name;
  final String status; // fallow | planted | harvested | prepared
  final double? areaSizeHa;
  final String? locationCoordinates;
  final String? currentCrop;
  final DateTime? plantingDate;
  final DateTime? expectedHarvestDate;
  final String? soilType;

  factory Field.fromJson(Map<String, dynamic> j) => Field(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        status: j['status'] as String? ?? 'fallow',
        areaSizeHa: _parseDouble(j['area_size']),
        locationCoordinates: j['location_coordinates'] as String?,
        currentCrop: j['current_crop'] as String?,
        plantingDate: _parseDate(j['planting_date']),
        expectedHarvestDate: _parseDate(j['expected_harvest_date']),
        soilType: j['soil_type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status,
        if (areaSizeHa != null) 'area_size': areaSizeHa,
        if (locationCoordinates != null)
          'location_coordinates': locationCoordinates,
        if (currentCrop != null) 'current_crop': currentCrop,
        if (plantingDate != null) 'planting_date': plantingDate!.toIso8601String(),
        if (soilType != null) 'soil_type': soilType,
      };

  @override
  List<Object?> get props => [id, name, status];
}

double? _parseDouble(dynamic v) =>
    v == null ? null : double.tryParse(v.toString());

DateTime? _parseDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
