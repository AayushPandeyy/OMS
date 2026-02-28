import 'package:oms/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:oms/features/onboarding/data/models/login_model.dart';
import 'package:oms/features/onboarding/data/models/register_user_model.dart';
import 'package:oms/features/onboarding/data/models/restaurant_setup_model.dart';
import 'package:oms/features/onboarding/domain/entities/login.dart';
import 'package:oms/features/onboarding/domain/entities/register_user.dart';
import 'package:oms/features/onboarding/domain/entities/restaurant_setup.dart';
import 'package:oms/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required OnboardingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final OnboardingRemoteDataSource _remoteDataSource;

  @override
  Future<RegisterUserResponse> registerUser(RegisterUserRequest request) async {
    final requestModel = RegisterUserModel.fromRequest(request);
    final responseModel = await _remoteDataSource.registerUser(
      requestModel,
      request.password,
    );
    return RegisterUserResponse(
      username: responseModel.username,
      email: responseModel.email,
      phoneNumber: responseModel.phoneNumber,
      role: responseModel.role,
    );
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final requestModel = LoginRequestModel.fromEntity(request);
    final responseModel = await _remoteDataSource.login(requestModel);
    return LoginResponse(
      accessToken: responseModel.accessToken,
      refreshToken: responseModel.refreshToken,
    );
  }

  @override
  Future<RestaurantSetupResponse> setupRestaurant(
    RestaurantSetupRequest request,
    {required String accessToken}
  ) async {
    final requestModel = RestaurantSetupRequestModel.fromEntity(request);
    final responseModel = await _remoteDataSource.setupRestaurant(
      requestModel,
      accessToken: accessToken,
    );
    return RestaurantSetupResponse(
      id: responseModel.id,
      name: responseModel.name,
      logoUrl: responseModel.logoUrl,
      restaurantType: responseModel.restaurantType,
      cuisineTypes: List<String>.from(responseModel.cuisineTypes),
      addressUrl: responseModel.addressUrl,
      openingTime: responseModel.openingTime,
      closingTime: responseModel.closingTime,
      openDays: List<String>.from(responseModel.openDays),
      orderTypes: List<String>.from(responseModel.orderTypes),
      totalTables: responseModel.totalTables,
      isTaxed: responseModel.isTaxed,
      planType: responseModel.planType,
      taxConfigurations: responseModel.taxConfigurations,
    );
  }
}
