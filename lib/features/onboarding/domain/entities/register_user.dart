class RegisterUserRequest {
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;

  const RegisterUserRequest({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.role = 'admin',
  });
}

class RegisterUserResponse {
  final String username;
  final String email;
  final String phoneNumber;
  final String role;

  const RegisterUserResponse({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });
}
