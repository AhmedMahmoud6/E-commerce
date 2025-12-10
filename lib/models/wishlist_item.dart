class Wishlist {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime? createdAt;

  Wishlist({
    required this.id,
    required this.userId,
    required this.productIds,
    this.createdAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
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

    return Wishlist(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      productIds: productIds,
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
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
