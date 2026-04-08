import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/reports.dart';

class ReportsService {
  const ReportsService(this._api);

  final ApiClient _api;

  Future<List<String>> getTypes() async {
    final list = await _api.getList(ApiEndpoints.reportTypes);
    return list.map((e) => e.toString()).toList();
  }

  Future<ReportDownloadLink> generate({
    required String type,
    String format = 'csv',
    String? startDate,
    String? endDate,
  }) async {
    final data = await _api.post(ApiEndpoints.reportGenerate, data: {
      'type': type,
      'format': format,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
    return ReportDownloadLink.fromJson(data);
  }
}
