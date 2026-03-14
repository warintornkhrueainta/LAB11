import '../db/app_database.dart';
import '../models/event_model.dart';

class EventRepository {
  final dbHelper = AppDatabase.instance;

  // เพิ่มกิจกรรมใหม่
  Future<int> insertEvent(Event event) async {
    final db = await dbHelper.database;
    return await db.insert('events', event.toMap());
  }

  // ดึงกิจกรรมทั้งหมด (เรียงตามวันที่และเวลาเริ่ม)
  Future<List<Event>> getAllEvents() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      orderBy: 'event_date ASC, start_time ASC', // จัดเรียงเวลาใกล้สุด
    );
    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }

  // อัปเดตข้อมูลกิจกรรม
  Future<int> updateEvent(Event event) async {
    final db = await dbHelper.database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // เปลี่ยนสถานะกิจกรรมอย่างเดียว
  Future<int> updateEventStatus(int id, String newStatus) async {
    final db = await dbHelper.database;
    return await db.update(
      'events',
      {'status': newStatus, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ลบกิจกรรม
  Future<int> deleteEvent(int id) async {
    final db = await dbHelper.database;
    // หมายเหตุ: โบนัส Reminder ถ้าลบ Event ต้องไปจัดการลบในตาราง reminders ด้วย
    // แต่เราตั้ง ON DELETE CASCADE ไว้ตอนสร้างตารางแล้ว SQLite จะลบ Reminder ให้อัตโนมัติ!
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
