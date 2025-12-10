import 'dart:convert';
import 'package:ecommerce_app/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String _baseUrl = 'https://e-commerce-ibm.vercel.app/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Order>> getUserOrders() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.get(
      Uri.parse('$_baseUrl/orders'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch orders: ${_extractErrorMessage(resp.body)}');
    }
    final decoded = jsonDecode(resp.body);
    final List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      list = (decoded['items'] ?? decoded['orders'] ?? decoded['data'] ?? []) as List;
    } else {
      list = [];
    }
    return list
        .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Order> createOrder(Order order) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final payload = {
      'product_id': order.productIds,
      'quantity': order.quantities,
    };
    final resp = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': token,
      },
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 201) {
      throw Exception('Failed to create order: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final item = (data['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return Order.fromJson(item);
  }

  Future<List<Order>> getOrders() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.get(
      Uri.parse('$_baseUrl/orders'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch orders: ${_extractErrorMessage(resp.body)}');
    }
    final decoded = jsonDecode(resp.body);
    final List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      list = (decoded['items'] ?? decoded['orders'] ?? decoded['data'] ?? []) as List;
    } else {
      list = [];
    }
    return list
        .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  String _extractErrorMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map && json['message'] is String) return json['message'] as String;
      return body;
    } catch (_) {
      return body;
    }
  }
}
