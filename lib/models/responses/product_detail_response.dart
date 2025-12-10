import 'package:ecommerce_app/models/product.dart';

class ProductMerchantInfo {
  final String username;
  final String email;
  final String address;
  final String role;
  final String? profileUrl;
  final DateTime? createdAt;

  ProductMerchantInfo({
    required this.username,
    required this.email,
    required this.address,
    required this.role,
    this.profileUrl,
    this.createdAt,
  });

  factory ProductMerchantInfo.fromJson(Map<String, dynamic> json) {
    return ProductMerchantInfo(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'merchant',
      profileUrl: json['profile_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'address': address,
      'role': role,
      'profile_url': profileUrl,
    };
  }
}

class ProductDetailResponse {
  final Product product;
  final ProductMerchantInfo merchantInfo;
  final String? message;

  ProductDetailResponse({
    required this.product,
    required this.merchantInfo,
    this.message,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    final item =
        (json['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return ProductDetailResponse(
      product: Product.fromJson(
        item['product'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      merchantInfo: ProductMerchantInfo.fromJson(
        item['merchantInfo'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': {
        'product': product.toJson(),
        'merchantInfo': merchantInfo.toJson(),
      },
      'message': message,
    };
  }
}
