import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  List<Order> _orders = [];
  Map<String, List<Product>> _orderProducts = {};
  bool _isLoading = false;
  String _error = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _orders = await _orderService.getUserOrders();
      _error = '';
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(Order newOrder, List<Product> orderProducts) async {
    try {
      final order = await _orderService.createOrder(newOrder);
      _orders.insert(0, order);
      _orderProducts[order.id] = orderProducts;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create order: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = Order(
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

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<Product>? getOrderProducts(String orderId) {
    return _orderProducts[orderId];
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> loadOrderProducts(String orderId) async {
    try {
      final order = getOrderById(orderId);
      if (order == null) return;
      final products = <Product>[];
      for (final pid in order.productIds) {
        final p = await _productService.getProductById(pid);
        products.add(p);
      }
      _orderProducts[orderId] = products;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load order products: ${e.toString()}';
      notifyListeners();
    }
  }
}
