import 'package:equatable/equatable.dart';

class IoTDevice extends Equatable {
  const IoTDevice({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.status,
    this.location,
    this.lastSeen,
    this.registeredAt,
  });

  final int id;
  final String name;
  final String deviceType;
  final String status; // online | offline | error
  final String? location;
  final DateTime? lastSeen;
  final DateTime? registeredAt;

  factory IoTDevice.fromJson(Map<String, dynamic> j) => IoTDevice(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        deviceType: j['device_type'] as String? ?? '',
        status: j['status'] as String? ?? 'offline',
        location: j['location'] as String?,
        lastSeen: _parseDate(j['last_seen']),
        registeredAt: _parseDate(j['registered_at']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'device_type': deviceType,
        'status': status,
        if (location != null) 'location': location,
      };

  @override
  List<Object?> get props => [id, name, status];
}

class SensorReading extends Equatable {
  const SensorReading({
    required this.id,
    required this.sensorType,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.location,
    this.deviceId,
  });

  final int id;
  final String sensorType;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String? location;
  final int? deviceId;

  factory SensorReading.fromJson(Map<String, dynamic> j) => SensorReading(
        id: j['id'] as int,
        sensorType: j['sensor_type'] as String? ?? '',
        value: _parseDouble(j['value']),
        unit: j['unit'] as String? ?? '',
        timestamp: _parseDate(j['timestamp']) ?? DateTime.now(),
        location: j['location'] as String?,
        deviceId: j['device_id'] as int?,
      );

  @override
  List<Object?> get props => [id, sensorType, value, timestamp];
}

class IoTAlert extends Equatable {
  const IoTAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.deviceId,
    this.acknowledged,
  });

  final int id;
  final String type;
  final String message;
  final String severity; // low | medium | high | critical
  final DateTime timestamp;
  final int? deviceId;
  final bool? acknowledged;

  factory IoTAlert.fromJson(Map<String, dynamic> j) => IoTAlert(
        id: j['id'] as int,
        type: j['type'] as String? ?? '',
        message: j['message'] as String? ?? '',
        severity: j['severity'] as String? ?? 'low',
        timestamp: _parseDate(j['timestamp']) ?? DateTime.now(),
        deviceId: j['device_id'] as int?,
        acknowledged: j['acknowledged'] as bool?,
      );

  @override
  List<Object?> get props => [id, type, severity];
}

double _parseDouble(dynamic v) =>
    v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

DateTime? _parseDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

// ---- Water Quality ----

class WaterQualityLog extends Equatable {
  const WaterQualityLog({
      required this.date,
      required this.source,
      required this.ph,
      required this.dissolvedOxygen,
      required this.turbidity,
      this.notes,
    });

    final String date;
    final String source;
    final double ph;
    final double dissolvedOxygen;
    final double turbidity;
    final String? notes;

    factory WaterQualityLog.fromJson(Map<String, dynamic> j) => WaterQualityLog(
          date: j['date'] as String? ?? '',
          source: j['source'] as String? ?? '',
          ph: _parseDouble(j['ph']),
          dissolvedOxygen: _parseDouble(j['dissolved_oxygen']),
          turbidity: _parseDouble(j['turbidity']),
          notes: j['notes'] as String?,
        );

    Map<String, dynamic> toJson() => {
          'date': date,
          'source': source,
          'ph': ph,
          'dissolved_oxygen': dissolvedOxygen,
          'turbidity': turbidity,
          if (notes != null) 'notes': notes,
        };

    @override
    List<Object?> get props => [date, source, ph];
  }
