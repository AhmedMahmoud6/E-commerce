class Category {
  final String id; 
  final String name;
  final String image;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.image,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'productCount': productCount,
    };
  }
}