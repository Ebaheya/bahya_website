class UserModel {
  final String email;
  final String name;
  final String id;
  final String role;
  final bool isActive;

  UserModel({
    required this.email,
    required this.name,
    required this.id,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['fullName'] ?? '',
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}
