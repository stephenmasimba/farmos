import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDbService {
  LocalDbService._();

  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;

    final path = p.join(await getDatabasesPath(), 'farmos_mobile.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Generic cache table for offline snapshots per resource key
        await db.execute('''
          CREATE TABLE IF NOT EXISTS api_cache (
            key TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Queue write operations to sync when connectivity returns
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            method TEXT NOT NULL,
            path TEXT NOT NULL,
            body TEXT,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
