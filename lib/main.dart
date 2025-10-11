import 'package:cooldown/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() {
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
