class UserModel {
  final String userId;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String token;
  final String? buildingId;

  const UserModel({
    required this.userId,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.token,
    this.buildingId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    final user = json['user'] ?? json;
    return UserModel(
      userId: user['user_id'] ?? '',
      name: user['name'] ?? '',
      phone: user['phone'] ?? '',
      email: user['email'],
      role: user['role'] ?? 'tenant',
      token: token,
      buildingId: user['building_id'],
    );
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? token,
    String? buildingId,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      buildingId: buildingId ?? this.buildingId,
    );
  }
}
