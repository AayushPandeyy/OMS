import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oms/core/constants/api_constants.dart';
import 'package:oms/core/error/app_exception.dart';
import 'package:oms/features/onboarding/data/models/login_model.dart';
import 'package:oms/features/onboarding/data/models/register_user_model.dart';
import 'package:oms/features/onboarding/data/models/restaurant_setup_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<RegisterUserModel> registerUser(
    RegisterUserModel request,
    String password,
  );
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<RestaurantSetupResponseModel> setupRestaurant(
    RestaurantSetupRequestModel request, {
    required String accessToken,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl({required http.Client client})
    : _client = client;

  final http.Client _client;

  @override
  Future<RegisterUserModel> registerUser(
    RegisterUserModel request,
    String password,
  ) async {
    print(jsonEncode(request.toJson(password: password)));
    final response = await _client.post(
      Uri.parse(ApiConstants.registerUser),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson(password: password)),
    );

    return _handleResponse(
      response,
      (data) => RegisterUserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.loginUser),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    return _handleResponse(
      response,
      (data) => LoginResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<RestaurantSetupResponseModel> setupRestaurant(
    RestaurantSetupRequestModel request, {
    required String accessToken,
  }) async {
    final payload = jsonEncode(request.toJson());
    print('Restaurant setup payload: $payload');
    print(accessToken);
    final response = await _client.post(
      Uri.parse(ApiConstants.setupRestaurant),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: payload,
    );

    return _handleResponse(
      response,
      (data) =>
          RestaurantSetupResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic data) parser,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw const AppException('Empty response from server');
      }
      final decoded = jsonDecode(response.body);
      return parser(decoded);
    }

    String message = 'Unexpected error occurred';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        message = decoded['message'].toString();
      } else if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
        message = decoded['detail'].toString();
      } else if (decoded is String) {
        message = decoded;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }
    throw AppException(message, statusCode: response.statusCode);
  }
}
