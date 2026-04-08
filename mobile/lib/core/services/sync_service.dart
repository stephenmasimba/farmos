import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../api/api_client.dart';
import 'local_db_service.dart';

enum SyncNoticeType { queued, synced, failed }

class SyncNotice {
  const SyncNotice({
    required this.type,
    required this.message,
    this.path,
  });

  final SyncNoticeType type;
  final String message;
  final String? path;
}

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.method,
    required this.path,
    required this.createdAt,
    required this.status,
    required this.retryCount,
    this.lastAttemptAt,
    this.body,
    this.lastError,
  });

  final int id;
  final String method;
  final String path;
  final DateTime createdAt;
  final String status;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final Map<String, dynamic>? body;
  final String? lastError;
}

class CachedPayload {
  const CachedPayload({
    required this.payload,
    this.updatedAt,
  });

  final Map<String, dynamic> payload;
  final DateTime? updatedAt;
}

class CacheDiagnosticItem {
  const CacheDiagnosticItem({
    required this.key,
    required this.module,
    required this.label,
    required this.updatedAt,
    required this.payloadBytes,
  });

  final String key;
  final String module;
  final String label;
  final DateTime updatedAt;
  final int payloadBytes;

  bool get isStale => DateTime.now().difference(updatedAt).inHours >= 24;
}

class SyncService {
  SyncService(this._api);

  final ApiClient _api;
  static final StreamController<SyncNotice> _noticesController =
      StreamController<SyncNotice>.broadcast();

  static Stream<SyncNotice> get notices => _noticesController.stream;

  void _emit(SyncNotice notice) {
    if (!_noticesController.isClosed) {
      _noticesController.add(notice);
    }
  }

  Future<void> enqueue({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final db = await LocalDbService.instance();
    await db.insert('sync_queue', {
      'method': method.toUpperCase(),
      'path': path,
      'body': body == null ? null : jsonEncode(body),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
      'retry_count': 0,
      'last_error': null,
      'last_attempt_at': null,
    });
    _emit(SyncNotice(
      type: SyncNoticeType.queued,
      message: 'Saved offline. Will sync automatically.',
      path: path,
    ));
  }

  Future<void> syncPending() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn.contains(ConnectivityResult.none)) return;

    final db = await LocalDbService.instance();
    final rows = await db.query('sync_queue', orderBy: 'id ASC', limit: 50);

    for (final row in rows) {
      final item = _mapRowToItem(row);
      if (!_shouldAttemptAuto(item)) continue;

      final id = item.id;
      final method = item.method;
      final path = item.path;
      final body = item.body;

      try {
        await _executeMethod(method: method, path: path, body: body);

        await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
      } on ApiException catch (e) {
        await _markFailed(id: id, error: e.message, statusCode: e.statusCode);
      } catch (e) {
        await _markFailed(id: id, error: e.toString(), statusCode: null);
      }
    }
  }

  Future<int> getPendingCount() async {
    final db = await LocalDbService.instance();
    final row = await db.rawQuery('SELECT COUNT(*) AS cnt FROM sync_queue');
    return (row.first['cnt'] as int?) ?? 0;
  }

  Future<List<SyncQueueItem>> getPendingItems({int limit = 200}) async {
    final db = await LocalDbService.instance();
    final rows = await db.query(
      'sync_queue',
      orderBy: 'CASE status WHEN "conflict" THEN 0 WHEN "failed" THEN 1 ELSE 2 END, id ASC',
      limit: limit,
    );
    return rows.map(_mapRowToItem).toList();
  }

  Future<List<SyncQueueItem>> getPendingItemsByPathPrefix(
    String pathPrefix, {
    int limit = 400,
  }) async {
    final items = await getPendingItems(limit: limit);
    return items.where((item) => item.path.startsWith(pathPrefix)).toList();
  }

  Future<void> removePendingItem(int id) async {
    final db = await LocalDbService.instance();
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearPendingQueue() async {
    final db = await LocalDbService.instance();
    await db.delete('sync_queue');
  }

  Future<void> updatePendingItemBody(
    int id,
    Map<String, dynamic>? body, {
    bool resetStatus = true,
  }) async {
    final db = await LocalDbService.instance();
    await db.update(
      'sync_queue',
      {
        'body': body == null ? null : jsonEncode(body),
        if (resetStatus) 'status': 'pending',
        if (resetStatus) 'last_error': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> retryPendingItem(int id) async {
    final db = await LocalDbService.instance();
    final rows = await db.query('sync_queue', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return true;

    final item = _mapRowToItem(rows.first);
    try {
      await _executeItem(item);
      await removePendingItem(id);
      _emit(const SyncNotice(
        type: SyncNoticeType.synced,
        message: 'Queued change synced successfully.',
      ));
      return true;
    } on ApiException catch (e) {
      await _markFailed(id: id, error: e.message, statusCode: e.statusCode);
      _emit(SyncNotice(
        type: SyncNoticeType.failed,
        message: 'Sync failed. Item remains in queue.',
        path: item.path,
      ));
      return false;
    } catch (e) {
      await _markFailed(id: id, error: e.toString(), statusCode: null);
      return false;
    }
  }

  Future<bool> retryAllPending({int limit = 200}) async {
    final items = await getPendingItems(limit: limit);
    if (items.isEmpty) return true;

    var allOk = true;
    for (final item in items) {
      try {
        await _executeItem(item);
        await removePendingItem(item.id);
      } on ApiException catch (e) {
        await _markFailed(id: item.id, error: e.message, statusCode: e.statusCode);
        allOk = false;
      } catch (e) {
        await _markFailed(id: item.id, error: e.toString(), statusCode: null);
        allOk = false;
      }
    }

    _emit(SyncNotice(
      type: allOk ? SyncNoticeType.synced : SyncNoticeType.failed,
      message: allOk
          ? 'Pending offline changes synced.'
          : 'Some queued items need manual review.',
    ));
    return allOk;
  }

  Future<void> cache(String key, Map<String, dynamic> payload) async {
    final db = await LocalDbService.instance();
    await db.insert(
      'api_cache',
      {
        'key': key,
        'payload': jsonEncode(payload),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> readCache(String key) async {
    final entry = await readCacheEntry(key);
    return entry?.payload;
  }

  Future<List<CacheDiagnosticItem>> getCacheDiagnostics({int limit = 200}) async {
    final db = await LocalDbService.instance();
    final rows = await db.query(
      'api_cache',
      orderBy: 'updated_at DESC',
      limit: limit,
    );

    return rows.map((row) {
      final key = row['key'] as String? ?? 'unknown';
      final payload = row['payload'] as String? ?? '';
      final updatedRaw = row['updated_at'];
      final updatedMs = updatedRaw is int
          ? updatedRaw
          : updatedRaw is num
              ? updatedRaw.toInt()
              : DateTime.now().millisecondsSinceEpoch;

      return CacheDiagnosticItem(
        key: key,
        module: _moduleFromCacheKey(key),
        label: _labelFromCacheKey(key),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedMs),
        payloadBytes: utf8.encode(payload).length,
      );
    }).toList();
  }

  Future<void> clearCache({String? key}) async {
    final db = await LocalDbService.instance();
    if (key == null) {
      await db.delete('api_cache');
      return;
    }
    await db.delete('api_cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<int> clearStaleCache({Duration maxAge = const Duration(hours: 24)}) async {
    final db = await LocalDbService.instance();
    final cutoff = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;
    return db.delete(
      'api_cache',
      where: 'updated_at < ?',
      whereArgs: [cutoff],
    );
  }

  Future<CachedPayload?> readCacheEntry(String key) async {
    final db = await LocalDbService.instance();
    final rows = await db.query('api_cache', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    final updatedRaw = rows.first['updated_at'];
    final updatedMs = updatedRaw is int
        ? updatedRaw
        : updatedRaw is num
            ? updatedRaw.toInt()
            : null;
    return CachedPayload(
      payload: jsonDecode(rows.first['payload'] as String)
          as Map<String, dynamic>,
      updatedAt: updatedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(updatedMs),
    );
  }

  SyncQueueItem _mapRowToItem(Map<String, dynamic> row) {
    final lastAttemptMs = row['last_attempt_at'] as int?;
    return SyncQueueItem(
      id: row['id'] as int,
      method: (row['method'] as String?)?.toUpperCase() ?? 'POST',
      path: row['path'] as String? ?? '',
      body: row['body'] == null
          ? null
          : jsonDecode(row['body'] as String) as Map<String, dynamic>,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (row['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      status: (row['status'] as String?) ?? 'pending',
      retryCount: (row['retry_count'] as int?) ?? 0,
      lastAttemptAt: lastAttemptMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastAttemptMs),
      lastError: row['last_error'] as String?,
    );
  }

  Future<void> _executeItem(SyncQueueItem item) async {
    await _executeMethod(method: item.method, path: item.path, body: item.body);
  }

  Future<void> _executeMethod({
    required String method,
    required String path,
    required Map<String, dynamic>? body,
  }) async {
    switch (method) {
      case 'POST':
        await _api.post(path, data: body);
        break;
      case 'PUT':
        await _api.put(path, data: body);
        break;
      case 'DELETE':
        await _api.delete(path);
        break;
      default:
        throw const ApiException(message: 'Unsupported queued method');
    }
  }

  Future<void> _markFailed({
    required int id,
    required String error,
    required int? statusCode,
  }) async {
    final db = await LocalDbService.instance();
    final status = _statusFromCode(statusCode);
    await db.rawUpdate(
      'UPDATE sync_queue SET status = ?, last_error = ?, retry_count = retry_count + 1, last_attempt_at = ? WHERE id = ?',
      [status, error, DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  String _statusFromCode(int? code) {
    if (code == 409 || code == 422) return 'conflict';
    if (code == null) return 'failed';
    if (code >= 400) return 'failed';
    return 'pending';
  }

  bool _shouldAttemptAuto(SyncQueueItem item) {
    // Conflicts require human review and should not auto-retry.
    if (item.status == 'conflict') return false;

    // Fresh pending items should be attempted immediately.
    if (item.status == 'pending') return true;

    // Failed items use exponential backoff before next attempt.
    if (item.status == 'failed') {
      if (item.lastAttemptAt == null) return true;
      final next = item.lastAttemptAt!.add(_backoffFor(item.retryCount));
      return DateTime.now().isAfter(next);
    }

    return true;
  }

  Duration _backoffFor(int retryCount) {
    final safe = retryCount <= 0 ? 1 : retryCount;
    final minutes = 1 << (safe - 1);
    final capped = minutes > 30 ? 30 : minutes;
    return Duration(minutes: capped);
  }

  String _moduleFromCacheKey(String key) {
    if (key.startsWith('dashboard_')) return 'Dashboard';
    if (key.startsWith('livestock_')) return 'Livestock';
    if (key.startsWith('inventory_')) return 'Inventory';
    if (key.startsWith('tasks_') || key.startsWith('task_')) return 'Tasks';
    if (key.startsWith('financial_')) return 'Financial';
    if (key.startsWith('weather_')) return 'Weather';
    if (key.startsWith('iot_')) return 'IoT';
    return 'Other';
  }

  String _labelFromCacheKey(String key) {
    final normalized = key
        .replaceAll(RegExp(r'^(dashboard|livestock|inventory|tasks|task|financial|weather|iot)_'), '')
        .replaceAll('_', ' ')
        .trim();
    if (normalized.isEmpty) return 'Snapshot';

    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
