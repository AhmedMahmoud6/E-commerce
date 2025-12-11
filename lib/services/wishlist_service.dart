import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_item.dart';

class WishlistService {
  static const String _baseUrl = "https://e-commerce-ibm.vercel.app/api";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Fetch wishlist from backend. Returns a Wishlist object when possible.
  Future<Wishlist> fetchWishlist() async {
    final token = await _getToken();
    if (token == null || token.isEmpty)
      return Wishlist(id: '', userId: '', productIds: []);

    final resp = await http.get(
      Uri.parse('$_baseUrl/wishlist'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      return Wishlist(id: '', userId: '', productIds: []);
    }

    final decoded = jsonDecode(resp.body);

    // If response is directly a wishlist object
    if (decoded is Map<String, dynamic>) {
      // If it contains product list directly
      if (decoded.containsKey('product_id') ||
          decoded.containsKey('productIds') ||
          decoded.containsKey('product_id')) {
        return Wishlist.fromJson(decoded);
      }

      // common envelope shapes
      if (decoded['item'] is Map)
        return Wishlist.fromJson(
          (decoded['item'] as Map).cast<String, dynamic>(),
        );
      if (decoded['wishlist'] is Map)
        return Wishlist.fromJson(
          (decoded['wishlist'] as Map).cast<String, dynamic>(),
        );
      if (decoded['data'] is Map && decoded['data']['wishlist'] is Map)
        return Wishlist.fromJson(
          (decoded['data']['wishlist'] as Map).cast<String, dynamic>(),
        );

      // If it contains product_id as a list under 'item' or 'data'
      if (decoded['item'] is List) {
        return Wishlist(
          id: '',
          userId: '',
          productIds: List<String>.from(
            decoded['item'].map((e) => e.toString()),
          ),
          createdAt: null,
        );
      }
    }

    // If response is list of ids
    if (decoded is List) {
      final ids = decoded.map((e) => e.toString()).toList();
      return Wishlist(id: '', userId: '', productIds: ids, createdAt: null);
    }

    return Wishlist(id: '', userId: '', productIds: [], createdAt: null);
  }

  /// Add product to wishlist. Returns updated Wishlist when backend provides it, otherwise null.
  Future<Wishlist?> addToWishlist(String productId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    final resp = await http.post(
      Uri.parse('$_baseUrl/wishlist'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({'product_id': productId}),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to add to wishlist: ${resp.body}');
    }
    try {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['item'] is Map)
          return Wishlist.fromJson(
            (decoded['item'] as Map).cast<String, dynamic>(),
          );
        if (decoded['wishlist'] is Map)
          return Wishlist.fromJson(
            (decoded['wishlist'] as Map).cast<String, dynamic>(),
          );
        if (decoded.containsKey('product_id') ||
            decoded.containsKey('productIds'))
          return Wishlist.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {}
    return null;
  }

  /// Remove product from wishlist. Returns updated Wishlist when backend provides it, otherwise null.
  Future<Wishlist?> removeFromWishlist(String productId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    final resp = await http.delete(
      Uri.parse('$_baseUrl/wishlist/$productId'),
      headers: {'authorization': token},
    );
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      try {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
        if (decoded is Map<String, dynamic>) {
          if (decoded['item'] is Map)
            return Wishlist.fromJson(
              (decoded['item'] as Map).cast<String, dynamic>(),
            );
          if (decoded['wishlist'] is Map)
            return Wishlist.fromJson(
              (decoded['wishlist'] as Map).cast<String, dynamic>(),
            );
          if (decoded.containsKey('product_id'))
            return Wishlist.fromJson(decoded.cast<String, dynamic>());
        }
      } catch (_) {}
      return null;
    }

    // fallback: try a remove POST
    final fallback = await http.post(
      Uri.parse('$_baseUrl/wishlist/remove'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: jsonEncode({'product_id': productId}),
    );
    if (fallback.statusCode == 200 || fallback.statusCode == 204) {
      try {
        final decoded = fallback.body.isNotEmpty
            ? jsonDecode(fallback.body)
            : null;
        if (decoded is Map<String, dynamic>) {
          if (decoded['item'] is Map)
            return Wishlist.fromJson(
              (decoded['item'] as Map).cast<String, dynamic>(),
            );
          if (decoded['wishlist'] is Map)
            return Wishlist.fromJson(
              (decoded['wishlist'] as Map).cast<String, dynamic>(),
            );
          if (decoded.containsKey('product_id'))
            return Wishlist.fromJson(decoded.cast<String, dynamic>());
        }
      } catch (_) {}
      return null;
    }

    throw Exception('Failed to remove from wishlist: ${resp.body}');
  }
}
