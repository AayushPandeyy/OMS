import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Check if user is authenticated by verifying saved tokens.
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Retrieve the saved access token.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Retrieve the saved refresh token.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Persist auth tokens after a successful login.
  static Future<void> saveTokens({
    required String accessToken,
    String refreshToken = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Clear all saved auth data (logout).
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
