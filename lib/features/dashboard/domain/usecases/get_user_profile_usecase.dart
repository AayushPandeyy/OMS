import 'package:oms/features/dashboard/domain/entities/user_profile.dart';
import 'package:oms/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetUserProfileUseCase {
  final DashboardRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile> call({required String accessToken}) {
    return repository.getUserProfile(accessToken: accessToken);
  }
}
