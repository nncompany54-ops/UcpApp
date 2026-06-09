import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:js' as js;
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/api_service.dart';
import '../widgets/premium_background.dart';
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
  int _selectedCompanyIndex = 0;
  
  List<Map<String, dynamic>> _banners = [];
  bool _hasNewNotification = false;
  String? _lastSeenBannerId;
  
  // فلاتر البحث
  Map<String, dynamic> _activeFilters = {};

  List<Map<String, dynamic>> _rawCategories = [];
  List<String> categories = ['الكل'];
  List<Map<String, dynamic>> _companies = [];
  List<Product> products = [];
  bool _isLoading = true;


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
      final fetchedBanners = await _apiService.fetchBanners();
      final fetchedCategories = await _apiService.fetchCategories(
        companyId: _activeFilters['company'],
      );
      final fetchedCompanies = await _apiService.fetchCompanies();
      final fetchedProducts = await _apiService.fetchProducts(
        search: search ?? _searchController.text,
        filters: _activeFilters,
      );

      await _loadLastSeenBannerId();
      bool hasNew = false;
      if (fetchedBanners.isNotEmpty) {
        final latestId = fetchedBanners.first['id'].toString();
        if (_lastSeenBannerId != latestId) {
          if (_lastSeenBannerId != null) {
            hasNew = true;
          }
        }
      }

      setState(() {
        _banners = fetchedBanners;
        _hasNewNotification = hasNew;
        _rawCategories = fetchedCategories;
        categories = ['الكل', ...fetchedCategories.map((c) => c['name'] as String)];
        _companies = [
          {'id': null, 'name': 'عام', 'logo': null},
          ...fetchedCompanies,
        ];
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
                          if (val) {
                            _activeFilters['skin_type'] = type;
                          } else {
                            _activeFilters.remove('skin_type');
                          }
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
                    setState(() {
                      _activeFilters = {};
                      _selectedCategoryIndex = 0;
                      _selectedCompanyIndex = 0;
                    });
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
        appBar: _buildAppBar(context),
        drawer: _buildDrawer(context),
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
                _buildCompanies(),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'المؤسسة المتحدة',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
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
        Stack(
          children: [
            IconButton(
              icon: Icon(
                _hasNewNotification ? Icons.notifications_active : Icons.notifications_none,
                color: _hasNewNotification ? const Color(0xFF0B3C87) : Colors.black87,
              ),
              onPressed: () => _showNotificationDialog(context),
            ),
            if (_hasNewNotification)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
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
            prefixIcon: const Icon(Icons.search, color: Color(0xFF0B3C87)),
            suffixIcon: IconButton(
              icon: Icon(Icons.filter_list, color: _activeFilters.isNotEmpty ? const Color(0xFF0B3C87) : Colors.grey),
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
    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: _banners.length > 1,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.9,
            onPageChanged: (index, reason) => setState(() => _currentBannerIndex = index),
          ),
          items: _banners.map((banner) {
            final imageUrl = banner['image'] ?? '';
            return GestureDetector(
              onTap: () => _launchWhatsAppForBooking(banner['title'] ?? '', imageUrl),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/images/ucp_logo.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _banners.asMap().entries.map((entry) => Container(
            width: _currentBannerIndex == entry.key ? 20.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _currentBannerIndex == entry.key ? const Color(0xFF0B3C87) : Colors.grey.shade300,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCompanies() {
    if (_companies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('الشركات'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: _companies.length,
            itemBuilder: (context, index) {
              final company = _companies[index];
              final isSelected = _selectedCompanyIndex == index;
              final isGeneral = index == 0;
              
              final name = company['name'] ?? '';
              final Color fallbackColor = Colors.primaries[name.hashCode % Colors.primaries.length].withOpacity(0.8);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCompanyIndex = index;
                    _selectedCategoryIndex = 0;
                    _activeFilters.remove('category');
                    if (isGeneral) {
                      _activeFilters.remove('company');
                    } else {
                      _activeFilters['company'] = company['id'];
                    }
                  });
                  _loadData();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: 100,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isGeneral
                              ? (isSelected ? const Color(0xFF0B3C87) : Colors.white.withOpacity(0.8))
                              : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0B3C87) : Colors.white.withOpacity(0.5),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? const Color(0xFF0B3C87).withOpacity(0.3)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: isSelected ? 12 : 6,
                              spreadRadius: isSelected ? 2 : 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: isGeneral
                              ? Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF0B3C87), Color(0xFF1E6DDF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                )
                              : company['logo'] != null && company['logo'].toString().isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Image.network(
                                        company['logo'],
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: fallbackColor,
                                            alignment: Alignment.center,
                                            child: Text(
                                              name.isNotEmpty ? name[0].toUpperCase() : '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      color: fallbackColor,
                                      alignment: Alignment.center,
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0B3C87) : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
                color: isSelected ? const Color(0xFF0B3C87) : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0B3C87) : Colors.white.withOpacity(0.5),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0B3C87).withOpacity(0.3),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B3C87), Color(0xFF1E6DDF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              currentAccountPicture: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/ucp_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              accountName: const Text(
                'المؤسسة المتحدة للأدوية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              accountEmail: const Text(
                'والمستلزمات الطبية - اليمن',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
            
            // Drawer Items
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF0B3C87)),
              title: const Text(
                'تعليمات الاستخدام',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showInstructionsDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: const Text(
                'خروج من التطبيق',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.redAccent,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showExitConfirmation(context);
              },
            ),
            
            const Spacer(),
            // Drawer Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'النسخة 1.0.0',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 جميع الحقوق محفوظة',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: const [
                Icon(Icons.info_outline, color: Color(0xFF0B3C87), size: 28),
                SizedBox(width: 10),
                Text(
                  'تعليمات المنصة',
                  style: TextStyle(
                    color: Color(0xFF0B3C87),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'نبذة عن التطبيق:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'تطبيق المؤسسة المتحدة هو منصة إلكترونية متكاملة لعرض وتصفح الأدوية والمستلزمات الطبية من مختلف الشركات والوكالات، مع تصفح تفاصيل كل منتج.',
                    style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'طريقة الاستخدام:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '• تصفح المنتجات عبر قائمة المنتجات في الصفحة الرئيسية.\n'
                    '• ابحث عن المنتجات باستخدام حقل البحث العلوي.\n'
                    '• اختر شركة معينة لتصفية المنتجات الخاصة بها.\n'
                    '• اضغط على أي منتج للاطلاع على تفاصيله الكاملة.',
                    style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'تصميم وتطوير:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'محمد عوض خميس بايعشوت',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0B3C87),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.email_outlined, size: 18, color: Colors.black54),
                      SizedBox(width: 6),
                      SelectableText(
                        'moha85awad@gmail.com',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(
                    color: Color(0xFF0B3C87),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('خروج', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('هل أنت متأكد من رغبتك في الخروج من التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  if (kIsWeb) {
                    try {
                      js.context.callMethod('close');
                      Future.delayed(const Duration(milliseconds: 100), () {
                        js.context['location'].callMethod('replace', ['about:blank']);
                      });
                    } catch (e) {
                      debugPrint('Error closing web window: $e');
                    }
                  } else {
                    SystemNavigator.pop();
                  }
                },
                child: const Text('خروج', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationDialog(BuildContext context) {
    if (_banners.isNotEmpty) {
      final latestBanner = _banners.first;
      final latestId = latestBanner['id'].toString();
      _saveLastSeenBannerId(latestId);
      setState(() {
        _hasNewNotification = false;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.notifications_active, color: Color(0xFF0B3C87)),
                SizedBox(width: 8),
                Text('الإشعارات والعروض الجديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B3C87),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _subscribeToNotifications();
                    },
                    icon: const Icon(Icons.notifications_active, size: 18),
                    label: const Text('تفعيل جرس الإشعارات الفورية', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  if (_banners.isEmpty)
                    const Text('لا توجد إشعارات أو عروض جديدة حالياً.')
                  else ...[
                    const Text(
                      'تم إضافة عروض ترويجية جديدة في المعرض! تفقدها الآن للحجز المباشر:',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ..._banners.take(3).map((banner) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                banner['title'] ?? 'عرض جديد',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً', style: TextStyle(color: Color(0xFF0B3C87), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadLastSeenBannerId() async {
    if (kIsWeb) {
      try {
        _lastSeenBannerId = js.context['localStorage'].callMethod('getItem', ['last_seen_banner_id']);
      } catch (e) {
        debugPrint('Error loading from localStorage: $e');
      }
    }
  }

  Future<void> _saveLastSeenBannerId(String id) async {
    _lastSeenBannerId = id;
    if (kIsWeb) {
      try {
        js.context['localStorage'].callMethod('setItem', ['last_seen_banner_id', id]);
      } catch (e) {
        debugPrint('Error saving to localStorage: $e');
      }
    }
  }

  Future<void> _launchWhatsAppForBooking(String bannerTitle, String imageUrl) async {
    String messageText = 'مرحباً، أود الاستفسار والحجز بخصوص العرض التالي من تطبيق المؤسسة المتحدة: ($bannerTitle)';
    if (imageUrl.isNotEmpty) {
      messageText += '\nرابط صورة العرض: $imageUrl';
    }
    final String message = Uri.encodeComponent(messageText);
    final Uri whatsappUrl = Uri.parse('https://wa.me/967783639836?text=$message');
    
    try {
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch WhatsApp for $whatsappUrl');
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  Future<void> _subscribeToNotifications() async {
    try {
      bool isInitialized = false;
      String errorDetails = '';
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
        isInitialized = true;
      } catch (e) {
        errorDetails = e.toString();
      }

      if (!isInitialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في تهيئة Firebase: $errorDetails', textDirection: TextDirection.rtl),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 10),
            ),
          );
        }
        return;
      }

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token;
        if (kIsWeb) {
          // You must replace YOUR_VAPID_KEY_HERE with your Web Push Certificate key from Firebase Console.
          token = await messaging.getToken(
            vapidKey: "BNIM9qYgyKLHkfitoD26U61zJIPw6kN1H6voIvt5xz3-9OCt6mWXQ-WBJcz_WHrNRx_qh0lJNkoU2lI2V2IVnWg"
          );
        } else {
          token = await messaging.getToken();
        }

        if (token != null) {
          debugPrint("FCM Token: $token");
          await _apiService.registerFCMToken(token);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تفعيل الجرس والاشتراك في الإشعارات بنجاح!', textDirection: TextDirection.rtl),
                backgroundColor: Color(0xFF0B3C87),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفض إذن الإشعارات من المتصفح.', textDirection: TextDirection.rtl),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error subscribing to notifications: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تفعيل الجرس: $e', textDirection: TextDirection.rtl),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
