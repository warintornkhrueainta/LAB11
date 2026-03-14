import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('event_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      // เปิดใช้งาน Foreign Key
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. ตารางประเภทกิจกรรม (Category)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 2. ตารางกิจกรรม (Event)
    // มี category_id เป็น Foreign Key เชื่อมกับตาราง categories
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER NOT NULL,
        event_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT NOT NULL,
        priority INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    // 3. ตารางการแจ้งเตือน (Reminder) สำหรับคะแนนพิเศษ
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        minutes_before INTEGER NOT NULL,
        remind_at TEXT NOT NULL,
        is_enabled INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
