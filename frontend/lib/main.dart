import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const UCPApp());
}

class UCPApp extends StatelessWidget {
  const UCPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'United Company Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B3C87),
          background: const Color(0xFFF6F9FE),
        ),
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
    );
  }
}
