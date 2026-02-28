import 'package:oms/features/onboarding/domain/entities/login.dart';
import 'package:oms/features/onboarding/domain/entities/register_user.dart';
import 'package:oms/features/onboarding/domain/entities/restaurant_setup.dart';

abstract class OnboardingRepository {
  Future<RegisterUserResponse> registerUser(RegisterUserRequest request);
  Future<LoginResponse> login(LoginRequest request);
  Future<RestaurantSetupResponse> setupRestaurant(
    RestaurantSetupRequest request,
    {required String accessToken}
  );
}
