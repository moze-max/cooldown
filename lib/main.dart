import 'package:cooldown/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz; // 导入时区数据

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cooldown',
      theme: ThemeData(fontFamily: "NotoSansSC"),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
