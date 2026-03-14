import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

class EventProvider with ChangeNotifier {
  final EventRepository _repository = EventRepository();
  List<Event> _allEvents = [];

  // ================= ตัวแปรสำหรับ Filter & Search =================
  String _searchQuery = '';
  int? _selectedCategoryId;
  String? _selectedStatus; // Pending, In Progress, Completed, Cancelled
  String? _dateFilter; // 'today', 'week', 'month'

  // ================= ฟังก์ชันตั้งค่า Filter =================
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setDateFilter(String? filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedStatus = null;
    _dateFilter = null;
    notifyListeners();
  }

  // ================= Getter ที่ส่งข้อมูลที่ผ่านการกรองแล้วไปให้ UI =================
  List<Event> get filteredEvents {
    List<Event> filtered = _allEvents;

    // 1. กรองตามชื่อกิจกรรม (Search)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // 2. กรองตามประเภท
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((e) => e.categoryId == _selectedCategoryId)
          .toList();
    }

    // 3. กรองตามสถานะ
    if (_selectedStatus != null) {
      filtered = filtered.where((e) => e.status == _selectedStatus).toList();
    }

    // 4. กรองตามวันที่ (ตัวอย่างการทำ 'วันนี้')
    if (_dateFilter != null) {
      final now = DateTime.now();
      filtered = filtered.where((e) {
        final eventDate = DateTime.parse(e.eventDate); // e.g., '2026-03-14'
        if (_dateFilter == 'today') {
          return eventDate.year == now.year &&
              eventDate.month == now.month &&
              eventDate.day == now.day;
        }
        // สามารถเพิ่ม logic สำหรับสัปดาห์นี้/เดือนนี้ ตรงนี้ได้
        return true;
      }).toList();
    }

    return filtered;
  }

  // ================= ฟังก์ชัน CRUD =================
  Future<void> loadEvents() async {
    _allEvents = await _repository.getAllEvents();
    notifyListeners();
  }

  Future<void> addEvent(Event event) async {
    await _repository.insertEvent(event);
    await loadEvents();
  }

  Future<void> updateEvent(Event event) async {
    await _repository.updateEvent(event);
    await loadEvents();
  }

  Future<void> updateEventStatus(int id, String status) async {
    await _repository.updateEventStatus(id, status);
    // TODO: ถ้า status เป็น 'Completed' ให้เรียกฟังก์ชันปิด Reminder ใน DB ตรงนี้
    await loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    await _repository.deleteEvent(id);
    await loadEvents();
  }
}
