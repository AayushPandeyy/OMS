import 'package:oms/features/dashboard/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.adminId,
    required super.username,
    required super.email,
    required super.phoneNumber,
    required super.role,
    required super.planType,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return UserProfileModel(
      adminId: user['adminId'] as String,
      username: user['username'] as String,
      email: user['email'] as String,
      phoneNumber: user['phoneNumber'] as String,
      role: user['role'] as String,
      planType: user['planType'] as String,
      isActive: user['isActive'] as bool,
      createdAt: DateTime.parse(user['createdAt'] as String),
      updatedAt: DateTime.parse(user['updatedAt'] as String),
    );
  }
}
