import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/category_provider.dart';
import '../../data/models/category_model.dart';
import '../../utils/constants.dart';

class CategoryManagePage extends StatelessWidget {
  const CategoryManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการประเภทกิจกรรม')),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text('ยังไม่มีประเภทกิจกรรม กด + เพื่อเพิ่มเลย'),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryColor = AppConstants.hexToColor(category.colorHex);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: categoryColor,
                    // สมมติว่าเก็บชื่อ icon เป็น string ง่ายๆ ไว้ตรวจสอบ
                    child: Icon(
                      category.iconKey == 'work' ? Icons.work : Icons.star,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // ยืนยันก่อนลบ
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('ยืนยันการลบ'),
                          content: Text(
                            'คุณต้องการลบหมวดหมู่ "${category.name}" ใช่หรือไม่?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('ยกเลิก'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'ลบ',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && category.id != null) {
                        // เรียกใช้ฟังก์ชันลบใน Provider ที่มี Logic ตรวจสอบการใช้งานอยู่แล้ว
                        final success = await provider.deleteCategory(
                          category.id!,
                        );
                        if (!success) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'ไม่สามารถลบได้ เนื่องจากมีกิจกรรมใช้หมวดหมู่นี้อยู่!',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ฟังก์ชันแสดงหน้าต่าง (Dialog) สำหรับเพิ่มหมวดหมู่ใหม่
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    String selectedColor = '#FF5733'; // สีเริ่มต้น (ส้ม)
    String selectedIcon = 'work'; // ไอคอนเริ่มต้น

    // รายการสีให้ผู้ใช้เลือก
    final List<String> colorOptions = [
      '#FF5733',
      '#33FF57',
      '#3357FF',
      '#F333FF',
      '#FFB533',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // ใช้ StatefulBuilder เพื่อให้หน้าต่าง Dialog อัปเดต UI ได้
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('เพิ่มประเภทใหม่'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อประเภทกิจกรรม',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('เลือกสี:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colorOptions.map((hex) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = hex),
                        child: CircleAvatar(
                          backgroundColor: AppConstants.hexToColor(hex),
                          radius: 16,
                          child: selectedColor == hex
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;

                    final newCategory = Category(
                      name: nameController.text.trim(),
                      colorHex: selectedColor,
                      iconKey: selectedIcon,
                    );

                    // สั่ง Provider ให้เพิ่มข้อมูลลง Database
                    Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).addCategory(newCategory);
                    Navigator.pop(context);
                  },
                  child: const Text('บันทึก'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
