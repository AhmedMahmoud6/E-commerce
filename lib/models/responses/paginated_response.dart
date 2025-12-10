class PaginatedResponse<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final String? message;

  PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    this.message,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    List<T> Function(List<dynamic> jsonList) fromJsonList,
  ) {
    return PaginatedResponse<T>(
      items: json['items'] != null
          ? fromJsonList(List<dynamic>.from(json['items']))
          : <T>[],
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson(
      List<dynamic> Function(List<T> items) toJsonList) {
    return {
      'items': toJsonList(items),
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'message': message,
    };
  }
}
