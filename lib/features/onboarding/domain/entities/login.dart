class LoginRequest {
  final String role;
  final String email;
  final String password;

  const LoginRequest({required this.role, required this.email, required this.password});
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;

  const LoginResponse({required this.accessToken, required this.refreshToken});
}
