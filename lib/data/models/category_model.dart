class Category {
  final int? id;
  final String name;
  final String colorHex;
  final String iconKey;

  Category({
    this.id,
    required this.name,
    required this.colorHex,
    required this.iconKey,
  });

  // แปลง Dart Object เป็น Map เพื่อบันทึกลง SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_key': iconKey,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // แปลง Map จาก SQLite กลับมาเป็น Dart Object
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorHex: map['color_hex'],
      iconKey: map['icon_key'],
    );
  }
}
