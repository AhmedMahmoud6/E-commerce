class Cart {
  final String id;
  final String userId;
  final List<String> productIds;
  final List<int> quantities;
  final DateTime? createdAt;

  Cart({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.quantities,
    this.createdAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
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

    return Cart(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      productIds: productIds,
      quantities: quantities,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productIds,
      'quantity': quantities,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}