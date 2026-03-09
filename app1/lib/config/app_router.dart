import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/identity_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/notes_display_screen.dart';
import '../screens/create_note_screen.dart';
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
          builder: (context) => LoginScreen(
            onLoginSuccess: args as VoidCallback?,
            onSignUpTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.registration);
            },
          ),
        );

      // Registration Screen
      case AppRoutes.registration:
        return MaterialPageRoute(
          builder: (context) => RegistrationScreen(
            onSignUpSuccess: (email) {
              Navigator.pushNamed(
                context,
                AppRoutes.emailVerification,
                arguments: email,
              );
            },
            onLoginTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        );

      // Email Verification Screen
      case AppRoutes.emailVerification:
        final email = args as String?;
        return MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            email: email,
            onVerificationComplete: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.identityConfirmation,
              );
            },
            onSkip: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        );

      // Identity Confirmation Screen
      case AppRoutes.identityConfirmation:
        return MaterialPageRoute(
          builder: (context) => IdentityConfirmationScreen(
            onConfirmed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
            onLogout: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        );

      // Home Screen
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (context) => HomeScreen(onLogout: args as VoidCallback?),
        );

      // Notes Screen
      case AppRoutes.notes:
        return MaterialPageRoute(builder: (_) => const NotesDisplayScreen());

      // Notes Display Screen
      case AppRoutes.notesDisplay:
        return MaterialPageRoute(builder: (_) => const NotesDisplayScreen());

      // Create Note Screen
      case AppRoutes.createNote:
        return MaterialPageRoute(builder: (_) => const CreateNoteScreen());

      // Logout Screen
      case AppRoutes.logout:
        return MaterialPageRoute(
          builder: (context) =>
              LogoutScreen(onLogoutSuccess: args as VoidCallback?),
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
