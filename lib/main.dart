import 'package:cooldown/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz; // 导入时区数据
import 'services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await LocalNotificationService().initialize();
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
