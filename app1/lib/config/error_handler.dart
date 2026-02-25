import 'package:firebase_auth/firebase_auth.dart';
import 'exceptions.dart';

/// Error message mapper untuk Firebase dan custom errors
class ErrorHandler {
  /// Map Firebase Auth error codes ke user-friendly messages
  static String getAuthErrorMessage(String errorCode) {
    switch (errorCode.toLowerCase()) {
      // Email related errors
      case 'invalid-email':
        return 'Format email tidak valid. Silakan periksa kembali.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau login.';
      case 'user-not-found':
        return 'Email tidak terdaftar. Silakan daftar terlebih dahulu.';

      // Password related errors
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';

      // Account related errors
      case 'user-disabled':
        return 'Akun Anda telah dinonaktifkan. Hubungi support.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login gagal. Coba lagi nanti.';

      // Network related errors
      case 'network-request-failed':
        return 'Koneksi internet tidak stabil. Periksa koneksi Anda.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan. Hubungi administrator.';

      // Verification errors
      case 'email-not-verified':
        return 'Email belum diverifikasi. Periksa email Anda.';

      // Generic errors
      case 'unknown':
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Parse Firebase exception menjadi user-friendly error
  static AuthException handleFirebaseAuthException(FirebaseAuthException e) {
    return AuthException(
      message: getAuthErrorMessage(e.code),
      code: e.code,
      originalException: e,
    );
  }

  /// Parse exception generic menjadi AppException
  static AppException handleException(dynamic exception) {
    // Firebase Auth Exception
    if (exception is FirebaseAuthException) {
      return handleFirebaseAuthException(exception);
    }

    // Network Exception
    if (exception.toString().contains('network')) {
      return NetworkException(
        message: 'Koneksi internet tidak tersedia. Periksa koneksi Anda.',
        originalException: exception,
      );
    }

    // Default AppException
    return AppException(
      message: 'Terjadi kesalahan tidak terduga. Silakan coba lagi.',
      originalException: exception,
    );
  }

  /// Get detailed error message dengan saran
  static String getErrorMessageWithSuggestion(AppException exception) {
    String message = exception.message;

    // Add suggestions based on error type
    if (exception is NetworkException) {
      message +=
          '\n\n💡 Saran: Periksa koneksi internet Anda atau coba lagi nanti.';
    } else if (exception is AuthException) {
      if (exception.code == 'user-not-found') {
        message += '\n\n💡 Saran: Belum punya akun? Daftar dengan email ini.';
      } else if (exception.code == 'wrong-password') {
        message += '\n\n💡 Saran: Lupa password? Klik "Lupa Password?"';
      }
    }

    return message;
  }

  /// Check if error is recoverable
  static bool isRecoverableError(AppException exception) {
    final code = exception.code;
    // Errors yang bisa diperbaiki user
    return code == 'wrong-password' ||
        code == 'user-not-found' ||
        code == 'invalid-email' ||
        code == 'network-request-failed';
  }
}
