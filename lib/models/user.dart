class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? profileUrl;
  final String? address;
  final String role;
  final DateTime? createdAt;

  User({
    String? id,
    required this.username,
    required this.email,
    required this.password,
    this.profileUrl,
    this.address,
    required this.role,
    this.createdAt,
  }) : id = id ?? '';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      profileUrl: json['profile_url'] ?? json['profileUrl'],
      address: json['address'],
      role: json['role'] ?? 'member',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'profile_url': profileUrl,
      'address': address,
      'role': role,
    };
  }
}
