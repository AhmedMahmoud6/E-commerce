import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';

class MerchantProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  List<Product> _merchantProducts = [];
  List<Order> _merchantOrders = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get merchantProducts => _merchantProducts;
  List<Order> get merchantOrders => _merchantOrders;
  bool get isLoading => _isLoading;
  String get error => _error;

  double get totalSales {
    return _merchantOrders.fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  int get totalOrders => _merchantOrders.length;
  int get totalProducts => _merchantProducts.length;

  Future<void> loadMerchantProducts(String merchantId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final allProducts = await _productService.getProducts();
        _merchantProducts = allProducts
          .where((product) => product.merchantId == merchantId)
          .toList();
      _error = '';
    } catch (e) {
      _error = 'Failed to load merchant products: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMerchantOrders(String merchantId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _merchantOrders = [
        Order(
          id: '101',
          userId: '1',
          productIds: ['1'],
          quantities: [2],
          totalPrice: 199.98,
          status: 'delivered',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      _error = '';
    } catch (e) {
      _error = 'Failed to load merchant orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    debugPrint('MerchantProvider.addProduct() called');

    try {
      final newProduct = await _productService.addProduct(product);
      debugPrint('Product added via service: ${newProduct.id}');

      _merchantProducts.insert(0, newProduct);
      debugPrint(
        ' Merchant products list updated. Count: ${_merchantProducts.length}',
      );

      notifyListeners();
      debugPrint('Listeners notified');
    } catch (e) {
      debugPrint(' Error in addProduct: $e');
      _error = 'Failed to add product: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    debugPrint(' MerchantProvider.updateProduct() called for: ${product.name}');

    try {
      final updatedProduct = await _productService.updateProduct(product);
      debugPrint(' ProductService returned: ${updatedProduct.name}');

      final index = _merchantProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _merchantProducts[index] = updatedProduct;
        debugPrint('Updated in local list');
        notifyListeners();
      } else {
        debugPrint(' Product not found in local list: ${product.id}');
      }
    } catch (e) {
      debugPrint(' Error in updateProduct: $e');
      _error = 'Failed to update product: ${e.toString()}';
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      _merchantProducts.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete product: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final index = _merchantOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final order = _merchantOrders[index];
        final updatedOrder = Order(
          id: order.id,
          userId: order.userId,
          productIds: order.productIds,
          quantities: order.quantities,
          totalPrice: order.totalPrice,
          status: status,
          createdAt: order.createdAt,
          updatedAt: DateTime.now(),
        );
        _merchantOrders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update order status: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}