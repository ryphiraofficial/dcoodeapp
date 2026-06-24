class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'guest',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;
  final String role;
  final User user;

  LoginResponse({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      role: data['role'],
      user: User.fromJson(data['user']),
    );
  }
}
