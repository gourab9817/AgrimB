// AuthException for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AuthException([32m$code[0m): $message';
} 