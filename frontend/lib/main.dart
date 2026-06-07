import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
      ),
    );
  } catch (e) {
    debugPrint("فشل تهيئة Firebase (يرجى التحقق من المفاتيح): $e");
  }
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
