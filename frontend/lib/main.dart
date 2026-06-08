import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB9uweZD8K7vXMKOtHVLVwjImKINlRR4ZE",
        authDomain: "ucp-platform.firebaseapp.com",
        projectId: "ucp-platform",
        storageBucket: "ucp-platform.firebasestorage.app",
        messagingSenderId: "757541342147",
        appId: "1:757541342147:web:f9d438d1c86c7c58eb4b76",
        measurementId: "G-MTX2TPJYN9",
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
