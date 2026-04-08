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

double _parseDoubleNn(dynamic v) =>
    v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

int _parseInt(dynamic v) =>
    v == null ? 0 : int.tryParse(v.toString()) ?? 0;

// ---- Weather Stats ----

class WeatherStats extends Equatable {
  const WeatherStats({
      required this.startDate,
      required this.endDate,
      required this.observations,
      required this.avgTemperature,
      required this.minTemperature,
      required this.maxTemperature,
      required this.avgHumidity,
      required this.totalPrecipitation,
      required this.rainyDays,
      required this.frostRiskDays,
    });

    final String startDate;
    final String endDate;
    final int observations;
    final double avgTemperature;
    final double minTemperature;
    final double maxTemperature;
    final double avgHumidity;
    final double totalPrecipitation;
    final int rainyDays;
    final int frostRiskDays;

    factory WeatherStats.fromJson(Map<String, dynamic> j) {
      final period = j['period'] as Map<String, dynamic>? ?? {};
      final stats = j['statistics'] as Map<String, dynamic>? ?? {};
      final temp = stats['temperature'] as Map<String, dynamic>? ?? {};
      final hum = stats['humidity'] as Map<String, dynamic>? ?? {};
      final precip = stats['precipitation'] as Map<String, dynamic>? ?? {};
      final events = j['weather_events'] as Map<String, dynamic>? ?? {};
      return WeatherStats(
        startDate: period['start'] as String? ?? '',
        endDate: period['end'] as String? ?? '',
        observations: _parseInt(stats['observations']),
        avgTemperature: _parseDoubleNn(temp['average']),
        minTemperature: _parseDoubleNn(temp['minimum']),
        maxTemperature: _parseDoubleNn(temp['maximum']),
        avgHumidity: _parseDoubleNn(hum['average']),
        totalPrecipitation: _parseDoubleNn(precip['total']),
        rainyDays: _parseInt(events['rainy_days']),
        frostRiskDays: _parseInt(events['frost_risk_days']),
      );
    }

    @override
    List<Object?> get props => [startDate, endDate, observations];
  }

  // ---- Weather Forecast ----

  class WeatherForecastDay extends Equatable {
    const WeatherForecastDay({
      required this.date,
      required this.temperatureHigh,
      required this.temperatureLow,
      required this.humidity,
      required this.windSpeed,
      required this.precipitationChance,
      required this.condition,
    });

    final String date;
    final double temperatureHigh;
    final double temperatureLow;
    final double humidity;
    final double windSpeed;
    final int precipitationChance;
    final String condition;

    factory WeatherForecastDay.fromJson(Map<String, dynamic> j) =>
        WeatherForecastDay(
          date: j['date'] as String? ?? '',
          temperatureHigh: _parseDoubleNn(j['temperature_high']),
          temperatureLow: _parseDoubleNn(j['temperature_low']),
          humidity: _parseDoubleNn(j['humidity']),
          windSpeed: _parseDoubleNn(j['wind_speed']),
          precipitationChance: _parseInt(j['precipitation_chance']),
          condition: j['condition'] as String? ?? 'unknown',
        );

    @override
    List<Object?> get props => [date];
  }
