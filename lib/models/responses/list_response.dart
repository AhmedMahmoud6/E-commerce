class ListResponse<T> {
  final List<T> items;
  final String? message;

  ListResponse({required this.items, this.message});

  factory ListResponse.fromJson(Map<String, dynamic> json,
      List<T> Function(List<dynamic> jsonList) fromJsonList) {
    return ListResponse<T>(
      items: json['items'] != null
          ? fromJsonList(List<dynamic>.from(json['items']))
          : <T>[],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson(
      List<dynamic> Function(List<T> items) toJsonList) {
    return {
      'items': toJsonList(items),
      'message': message,
    };
  }
}
