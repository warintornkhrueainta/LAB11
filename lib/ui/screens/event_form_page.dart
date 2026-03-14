import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/event_provider.dart';
import '../state/category_provider.dart';
import '../../data/models/event_model.dart';

class EventFormPage extends StatefulWidget {
  final Event? eventToEdit; // เผื่อไว้สำหรับโหมดแก้ไขข้อมูล

  const EventFormPage({super.key, this.eventToEdit});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers สำหรับ TextFields
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // ตัวแปรเก็บค่าต่างๆ ของ Form
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
    hour: TimeOfDay.now().hour + 1,
    minute: TimeOfDay.now().minute,
  ); // Default ให้เวลาจบห่าง 1 ชม.

  String _selectedStatus = 'Pending';
  int _selectedPriority = 2; // 1=Low, 2=Normal, 3=High

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นการแก้ไขข้อมูล ให้นำข้อมูลเก่ามาใส่ในฟอร์ม (คุณสามารถทำต่อยอดได้)
    if (widget.eventToEdit != null) {
      // Setup edit mode ...
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ฟังก์ชันแปลง Date เป็น String (YYYY-MM-DD) เพื่อบันทึกลง DB
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ฟังก์ชันแปลง TimeOfDay เป็น String (HH:mm)
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // ฟังก์ชันตรวจสอบและบันทึกข้อมูล
  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกประเภทกิจกรรม')));
      return;
    }

    // --- ตรวจสอบ Logic: End Time > Start Time ตามโจทย์ ---
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มกิจกรรม!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // สร้าง Object กิจกรรมใหม่
    final newEvent = Event(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      categoryId: _selectedCategoryId!,
      eventDate: _formatDate(_selectedDate),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      status: _selectedStatus,
      priority: _selectedPriority,
    );

    // สั่ง Provider บันทึกและย้อนกลับหน้าเดิม
    Provider.of<EventProvider>(context, listen: false).addEvent(newEvent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มกิจกรรมใหม่')),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final categories = categoryProvider.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text('กรุณาเพิ่มประเภทกิจกรรมก่อนสร้างกิจกรรม!'),
            );
          }

          // เพื่อไม่ให้แอปแครช ถ้ายังไม่เคยเลือก ให้ใช้ ID ของประเภทแรกเป็นค่าเริ่มต้น
          _selectedCategoryId ??= categories.first.id;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. ชื่อกิจกรรม
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อกิจกรรม *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'กรุณากรอกชื่อกิจกรรม'
                      : null,
                ),
                const SizedBox(height: 16),

                // 2. รายละเอียด
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียด (ไม่บังคับ)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // 3. ประเภทกิจกรรม (ดึงจาก CategoryProvider)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'ประเภทกิจกรรม',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategoryId,
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                const SizedBox(height: 16),

                // 4. วันที่กิจกรรม
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('วันที่จัดกิจกรรม'),
                  subtitle: Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                const Divider(),

                // 5. เวลาเริ่ม และ เวลาสิ้นสุด
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('เวลาเริ่ม'),
                        subtitle: Text(
                          _formatTime(_startTime),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (picked != null)
                            setState(() => _startTime = picked);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('เวลาสิ้นสุด'),
                        subtitle: Text(
                          _formatTime(_endTime),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (picked != null) setState(() => _endTime = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(),

                // 6. สถานะ
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'สถานะเริ่มต้น',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatus,
                  items: _statusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
                const SizedBox(height: 32),

                // 7. ปุ่มบันทึก
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _saveForm,
                  child: const Text(
                    'บันทึกข้อมูล',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
