class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final String status;
  final int stock;
  final String merchantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.status = 'available',
    required this.stock,
    required this.merchantId,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    String? imageUrl,
    String? status,
    int? stock,
    String? merchantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      stock: stock ?? this.stock,
      merchantId: merchantId ?? this.merchantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['_id'];
    final idStr = idValue == null ? '' : idValue.toString();

    final dynamic p = json['price'];
    double parsedPrice;
    if (p is num) {
      parsedPrice = p.toDouble();
    } else if (p is String) {
      parsedPrice = double.tryParse(p) ?? 0.0;
    } else if (p is Map && p.containsKey('\$numberDecimal')) {
      parsedPrice = double.tryParse(p['\$numberDecimal']?.toString() ?? '') ?? 0.0;
    } else {
      parsedPrice = 0.0;
    }

    return Product(
      id: idStr,
      name: json['name'] ?? '',
      price: parsedPrice,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      status: json['status'] ?? 'available',
      stock: (json['stock'] is int)
          ? json['stock']
          : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      merchantId: (json['merchant_id'] ?? json['merchantId'])?.toString() ?? '',
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
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'status': status,
      'stock': stock,
      'merchant_id': merchantId,
    };
  }
}