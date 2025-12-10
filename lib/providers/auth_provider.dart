import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String _error = '';

  final AuthService _authService = AuthService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> login(String email, String password, String role) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(User newUser) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.register(newUser);
      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}