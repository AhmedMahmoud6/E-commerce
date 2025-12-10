import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  String _userRole = 'member';

  int get currentIndex => _currentIndex;
  String get userRole => _userRole;

  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
    _userRole = 'member';
    notifyListeners();
  }
}