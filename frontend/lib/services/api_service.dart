import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // استخدم 10.0.2.2 للمحاكي (Android Emulator)

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

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories/'));
      
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
}
