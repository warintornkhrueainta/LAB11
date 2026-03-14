class Reminder {
  final int? id;
  final int eventId;
  final int minutesBefore; // แจ้งเตือนล่วงหน้ากี่นาที (เช่น 5, 10, 15, 30, 60)
  final String remindAt; // เวลาที่ต้องแจ้งเตือนจริง (YYYY-MM-DD HH:mm)
  final bool isEnabled; // สถานะเปิด/ปิด

  Reminder({
    this.id,
    required this.eventId,
    required this.minutesBefore,
    required this.remindAt,
    this.isEnabled = true, // ค่าเริ่มต้นคือเปิดใช้งาน
  });

  // แปลง Dart Object เป็น Map เพื่อบันทึกลง SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'minutes_before': minutesBefore,
      'remind_at': remindAt,
      // แปลง bool เป็น int (1 = true, 0 = false) เพราะ SQLite ไม่มี Boolean
      'is_enabled': isEnabled ? 1 : 0,
    };
  }

  // แปลง Map จาก SQLite กลับมาเป็น Dart Object
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      eventId: map['event_id'],
      minutesBefore: map['minutes_before'],
      remindAt: map['remind_at'],
      // แปลง int กลับเป็น bool
      isEnabled: map['is_enabled'] == 1,
    );
  }
}
