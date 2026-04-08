import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/iot.dart';

class IoTService {
  const IoTService(this._api);
  final ApiClient _api;

  Future<List<IoTDevice>> getDevices() async {
    final list = await _api.getList(ApiEndpoints.iotDevices);
    return list
        .map((e) => IoTDevice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<IoTDevice> registerDevice(Map<String, dynamic> body) async {
    final data = await _api.post(ApiEndpoints.iotDevices, data: body);
    return IoTDevice.fromJson(data['device'] as Map<String, dynamic>? ?? data);
  }

  Future<List<SensorReading>> getLatestReadings() async {
    final list = await _api.getList(ApiEndpoints.iotSensorsLatest);
    return list
        .map((e) => SensorReading.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<IoTAlert>> getAlerts() async {
    final list = await _api.getList(ApiEndpoints.iotAlerts);
    return list
        .map((e) => IoTAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> ingestReading(Map<String, dynamic> body) =>
      _api.post(ApiEndpoints.iotSensors, data: body);
}
