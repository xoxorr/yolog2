class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.yolog.com';
  static const String imageBaseUrl = 'https://images.yolog.com';

  // API Endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String refreshToken = '/auth/refresh';

  static const String posts = '/posts';
  static const String users = '/users';
  static const String media = '/media';
  static const String search = '/search';

  // API Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';

  // API Response Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
}
