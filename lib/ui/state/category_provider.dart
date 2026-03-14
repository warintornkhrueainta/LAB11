import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  // ดึงข้อมูลทั้งหมดจากฐานข้อมูล
  Future<void> loadCategories() async {
    _categories = await _repository.getAllCategories();
    notifyListeners(); // สั่งให้ UI รีเฟรช
  }

  // เพิ่มข้อมูล
  Future<void> addCategory(Category category) async {
    await _repository.insertCategory(category);
    await loadCategories();
  }

  // อัปเดตข้อมูล
  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }

  // ลบข้อมูล (จะคืนค่า true ถ้าลบสำเร็จ, คืน false ถ้าติดเงื่อนไขถูกใช้งานอยู่)
  Future<bool> deleteCategory(int id) async {
    bool canDelete = await _repository.canDeleteCategory(id);
    if (canDelete) {
      await _repository.deleteCategory(id);
      await loadCategories();
      return true;
    }
    return false; // ส่งกลับไปบอก UI ให้แจ้งเตือนผู้ใช้ว่าลบไม่ได้
  }
}
