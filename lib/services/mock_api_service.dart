import 'dart:math';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:ecommerce_app/models/wishlist_item.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/category.dart';

class MockApiService {
  static final Random _random = Random();

  static final List<User> _mockUsers = [];

  static final List<Category> _mockCategories = [];

  static final List<Product> _mockProducts = [];

  static final List<Cart> _mockCarts = [];

  static final List<Wishlist> _mockWishlists = [];

  static final List<Order> _mockOrders = [];

  Future<Order> createOrderWithPendingStatus(dynamic data) async {
    await _simulateNetworkDelay();

    Order order;

    if (data is Order) {
      order = data;
    } else if (data is Map<String, dynamic>) {
      order = Order.fromJson(data);
    } else {
      throw Exception('Invalid data type for createOrder');
    }
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: order.userId,
      productIds: order.productIds,
      quantities: order.quantities,
      totalPrice: order.totalPrice,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockOrders.add(newOrder);
    return newOrder;
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }

  Future<User> login(String email, String password) async {
    await _simulateNetworkDelay();

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    try {
      final user = _mockUsers.firstWhere((user) => user.email == email);
      return user;
    } catch (e) {
      throw Exception('User not found or invalid credentials');
    }
  }

  Future<User> register(User newUser) async {
    await _simulateNetworkDelay();

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: newUser.username,
      email: newUser.email,
      password: newUser.password,
      profileUrl: newUser.profileUrl,
      address: newUser.address,
      role: newUser.role,
      createdAt: DateTime.now(),
    );

    _mockUsers.add(user);
    return user;
  }
  Future<List<Product>> getProducts() async {
    await _simulateNetworkDelay();
    return _mockProducts;
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    await _simulateNetworkDelay();
    return _mockProducts
        .where((product) => product.category == category)
        .toList();
  }

  Future<Product> getProductById(String id) async {
    await _simulateNetworkDelay();
    return _mockProducts.firstWhere((product) => product.id == id);
  }

  Future<Product> addProduct(dynamic data) async {
    await _simulateNetworkDelay();

    Product product;

    if (data is Product) {
      product = data;
    } else if (data is Map<String, dynamic>) {
      product = Product.fromJson(data);
    } else {
      throw Exception('Invalid data type for addProduct');
    }

    final newProduct = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: product.name,
      price: product.price,
      description: product.description,
      category: product.category,
      imageUrl: product.imageUrl,
      status: product.status,
      stock: product.stock,
      merchantId: product.merchantId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockProducts.add(newProduct);
    return newProduct;
  }

  Future<Product> updateProduct(dynamic data) async {
    await _simulateNetworkDelay();

    Product product;

    if (data is Product) {
      product = data;
    } else if (data is Map<String, dynamic>) {
      product = Product.fromJson(data);
    } else {
      throw Exception('Invalid data type for updateProduct');
    }

    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());

      _mockProducts[index] = updatedProduct;
      return updatedProduct;
    }

    throw Exception('Product not found: ${product.id}');
  }

  Future<void> deleteProduct(String id) async {
    await _simulateNetworkDelay();
    _mockProducts.removeWhere((product) => product.id == id);
  }

  Future<List<Category>> getCategories() async {
    await _simulateNetworkDelay();
    return _mockCategories;
  }

  Future<List<User>> getUsers() async {
    await _simulateNetworkDelay();
    return _mockUsers;
  }
  Future<User> updateUser(dynamic data) async {
    await _simulateNetworkDelay();

    User user;

    if (data is User) {
      user = data;
    } else if (data is Map<String, dynamic>) {
      user = User.fromJson(data);
    } else {
      throw Exception('Invalid data type for updateUser');
    }

    final index = _mockUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _mockUsers[index] = user;
    }
    return user;
  }

  Future<void> deleteUser(String id) async {
    await _simulateNetworkDelay();
    _mockUsers.removeWhere((user) => user.id == id);
  }

  Future<Cart> getUserCart(String userId) async {
    await _simulateNetworkDelay();
    return _mockCarts.firstWhere(
      (cart) => cart.userId == userId,
      orElse: () => Cart(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        productIds: [],
        quantities: [],
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<Cart> updateCart(dynamic data) async {
    await _simulateNetworkDelay();

    Cart cart;

    if (data is Cart) {
      cart = data;
    } else if (data is Map<String, dynamic>) {
      cart = Cart.fromJson(data);
    } else {
      throw Exception('Invalid data type for updateCart');
    }

    final index = _mockCarts.indexWhere((c) => c.id == cart.id);
    if (index != -1) {
      _mockCarts[index] = cart;
    } else {
      _mockCarts.add(cart);
    }
    return cart;
  }

  Future<Wishlist> getUserWishlist(String userId) async {
    await _simulateNetworkDelay();
    return _mockWishlists.firstWhere(
      (wishlist) => wishlist.userId == userId,
      orElse: () => Wishlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        productIds: [],
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<Wishlist> updateWishlist(dynamic data) async {
    await _simulateNetworkDelay();

    Wishlist wishlist;

    if (data is Wishlist) {
      wishlist = data;
    } else if (data is Map<String, dynamic>) {
      wishlist = Wishlist.fromJson(data);
    } else {
      throw Exception('Invalid data type for updateWishlist');
    }

    final index = _mockWishlists.indexWhere((w) => w.id == wishlist.id);
    if (index != -1) {
      _mockWishlists[index] = wishlist;
    } else {
      _mockWishlists.add(wishlist);
    }
    return wishlist;
  }

  Future<List<Order>> getUserOrders(String userId) async {
    await _simulateNetworkDelay();
    return _mockOrders.where((order) => order.userId == userId).toList();
  }

  Future<Order> createOrder(dynamic data) async {
    await _simulateNetworkDelay();

    Order order;

    if (data is Order) {
      order = data;
    } else if (data is Map<String, dynamic>) {
      order = Order.fromJson(data);
    } else {
      throw Exception('Invalid data type for createOrder');
    }

    final newOrder = Order(
      id: (order.id == '' || order.id == '0') ? DateTime.now().millisecondsSinceEpoch.toString() : order.id,
      userId: order.userId,
      productIds: order.productIds,
      quantities: order.quantities,
      totalPrice: order.totalPrice,
      status: 'pending',
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
    );

    _mockOrders.add(newOrder);
    return newOrder;
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    await _simulateNetworkDelay();
    final index = _mockOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _mockOrders[index];
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
      _mockOrders[index] = updatedOrder;
      return updatedOrder;
    }
    throw Exception('Order not found');
  }
}