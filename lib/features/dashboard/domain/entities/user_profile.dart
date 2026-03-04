class UserProfile {
  final String adminId;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;
  final String planType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.adminId,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.planType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class UpdateUserRequest {
  final String? username;
  final String? email;
  final String? phoneNumber;

  const UpdateUserRequest({this.username, this.email, this.phoneNumber});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (username != null) map['username'] = username;
    if (email != null) map['email'] = email;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    return map;
  }
}
