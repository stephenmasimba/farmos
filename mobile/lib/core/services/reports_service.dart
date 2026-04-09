import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/reports.dart';

class ReportsService {
  const ReportsService(this._api);

  final ApiClient _api;

  Future<List<String>> getTypes() async {
    try {
      final list = await _api.getList(ApiEndpoints.reportTypes);
      return list.map((e) => e.toString()).toList();
    } on ApiException catch (e) {
      if (e.isNotFound) {
        return const ['Financial'];
      }
      rethrow;
    }
  }

  Future<ReportDownloadLink> generate({
    required String type,
    String format = 'csv',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final data = await _api.post(ApiEndpoints.reportGenerate, data: {
        'type': type,
        'format': format,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      });
      return ReportDownloadLink.fromJson(data);
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw const ApiException(
          message:
              'Report download endpoint is not enabled on this backend yet.',
          statusCode: 404,
        );
      }
      rethrow;
    }
  }
}
