import 'dart:convert';
import '../models/order.dart';
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
      throw Exception(
        'Failed to fetch orders: ${_extractErrorMessage(resp.body)}',
      );
    }
    final decoded = jsonDecode(resp.body);
    final List list = _extractListFromDecoded(decoded);
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
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 201) {
      throw Exception('Failed to create order: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final item =
        (data['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
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
      throw Exception(
        'Failed to fetch orders: ${_extractErrorMessage(resp.body)}',
      );
    }
    final decoded = jsonDecode(resp.body);
    final List list = _extractListFromDecoded(decoded);
    return list
        .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<Order>> getAllOrdersAdmin() async {
    final token = await _getToken();
    // Try admin-specific endpoints first so we don't accept a non-admin empty
    // response (e.g. the user's own /orders) and stop prematurely.
    final endpoint = '$_baseUrl/orders/admin';

    List<Order> lastParsed = <Order>[];

    try {
      final resp = await http.get(
        Uri.parse(endpoint),
        headers: token != null && token.isNotEmpty
            ? {'authorization': token}
            : {},
      );
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final List list = _extractListFromDecoded(decoded);
        final orders = list
            .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
        // If we found orders, return them immediately. Otherwise keep
        // searching other admin endpoints before falling back to an empty
        // user-scoped /orders response.
        if (orders.isNotEmpty) return orders;
        lastParsed = orders;

        return lastParsed;
      }
    } catch (_) {
      // ignore and try next endpoint
    }
    return lastParsed;
  }

  Future<List<Order>> getOrdersByMerchant(String merchantId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.get(
      Uri.parse('$_baseUrl/orders/merchant/$merchantId'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to fetch merchant orders: ${_extractErrorMessage(resp.body)}',
      );
    }
    final decoded = jsonDecode(resp.body);
    final List list = _extractListFromDecoded(decoded);
    return list
        .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  List _extractListFromDecoded(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      // direct lists
      if (decoded['items'] is List) return decoded['items'];
      if (decoded['orders'] is List) return decoded['orders'];
      if (decoded['data'] is List) return decoded['data'];

      // nested shapes
      if (decoded['item'] is List) return decoded['item'];
      if (decoded['result'] is List) return decoded['result'];

      // sometimes 'data' is an object with items
      final possible = decoded['data'];
      if (possible is Map && possible['items'] is List)
        return possible['items'];

      // fallback: search for first list value
      for (final v in decoded.values) {
        if (v is List) return v;
      }
    }
    return <dynamic>[];
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

  Future<Order> updateOrderStatus(String orderId, String status) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.patch(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({'status': status}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isNotEmpty) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) {
          final item =
              (decoded['item'] as Map?)?.cast<String, dynamic>() ??
              (decoded['order'] as Map?)?.cast<String, dynamic>() ??
              (decoded['data'] is Map && (decoded['data']['order'] is Map)
                  ? (decoded['data']['order'] as Map).cast<String, dynamic>()
                  : null);
          if (item != null) {
            return Order.fromJson(item);
          }
          if (decoded.containsKey('id') || decoded.containsKey('_id')) {
            return Order.fromJson(decoded.cast<String, dynamic>());
          }
        }
      }
      final getResp = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: {'authorization': token},
      );
      if (getResp.statusCode == 200) {
        final d = jsonDecode(getResp.body);
        if (d is Map<String, dynamic>) {
          final item =
              (d['item'] as Map?)?.cast<String, dynamic>() ??
              (d['order'] as Map?)?.cast<String, dynamic>() ??
              (d['data'] is Map && (d['data']['order'] is Map)
                  ? (d['data']['order'] as Map).cast<String, dynamic>()
                  : null);
          if (item != null) {
            return Order.fromJson(item);
          }
        }
      }
      throw Exception('Failed to parse updated order');
    }
    throw Exception(
      'Failed to update order status: ${_extractErrorMessage(resp.body)}',
    );
  }

  Future<void> clearCart() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;
    final resp = await http.delete(
      Uri.parse('$_baseUrl/cart'),
      headers: {'authorization': token},
    );
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    }
    await http.post(
      Uri.parse('$_baseUrl/cart/clear'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({}),
    );
  }
}
