import 'package:equatable/equatable.dart';

class WeatherAlert extends Equatable {
  const WeatherAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.issuedAt,
    this.expiresAt,
    this.location,
    this.acknowledged,
  });

  final int id;
  final String type; // frost, heavy_rain, high_wind, heat_wave, drought
  final String message;
  final String severity; // info, warning, critical
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final String? location;
  final bool? acknowledged;

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    final rawAck = json['acknowledged'];
    final boolAck = rawAck is bool
        ? rawAck
        : (rawAck is num ? rawAck != 0 : (rawAck?.toString().toLowerCase() == 'true'));

    return WeatherAlert(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      type: (json['type'] as String?) ?? 'info',
      message: (json['message'] as String?) ?? '',
      severity: (json['severity'] as String?) ?? 'info',
      issuedAt: DateTime.tryParse(json['issued_at'].toString()) ?? DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      location: json['location'] as String?,
      acknowledged: rawAck == null ? null : boolAck,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'severity': severity,
      };

  @override
  List<Object?> get props => [id, type, severity, issuedAt];
}
