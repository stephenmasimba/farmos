import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/weather.dart';

class WeatherService {
  const WeatherService(this._api);
  final ApiClient _api;

  Future<CurrentWeather> getCurrent() async {
    final data = await _api.get(ApiEndpoints.weatherCurrent);
    return CurrentWeather.fromJson(
        data['weather'] as Map<String, dynamic>? ?? data);
  }

  Future<List<WeatherLog>> getHistory({int? limit}) async {
    final list = await _api.getList(ApiEndpoints.weatherHistory,
        params: {if (limit != null) 'limit': limit});
    return list
        .map((e) => WeatherLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherLog> addObservation(Map<String, dynamic> body) async {
    final data = await _api.post(ApiEndpoints.weatherObservation, data: body);
    return WeatherLog.fromJson(
        data['observation'] as Map<String, dynamic>? ?? data);
  }
}
