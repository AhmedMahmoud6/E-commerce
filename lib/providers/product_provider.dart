import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/category.dart' as models;
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _allProducts = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allProducts = await _productService.getProducts();
      _products = List<Product>.from(_allProducts);
      _error = '';
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      if (_allProducts.isEmpty) {
        _allProducts = await _productService.getProducts();
        _products = List<Product>.from(_allProducts);
      }
      final map = <String, int>{};
      for (final p in _allProducts) {
        final key = p.category;
        map[key] = (map[key] ?? 0) + 1;
      }
      _categories = map.entries
          .map((e) => models.Category(id: e.key, name: e.key, image: '', productCount: e.value))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load categories: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _products = List<Product>.from(_allProducts);
      } else {
        _products = await _productService.searchProducts(query);
      }
      _error = '';
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await _productService.addProduct(product);
      _products.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add product: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final updatedProduct = await _productService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update product: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete product: ${e.toString()}';
      notifyListeners();
    }
  }

  void filterByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      _products = List<Product>.from(_allProducts);
    } else {
      _products = _allProducts
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}