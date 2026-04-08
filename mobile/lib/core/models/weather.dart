import 'package:equatable/equatable.dart';

class WeatherLog extends Equatable {
  const WeatherLog({
    required this.id,
    required this.logDate,
    this.temperatureC,
    this.humidityPercent,
    this.rainfallMm,
    this.windSpeedKph,
    this.conditions,
    this.notes,
    this.recordedBy,
  });

  final int id;
  final DateTime logDate;
  final double? temperatureC;
  final double? humidityPercent;
  final double? rainfallMm;
  final double? windSpeedKph;
  final String? conditions;
  final String? notes;
  final String? recordedBy;

  factory WeatherLog.fromJson(Map<String, dynamic> j) => WeatherLog(
        id: j['id'] as int,
        logDate: _parseDate(j['log_date']) ?? DateTime.now(),
        temperatureC: _parseDouble(j['temperature_c']),
        humidityPercent: _parseDouble(j['humidity_percent']),
        rainfallMm: _parseDouble(j['rainfall_mm']),
        windSpeedKph: _parseDouble(j['wind_speed_kph']),
        conditions: j['conditions'] as String?,
        notes: j['notes'] as String?,
        recordedBy: j['recorded_by'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'log_date': logDate.toIso8601String(),
        if (temperatureC != null) 'temperature_c': temperatureC,
        if (humidityPercent != null) 'humidity_percent': humidityPercent,
        if (rainfallMm != null) 'rainfall_mm': rainfallMm,
        if (windSpeedKph != null) 'wind_speed_kph': windSpeedKph,
        if (conditions != null) 'conditions': conditions,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [id, logDate];
}

class CurrentWeather extends Equatable {
  const CurrentWeather({
    required this.temperatureC,
    required this.humidityPercent,
    required this.conditions,
    this.rainfallMm,
    this.windSpeedKph,
    this.forecastedAt,
  });

  final double temperatureC;
  final double humidityPercent;
  final String conditions;
  final double? rainfallMm;
  final double? windSpeedKph;
  final DateTime? forecastedAt;

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
        temperatureC: _parseDouble(j['temperature_c'] ?? j['temperature']),
        humidityPercent: _parseDouble(j['humidity_percent'] ?? j['humidity']),
        conditions: j['conditions'] as String? ?? 'Unknown',
        rainfallMm: _parseDouble(j['rainfall_mm'] ?? j['rainfall']),
        windSpeedKph: _parseDouble(j['wind_speed_kph'] ?? j['wind_speed']),
        forecastedAt: _parseDate(j['recorded_at'] ?? j['forecasted_at']),
      );

  @override
  List<Object?> get props => [temperatureC, humidityPercent, conditions];
}

double? _parseDouble(dynamic v) =>
    v == null ? null : double.tryParse(v.toString());

DateTime? _parseDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
