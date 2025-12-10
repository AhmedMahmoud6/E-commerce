class SingleResponse<T> {
  final T? item;
  final String? message;

  SingleResponse({this.item, this.message});

  factory SingleResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return SingleResponse<T>(
      item: json['item'] != null ? fromJsonT(json['item']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'item': item != null ? toJsonT(item as T) : null,
      'message': message,
    };
  }
}
