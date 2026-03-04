import 'package:oms/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:oms/features/dashboard/domain/entities/user_profile.dart';
import 'package:oms/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getUserProfile({required String accessToken}) async {
    return _remoteDataSource.getUserProfile(accessToken: accessToken);
  }

  @override
  Future<UserProfile> updateUserProfile({
    required String accessToken,
    required UpdateUserRequest request,
  }) async {
    return _remoteDataSource.updateUserProfile(
      accessToken: accessToken,
      request: request,
    );
  }
}
