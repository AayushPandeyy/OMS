import 'package:oms/features/onboarding/domain/entities/login.dart';

class LoginRequestModel extends LoginRequest {
  const LoginRequestModel({
    required super.role,
    required super.email,
    required super.password,
  });

  Map<String, dynamic> toJson() {
    return {'role': role, 'email': email, 'password': password};
  }

  factory LoginRequestModel.fromEntity(LoginRequest request) {
    return LoginRequestModel(
      role: request.role,
      email: request.email,
      password: request.password,
    );
  }
}

class LoginResponseModel extends LoginResponse {
  const LoginResponseModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final access = json['access'] ?? json['access_token'] ?? json['token'];
    final refresh = json['refresh'] ?? json['refresh_token'] ?? '';
    return LoginResponseModel(
      accessToken: (access ?? '').toString(),
      refreshToken: (refresh ?? '').toString(),
    );
  }
}
