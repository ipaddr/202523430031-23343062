/// Custom Exception Classes untuk Authentication
///
/// Define semua exception types yang mungkin terjadi saat login/register

/// Base exception class untuk Auth
abstract class AuthException implements Exception {
  final String message;
  final String? errorCode;

  AuthException({
    required this.message,
    this.errorCode,
  });

  @override
  String toString() => message;
}

// ==================== SPECIFIC EXCEPTIONS ====================

/// Exception: User tidak ditemukan
class UserNotFoundException extends AuthException {
  UserNotFoundException()
      : super(
          message: 'User tidak ditemukan. Silahkan daftar terlebih dahulu',
          errorCode: 'user-not-found',
        );
}

/// Exception: Password salah
class WrongPasswordException extends AuthException {
  WrongPasswordException()
      : super(
          message: 'Password salah. Coba lagi',
          errorCode: 'wrong-password',
        );
}

/// Exception: Password terlalu lemah
class WeakPasswordException extends AuthException {
  WeakPasswordException()
      : super(
          message: 'Password terlalu lemah. Minimal 6 karakter dengan mix huruf, angka, dan simbol',
          errorCode: 'weak-password',
        );
}

/// Exception: Email sudah digunakan
class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException()
      : super(
          message: 'Email sudah digunakan. Gunakan email lain',
          errorCode: 'email-already-in-use',
        );
}

/// Exception: Email tidak valid
class InvalidEmailException extends AuthException {
  InvalidEmailException()
      : super(
          message: 'Email tidak valid. Cek kembali format email',
          errorCode: 'invalid-email',
        );
}

/// Exception: Network error
class NetworkException extends AuthException {
  NetworkException()
      : super(
          message: 'Network error. Periksa koneksi internet dan coba lagi',
          errorCode: 'network-request-failed',
        );
}

/// Exception: Too many login attempts
class TooManyAttemptsException extends AuthException {
  TooManyAttemptsException()
      : super(
          message: 'Terlalu banyak percobaan gagal. Coba lagi nanti',
          errorCode: 'too-many-requests',
        );
}

/// Exception: Account disabled
class AccountDisabledException extends AuthException {
  AccountDisabledException()
      : super(
          message: 'Akun Anda telah dinonaktifkan. Hubungi support',
          errorCode: 'user-disabled',
        );
}

/// Exception: Operation not allowed
class OperationNotAllowedException extends AuthException {
  OperationNotAllowedException()
      : super(
          message: 'Operasi tidak diizinkan. Hubungi support',
          errorCode: 'operation-not-allowed',
        );
}

/// Exception: Unknown error
class UnknownAuthException extends AuthException {
  UnknownAuthException({
    String message = 'Terjadi error. Coba lagi',
    String? errorCode,
  }) : super(
    message: message,
    errorCode: errorCode,
  );
}

// ==================== VALIDATION EXCEPTIONS ====================

/// Exception: Empty email
class EmptyEmailException extends AuthException {
  EmptyEmailException()
      : super(
          message: 'Email tidak boleh kosong',
          errorCode: 'empty-email',
        );
}

/// Exception: Empty password
class EmptyPasswordException extends AuthException {
  EmptyPasswordException()
      : super(
          message: 'Password tidak boleh kosong',
          errorCode: 'empty-password',
        );
}

/// Exception: Invalid email format
class InvalidEmailFormatException extends AuthException {
  InvalidEmailFormatException()
      : super(
          message: 'Format email tidak benar',
          errorCode: 'invalid-email-format',
        );
}

/// Exception: Password too short
class PasswordTooShortException extends AuthException {
  PasswordTooShortException()
      : super(
          message: 'Password minimal 6 karakter',
          errorCode: 'password-too-short',
        );
}

// ==================== EXCEPTION HANDLER UTILITY ====================

/// Utility untuk handle Firebase exceptions dan convert ke custom exceptions
class AuthExceptionHandler {
  /// Map Firebase error code ke custom exception
  static AuthException handleFirebaseException(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseException(error.code);
    }
    
    return UnknownAuthException(
      message: error.toString(),
    );
  }

  /// Map individual Firebase error codes
  static AuthException _mapFirebaseException(String code) {
    return switch (code) {
      'user-not-found' => UserNotFoundException(),
      'wrong-password' => WrongPasswordException(),
      'weak-password' => WeakPasswordException(),
      'email-already-in-use' => EmailAlreadyInUseException(),
      'invalid-email' => InvalidEmailException(),
      'network-request-failed' => NetworkException(),
      'too-many-requests' => TooManyAttemptsException(),
      'user-disabled' => AccountDisabledException(),
      'operation-not-allowed' => OperationNotAllowedException(),
      _ => UnknownAuthException(errorCode: code),
    };
  }

  /// Validate email format
  static AuthException? validateEmail(String email) {
    if (email.isEmpty) {
      return EmptyEmailException();
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      return InvalidEmailFormatException();
    }
    
    return null;
  }

  /// Validate password
  static AuthException? validatePassword(String password) {
    if (password.isEmpty) {
      return EmptyPasswordException();
    }
    
    if (password.length < 6) {
      return PasswordTooShortException();
    }
    
    return null;
  }

  /// Validate email dan password sekaligus
  static List<AuthException> validateLoginForm(String email, String password) {
    final errors = <AuthException>[];
    
    final emailError = validateEmail(email);
    if (emailError != null) errors.add(emailError);
    
    final passwordError = validatePassword(password);
    if (passwordError != null) errors.add(passwordError);
    
    return errors;
  }
}

// Perlu import firebase_auth di file yang menggunakan ini
import 'package:firebase_auth/firebase_auth.dart';
