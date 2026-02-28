import 'package:oms/features/onboarding/domain/entities/restaurant_setup.dart';
import 'package:oms/features/onboarding/domain/repositories/onboarding_repository.dart';

class SetupRestaurantUseCase {
  final OnboardingRepository repository;

  SetupRestaurantUseCase(this.repository);

  Future<RestaurantSetupResponse> call(
    RestaurantSetupRequest request, {
    required String accessToken,
  }) {
    return repository.setupRestaurant(request, accessToken: accessToken);
  }
}
