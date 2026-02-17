import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import 'auth_state_wrapper.dart';

/// AppInitializer - Manages app initialization and routing
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  /// Initialize app resources (Firebase, etc.)
  Future<void> _initializeApp() async {
    try {
      // Simulate initialization delay for splash screen visibility
      await Future.delayed(const Duration(seconds: 2));

      // You can add more initialization logic here:
      // - Load user preferences
      // - Initialize analytics
      // - Load cached data
      // - Load app configuration

      debugPrint('App initialization completed');
    } catch (e) {
      debugPrint('App initialization error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // Still initializing - show splash screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(message: 'Memuat aplikasi...');
        }

        // Initialization error
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi kesalahan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _initializationFuture = _initializeApp();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        // Initialization complete - show main app with auth wrapper
        return const AuthStateWrapper();
      },
    );
  }
}
