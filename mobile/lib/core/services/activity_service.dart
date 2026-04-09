import '../api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_endpoints.dart';
import '../models/task_comment.dart';
import 'sync_service.dart';
import 'cache_status_service.dart';

class ActivityService {
  ActivityService(this._client, this._sync, this._cache);

  final ApiClient _client;
  final SyncService _sync;
  final StateNotifierProvider<CacheStatusService, Map<String, CacheStatusRecord>> _cache;

  static const commentsKey = 'activity_service_comments';

  Future<List<TaskComment>> getTaskComments(int taskId) async {
    final data = await _client.getList(
      '/api/tasks/$taskId/comments',
      params: {'perPage': 50},
    );
    return data.map((e) => TaskComment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskComment> addComment(int taskId, String content) {
    return _sync.enqueue(
      label: 'Add comment to task',
      operation: () async {
        final result = await _client.post(
          '/api/tasks/$taskId/comments',
          data: {'content': content},
        );
        return TaskComment.fromJson(result);
      },
    );
  }

  Future<TaskComment> updateComment(int commentId, String content) {
    return _sync.enqueue(
      label: 'Update comment',
      operation: () async {
        final result = await _client.put(
          '/api/comments/$commentId',
          data: {'content': content},
        );
        return TaskComment.fromJson(result);
      },
    );
  }

  Future<void> deleteComment(int commentId) {
    return _sync.enqueue(
      label: 'Delete comment',
      operation: () => _client.delete('/api/comments/$commentId'),
    );
  }
}

