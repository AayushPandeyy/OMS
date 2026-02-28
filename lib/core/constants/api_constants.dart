class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'http://192.168.1.10:8000';
  static const String registerUser = '$baseUrl/api/auth/register/';
  static const String loginUser = '$baseUrl/api/auth/login/';
  static const String setupRestaurant = '$baseUrl/api/setup/restaurants/';
  static const String uploadMedia = 'http://192.168.1.10:8001/media';
}
