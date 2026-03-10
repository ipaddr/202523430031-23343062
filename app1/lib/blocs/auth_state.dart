import 'package:equatable/equatable.dart';

/// Abstract class untuk Auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - App baru dibuka
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - Sedang proses auth
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state - User authenticated
class AuthSuccess extends AuthState {
  final String userId;
  final String email;
  final String? name;
  final String? photoUrl;

  const AuthSuccess({
    required this.userId,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, email, name, photoUrl];
}

/// Unauthenticated state - User tidak login
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state - Ada error saat auth
class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];

  /// Getter untuk check apakah error dapat di-retry
  bool get isRetryable =>
      errorCode == 'network-request-failed' ||
      errorCode == 'too-many-requests' ||
      errorCode == 'service-unavailable';

  /// Getter untuk check apakah error adalah network error
  bool get isNetworkError => errorCode == 'network-request-failed';
}

/// State untuk profile update success
class ProfileUpdateSuccess extends AuthState {
  final String message;

  const ProfileUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State ketika password reset email dikirim
class ResetPasswordEmailSent extends AuthState {
  final String email;

  const ResetPasswordEmailSent({required this.email});

  @override
  List<Object?> get props => [email];
}
