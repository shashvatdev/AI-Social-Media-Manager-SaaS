class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? companyName;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.companyName,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      companyName: json['company_name'],
      role: json['role'] ?? 'OWNER',
      isActive: json['is_active'] ?? true,
    );
  }
}
