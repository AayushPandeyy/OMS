import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oms/core/constants/api_constants.dart';
import 'package:oms/core/error/app_exception.dart';
import 'package:oms/features/dashboard/data/models/user_profile_model.dart';
import 'package:oms/features/dashboard/domain/entities/user_profile.dart';

abstract class DashboardRemoteDataSource {
  Future<UserProfileModel> getUserProfile({required String accessToken});
  Future<UserProfileModel> updateUserProfile({
    required String accessToken,
    required UpdateUserRequest request,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({required http.Client client})
    : _client = client;

  final http.Client _client;

  @override
  Future<UserProfileModel> getUserProfile({required String accessToken}) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.userMe),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw const AppException('Empty response from server');
      }
      final decoded = jsonDecode(response.body);
      return UserProfileModel.fromJson(decoded as Map<String, dynamic>);
    }

    String message = 'Unexpected error occurred';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {}
    throw AppException(message);
  }

  @override
  Future<UserProfileModel> updateUserProfile({
    required String accessToken,
    required UpdateUserRequest request,
  }) async {
    final response = await _client.put(
      Uri.parse(ApiConstants.userMe),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw const AppException('Empty response from server');
      }
      final decoded = jsonDecode(response.body);
      return UserProfileModel.fromJson(decoded as Map<String, dynamic>);
    }

    String message = 'Unexpected error occurred';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {}
    throw AppException(message);
  }
}
