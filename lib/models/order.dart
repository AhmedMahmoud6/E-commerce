import 'package:ecommerce_app/models/product.dart';

class Order {
  final String id;
  final String userId;
  final List<String> productIds;
  final List<int> quantities;
  final String status;
  final double totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.quantities,
    this.status = 'pending',
    required this.totalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<String> productIds = [];
    if (json['product_id'] is List) {
      productIds = List<String>.from(
        json['product_id'].map((x) => x is Map
            ? ((x['id'] ?? x['_id'])?.toString() ?? '')
            : x.toString()),
      );
    } else if (json['product_id'] is String) {
      productIds = (json['product_id'] as String)
          .split(',')
          .map((s) => s.trim())
          .toList();
    }

    List<int> quantities = [];
    if (json['quantity'] is List) {
      quantities = List<int>.from(
        json['quantity'].map(
          (x) => x is int ? x : int.tryParse(x.toString()) ?? 1,
        ),
      );
    } else if (json['quantity'] is String) {
      quantities = (json['quantity'] as String)
          .split(',')
          .map((s) => int.tryParse(s.trim()) ?? 1)
          .toList();
    }

    final dynamic tp = json['total_price'];
    double parsedTotal;
    if (tp is num) {
      parsedTotal = tp.toDouble();
    } else if (tp is String) {
      parsedTotal = double.tryParse(tp) ?? 0.0;
    } else if (tp is Map && tp.containsKey('\$numberDecimal')) {
      parsedTotal = double.tryParse(tp['\$numberDecimal']?.toString() ?? '') ?? 0.0;
    } else {
      parsedTotal = 0.0;
    }

    return Order(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      productIds: productIds,
      quantities: quantities,
      totalPrice: parsedTotal,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productIds,
      'quantity': quantities,
      'total_price': totalPrice,
      'status': status,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] ?? json['product_id'])?.toString() ?? '',
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  double get itemTotal => price * quantity;
}