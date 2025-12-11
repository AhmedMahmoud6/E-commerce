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
    // Compute total sales for this merchant from actual ordered products
    // (order.totalPrice may include items from other merchants).
    if (_merchantProducts.isEmpty || _merchantOrders.isEmpty) return 0.0;
    final priceById = {for (var p in _merchantProducts) p.id: p.price};
    double total = 0.0;
    for (final order in _merchantOrders) {
      for (int i = 0; i < order.productIds.length; i++) {
        final pid = order.productIds[i];
        final qty = (i < order.quantities.length) ? order.quantities[i] : 1;
        final price = priceById[pid];
        if (price != null) total += price * qty;
      }
    }
    return total;
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
      // Load merchant products first (used for filtering and sales calc)
      List<Product> products = [];
      try {
        final allProducts = await _productService.getProducts();
        products = allProducts
            .where((p) => p.merchantId == merchantId)
            .toList();
        _merchantProducts = products;
      } catch (e) {
        debugPrint('Failed to load merchant products while loading orders: $e');
      }

      // Prefer the merchant-specific endpoint we just added.
      List<Order> allOrders = [];
      try {
        allOrders = await _orderService.getOrdersByMerchant(merchantId);
      } catch (_) {
        // fall back to other endpoints if merchant endpoint unavailable
        try {
          allOrders = await _orderService.getAllOrdersAdmin();
        } catch (_) {}
        if (allOrders.isEmpty) {
          try {
            allOrders = await _orderService.getOrders();
          } catch (_) {}
        }
        if (allOrders.isEmpty) {
          try {
            allOrders = await _orderService.getUserOrders();
          } catch (_) {}
        }
      }

      final merchantProductIds = products.map((p) => p.id).toSet();
      _merchantOrders = allOrders
          .where(
            (o) => o.productIds.any((pid) => merchantProductIds.contains(pid)),
          )
          .toList();
      debugPrint(
        'Merchant orders loaded: ${_merchantOrders.length} for merchant $merchantId',
      );
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
      final updated = await _orderService.updateOrderStatus(orderId, status);
      final index = _merchantOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _merchantOrders[index] = updated;
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
