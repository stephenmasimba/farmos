import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../api/api_client.dart';
import 'local_db_service.dart';

class SyncService {
  SyncService(this._api);

  final ApiClient _api;

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
    });
  }

  Future<void> syncPending() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn.contains(ConnectivityResult.none)) return;

    final db = await LocalDbService.instance();
    final rows = await db.query('sync_queue', orderBy: 'id ASC', limit: 50);

    for (final row in rows) {
      final id = row['id'] as int;
      final method = (row['method'] as String).toUpperCase();
      final path = row['path'] as String;
      final body = row['body'] == null
          ? null
          : jsonDecode(row['body'] as String) as Map<String, dynamic>;

      try {
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
            break;
        }

        await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
      } catch (_) {
        // Keep failed entries in queue and retry later.
      }
    }
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
    final db = await LocalDbService.instance();
    final rows = await db.query('api_cache', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['payload'] as String) as Map<String, dynamic>;
  }
}
