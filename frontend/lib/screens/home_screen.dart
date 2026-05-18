import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/api_service.dart';
import '../widgets/premium_background.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  int _currentBannerIndex = 0;
  int _selectedCategoryIndex = 0;
  
  // فلاتر البحث
  Map<String, dynamic> _activeFilters = {};

  List<Map<String, dynamic>> _rawCategories = [];
  List<String> categories = ['الكل'];
  List<Product> products = [];
  bool _isLoading = true;

  final List<String> bannerImages = [
    'https://images.unsplash.com/photo-1596462502278-27bfdc403348?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1612817288484-6f916006741a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData({String? search}) async {
    setState(() => _isLoading = true);
    try {
      final fetchedCategories = await _apiService.fetchCategories();
      final fetchedProducts = await _apiService.fetchProducts(
        search: search ?? _searchController.text,
        filters: _activeFilters,
      );
      setState(() {
        _rawCategories = fetchedCategories;
        categories = ['الكل', ...fetchedCategories.map((c) => c['name'] as String)];
        products = fetchedProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading data: $e');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadData(search: query);
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تصفية النتائج', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('نوع البشرة', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 10,
                  children: ['جافة', 'دهنية', 'مختلطة', 'عادية'].map((type) {
                    final isSelected = _activeFilters['skin_type'] == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) _activeFilters['skin_type'] = type;
                          else _activeFilters.remove('skin_type');
                        });
                        Navigator.pop(context);
                        _loadData();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _activeFilters = {});
                    Navigator.pop(context);
                    _loadData();
                  },
                  child: const Center(child: Text('إعادة ضبط الفلاتر')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () => _loadData(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                _buildSearchSection(),
                const SizedBox(height: 25),
                _buildCarouselSlider(),
                const SizedBox(height: 25),
                _buildSectionHeader('الأقسام'),
                const SizedBox(height: 15),
                _buildCategories(),
                const SizedBox(height: 25),
                _buildSectionHeader(_searchController.text.isEmpty && _activeFilters.isEmpty
                    ? 'أحدث المنتجات'
                    : 'نتائج البحث المخصصة'),
                const SizedBox(height: 15),
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    : products.isEmpty
                        ? const Center(
                            child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد منتجات تطابق اختياراتك')))
                        : _buildProductsGrid(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'المؤسسة المتحدة',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      leading: IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () {}),
      actions: [
        IconButton(
          icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
      ],
    );
  }
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'ابحث عن منتج، شركة، أو قسم...',
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFF8C00)),
            suffixIcon: IconButton(
              icon: Icon(Icons.filter_list, color: _activeFilters.isNotEmpty ? const Color(0xFFFF8C00) : Colors.grey),
              onPressed: _showFilterSheet,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
  Widget _buildCarouselSlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.9,
            onPageChanged: (index, reason) => setState(() => _currentBannerIndex = index),
          ),
          items: bannerImages.map((imageUrl) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerImages.asMap().entries.map((entry) => Container(
            width: _currentBannerIndex == entry.key ? 20.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: _currentBannerIndex == entry.key ? Colors.blue : Colors.grey.shade300),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          TextButton(onPressed: () {}, child: const Text('عرض الكل', style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
                if (index == 0) {
                  _activeFilters.remove('category');
                } else {
                  _activeFilters['category'] = _rawCategories[index - 1]['id'];
                }
              });
              _loadData();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF8C00) : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF8C00) : Colors.white.withOpacity(0.5),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF8C00).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCard(product: products[index]),
      ),
    );
  }
}
