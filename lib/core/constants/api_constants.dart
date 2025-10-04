class APIConstants {
  // TODO: Replace with your real API base URL
  static const String apiBaseUrl =
      'https://healer-map.com/wp-json/wp-mobile/v1/';
}

/// Centralized API endpoint paths
class APIEndpoints {
  // Auth
  static const String login = 'auth/login';
  static const String signup = 'auth/register';
  static const String forgotPassword = 'auth/forgot';
  static const String logout = 'auth/logout';
  static const String deleteAccount = 'profile';
  static const String changePassword = 'profile/password';
  static const String profile = 'profile';


  // Blog
  static const String posts = 'posts';

  // Places
  static const String places = 'places';
}
