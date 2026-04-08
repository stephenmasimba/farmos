import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/task.dart';

class TaskService {
  const TaskService(this._api);
  final ApiClient _api;

  Future<List<Task>> getAll({
    int page = 1,
    int perPage = 20,
    String? status,
    String? priority,
  }) async {
    final list = await _api.getList(ApiEndpoints.tasks, params: {
      'page': page,
      'per_page': perPage,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
    });
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Task> getById(int id) async {
    final data = await _api.get(ApiEndpoints.taskById(id));
    return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
  }

  Future<Task> create(Map<String, dynamic> body) async {
    final data = await _api.post(ApiEndpoints.tasks, data: body);
    return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
  }

  Future<Task> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put(ApiEndpoints.taskById(id), data: body);
    return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
  }

  Future<void> delete(int id) => _api.delete(ApiEndpoints.taskById(id));

  Future<Task> complete(int id) async {
    final data = await _api.post(ApiEndpoints.taskComplete(id));
    return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
  }

  Future<Task> assign(int id, int userId) async {
    final data = await _api.post(ApiEndpoints.taskAssign(id),
        data: {'user_id': userId});
    return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
  }

  Future<TaskStats> getStats() async {
    final data = await _api.get(ApiEndpoints.taskStats);
    return TaskStats.fromJson(data);
  }
}
