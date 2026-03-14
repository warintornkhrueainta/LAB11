import 'package:flutter/material.dart';

class AppConstants {
  // ฟังก์ชันแปลง String (เช่น "#FF5733") เป็น Color object ของ Flutter
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // ฟังก์ชันแปลง Color object กลับเป็น String เพื่อเซฟลง DB
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
