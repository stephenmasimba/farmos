import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/task.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class TaskService {
  const TaskService(this._api, this._sync, this._cacheStatus);
  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const listStatusKey = 'tasks:list';
  static const statsStatusKey = 'tasks:stats';

  String _listCacheKey(String? status, String? priority) =>
      'tasks_list_${status ?? 'all'}_${priority ?? 'all'}';
  String _detailCacheKey(int id) => 'task_detail_$id';
  String _statsCacheKey() => 'task_stats';

  Future<List<Task>> getAll({
    int page = 1,
    int perPage = 20,
    String? status,
    String? priority,
  }) async {
    try {
      final list = await _api.getList(ApiEndpoints.tasks, params: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
      });
      await _sync.cache(_listCacheKey(status, priority), {'items': list});
      _cacheStatus.markFresh(listStatusKey);
      final base = list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
      return _applyQueuedChanges(base, status: status, priority: priority);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_listCacheKey(status, priority));
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          listStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        final base = items.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
        return _applyQueuedChanges(base, status: status, priority: priority);
      }
      rethrow;
    }
  }

  Future<Task> getById(int id) async {
    try {
      final data = await _api.get(ApiEndpoints.taskById(id));
      final payload = data['task'] as Map<String, dynamic>? ?? data;
      await _sync.cache(_detailCacheKey(id), payload);
      return Task.fromJson(payload);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCache(_detailCacheKey(id));
      if (cached != null) return Task.fromJson(cached);
      rethrow;
    }
  }

  Future<Task> create(Map<String, dynamic> body) async {
    try {
      final data = await _api.post(ApiEndpoints.tasks, data: body);
      return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(method: 'POST', path: ApiEndpoints.tasks, body: body);
      return _optimisticTask(body);
    }
  }

  Future<Task> update(int id, Map<String, dynamic> body) async {
    try {
      final data = await _api.put(ApiEndpoints.taskById(id), data: body);
      return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'PUT',
        path: ApiEndpoints.taskById(id),
        body: body,
      );
      return _optimisticTask(body, fallbackId: id);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.delete(ApiEndpoints.taskById(id));
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(method: 'DELETE', path: ApiEndpoints.taskById(id));
    }
  }

  Future<Task> complete(int id) async {
    try {
      final data = await _api.post(ApiEndpoints.taskComplete(id));
      return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(method: 'POST', path: ApiEndpoints.taskComplete(id));
      return Task(
        id: id,
        title: 'Pending completion sync',
        status: 'completed',
        priority: 'medium',
      );
    }
  }

  Future<Task> assign(int id, int userId) async {
    try {
      final data = await _api.post(ApiEndpoints.taskAssign(id),
          data: {'user_id': userId});
      return Task.fromJson(data['task'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.taskAssign(id),
        body: {'user_id': userId},
      );
      return Task(
        id: id,
        title: 'Pending assignment sync',
        status: 'pending',
        priority: 'medium',
        assignedTo: userId,
      );
    }
  }

  Future<TaskStats> getStats() async {
    try {
      final data = await _api.get(ApiEndpoints.taskStats);
      await _sync.cache(_statsCacheKey(), data);
      _cacheStatus.markFresh(statsStatusKey);
      return TaskStats.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_statsCacheKey());
      if (cached != null) {
        _cacheStatus.markOffline(
          statsStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return TaskStats.fromJson(cached.payload);
      }
      rethrow;
    }
  }

  bool _shouldQueue(ApiException e) => e.statusCode == null;

  Future<List<Task>> _applyQueuedChanges(
    List<Task> base, {
    String? status,
    String? priority,
  }) async {
    final queue = await _sync.getPendingItemsByPathPrefix(ApiEndpoints.tasks);
    var list = List<Task>.from(base);

    for (final item in queue) {
      final body = item.body;
      final id = _extractId(item.path);

      if (item.method == 'POST' && item.path == ApiEndpoints.tasks && body != null) {
        list.insert(0, _optimisticTask(body, localId: -item.id));
        continue;
      }

      if (item.method == 'PUT' && id != null && body != null) {
        final index = list.indexWhere((entry) => entry.id == id);
        final optimistic = _optimisticTask(body, fallbackId: id);
        if (index >= 0) {
          list[index] = optimistic;
        } else {
          list.insert(0, optimistic);
        }
        continue;
      }

      if (item.method == 'POST' && item.path.endsWith('/complete') && id != null) {
        final index = list.indexWhere((entry) => entry.id == id);
        if (index >= 0) {
          final current = list[index];
          list[index] = Task(
            id: current.id,
            title: current.title,
            status: 'completed',
            priority: current.priority,
            description: current.description,
            assignedTo: current.assignedTo,
            assigneeName: current.assigneeName,
            dueDate: current.dueDate,
            createdBy: current.createdBy,
            createdAt: current.createdAt,
          );
        }
        continue;
      }

      if (item.method == 'POST' && item.path.endsWith('/assign') && id != null && body != null) {
        final index = list.indexWhere((entry) => entry.id == id);
        if (index >= 0) {
          final current = list[index];
          list[index] = Task(
            id: current.id,
            title: current.title,
            status: current.status,
            priority: current.priority,
            description: current.description,
            assignedTo: body['user_id'] as int? ?? current.assignedTo,
            assigneeName: current.assigneeName,
            dueDate: current.dueDate,
            createdBy: current.createdBy,
            createdAt: current.createdAt,
          );
        }
        continue;
      }

      if (item.method == 'DELETE' && id != null) {
        list.removeWhere((entry) => entry.id == id);
      }
    }

    return list.where((entry) {
      if (status != null && entry.status != status) return false;
      if (priority != null && entry.priority != priority) return false;
      return true;
    }).toList();
  }

  int? _extractId(String path) {
    final match = RegExp(r'^/api/tasks/(\d+)').firstMatch(path);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  Task _optimisticTask(
    Map<String, dynamic> body, {
    int? fallbackId,
    int? localId,
  }) {
    DateTime? toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return Task(
      id: fallbackId ?? localId ?? -DateTime.now().millisecondsSinceEpoch,
      title: (body['title'] as String?) ?? 'Pending Task',
      status: (body['status'] as String?) ?? 'pending',
      priority: (body['priority'] as String?) ?? 'medium',
      description: body['description'] as String?,
      assignedTo: body['assigned_to'] as int?,
      dueDate: toDate(body['due_date']),
    );
  }
}
