import 'package:oms/features/onboarding/domain/entities/register_user.dart';

class RegisterUserModel extends RegisterUserResponse {
  const RegisterUserModel({
    required super.username,
    required super.email,
    required super.phoneNumber,
    required super.role,
  });

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserModel(
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'owner',
    );
  }

  RegisterUserRequest toRequest(String password) {
    return RegisterUserRequest(
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    return {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      if (password != null) 'password': password,
      'role': role,
    };
  }

  static RegisterUserModel fromRequest(RegisterUserRequest request) {
    return RegisterUserModel(
      username: request.username,
      email: request.email,
      phoneNumber: request.phoneNumber,
      role: request.role,
    );
  }
}
