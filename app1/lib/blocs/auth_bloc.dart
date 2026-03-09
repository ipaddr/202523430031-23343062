import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../services/auth_service.dart';

/// AuthBloc untuk manage authentication state dan logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc({required AuthService authService})
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

  /// Handle: Check apakah user sudah login saat app start
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Check jika user sudah login
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        // Get user info dari Firestore
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
          // Create user profile jika belum ada
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
    } catch (e) {
      emit(AuthError(message: 'Error checking auth: $e'));
    }
  }

  // ==================== LOGIN ====================

  /// Handle: Login dengan email dan password
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Sign in dengan Firebase
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Get user info dari Firestore
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
      String message = 'Login gagal';
      if (e.code == 'user-not-found') {
        message = 'User tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      } else if (e.code == 'invalid-email') {
        message = 'Email tidak valid';
      }
      emit(AuthError(message: message, errorCode: e.code));
    } catch (e) {
      emit(AuthError(message: 'Error: $e'));
    }
  }

  // ==================== REGISTER ====================

  /// Handle: Register user baru
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Create user dengan Firebase
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Set user display name
        await user.updateDisplayName(event.name);

        // Create user profile di Firestore
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
      String message = 'Register gagal';
      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan';
      } else if (e.code == 'invalid-email') {
        message = 'Email tidak valid';
      }
      emit(AuthError(message: message, errorCode: e.code));
    } catch (e) {
      emit(AuthError(message: 'Error: $e'));
    }
  }

  // ==================== LOGOUT ====================

  /// Handle: Logout / Sign out
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Sign out dari Firebase
      await FirebaseAuth.instance.signOut();

      emit(const AuthUnauthenticated(message: 'Logout berhasil'));
    } catch (e) {
      emit(AuthError(message: 'Error logout: $e'));
    }
  }

  // ==================== UPDATE PROFILE ====================

  /// Handle: Update user profile
  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const AuthError(message: 'User tidak terautentikasi'));
        return;
      }

      // Update di Firebase Auth
      if (event.name != null) {
        await user.updateDisplayName(event.name);
      }
      if (event.photoUrl != null) {
        await user.updatePhotoURL(event.photoUrl);
      }

      // Update di Firestore
      final updateData = <String, dynamic>{};
      if (event.name != null) updateData['name'] = event.name;
      if (event.photoUrl != null) updateData['photoUrl'] = event.photoUrl;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(updateData);

      emit(
        AuthSuccess(
          userId: user.uid,
          email: user.email ?? 'Unknown',
          name: event.name ?? user.displayName,
          photoUrl: event.photoUrl ?? user.photoURL,
        ),
      );

      emit(const ProfileUpdateSuccess(message: 'Profile berhasil diperbarui'));
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          message: 'Error update profile: ${e.message}',
          errorCode: e.code,
        ),
      );
    } catch (e) {
      emit(AuthError(message: 'Error: $e'));
    }
  }

  // ==================== RESET PASSWORD ====================

  /// Handle: Reset password via email
  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);

      emit(ResetPasswordEmailSent(email: event.email));
    } on FirebaseAuthException catch (e) {
      String message = 'Error sending reset email';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar';
      } else if (e.code == 'invalid-email') {
        message = 'Email tidak valid';
      }
      emit(AuthError(message: message, errorCode: e.code));
    } catch (e) {
      emit(AuthError(message: 'Error: $e'));
    }
  }

  // ==================== HELPER METHODS ====================

  /// Create user profile di Firestore
  Future<void> _createUserProfile(User user, {String? name}) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'name': name ?? user.displayName ?? 'User',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  /// Get current auth state
  AuthState getCurrentState() => state;

  /// Get current user ID
  String? getCurrentUserId() {
    if (state is AuthSuccess) {
      return (state as AuthSuccess).userId;
    }
    return null;
  }

  /// Check kalau user adalah authenticated
  bool isAuthenticated() => state is AuthSuccess;
}
