import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/timesheet.dart';

class TimesheetsService {
  const TimesheetsService(this._api);

  final ApiClient _api;

  Future<List<Timesheet>> list() async {
    final list = await _api.getList(ApiEndpoints.timesheets);
    return list
        .map((e) => Timesheet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TimesheetStats> stats() async {
    final data = await _api.get(ApiEndpoints.timesheetsStats);
    return TimesheetStats.fromJson(data);
  }

  Future<void> logHours({
    required DateTime date,
    required double hoursWorked,
    required String taskDescription,
  }) async {
    await _api.post(ApiEndpoints.timesheetsLog, data: {
      'date': _formatDate(date),
      'hours_worked': hoursWorked,
      'task_description': taskDescription,
    });
  }

  Future<void> updateStatus({
    required int timesheetId,
    required String status,
  }) async {
    await _api.put(ApiEndpoints.timesheetStatus(timesheetId), data: {
      'status': status,
    });
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
