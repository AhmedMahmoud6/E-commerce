import 'dart:convert';
import 'package:ecommerce_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://e-commerce-ibm.vercel.app/api';

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<User> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode != 200) {
      String msg;
      try {
        final err = jsonDecode(resp.body) as Map<String, dynamic>;
        msg = err['message']?.toString() ?? 'Login failed';
      } catch (_) {
        msg = 'Login failed';
      }
      throw Exception(msg);
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Login failed: token missing');
    }
    await _setToken(token);
    return await getProfile();
  }

  Future<User> register(User newUser) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newUser.toJson()),
    );
    if (resp.statusCode != 201) {
      String msg;
      try {
        final err = jsonDecode(resp.body) as Map<String, dynamic>;
        msg = err['message']?.toString() ?? 'Registration failed';
      } catch (_) {
        msg = 'Registration failed';
      }
      throw Exception(msg);
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final item =
        (data['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return User.fromJson(item);
  }

  Future<User> getProfile() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final resp = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {'authorization': token},
    );
    if (resp.statusCode != 200) {
      throw Exception('Profile fetch failed: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final item =
        (data['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return User.fromJson(item);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}