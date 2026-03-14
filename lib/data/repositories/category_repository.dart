import '../db/app_database.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final dbHelper = AppDatabase.instance;

  // เพิ่มหมวดหมู่ใหม่
  Future<int> insertCategory(Category category) async {
    final db = await dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  // ดึงข้อมูลหมวดหมู่ทั้งหมด
  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // อัปเดตข้อมูลหมวดหมู่
  Future<int> updateCategory(Category category) async {
    final db = await dbHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // ตรวจสอบว่าหมวดหมู่นี้ถูกใช้งานในกิจกรรมไหนอยู่หรือไม่ (ป้องกันการลบ)
  Future<bool> canDeleteCategory(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'events',
      where: 'category_id = ?',
      whereArgs: [id],
    );
    return result.isEmpty; // ถ้าว่าง (isEmpty) แปลว่าลบได้
  }

  // ลบหมวดหมู่
  Future<int> deleteCategory(int id) async {
    final db = await dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
