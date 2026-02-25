import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/exceptions.dart';
import '../config/error_handler.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

/// Auth Service - Mengelola semua operasi autentikasi Firebase
/// 
/// Fitur:
/// - Login/Registration dengan email dan password
/// - Email verification
/// - Password reset
/// - Profile management
/// - User state management via streams
/// - Error handling terintegrasi dengan custom exceptions
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final _firebaseService = FirebaseService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Check if user logged in (legacy)
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// Get user UID
  String? get uid => currentUser?.uid;

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Stream untuk user state changes
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Stream untuk user auth dengan delay (untuk better UX)
  Stream<User?> get authStateChangesDelayed {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      await Future.delayed(const Duration(milliseconds: 500));
      return user;
    });
  }

  /// Register dengan email dan password
  /// 
  /// Return: AuthResult dengan status dan pesan
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validasi input
      _validateEmail(email);
      _validatePassword(password);
      _validateName(name);

      debugPrint('Starting registration for email: $email');

      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      // Save user data ke Firestore
      await _saveUserToFirestore(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      debugPrint('Registration successful for email: $email');

      return AuthResult.success(
        userCredential.user,
        'Pendaftaran berhasil. Silakan verifikasi email Anda.',
      );
    } on FirebaseAuthException catch (e) {
      final authException = ErrorHandler.handleFirebaseAuthException(e);
      debugPrint('Firebase registration error: ${e.code} - ${e.message}');
      return AuthResult.error(authException.message);
    } on ValidationException catch (e) {
      debugPrint('Validation error during registration: ${e.message}');
      return AuthResult.error(e.message);
    } catch (e) {
      debugPrint('Unexpected registration error: $e');
      return AuthResult.error('Terjadi kesalahan saat pendaftaran.');
    }
  }

  /// Sign Up dengan email dan password (legacy method)
  @Deprecated('Gunakan register() instead')
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
      // Validasi input
      _validateEmail(email);

      debugPrint('Starting login for email: $email');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('Login successful for email: $email');

      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      final authException = ErrorHandler.handleFirebaseAuthException(e);
      debugPrint('Firebase login error: ${e.code} - ${e.message}');
      return AuthResult.error(authException.message);
    } on ValidationException catch (e) {
      debugPrint('Validation error during login: ${e.message}');
      return AuthResult.error(e.message);
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      return AuthResult.error('Terjadi kesalahan saat login.');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      debugPrint('Logging out user: ${currentUser?.email}');
      await _firebaseAuth.signOut();
      debugPrint('Logout successful');
    } catch (e) {
      debugPrint('Error during logout: $e');
      throw AppException(
        message: 'Gagal logout',
        originalException: e,
      );
    }
  }

  /// Reset Password
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      _validateEmail(email);

      debugPrint('Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent');

      return AuthResult.success(null, 'Email reset password telah dikirim');
    } on FirebaseAuthException catch (e) {
      final authException = ErrorHandler.handleFirebaseAuthException(e);
      return AuthResult.error(authException.message);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  /// Change password
  /// 
  /// Return: bool - true jika sukses
  Future<bool> changePassword(String newPassword) async {
    try {
      if (currentUser == null) {
        throw AuthException(
          message: 'User tidak ditemukan',
          code: 'user-not-found',
        );
      }

      _validatePassword(newPassword);

      debugPrint('Changing password for user: ${currentUser!.email}');
      await currentUser!.updatePassword(newPassword);
      debugPrint('Password changed successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      throw AppException(
        message: 'Gagal mengubah password',
        originalException: e,
      );
    }
  }

  /// Update Display Name
  Future<AuthResult> updateDisplayName({required String displayName}) async {
    try {
      _validateName(displayName);

      if (currentUser == null) {
        return AuthResult.error('User tidak ditemukan');
      }

      await currentUser!.updateDisplayName(displayName);

      // Update di Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await currentUser!.reload();
      debugPrint('Display name updated');
      return AuthResult.success(currentUser);
    } catch (e) {
      debugPrint('Error updating display name: $e');
      return AuthResult.error(e.toString());
    }
  }

  /// Update Photo URL
  Future<AuthResult> updatePhotoUrl({required String photoUrl}) async {
    try {
      if (currentUser == null) {
        return AuthResult.error('User tidak ditemukan');
      }

      await currentUser!.updatePhotoURL(photoUrl);

      // Update di Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await currentUser!.reload();
      debugPrint('Photo URL updated');
      return AuthResult.success(currentUser);
    } catch (e) {
      debugPrint('Error updating photo URL: $e');
      return AuthResult.error(e.toString());
    }
  }

  /// Update user profile
  /// 
  /// Return: bool - true jika sukses
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      if (currentUser == null) {
        throw AuthException(
          message: 'User tidak ditemukan',
          code: 'user-not-found',
        );
      }

      if (displayName != null) {
        _validateName(displayName);
        await currentUser!.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await currentUser!.updatePhotoURL(photoUrl);
      }

      // Update di Firestore
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updates);

      await currentUser!.reload();
      debugPrint('User profile updated');
      return true;
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      throw AppException(
        message: 'Gagal update profil',
        originalException: e,
      );
    }
  }

  /// Send Email Verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      if (currentUser == null) {
        return AuthResult.error('User tidak ditemukan');
      }

      if (currentUser!.emailVerified) {
        return AuthResult.success(
          null,
          'Email Anda sudah diverifikasi',
        );
      }

      debugPrint('Sending email verification to: ${currentUser!.email}');
      await currentUser!.sendEmailVerification();
      debugPrint('Email verification sent');

      return AuthResult.success(
        null,
        'Link verifikasi email telah dikirim. Silakan cek email Anda.',
      );
    } on FirebaseAuthException catch (e) {
      final authException = ErrorHandler.handleFirebaseAuthException(e);
      return AuthResult.error(authException.message);
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      return AuthResult.error(e.toString());
    }
  }

  /// Check Email Verification Status
  Future<bool> isEmailVerified() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      final isVerified = _firebaseAuth.currentUser?.emailVerified ?? false;
      debugPrint('Email verified: $isVerified');
      return isVerified;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  /// Reload user dan check email verification status
  /// 
  /// Return: bool - true jika email verified
  Future<bool> reloadUserAndCheckEmailVerification() async {
    try {
      if (currentUser == null) {
        throw AuthException(
          message: 'User tidak ditemukan',
          code: 'user-not-found',
        );
      }

      await currentUser!.reload();
      final user = _firebaseAuth.currentUser;

      debugPrint('Email verified: ${user?.emailVerified}');
      return user?.emailVerified ?? false;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      throw AppException(
        message: 'Gagal memeriksa verifikasi email',
        originalException: e,
      );
    }
  }

  /// Resend Email Verification
  Future<AuthResult> resendEmailVerification() async {
    try {
      if (currentUser == null) {
        return AuthResult.error('User tidak ditemukan');
      }

      await currentUser!.sendEmailVerification();
      return AuthResult.success(
        null,
        'Link verifikasi ulang telah dikirim ke email Anda.',
      );
    } on FirebaseAuthException catch (e) {
      final authException = ErrorHandler.handleFirebaseAuthException(e);
      return AuthResult.error(authException.message);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

/// Get user data dari Firestore
  /// 
  /// Return: UserModel atau null jika tidak ditemukan
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        debugPrint('User data fetched for uid: $uid');
        return UserModel.fromFirestore(doc);
      }

      debugPrint('User document not found for uid: $uid');
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      throw AppException(
        message: 'Gagal mengambil data pengguna',
        originalException: e,
      );
    }
  }

  /// Get current user data
  /// 
  /// Return: UserModel atau null
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    return getUserData(currentUser!.uid);
  }

  /// Stream untuk current user data
  Stream<UserModel?> get currentUserData {
    if (currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Delete user account
  /// 
  /// Return: bool - true jika sukses
  Future<bool> deleteUserAccount() async {
    try {
      if (currentUser == null) {
        throw AuthException(
          message: 'User tidak ditemukan',
          code: 'user-not-found',
        );
      }

      final uid = currentUser!.uid;

      // Delete user document dari Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete user account dari Firebase Auth
      await currentUser!.delete();

      debugPrint('User account deleted: $uid');
      return true;
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      throw AppException(
        message: 'Gagal menghapus akun pengguna',
        originalException: e,
      );
    }
  }

  /// Check if email exists
  /// 
  /// Return: bool - true jika email sudah terdaftar
  Future<bool> checkEmailExists(String email) async {
    try {
      _validateEmail(email);

      final methods =
          await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      throw AppException(
        message: 'Gagal memeriksa email',
        originalException: e,
      );
    }
  }

  // ============= Private Helper Methods =============

  /// Validate email format
  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw ValidationException(
        message: 'Email tidak boleh kosong',
        code: 'empty-email',
      );
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      throw ValidationException(
        message: 'Format email tidak valid',
        code: 'invalid-email-format',
      );
    }
  }

  /// Validate password strength
  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw ValidationException(
        message: 'Password tidak boleh kosong',
        code: 'empty-password',
      );
    }

    if (password.length < 6) {
      throw ValidationException(
        message: 'Password minimal 6 karakter',
        code: 'weak-password',
      );
    }
  }

  /// Validate user name
  void _validateName(String name) {
    if (name.isEmpty) {
      throw ValidationException(
        message: 'Nama tidak boleh kosong',
        code: 'empty-name',
      );
    }

    if (name.length < 3) {
      throw ValidationException(
        message: 'Nama minimal 3 karakter',
        code: 'short-name',
      );
    }

    if (name.length > 50) {
      throw ValidationException(
        message: 'Nama maksimal 50 karakter',
        code: 'long-name',
      );
    }
  }

  /// Save user data ke Firestore
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': name,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      debugPrint('User data saved to Firestore: $uid');
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      throw AppException(
        message: 'Gagal menyimpan data pengguna',
        originalException: e,
      );
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

  @override
  String toString() =>
      'AuthResult(isSuccess: $isSuccess, message: $message, user: ${user?.email})';
}
