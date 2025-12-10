import 'dart:math';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:ecommerce_app/models/wishlist_item.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/category.dart';

class MockApiService {
  static final Random _random = Random();

  static final List<User> _mockUsers = [
    User(
      id: '1',
      username: 'john_doe',
      email: 'member@test.com',
      password: 'password123',
      role: 'member',
      profileUrl: 'https://via.placeholder.com/150',
      address: '123 Main Street, New York, NY 10001',
      createdAt: DateTime.now().subtract(Duration(days: 100)),
    ),
    User(
      id: '2',
      username: 'alice_merchant',
      email: 'merchant@test.com',
      password: 'password123',
      role: 'merchant',
      profileUrl: 'https://via.placeholder.com/150',
      address: '456 Market Ave, Los Angeles, CA 90001',
      createdAt: DateTime.now().subtract(Duration(days: 80)),
    ),
    User(
      id: '3',
      username: 'admin_user',
      email: 'admin@test.com',
      password: 'password123',
      role: 'admin',
      profileUrl: 'https://via.placeholder.com/150',
      address: '789 Admin Blvd, Chicago, IL 60601',
      createdAt: DateTime.now().subtract(Duration(days: 50)),
    ),
  ];

  static final List<Category> _mockCategories = [
    Category(
      id: '1',
      name: 'Electronics',
      image: 'https://via.placeholder.com/150',
      productCount: 8,
    ),
    Category(
      id: '2',
      name: 'Fashion',
      image: 'https://via.placeholder.com/150',
      productCount: 6,
    ),
    Category(
      id: '3',
      name: 'Home',
      image: 'https://via.placeholder.com/150',
      productCount: 5,
    ),
    Category(
      id: '4',
      name: 'Sports',
      image: 'https://via.placeholder.com/150',
      productCount: 4,
    ),
    Category(
      id: '5',
      name: 'Books',
      image: 'https://via.placeholder.com/150',
      productCount: 3,
    ),
    Category(
      id: '6',
      name: 'Beauty',
      image: 'https://via.placeholder.com/150',
      productCount: 4,
    ),
  ];

  static final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Wireless Headphones',
      price: 99.99,
      description:
          'High-quality wireless headphones with noise cancellation and 30-hour battery life.',
      category: 'Electronics',
      imageUrl: 'https://via.placeholder.com/300',
      status: 'available',
      stock: 50,
      merchantId: '2',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now().subtract(Duration(days: 5)),
    ),
    Product(
      id: '2',
      name: 'Smart Watch Series 5',
      price: 199.99,
      description:
          'Advanced smartwatch with health monitoring, GPS, and water resistance.',
      category: 'Electronics',
      imageUrl: 'https://via.placeholder.com/300',
      status: 'available',
      stock: 30,
      merchantId: '2',
      createdAt: DateTime.now().subtract(Duration(days: 25)),
      updatedAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    Product(
      id: '3',
      name: 'Running Shoes',
      price: 79.99,
      description:
          'Comfortable running shoes with cushioning for all terrains.',
      category: 'Sports',
      imageUrl: 'https://via.placeholder.com/300',
      status: 'available',
      stock: 100,
      merchantId: '2',
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    Product(
      id: '4',
      name: 'Leather Backpack',
      price: 49.99,
      description:
          'Durable leather backpack for everyday use with laptop compartment.',
      category: 'Fashion',
      imageUrl: 'https://via.placeholder.com/300',
      status: 'available',
      stock: 75,
      merchantId: '2',
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    Product(
      id: '5',
      name: 'Coffee Maker',
      price: 89.99,
      description:
          'Automatic coffee maker with programmable settings and thermal carafe.',
      category: 'Home',
      imageUrl: 'https://via.placeholder.com/300',
      status: 'available',
      stock: 25,
      merchantId: '2',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<Cart> _mockCarts = [
    Cart(
      id: '1',
      userId: '1',
      productIds: ['1', '3', '4'],
      quantities: [2, 1, 3],
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
  ];

  static final List<Wishlist> _mockWishlists = [
    Wishlist(
      id: '1',
      userId: '1',
      productIds: ['1', '2', '5'],
      createdAt: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  static final List<Order> _mockOrders = [
    Order(
      id: '1',
      userId: '1',
      productIds: ['1', '3'],
      quantities: [1, 2],
      totalPrice: 259.97,
      status: 'pending',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      updatedAt: DateTime.now().subtract(Duration(days: 4)),
    ),
    Order(
      id: '2',
      userId: '1',
      productIds: ['2'],
      quantities: [1],
      totalPrice: 199.99,
      status: 'pending',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    Order(
      id: '3',
      userId: '1',
      productIds: ['4', '5'],
      quantities: [1, 1],
      totalPrice: 139.98,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

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