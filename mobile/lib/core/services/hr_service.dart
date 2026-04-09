import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/hr.dart';

class HrService {
  const HrService(this._api);

  final ApiClient _api;

  Future<List<HrSop>> listSops() async {
    final list = await _api.getList(ApiEndpoints.hrSops);
    return list.map((e) => HrSop.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createSop({
    required String title,
    required String role,
    required String content,
  }) async {
    await _api.post(ApiEndpoints.hrSops, data: {
      'title': title,
      'role': role,
      'content': content,
    });
  }

  Future<List<HrTask>> listTasks() async {
    final list = await _api.getList(ApiEndpoints.hrTasks);
    return list.map((e) => HrTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createTask({
    required String title,
    required DateTime dueDate,
    int? assignedTo,
  }) async {
    await _api.post(ApiEndpoints.hrTasks, data: {
      'title': title,
      'due_date': _formatDate(dueDate),
      if (assignedTo != null) 'assigned_to': assignedTo,
    });
  }

  Future<List<HrSchedule>> listSchedules() async {
    final list = await _api.getList(ApiEndpoints.hrSchedules);
    return list
        .map((e) => HrSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createSchedule({
    required int userId,
    required String role,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await _api.post(ApiEndpoints.hrSchedules, data: {
      'user_id': userId,
      'role': role,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    });
  }

  Future<List<HrSopExecution>> listExecutions() async {
    final list = await _api.getList(ApiEndpoints.hrSopExecutions);
    return list
        .map((e) => HrSopExecution.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> runSop({
    required int sopId,
    required String status,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.hrSopRun, data: {
      'sop_id': sopId,
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
