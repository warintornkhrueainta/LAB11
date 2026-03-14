import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/event_model.dart';
import '../state/event_provider.dart';
import '../state/category_provider.dart';
import '../../utils/constants.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดกิจกรรม'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('ยืนยันการลบ'),
                  content: const Text('คุณต้องการลบกิจกรรมนี้ใช่หรือไม่?'),
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

              if (confirm == true && event.id != null) {
                Provider.of<EventProvider>(
                  context,
                  listen: false,
                ).deleteEvent(event.id!);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Consumer2<EventProvider, CategoryProvider>(
        builder: (context, eventProvider, catProvider, child) {
          // ดึงข้อมูลกิจกรรมล่าสุดจาก Provider (เผื่อมีการเปลี่ยนสถานะไปแล้ว)
          final currentEvent = eventProvider.filteredEvents.firstWhere(
            (e) => e.id == event.id,
            orElse: () => event,
          );

          final category = catProvider.categories.firstWhere(
            (c) => c.id == currentEvent.categoryId,
            orElse: () => catProvider.categories.first,
          );

          final categoryColor = AppConstants.hexToColor(category.colorHex);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนหัว: ชื่อและประเภท
                Text(
                  currentEvent.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    category.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: categoryColor,
                ),
                const Divider(height: 32),

                // รายละเอียด
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('รายละเอียด'),
                  subtitle: Text(
                    currentEvent.description?.isNotEmpty == true
                        ? currentEvent.description!
                        : 'ไม่มีรายละเอียด',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('วันที่และเวลา'),
                  subtitle: Text(
                    '${currentEvent.eventDate}\nเวลา: ${currentEvent.startTime} - ${currentEvent.endTime}',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 32),

                // ส่วนเปลี่ยนสถานะ (โจทย์ข้อ 3.3)
                const Text(
                  'สถานะกิจกรรม',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: currentEvent.status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Pending',
                      child: Text('ยังไม่เริ่ม (Pending)'),
                    ),
                    DropdownMenuItem(
                      value: 'In Progress',
                      child: Text('กำลังดำเนินการ (In Progress)'),
                    ),
                    DropdownMenuItem(
                      value: 'Completed',
                      child: Text('เสร็จสิ้น (Completed)'),
                    ),
                    DropdownMenuItem(
                      value: 'Cancelled',
                      child: Text('ยกเลิก (Cancelled)'),
                    ),
                  ],
                  onChanged: (newStatus) {
                    if (newStatus != null && currentEvent.id != null) {
                      // สั่งอัปเดตสถานะในฐานข้อมูล
                      eventProvider.updateEventStatus(
                        currentEvent.id!,
                        newStatus,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เปลี่ยนสถานะเป็น $newStatus แล้ว'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
