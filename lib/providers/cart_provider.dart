import 'package:ecommerce_app/models/cart_item.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  Cart? _cart;
  List<Product> _cartProducts = [];
  double _totalPrice = 0.0;

  Cart? get cart => _cart;
  List<Product> get cartProducts => _cartProducts;
  double get totalPrice => _totalPrice;
  int get itemCount => _cart?.productIds.length ?? 0;
  Future<void> _loadCartProducts(List<String> productIds) async {
    _cartProducts = [
      Product(
        id: '1',
        name: 'Wireless Bluetooth Headphones',
        price: 99.99,
        description: 'High-quality wireless headphones',
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/300',
        status: 'available',
        stock: 50,
        merchantId: '2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ].where((product) => productIds.contains(product.id)).toList();
  }

  void addToCart(Product product) {
    debugPrint('Adding to cart: ${product.name}');

    if (_cart == null) {
      _cart = Cart(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        productIds: [product.id],
        quantities: [1],
      );
      debugPrint('Created new cart');
    } else {
      final index = _cart!.productIds.indexWhere((id) => id == product.id);

      if (index >= 0) {
        final newQuantities = List<int>.from(_cart!.quantities);
        newQuantities[index] = newQuantities[index] + 1;

        _cart = Cart(
          id: _cart!.id,
          userId: _cart!.userId,
          productIds: _cart!.productIds,
          quantities: newQuantities,
          createdAt: _cart!.createdAt,
        );
        debugPrint('Increased quantity for ${product.name}');
      } else {
        final newProductIds = List<String>.from(_cart!.productIds)
          ..add(product.id);
        final newQuantities = List<int>.from(_cart!.quantities)..add(1);

        _cart = Cart(
          id: _cart!.id,
          userId: _cart!.userId,
          productIds: newProductIds,
          quantities: newQuantities,
        );
        debugPrint('Added new product: ${product.name}');
      }
    }

    if (!_cartProducts.any((p) => p.id == product.id)) {
      _cartProducts.add(product);
      debugPrint('Added to cartProducts: ${product.name}');
    }

    _calculateTotal();
    notifyListeners();

    debugPrint(' Cart updated. Items: ${_cart?.productIds}');
    debugPrint(' Total price: $_totalPrice');
  }

  void removeFromCart(String productId) {
    debugPrint('Removing from cart: $productId');

    if (_cart == null) return;

    final index = _cart!.productIds.indexWhere((id) => id == productId);
    if (index >= 0) {
      final newProductIds = List<String>.from(_cart!.productIds)
        ..removeAt(index);
      final newQuantities = List<int>.from(_cart!.quantities)..removeAt(index);

      _cart = Cart(
        id: _cart!.id,
        userId: _cart!.userId,
        productIds: newProductIds,
        quantities: newQuantities,
        createdAt: _cart!.createdAt,
      );

      _cartProducts.removeWhere((product) => product.id == productId);

      _calculateTotal();
      notifyListeners();

      debugPrint('Removed from cart: $productId');
    }
  }

  void updateQuantity(String productId, int newQuantity) {
    debugPrint('Updating quantity: $productId -> $newQuantity');

    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    if (_cart == null) return;

    final index = _cart!.productIds.indexWhere((id) => id == productId);
    if (index >= 0) {
      final newQuantities = List<int>.from(_cart!.quantities);
      newQuantities[index] = newQuantity;

      _cart = Cart(
        id: _cart!.id,
        userId: _cart!.userId,
        productIds: _cart!.productIds,
        quantities: newQuantities,
        createdAt: _cart!.createdAt,
      );

      _calculateTotal();
      notifyListeners();

      debugPrint('Quantity updated');
    }
  }

  void clearCart() {
    debugPrint(' Clearing cart');
    _cart = null;
    _cartProducts.clear();
    _totalPrice = 0.0;
    notifyListeners();
    debugPrint(' Cart cleared');
  }

  void _calculateTotal() {
    if (_cart == null) {
      _totalPrice = 0.0;
      return;
    }

    double total = 0.0;
    for (int i = 0; i < _cart!.productIds.length; i++) {
      final product = _cartProducts.firstWhere(
        (p) => p.id == _cart!.productIds[i],
        orElse: () => Product(
          id: _cart!.productIds[i],
          name: 'Unknown',
          price: 0.0,
          description: '',
          category: '',
          imageUrl: '',
          status: 'available',
          stock: 0,
          merchantId: '0',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      total += product.price * _cart!.quantities[i];
    }
    _totalPrice = total;
  }

  bool isInCart(String productId) {
    final result = _cart?.productIds.contains(productId) ?? false;
    debugPrint('isInCart($productId): $result');
    return result;
  }

  Future<void> loadCart() async {
    debugPrint('Loading cart...');

    await Future.delayed(Duration(seconds: 1));

    _cart = Cart(
      id: '1',
      userId: '1',
      productIds: ['1', '2'],
      quantities: [2, 1],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    );

    await _loadCartProducts(_cart!.productIds);
    _calculateTotal();
    notifyListeners();

    debugPrint('Cart loaded. Items: ${_cart!.productIds}');
  }
}
