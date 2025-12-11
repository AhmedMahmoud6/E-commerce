import 'dart:convert';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class ProductService {
  static const String _baseUrl = "https://e-commerce-ibm.vercel.app/api";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Product>> getProducts({
    String? search,
    int limit = 50,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/products').replace(
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'limit': limit.toString(),
        'page': page.toString(),
      },
    );
    final resp = await http.get(uri);
    if (resp.statusCode == 404) {
      return <Product>[];
    }
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to fetch products: ${_extractErrorMessage(resp.body)}',
      );
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = (data['items'] as List?) ?? [];
    return items
        .map((e) => Product.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Product> getProductById(String id) async {
    final resp = await http.get(Uri.parse('$_baseUrl/products/$id'));
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch product: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final item =
        (data['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final productJson =
        (item['product'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    return Product.fromJson(productJson);
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final all = await getProducts();
    return all
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final products = await getProducts();
    final map = <String, int>{};
    for (final p in products) {
      final key = p.category;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map.entries
        .map(
          (e) => Category(
            id: e.key,
            name: e.key,
            image: '',
            productCount: e.value,
          ),
        )
        .toList();
  }

  Future<Product> addProduct(Product product) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode(product.toJson()),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to add product: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final item =
        (data['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return Product.fromJson(item);
  }

  Future<Product> updateProduct(Product product) async {
    debugPrint(' ProductService.updateProduct called with ID: ${product.id}');
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.put(
      Uri.parse('$_baseUrl/products/${product.id}'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode(product.toJson()),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to update product: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final item =
        (data['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return Product.fromJson(item);
  }

  Future<void> deleteProduct(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.delete(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete product: ${resp.body}');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts(search: query);
    return products;
  }

  String _extractErrorMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map && json['message'] is String)
        return json['message'] as String;
      return body;
    } catch (_) {
      return body;
    }
  }
}
