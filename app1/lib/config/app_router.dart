import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/home_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/logout_screen.dart';
import '../widgets/app_initializer.dart';
import 'routes.dart';

/// AppRouter - Mengelola semua route navigation di aplikasi
///
/// Menggunakan named routes untuk navigasi yang lebih terstruktur dan mudah di-maintain
class AppRouter {
  /// Generate route berdasarkan route name
  ///
  /// Return: Route yang sesuai atau error page jika route tidak ditemukan
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Parse route arguments
    final args = settings.arguments;

    switch (settings.name) {
      // Splash Screen
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(message: 'Memuat aplikasi...'),
        );

      // App Initializer
      case AppRoutes.appInit:
        return MaterialPageRoute(builder: (_) => const AppInitializer());

      // Login Screen
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLoginSuccess: args is Function ? args : null,
            onSignUpTap: () {
              Navigator.pushReplacementNamed(_, AppRoutes.registration);
            },
          ),
        );

      // Registration Screen
      case AppRoutes.registration:
        return MaterialPageRoute(
          builder: (_) => RegistrationScreen(
            onSignUpSuccess: (email) {
              Navigator.pushNamed(
                _,
                AppRoutes.emailVerification,
                arguments: email,
              );
            },
            onLoginTap: () {
              Navigator.pushReplacementNamed(_, AppRoutes.login);
            },
          ),
        );

      // Email Verification Screen
      case AppRoutes.emailVerification:
        final email = args as String?;
        return MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: email,
            onVerificationComplete: () {
              Navigator.pushReplacementNamed(_, AppRoutes.home);
            },
            onSkip: () {
              Navigator.pushReplacementNamed(_, AppRoutes.login);
            },
          ),
        );

      // Home Screen
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(onLogout: args is Function ? args : null),
        );

      // Notes Screen
      case AppRoutes.notes:
        return MaterialPageRoute(builder: (_) => const NotesScreen());

      // Logout Screen
      case AppRoutes.logout:
        return MaterialPageRoute(
          builder: (_) =>
              LogoutScreen(onLogoutSuccess: args is Function ? args : null),
        );

      // Error Screen (404)
      case AppRoutes.error:
      default:
        return MaterialPageRoute(builder: (_) => const _ErrorScreen());
    }
  }
}

/// Error Screen - ditampilkan jika route tidak ditemukan
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tidak Ditemukan'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Halaman tidak ditemukan (404)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Route yang Anda cari tidak tersedia',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.home),
              child: const Text('Kembali ke Home'),
            ),
          ],
        ),
      ),
    );
  }
}
