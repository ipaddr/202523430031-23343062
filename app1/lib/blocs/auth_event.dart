import 'package:equatable/equatable.dart';

/// Events untuk AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Check apakah user sudah login saat app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event: Login dengan email dan password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event: Register user baru
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Event: Logout / Sign out
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event: Update user profile
class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? photoUrl;

  const UpdateProfileRequested({this.name, this.photoUrl});

  @override
  List<Object?> get props => [name, photoUrl];
}

/// Event: Reset password
class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
