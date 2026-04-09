import 'package:equatable/equatable.dart';
import 'dart:math';

class GeoPoint extends Equatable {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: double.tryParse((json['latitude'] ?? '0').toString()) ?? 0.0,
      longitude: double.tryParse((json['longitude'] ?? '0').toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  List<Object?> get props => [latitude, longitude];
}

class FieldBoundary extends Equatable {
  const FieldBoundary({
    required this.fieldId,
    required this.boundaryPoints,
  });

  final int fieldId;
  final List<GeoPoint> boundaryPoints;

  double calculateAreaHa() {
    if (boundaryPoints.length < 3) return 0.0;
    return _polygonArea(boundaryPoints) / 10000;
  }

  static double _polygonArea(List<GeoPoint> points) {
    double area = 0.0;
    const p = 0.017453292519943295;
    late double x1;
    late double x2;
    late double y1;
    late double y2;

    for (int i = 0; i < points.length - 1; i++) {
      x1 = points[i].longitude * p;
      y1 = points[i].latitude * p;
      x2 = points[i + 1].longitude * p;
      y2 = points[i + 1].latitude * p;
      area += ((x2 - x1) * (2 + sin(y1) + sin(y2)));
    }

    return abs(area * 6378137.0 * 6378137.0 / 2.0);
  }

  factory FieldBoundary.fromJson(Map<String, dynamic> json) {
    final points = (json['boundary_points'] as List<dynamic>?)
            ?.map((p) => GeoPoint.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];
    return FieldBoundary(
      fieldId: int.tryParse((json['field_id'] ?? '0').toString()) ?? 0,
      boundaryPoints: points,
    );
  }

  Map<String, dynamic> toJson() => {
        'field_id': fieldId,
        'boundary_points': boundaryPoints.map((p) => p.toJson()).toList(),
      };

  @override
  List<Object?> get props => [fieldId, boundaryPoints];
}

