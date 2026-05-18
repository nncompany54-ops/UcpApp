import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/premium_background.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _launchAdminUrl(String path) async {
    final Uri url = Uri.parse('https://ucp.moha85awad.site/admin/$path');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('لوحة الإدارة', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _buildAdminCard(context, Icons.add_business, 'إضافة منتج', 'نشر منتجات جديدة', () {
                _launchAdminUrl('core/product/add/');
              }),
              _buildAdminCard(context, Icons.business_outlined, 'الشركات', 'إدارة الشركات والوكالات', () {
                _launchAdminUrl('core/company/');
              }),
              _buildAdminCard(context, Icons.category_outlined, 'الأقسام', 'تنظيم المنتجات في أقسام', () {
                _launchAdminUrl('core/category/');
              }),
              _buildAdminCard(context, Icons.people_outline, 'المستخدمين', 'إدارة حسابات العملاء', () {
                _launchAdminUrl('auth/user/');
              }),
              _buildAdminCard(context, Icons.analytics_outlined, 'الإحصائيات', 'عرض تقارير المبيعات', () {
                _launchAdminUrl('');
              }),
              _buildAdminCard(context, Icons.settings_applications, 'الإعدادات', 'إعدادات المنصة العامة', () {
                _launchAdminUrl('');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFFFF8C00)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
