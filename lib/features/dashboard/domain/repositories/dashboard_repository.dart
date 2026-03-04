import 'package:oms/features/dashboard/domain/entities/user_profile.dart';

abstract class DashboardRepository {
  Future<UserProfile> getUserProfile({required String accessToken});
  Future<UserProfile> updateUserProfile({
    required String accessToken,
    required UpdateUserRequest request,
  });
}
