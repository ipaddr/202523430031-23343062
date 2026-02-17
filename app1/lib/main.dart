import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthStateWrapper(),
    );
  }
}

/// AuthStateWrapper - Handle authentication state
class AuthStateWrapper extends StatefulWidget {
  const AuthStateWrapper({super.key});

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  final _authService = AuthService();
  late int _currentIndex; // 0: Login, 1: Registration

  @override
  void initState() {
    super.initState();
    _currentIndex = 0; // Default to login screen
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(
            onLogout: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          );
        }

        // If user not logged in, show login/registration screens
        return _currentIndex == 0
            ? LoginScreen(
                onLoginSuccess: () {
                  // Navigation handled by stream
                },
                onSignUpTap: () {
                  setState(() => _currentIndex = 1);
                },
              )
            : RegistrationScreen(
                onSignUpSuccess: () {
                  setState(() => _currentIndex = 0);
                },
                onLoginTap: () {
                  setState(() => _currentIndex = 0);
                },
              );
      },
    );
  }
}
