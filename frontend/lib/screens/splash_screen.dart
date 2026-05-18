import 'package:flutter/material.dart';
import 'dart:async';
import 'main_screen.dart';
import 'login_screen.dart';
import '../widgets/premium_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, size: 100, color: Color(0xFFFF8C00)),
              ),
              const SizedBox(height: 25),
              const Text(
                'المؤسسة المتحدة',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                'United Company Platform',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(color: Color(0xFFFF8C00)),
            ],
          ),
        ),
      ),
    );
  }
}
