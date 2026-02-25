/// Custom exceptions untuk aplikasi
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => message;
}

/// Authentication-specific exception
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code,
         originalException: originalException,
       );
}

/// Network-specific exception
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code,
         originalException: originalException,
       );
}

/// Validation-specific exception
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    required String message,
    this.fieldErrors,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code,
         originalException: originalException,
       );
}
