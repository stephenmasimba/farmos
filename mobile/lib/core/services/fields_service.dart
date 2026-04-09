import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/field.dart';

class FieldsService {
  const FieldsService(this._api);

  final ApiClient _api;

  Future<List<Field>> list() async {
    final list = await _api.getList(ApiEndpoints.fields);
    return list.map((e) => Field.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> create({
    required String name,
    required double area,
    String crop = '',
    String status = 'Active',
    String notes = '',
  }) async {
    await _api.post(ApiEndpoints.fields, data: {
      'name': name,
      'area': area,
      'crop': crop,
      'status': status,
      'notes': notes,
    });
  }
}
