class ErrorResponse {
  final int? statusCode;
  final String message;
  final dynamic error;

  ErrorResponse({this.statusCode, required this.message, this.error});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      statusCode: json['statusCode'] is int
          ? json['statusCode']
          : (json['statusCode'] != null
              ? int.tryParse(json['statusCode'].toString())
              : null),
      message: json['message'] ?? '',
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'message': message};
    if (statusCode != null) map['statusCode'] = statusCode;
    if (error != null) map['error'] = error;
    return map;
  }
}
