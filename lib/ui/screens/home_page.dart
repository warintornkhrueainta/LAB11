import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/event_provider.dart';
import 'category_manage_page.dart';
import 'event_form_page.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายการกิจกรรม',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // ปุ่มไปหน้าจัดการประเภทกิจกรรม
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'จัดการประเภทกิจกรรม',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryManagePage()),
              );
            },
          ),
          // ปุ่มเปิดหน้าต่างตัวกรอง (Filter)
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'กรองข้อมูล',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // ทำให้ชีทขยายได้ตามเนื้อหา
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ส่วนค้นหา (Search Bar) - ตามโจทย์ข้อ 4.2
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อกิจกรรม...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                // ส่งคำค้นหาไปที่ Provider ให้กรองข้อมูลแบบ Real-time
                Provider.of<EventProvider>(
                  context,
                  listen: false,
                ).setSearchQuery(value);
              },
            ),
          ),

          // ส่วนแสดงรายการกิจกรรม
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                final events = eventProvider.filteredEvents;

                // กรณีไม่มีข้อมูล หรือค้นหาไม่เจอ
                if (events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'ไม่พบกิจกรรม\nกดปุ่ม + เพื่อเพิ่มกิจกรรมใหม่',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // กรณีมีข้อมูล ให้แสดงผลเป็น List ของ EventCard
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCard(event: event);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // ปุ่มลอยสำหรับเพิ่มกิจกรรม
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormPage()),
          );
        },
        backgroundColor: Colors.blue,
        tooltip: 'เพิ่มกิจกรรมใหม่',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
