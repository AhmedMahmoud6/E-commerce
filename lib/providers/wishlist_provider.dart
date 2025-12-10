import 'package:ecommerce_app/models/wishlist_item.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  Wishlist? _wishlist;
  List<Product> _wishlistProducts = [];

  Wishlist? get wishlist => _wishlist;
  List<Product> get wishlistProducts => _wishlistProducts;
  int get itemCount => _wishlist?.productIds.length ?? 0;

  Future<void> _loadWishlistProducts(List<String> productIds) async {
    _wishlistProducts = [
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
      Product(
        id: '2',
        name: 'Smart Watch Series 5',
        price: 199.99,
        description: 'Advanced smartwatch',
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/300',
        status: 'available',
        stock: 30,
        merchantId: '2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ].where((product) => productIds.contains(product.id)).toList();
  }

  void addToWishlist(Product product) {
    debugPrint('Adding to wishlist: ${product.name}');

    if (_wishlist == null) {
      _wishlist = Wishlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        productIds: [product.id],
        createdAt: DateTime.now(),
      );
    }

    if (!_wishlist!.productIds.contains(product.id)) {
      _wishlist!.productIds.add(product.id);
      _wishlistProducts.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    debugPrint('Removing from wishlist: $productId');

    if (_wishlist != null && _wishlist!.productIds.contains(productId)) {
      _wishlist!.productIds.remove(productId);
      _wishlistProducts.removeWhere((product) => product.id == productId);
      notifyListeners();
    }
  }

  bool isInWishlist(String productId) {
    final result = _wishlist?.productIds.contains(productId) ?? false;
    debugPrint('isInWishlist($productId): $result');
    return result;
  }

  void clearWishlist() {
    debugPrint('Clearing wishlist');
    _wishlist = null;
    _wishlistProducts.clear();
    notifyListeners();
    debugPrint('Wishlist cleared');
  }

  Future<void> loadWishlist() async {
    debugPrint('Loading wishlist...');

    await Future.delayed(Duration(seconds: 1));

    _wishlist = Wishlist(
      id: '1',
      userId: '1',
      productIds: ['1', '2', '3'],
      createdAt: DateTime.now().subtract(Duration(days: 5)),
    );

    await _loadWishlistProducts(_wishlist!.productIds);
    notifyListeners();

    debugPrint('Wishlist loaded. Items: ${_wishlist!.productIds}');
  }
}
