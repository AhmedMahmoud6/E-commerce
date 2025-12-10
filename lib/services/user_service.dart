import 'dart:convert';
import 'package:ecommerce_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = 'https://e-commerce-ibm.vercel.app/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<User>> getUsers() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.get(
      Uri.parse('$_baseUrl/profile/admin'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch users: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = (data['items'] as List?) ?? [];
    return items
        .map((e) => User.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> deleteUser(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.delete(
      Uri.parse('$_baseUrl/profile/$id/admin'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete user: ${resp.body}');
    }
  }
}
