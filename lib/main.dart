import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/state/category_provider.dart';
import 'ui/state/event_provider.dart';
import 'ui/screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // สร้าง Provider และสั่งให้โหลดข้อมูลจาก SQLite ทันทีที่เปิดแอป
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
        ChangeNotifierProvider(create: (_) => EventProvider()..loadEvents()),
      ],
      child: MaterialApp(
        title: 'Event & Reminder App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}
