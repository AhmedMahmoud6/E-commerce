import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartService {
  static const String _baseUrl = 'https://e-commerce-ibm.vercel.app/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Cart> fetchCart() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return Cart(
        id: '',
        userId: '',
        productIds: [],
        quantities: [],
        createdAt: null,
      );
    }
    final resp = await http.get(
      Uri.parse('$_baseUrl/cart'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      // Log unexpected status for debugging
      try {
        print(
          '[CartService.fetchCart] unexpected status ${resp.statusCode}: ${resp.body}',
        );
      } catch (_) {}
      return Cart(
        id: '',
        userId: '',
        productIds: [],
        quantities: [],
        createdAt: null,
      );
    }
    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      // Sometimes the backend returns a List or other shape; log it for debugging
      try {
        print('[CartService.fetchCart] unexpected body shape: ${resp.body}');
      } catch (_) {}
    }
    if (decoded is Map<String, dynamic>) {
      if (decoded['item'] is Map) {
        return Cart.fromJson((decoded['item'] as Map).cast<String, dynamic>());
      }
      if (decoded['cart'] is Map) {
        return Cart.fromJson((decoded['cart'] as Map).cast<String, dynamic>());
      }
      return Cart.fromJson(decoded.cast<String, dynamic>());
    }
    return Cart(
      id: '',
      userId: '',
      productIds: [],
      quantities: [],
      createdAt: null,
    );
  }

  Future<Cart?> addToCart(String productId, {int qty = 1}) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    final resp = await http.post(
      Uri.parse('$_baseUrl/cart'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({'product_id': productId, 'quantity': qty}),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to add to cart: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body);
    if (decoded is Map<String, dynamic>) {
      if (decoded['item'] is Map) {
        return Cart.fromJson((decoded['item'] as Map).cast<String, dynamic>());
      }
      if (decoded['cart'] is Map) {
        return Cart.fromJson((decoded['cart'] as Map).cast<String, dynamic>());
      }
      return Cart.fromJson(decoded.cast<String, dynamic>());
    }
    return null;
  }

  Future<Cart?> removeFromCart(String productId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    final resp = await http.delete(
      Uri.parse('$_baseUrl/cart/$productId'),
      headers: {'authorization': token},
    );
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      if (resp.body.isNotEmpty) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['item'] is Map) {
            return Cart.fromJson(
              (decoded['item'] as Map).cast<String, dynamic>(),
            );
          }
          if (decoded['cart'] is Map) {
            return Cart.fromJson(
              (decoded['cart'] as Map).cast<String, dynamic>(),
            );
          }
          if (decoded.containsKey('product_id')) {
            return Cart.fromJson(decoded.cast<String, dynamic>());
          }
        }
      }
      return null;
    }
    // Log unexpected delete response for debugging
    try {
      print(
        '[CartService.removeFromCart] delete returned ${resp.statusCode}: ${resp.body}',
      );
    } catch (_) {}
    final fallback = await http.post(
      Uri.parse('$_baseUrl/cart/remove'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({'product_id': productId}),
    );
    if (fallback.statusCode == 200 || fallback.statusCode == 204) {
      if (fallback.body.isNotEmpty) {
        final decoded = jsonDecode(fallback.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['item'] is Map) {
            return Cart.fromJson(
              (decoded['item'] as Map).cast<String, dynamic>(),
            );
          }
          if (decoded['cart'] is Map) {
            return Cart.fromJson(
              (decoded['cart'] as Map).cast<String, dynamic>(),
            );
          }
          if (decoded.containsKey('product_id')) {
            return Cart.fromJson(decoded.cast<String, dynamic>());
          }
        }
      }
      return null;
    }
    try {
      print(
        '[CartService.removeFromCart] fallback failed: ${fallback.statusCode}: ${fallback.body}',
      );
    } catch (_) {}
    throw Exception('Failed to remove from cart: ${resp.body}');
  }

  Future<Cart?> updateQuantity(String productId, int qty) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    final resp = await http.patch(
      Uri.parse('$_baseUrl/cart/$productId'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({'quantity': qty}),
    );
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['item'] is Map) {
          return Cart.fromJson(
            (decoded['item'] as Map).cast<String, dynamic>(),
          );
        }
        if (decoded['cart'] is Map) {
          return Cart.fromJson(
            (decoded['cart'] as Map).cast<String, dynamic>(),
          );
        }
        if (decoded.containsKey('product_id')) {
          return Cart.fromJson(decoded.cast<String, dynamic>());
        }
      }
      return null;
    }
    final fallback = await http.post(
      Uri.parse('$_baseUrl/cart/update'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({'product_id': productId, 'quantity': qty}),
    );
    if (fallback.statusCode == 200) {
      final decoded = jsonDecode(fallback.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['item'] is Map) {
          return Cart.fromJson(
            (decoded['item'] as Map).cast<String, dynamic>(),
          );
        }
        if (decoded['cart'] is Map) {
          return Cart.fromJson(
            (decoded['cart'] as Map).cast<String, dynamic>(),
          );
        }
        if (decoded.containsKey('product_id')) {
          return Cart.fromJson(decoded.cast<String, dynamic>());
        }
      }
      return null;
    }
    throw Exception('Failed to update cart quantity: ${resp.body}');
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
