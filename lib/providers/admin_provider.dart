import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/user_service.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';

class AdminProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  List<User> _users = [];
  List<Product> _allProducts = [];
  List<Order> _allOrders = [];
  bool _isLoading = false;
  String _error = '';

  List<User> get users => _users;
  List<Product> get allProducts => _allProducts;
  List<Order> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String get error => _error;

  int get totalUsers => _users.length;
  int get totalProducts => _allProducts.length;
  int get totalOrders => _allOrders.length;

  double get totalRevenue {
    return _allOrders.fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _users = await _userService.getUsers();
      _error = '';
    } catch (e) {
      _error = 'Failed to load users: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allProducts = await _productService.getProducts(limit: 1000);
      await _computeMissingOrderTotalsAsync();
      _error = '';
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allOrders = await _orderService.getOrders();
      if (_allProducts.isEmpty) {
        _allProducts = await _productService.getProducts(limit: 1000);
      }
      await _computeMissingOrderTotalsAsync();
      _error = '';
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> deleteUser(String id) async {
    try {
      await _userService.deleteUser(id);
      _users.removeWhere((user) => user.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete user: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      _allProducts.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete product: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _allOrders[index];
      _allOrders[index] = Order(
        id: order.id,
        userId: order.userId,
        productIds: order.productIds,
        quantities: order.quantities,
        totalPrice: order.totalPrice,
        status: status,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> _computeMissingOrderTotalsAsync() async {
    if (_allOrders.isEmpty) return;
    final priceMap = <String, double>{ for (final p in _allProducts) p.id: p.price };
    for (var i = 0; i < _allOrders.length; i++) {
      final order = _allOrders[i];
      if (order.totalPrice > 0) continue;
      double sum = 0.0;
      for (var j = 0; j < order.productIds.length; j++) {
        final pid = order.productIds[j];
        final qty = (j < order.quantities.length) ? order.quantities[j] : 1;
        var price = priceMap[pid];
        if (price == null) {
          try {
            final p = await _productService.getProductById(pid);
            price = p.price;
            priceMap[pid] = price;
          } catch (_) {
            price = 0.0;
          }
        }
        sum += price * qty;
      }
      _allOrders[i] = Order(
        id: order.id,
        userId: order.userId,
        productIds: order.productIds,
        quantities: order.quantities,
        totalPrice: sum,
        status: order.status,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      );
    }
  }
}