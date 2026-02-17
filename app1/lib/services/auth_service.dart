import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

/// Auth Service untuk menangani autentikasi aplikasi
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final _firebaseService = FirebaseService();

  // Stream untuk user state changes
  Stream<User?> get authStateChanges =>
      _firebaseService.auth.authStateChanges();

  // Current user
  User? get currentUser => _firebaseService.auth.currentUser;

  // Check if user logged in
  bool get isLoggedIn => _firebaseService.auth.currentUser != null;

  /// Sign Up dengan email dan password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseService.signUp(
        email: email,
        password: password,
      );

      if (userCredential != null && displayName != null) {
        await _firebaseService.updateUserProfile(displayName: displayName);
      }

      return AuthResult.success(userCredential?.user);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  /// Login dengan email dan password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseService.login(
        email: email,
        password: password,
      );

      return AuthResult.success(userCredential?.user);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseService.logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset Password
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _firebaseService.resetPassword(email: email);
      return AuthResult.success(null, 'Email reset password telah dikirim');
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  /// Update Display Name
  Future<AuthResult> updateDisplayName({required String displayName}) async {
    try {
      await _firebaseService.updateUserProfile(displayName: displayName);
      return AuthResult.success(currentUser);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  /// Update Photo URL
  Future<AuthResult> updatePhotoUrl({required String photoUrl}) async {
    try {
      await _firebaseService.updateUserProfile(photoUrl: photoUrl);
      return AuthResult.success(currentUser);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
}

/// Result class untuk auth operations
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? message;

  AuthResult({required this.isSuccess, this.user, this.message});

  factory AuthResult.success(User? user, [String? message]) {
    return AuthResult(isSuccess: true, user: user, message: message);
  }

  factory AuthResult.error(String error) {
    return AuthResult(isSuccess: false, message: error);
  }
}
