import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/home_screen.dart';

/// AuthStateWrapper - Handles authentication state and routing
class AuthStateWrapper extends StatefulWidget {
  const AuthStateWrapper({super.key});

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  final _authService = AuthService();
  late int _currentScreenIndex; // 0: Login, 1: Registration

  @override
  void initState() {
    super.initState();
    _currentScreenIndex = 0; // Default to login screen
  }

  /// Navigate to login screen
  void _goToLogin() {
    setState(() => _currentScreenIndex = 0);
  }

  /// Navigate to registration screen
  void _goToRegistration() {
    setState(() => _currentScreenIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Still loading auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is authenticated - show home screen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(onLogout: _goToLogin);
        }

        // User not authenticated - show login or registration screen
        return _currentScreenIndex == 0
            ? LoginScreen(
                onLoginSuccess: () {
                  // Navigation handled by auth stream
                },
                onSignUpTap: _goToRegistration,
              )
            : RegistrationScreen(
                onSignUpSuccess: _goToLogin,
                onLoginTap: _goToLogin,
              );
      },
    );
  }
}
