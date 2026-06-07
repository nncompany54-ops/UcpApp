import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://ucp.moha85awad.site/api';

  Future<List<Product>> fetchProducts({String? search, Map<String, dynamic>? filters}) async {
    try {
      String url = '$baseUrl/products/';
      Map<String, String> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) queryParams[key] = value.toString();
        });
      }

      if (queryParams.isNotEmpty) {
        url += '?' + Uri(queryParameters: queryParams).query;
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('فشل في تحميل المنتجات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories({int? companyId}) async {
    try {
      String url = '$baseUrl/categories/';
      if (companyId != null) {
        url += '?company=$companyId';
      }
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(body);
      } else {
        throw Exception('فشل في تحميل الأقسام');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCompanies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/companies/'));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(body);
      } else {
        throw Exception('فشل في تحميل الشركات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/banners/'));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(body);
      } else {
        throw Exception('فشل في تحميل السلايدر');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<void> registerFCMToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm-devices/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشل تسجيل رمز الجهاز على الخادم: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في تسجيل الرمز: $e');
    }
  }
}
