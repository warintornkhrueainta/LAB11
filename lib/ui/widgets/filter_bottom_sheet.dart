import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/event_provider.dart';
import '../state/category_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // ตัวแปรเก็บค่าตัวกรองชั่วคราวก่อนกดยืนยัน
  String? _localDateFilter;
  int? _localCategoryId;
  String? _localStatus;

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลหมวดหมู่มาแสดงเป็นตัวเลือก
    final categories = Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).categories;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ให้ความสูงพอดีกับเนื้อหา
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'กรองข้อมูล',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          // 1. กรองตามวันที่
          const Text('วันที่', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('ทั้งหมด'),
                selected: _localDateFilter == null,
                onSelected: (val) => setState(() => _localDateFilter = null),
              ),
              ChoiceChip(
                label: const Text('วันนี้'),
                selected: _localDateFilter == 'today',
                onSelected: (val) => setState(() => _localDateFilter = 'today'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. กรองตามประเภทกิจกรรม
          const Text(
            'ประเภทกิจกรรม',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('ทั้งหมด'),
                selected: _localCategoryId == null,
                onSelected: (val) => setState(() => _localCategoryId = null),
              ),
              ...categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat.name),
                  selected: _localCategoryId == cat.id,
                  onSelected: (val) =>
                      setState(() => _localCategoryId = cat.id),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // 3. กรองตามสถานะ
          const Text('สถานะ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('ทั้งหมด'),
                selected: _localStatus == null,
                onSelected: (val) => setState(() => _localStatus = null),
              ),
              ..._statusOptions.map((status) {
                return ChoiceChip(
                  label: Text(status),
                  selected: _localStatus == status,
                  onSelected: (val) => setState(() => _localStatus = status),
                );
              }),
            ],
          ),
          const SizedBox(height: 32),

          // 4. ปุ่มล้างตัวกรอง และ ปุ่มตกลง
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // สั่ง Provider ให้ล้าง Filter ทั้งหมด
                    Provider.of<EventProvider>(
                      context,
                      listen: false,
                    ).clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('ล้างทั้งหมด'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    // ส่งค่า Filter กลับไปให้ Provider ทำการกรอง List
                    final provider = Provider.of<EventProvider>(
                      context,
                      listen: false,
                    );
                    provider.setDateFilter(_localDateFilter);
                    provider.setCategoryFilter(_localCategoryId);
                    provider.setStatusFilter(_localStatus);

                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ตกลง',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
