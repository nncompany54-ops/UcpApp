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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B3C87).withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/ucp_logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'المؤسسة المتحدة',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3C87),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'للأدوية والمستلزمات الطبية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E6DDF),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'اليمن - صنعاء',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(color: Color(0xFF0B3C87)),
            ],
          ),
        ),
      ),
    );
  }
}
