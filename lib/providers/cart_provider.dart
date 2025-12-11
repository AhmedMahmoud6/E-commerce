import '../models/cart_item.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';

class CartProvider with ChangeNotifier {
  Cart? _cart;
  List<Product> _cartProducts = [];
  double _totalPrice = 0.0;
  final CartService _cartService = CartService();
  bool _isLoading = false;

  Cart? get cart => _cart;
  List<Product> get cartProducts => _cartProducts;
  double get totalPrice => _totalPrice;
  int get itemCount => _cart?.productIds.length ?? 0;
  bool get isLoading => _isLoading;
  Future<void> _loadCartProducts(List<String> productIds) async {
    _cartProducts = [];
    if (productIds.isEmpty) return;
    final productService = ProductService();
    final futures = <Future<Product?>>[];
    for (final id in productIds) {
      futures.add(() async {
        try {
          return await productService.getProductById(id);
        } catch (_) {
          return null;
        }
      }());
    }
    final results = await Future.wait<Product?>(futures);
    // Preserve order and create placeholder objects for any products
    // that failed to load so the UI can still render the cart items.
    final loaded = results;
    final List<Product> resolved = [];
    for (int i = 0; i < productIds.length; i++) {
      final p = (i < loaded.length) ? loaded[i] : null;
      if (p != null) {
        resolved.add(p);
      } else {
        resolved.add(
          Product(
            id: productIds[i],
            name: 'Unknown product',
            price: 0.0,
            description: '',
            category: '',
            imageUrl: '',
            status: 'unknown',
            stock: 0,
            merchantId: '0',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    _cartProducts = resolved;
  }

  Future<void> addToCart(Product product) async {
    debugPrint('Adding to cart: ${product.name}');

    if (_cart == null) {
      _cart = Cart(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _cart?.userId ?? '',
        productIds: [product.id],
        quantities: [1],
      );
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
      }
    }

    if (!_cartProducts.any((p) => p.id == product.id)) {
      _cartProducts.add(product);
    }

    _calculateTotal();
    notifyListeners();

    try {
      final updated = await _cartService.addToCart(product.id, qty: 1);
      if (updated != null) {
        _cart = updated;
        await _loadCartProducts(_cart!.productIds);
        _calculateTotal();
        notifyListeners();
      } else {
        final fetched = await _cartService.fetchCart();
        _cart = fetched;
        await _loadCartProducts(_cart!.productIds);
        _calculateTotal();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to persist cart add: $e');
      try {
        final fetched = await _cartService.fetchCart();
        _cart = fetched;
        await _loadCartProducts(_cart!.productIds);
        _calculateTotal();
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> removeFromCart(String productId) async {
    debugPrint('Removing from cart: $productId');

    if (_cart == null) return;
    final index = _cart!.productIds.indexWhere((id) => id == productId);
    if (index < 0) return;

    // Snapshot current state so we can restore on failure
    final previousCart = _cart!;
    final previousCartProducts = List<Product>.from(_cartProducts);

    // Optimistic local removal
    final newProductIds = List<String>.from(_cart!.productIds)..removeAt(index);
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

    try {
      final updated = await _cartService.removeFromCart(productId);

      // If service returned an updated cart, apply it. Otherwise fetch server state.
      Cart serverCart;
      if (updated != null) {
        serverCart = updated;
      } else {
        serverCart = await _cartService.fetchCart();
      }

      // Defensive validation: if the server returned an empty cart while our
      // previous cart had items (i.e. the server response looks suspicious),
      // do not blindly apply it. Try to re-fetch; if still empty, restore the
      // previous snapshot to avoid wiping the UI.
      if (serverCart.productIds.isEmpty && previousCart.productIds.isNotEmpty) {
        debugPrint(
            'Warning: server returned empty cart after remove; verifying with fetch...');
        try {
          final fetched = await _cartService.fetchCart();
          if (fetched.productIds.isNotEmpty) {
            _cart = fetched;
          } else {
            debugPrint('Fetch also returned empty cart — restoring previous snapshot');
            _cart = previousCart;
            _cartProducts = previousCartProducts;
          }
        } catch (e) {
          debugPrint('Fetch failed while validating server cart: $e');
          _cart = previousCart;
          _cartProducts = previousCartProducts;
        }
        _calculateTotal();
        notifyListeners();
        return;
      }

      _cart = serverCart;
      debugPrint('Server cart after remove: ${_cart?.productIds}');
      await _loadCartProducts(_cart!.productIds);
      _calculateTotal();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to persist cart remove: $e');
      // Restore previous state to keep UI consistent with server
      _cart = previousCart;
      _cartProducts = previousCartProducts;
      _calculateTotal();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    debugPrint('Updating quantity: $productId -> $newQuantity');

    if (newQuantity <= 0) {
      await removeFromCart(productId);
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

      try {
        final updated = await _cartService.updateQuantity(
          productId,
          newQuantity,
        );
        if (updated != null) {
          _cart = updated;
          await _loadCartProducts(_cart!.productIds);
          _calculateTotal();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Failed to persist cart quantity update: $e');
      }
    }
  }

  Future<void> clearCart() async {
    debugPrint(' Clearing cart');
    try {
      await _cartService.clearCart();
    } catch (e) {
      debugPrint('Failed to persist cart clear: $e');
    }
    _cart = Cart(
      id: '',
      userId: '',
      productIds: [],
      quantities: [],
      createdAt: null,
    );
    _cartProducts.clear();
    _totalPrice = 0.0;
    notifyListeners();
    try {
      final fetched = await _cartService.fetchCart();
      _cart = fetched;
      await _loadCartProducts(_cart!.productIds);
      _calculateTotal();
      notifyListeners();
    } catch (_) {}
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
    _isLoading = true;
    notifyListeners();
    try {
      final fetched = await _cartService.fetchCart();
      _cart = fetched;
      await _loadCartProducts(_cart!.productIds);
      _calculateTotal();
      debugPrint('Cart loaded. Items: ${_cart!.productIds}');
    } catch (e) {
      debugPrint('Failed to load cart from API: $e');
      _cart = Cart(
        id: '',
        userId: '',
        productIds: [],
        quantities: [],
        createdAt: null,
      );
      _cartProducts = [];
      _totalPrice = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
