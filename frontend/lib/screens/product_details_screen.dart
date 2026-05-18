import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductTitleSection(),
                    const SizedBox(height: 25),
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),
                    if (product.ingredients != null && product.ingredients!.isNotEmpty)
                      _buildExpandableSection(context, 'المكونات', product.ingredients!),
                    if (product.usage != null && product.usage!.isNotEmpty)
                      _buildExpandableSection(context, 'طريقة الاستخدام', product.usage!),
                    if (product.warnings != null && product.warnings!.isNotEmpty)
                      _buildExpandableSection(context, 'تحذيرات', product.warnings!),
                    const SizedBox(height: 100), // مساحة للزر الثابت في الأسفل
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: _buildBottomActionBar(),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${product.id}',
          child: Image.network(
            product.imageUrl.isNotEmpty ? product.imageUrl : 'https://via.placeholder.com/400',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.companyName,
                    style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (product.skinType != null && product.skinType!.isNotEmpty)
          _buildChip(Icons.face, 'نوع البشرة: ${product.skinType}'),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.blue, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('عن المنتج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
          product.description,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildExpandableSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // لإخفاء الخط الفاصل الافتراضي
        child: ExpansionTile(
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(content, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black54)),
            ),
          ],
          tilePadding: EdgeInsets.zero,
          iconColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('أضف إلى السلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
              onPressed: () {}, // WhatsApp functionality later
            ),
          ),
        ],
      ),
    );
  }
}
