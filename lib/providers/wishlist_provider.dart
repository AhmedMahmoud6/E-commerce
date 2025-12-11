import '../models/wishlist_item.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/wishlist_service.dart';
import '../services/product_service.dart';

class WishlistProvider with ChangeNotifier {
  Wishlist? _wishlist;
  List<Product> _wishlistProducts = [];
  final WishlistService _wishlistService = WishlistService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Wishlist? get wishlist => _wishlist;
  List<Product> get wishlistProducts => _wishlistProducts;
  int get itemCount => _wishlist?.productIds.length ?? 0;

  Future<void> _loadWishlistProducts(List<String> productIds) async {
    _wishlistProducts = [];
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
    _wishlistProducts = results.whereType<Product>().toList();
  }

  Future<void> addToWishlist(Product product, {String? currentUserId}) async {
    debugPrint('Adding to wishlist: ${product.name}');

    // If we don't yet have a wishlist object, try to call server first
    if (_wishlist == null ||
        (_wishlist!.productIds.isEmpty && _wishlist!.id == '')) {
      try {
        final updated = await _wishlistService.addToWishlist(product.id);
        if (updated != null) {
          // use server-provided user id if missing
          _wishlist = Wishlist(
            id: updated.id.isNotEmpty ? updated.id : (currentUserId ?? ''),
            userId: updated.userId.isNotEmpty
                ? updated.userId
                : (currentUserId ?? ''),
            productIds: updated.productIds,
            createdAt: updated.createdAt,
          );
          await _loadWishlistProducts(_wishlist!.productIds);
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Server add failed, falling back to optimistic update: $e');
      }
    }

    // Optimistic update: add locally then try to persist
    if (_wishlist == null) {
      _wishlist = Wishlist(id: '', userId: currentUserId ?? '', productIds: []);
    }
    if (!_wishlist!.productIds.contains(product.id)) {
      _wishlist!.productIds.add(product.id);
      _wishlistProducts.add(product);
      notifyListeners();
      try {
        final updated = await _wishlistService.addToWishlist(product.id);
        if (updated != null) {
          _wishlist = updated;
          await _loadWishlistProducts(_wishlist!.productIds);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Failed to persist wishlist add: $e');
      }
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    debugPrint('Removing from wishlist: $productId');
    if (_wishlist != null && _wishlist!.productIds.contains(productId)) {
      // optimistic remove
      _wishlist!.productIds.remove(productId);
      _wishlistProducts.removeWhere((product) => product.id == productId);
      notifyListeners();
      try {
        final updated = await _wishlistService.removeFromWishlist(productId);
        if (updated != null) {
          _wishlist = updated;
          await _loadWishlistProducts(_wishlist!.productIds);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Failed to persist wishlist remove: $e');
      }
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

  Future<void> loadWishlist({String? currentUserId}) async {
    debugPrint('Loading wishlist...');
    _isLoading = true;
    notifyListeners();
    try {
      final fetched = await _wishlistService.fetchWishlist();
      // Use server-supplied metadata when available; otherwise use currentUserId if provided
      final uid = fetched.userId.isNotEmpty
          ? fetched.userId
          : (currentUserId ?? '');
      _wishlist = Wishlist(
        id: fetched.id.isNotEmpty ? fetched.id : '',
        userId: uid,
        productIds: fetched.productIds,
        createdAt: fetched.createdAt,
      );
      await _loadWishlistProducts(_wishlist!.productIds);
      debugPrint('Wishlist loaded. Items: ${_wishlist!.productIds}');
    } catch (e) {
      debugPrint('Failed to load wishlist from API: $e');
      _wishlist = Wishlist(
        id: '',
        userId: currentUserId ?? '',
        productIds: [],
        createdAt: null,
      );
      _wishlistProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
