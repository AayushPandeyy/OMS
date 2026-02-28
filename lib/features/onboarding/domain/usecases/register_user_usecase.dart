import 'package:oms/features/onboarding/domain/entities/register_user.dart';
import 'package:oms/features/onboarding/domain/repositories/onboarding_repository.dart';

class RegisterUserUseCase {
  final OnboardingRepository repository;

  RegisterUserUseCase(this.repository);

  Future<RegisterUserResponse> call(RegisterUserRequest request) {
    return repository.registerUser(request);
  }
}
