import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/home_screen.dart';

/// AuthStateWrapper - Handles authentication state and routing
///
/// Screen Flow:
/// - Login Screen (index 0) <-> Registration Screen (index 1) <-> Email Verification (index 2)
/// - After successful login or email verification, navigate to Home Screen
class AuthStateWrapper extends StatefulWidget {
  const AuthStateWrapper({super.key});

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  final _authService = AuthService();

  // Screen indices for navigation
  static const int _screenLogin = 0;
  static const int _screenRegistration = 1;
  static const int _screenEmailVerification = 2;

  late int _currentScreenIndex;
  String? _newUserEmail; // Store email for verification screen

  @override
  void initState() {
    super.initState();
    _currentScreenIndex = _screenLogin; // Default to login screen
  }

  /// Navigate to login screen
  void _goToLogin() {
    if (mounted) {
      setState(() {
        _currentScreenIndex = _screenLogin;
        _newUserEmail = null;
      });
    }
  }

  /// Navigate to registration screen
  void _goToRegistration() {
    if (mounted) {
      setState(() => _currentScreenIndex = _screenRegistration);
    }
  }

  /// Navigate to email verification screen
  void _goToEmailVerification(String email) {
    if (mounted) {
      setState(() {
        _currentScreenIndex = _screenEmailVerification;
        _newUserEmail = email;
      });
    }
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

        // User not authenticated - show authentication screens
        return _buildAuthScreen();
      },
    );
  }

  /// Build appropriate auth screen based on current index
  Widget _buildAuthScreen() {
    switch (_currentScreenIndex) {
      case _screenLogin:
        return LoginScreen(
          onLoginSuccess: () {
            // Navigation handled by auth stream
          },
          onSignUpTap: _goToRegistration,
        );

      case _screenRegistration:
        return RegistrationScreen(
          onSignUpSuccess: (email) {
            // Navigate to email verification screen
            _goToEmailVerification(email);
          },
          onLoginTap: _goToLogin,
        );

      case _screenEmailVerification:
        return EmailVerificationScreen(
          email: _newUserEmail,
          onVerificationComplete: () {
            // User verified - auth stream will handle navigation to home
          },
          onSkip: _goToLogin,
        );

      default:
        return LoginScreen(
          onLoginSuccess: () {},
          onSignUpTap: _goToRegistration,
        );
    }
  }
}
