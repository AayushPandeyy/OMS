import 'package:oms/features/dashboard/domain/entities/user_profile.dart';
import 'package:oms/features/dashboard/domain/repositories/dashboard_repository.dart';

class UpdateUserProfileUseCase {
  final DashboardRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<UserProfile> call({
    required String accessToken,
    required UpdateUserRequest request,
  }) {
    return repository.updateUserProfile(
      accessToken: accessToken,
      request: request,
    );
  }
}
