import 'package:oms/features/onboarding/domain/entities/login.dart';
import 'package:oms/features/onboarding/domain/repositories/onboarding_repository.dart';

class LoginUserUseCase {
  final OnboardingRepository repository;

  LoginUserUseCase(this.repository);

  Future<LoginResponse> call(LoginRequest request) {
    return repository.login(request);
  }
}
