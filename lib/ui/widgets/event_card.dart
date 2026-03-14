import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/event_model.dart';
import '../state/category_provider.dart';
import '../../utils/constants.dart';
import '../screens/event_detail_page.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, catProvider, child) {
        // ค้นหาหมวดหมู่ของกิจกรรมนี้เพื่อเอา "สี" มาแสดง
        final category = catProvider.categories.firstWhere(
          (c) => c.id == event.categoryId,
          orElse: () => catProvider.categories.first, // Fallback
        );

        final categoryColor = AppConstants.hexToColor(category.colorHex);

        // กำหนดสีของสถานะ
        Color statusColor;
        switch (event.status) {
          case 'Completed':
            statusColor = Colors.green;
            break;
          case 'In Progress':
            statusColor = Colors.orange;
            break;
          case 'Cancelled':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.grey; // Pending
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: categoryColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(event.eventDate),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${event.startTime} - ${event.endTime}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(color: categoryColor, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(
                        event.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: statusColor,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              // เมื่อกดที่การ์ด ให้เปิดหน้ารายละเอียด
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailPage(event: event),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
