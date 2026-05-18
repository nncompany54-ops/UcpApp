import 'package:flutter/material.dart';
import 'dart:ui';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background Color
        Container(
          color: const Color(0xFFFFFBF5),
        ),
        
        // Background Blobs
        Positioned(
          top: -100,
          right: -50,
          child: _buildBlob(
            width: 300,
            height: 300,
            color: const Color(0xFFFFE0C2).withOpacity(0.5),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: _buildBlob(
            width: 400,
            height: 400,
            color: const Color(0xFFFFD1A9).withOpacity(0.3),
          ),
        ),
        Positioned(
          top: 300,
          right: -150,
          child: _buildBlob(
            width: 350,
            height: 350,
            color: const Color(0xFFFFEBD2).withOpacity(0.4),
          ),
        ),

        // Optional: Glassmorphism layer if needed
        // BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
        //   child: Container(color: Colors.transparent),
        // ),

        // Main Content
        child,
      ],
    );
  }

  Widget _buildBlob({required double width, required double height, required Color color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
