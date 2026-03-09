/// Enhanced Auth BLoC dengan Exception Handling
///
/// Contoh implementation yang lebih lengkap dengan error handling

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../services/auth_service.dart';
import '../exceptions/auth_exceptions.dart';

/// Enhanced AuthBloc dengan complete exception handling
class EnhancedAuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EnhancedAuthBloc({required AuthService authService})
    : _authService = authService,
      super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  // ==================== AUTH CHECK ====================

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          emit(
            AuthSuccess(
              userId: currentUser.uid,
              email: currentUser.email ?? 'Unknown',
              name: userData['name'] as String?,
              photoUrl: userData['photoUrl'] as String?,
            ),
          );
        } else {
          await _createUserProfile(currentUser);
          emit(
            AuthSuccess(
              userId: currentUser.uid,
              email: currentUser.email ?? 'Unknown',
              name: currentUser.displayName,
              photoUrl: currentUser.photoURL,
            ),
          );
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(message: e.message, errorCode: e.errorCode));
    } catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    }
  }

  // ==================== LOGIN ====================

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Validate input
      final validationErrors = AuthExceptionHandler.validateLoginForm(
        event.email,
        event.password,
      );

      if (validationErrors.isNotEmpty) {
        final firstError = validationErrors.first;
        emit(
          AuthError(
            message: firstError.message,
            errorCode: firstError.errorCode,
          ),
        );
        return;
      }

      // Try sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          emit(
            AuthSuccess(
              userId: user.uid,
              email: user.email ?? 'Unknown',
              name: userData['name'] as String?,
              photoUrl: userData['photoUrl'] as String?,
            ),
          );
        } else {
          emit(
            AuthSuccess(
              userId: user.uid,
              email: user.email ?? 'Unknown',
              name: user.displayName,
              photoUrl: user.photoURL,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific exceptions
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    } on AuthException catch (e) {
      // Handle custom auth exceptions
      emit(AuthError(message: e.message, errorCode: e.errorCode));
    } catch (e) {
      // Handle unknown exceptions
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    }
  }

  // ==================== REGISTER ====================

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Validate email
      final emailError = AuthExceptionHandler.validateEmail(event.email);
      if (emailError != null) {
        emit(
          AuthError(
            message: emailError.message,
            errorCode: emailError.errorCode,
          ),
        );
        return;
      }

      // Validate password
      final passwordError = AuthExceptionHandler.validatePassword(
        event.password,
      );
      if (passwordError != null) {
        emit(
          AuthError(
            message: passwordError.message,
            errorCode: passwordError.errorCode,
          ),
        );
        return;
      }

      // Try create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Update display name
        await user.updateDisplayName(event.name);

        // Create profile di Firestore
        await _createUserProfile(user, name: event.name);

        emit(
          AuthSuccess(
            userId: user.uid,
            email: user.email ?? 'Unknown',
            name: event.name,
            photoUrl: null,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    } on AuthException catch (e) {
      emit(AuthError(message: e.message, errorCode: e.errorCode));
    } catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    }
  }

  // ==================== LOGOUT ====================

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      await _auth.signOut();

      emit(const AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    } catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    }
  }

  // ==================== UPDATE PROFILE ====================

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final user = _auth.currentUser;
      if (user == null) {
        emit(const AuthError(message: 'User tidak login'));
        return;
      }

      // Update Firebase Auth
      await user.updateDisplayName(event.name);
      if (event.photoUrl != null) {
        await user.updatePhotoURL(event.photoUrl);
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': event.name,
        if (event.photoUrl != null) 'photoUrl': event.photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      emit(const AuthState.profileUpdateSuccess('Profile berhasil diperbarui'));
    } on FirebaseAuthException catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    } catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    }
  }

  // ==================== RESET PASSWORD ====================

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Validate email
      final emailError = AuthExceptionHandler.validateEmail(event.email);
      if (emailError != null) {
        emit(
          AuthError(
            message: emailError.message,
            errorCode: emailError.errorCode,
          ),
        );
        return;
      }

      // Send reset email
      await _auth.sendPasswordResetEmail(email: event.email.trim());

      emit(AuthState.resetPasswordEmailSent(event.email));
    } on FirebaseAuthException catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    } catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseException(e);
      emit(
        AuthError(message: exception.message, errorCode: exception.errorCode),
      );
    }
  }

  // ==================== HELPER ====================

  /// Create user profile di Firestore
  Future<void> _createUserProfile(User user, {String? name}) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name ?? user.displayName ?? 'User',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }
}

// ==================== ADDITIONAL HELPER METHODS ====================

/// Extension method untuk AuthError state
extension AuthErrorExtension on AuthError {
  /// Cek apakah error terkait network
  bool get isNetworkError => errorCode == 'network-request-failed';

  /// Cek apakah error terkait authentication
  bool get isAuthError =>
      errorCode == 'wrong-password' ||
      errorCode == 'user-not-found' ||
      errorCode == 'user-disabled';

  /// Cek apakah error bisa di-retry
  bool get isRetryable => isNetworkError || errorCode == 'too-many-requests';

  /// Get user-friendly message dengan icon/emoji
  String get friendlyMessage => message;
}
