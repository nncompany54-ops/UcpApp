import 'package:flutter/material.dart';
import '../widgets/premium_background.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMenuSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 65, color: Colors.blue),
          ),
          const SizedBox(height: 15),
          const Text(
            'اسم المستخدم',
            style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'user@example.com',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(Icons.shopping_bag_outlined, 'طلباتي', () {}),
          _buildMenuItem(Icons.favorite_border, 'المفضلة', () {}),
          _buildMenuItem(Icons.location_on_outlined, 'عناويني', () {}),
          _buildMenuItem(Icons.admin_panel_settings_outlined, 'لوحة الإدارة', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }),
          const Divider(),
          _buildMenuItem(Icons.settings_outlined, 'الإعدادات', () {}),
          _buildMenuItem(Icons.help_outline, 'مركز المساعدة', () {}),
          const SizedBox(height: 20),
          _buildMenuItem(Icons.logout, 'تسجيل الخروج', () {}, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? Colors.red : Colors.blue, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }
}
