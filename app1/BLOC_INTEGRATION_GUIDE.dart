/// BLoC Integration Steps
///
/// Panduan step-by-step mengintegrasikan AuthBloc ke app

// ============ STEP 1: Update pubspec.yaml ============
/*
Add these dependencies:

dependencies:
  flutter:
    sdk: flutter
  
  # BLoC packages
  flutter_bloc: ^8.1.0
  bloc: ^8.1.0
  equatable: ^2.0.5
  
  # Firebase (existing)
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest

Run: flutter pub get
*/

// ============ STEP 2: Update main.dart ============
/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/auth_event.dart';
import 'services/auth_service.dart';
import 'config/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create AuthBloc (singleton)
  final authBloc = AuthBloc(authService: AuthService());
  
  // Check auth on app start
  authBloc.add(const AuthCheckRequested());

  runApp(MyApp(authBloc: authBloc));
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const AuthWrapper(),
      ),
    );
  }
}

// AuthWrapper untuk route ke home atau login based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            ),
          );
        } else if (state is AuthSuccess) {
          // Navigate ke home
          return const HomeScreen();
        } else {
          // Navigate ke login
          return const LoginScreen();
        }
      },
    );
  }
}
*/

// ============ STEP 3: Update LoginScreen ============
/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add LoginRequested event
    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            bool isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Selamat datang',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login untuk melanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(
                            () => _showPassword = !_showPassword,
                          );
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to register
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Daftar',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
*/

// ============ STEP 4: Update RegisterScreen ============
/*
Similar to LoginScreen, tapi:

void _register() {
  context.read<AuthBloc>().add(
    RegisterRequested(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
    ),
  );
}

BlocListener listener, BlocBuilder builder, etc
*/

// ============ STEP 5: Update HomeScreen ============
/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    // Add LogoutRequested event
    context.read<AuthBloc>().add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Go back to login
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Halo, ${state.name}'),
                backgroundColor: Colors.deepPurple,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Email: ${state.email}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            ),
          );
        },
      ),
    );
  }
}
*/

// ============ STEP 6: Using BLoC di Multiple Screens ============
/*
// Access BLoC dari any widget:

// Option 1: context.read (one-time access)
context.read<AuthBloc>().add(LogoutRequested());

// Option 2: context.watch (rebuild on state change)
final authState = context.watch<AuthBloc>().state;

// Option 3: Inside BlocBuilder
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    // state is watched automatically
    return Text('User: ${state.email}');
  },
)

// Option 4: Inside BlocListener
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      // Handle state change
    }
  },
  child: SomeWidget(),
)
*/

// ============ STEP 7: Testing BLoC ============
/*
File: test/auth_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc(authService: AuthService());
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits AuthLoading when LoginRequested is added',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        LoginRequested(email: 'test@test.com', password: 'pass123'),
      ),
      expect: () => [
        AuthLoading(),
        // Next state depends on Firebase response
      ],
    );
  });
}

Run tests: flutter test
*/

// ============ CHECKLIST ============
/*
☐ pubspec.yaml updated with BLoC dependencies
☐ auth_event.dart created
☐ auth_state.dart created
☐ auth_bloc.dart created
☐ main.dart setup BLoC
☐ AuthWrapper created
☐ LoginScreen updated to use BLoC
☐ RegisterScreen updated to use BLoC
☐ HomeScreen updated to use BLoC
☐ BLoC observer added (optional)
☐ Tested login functionality
☐ Tested register functionality
☐ Tested logout functionality
☐ Tested state persistence
☐ Error handling works
☐ Loading states shown
*/

// ============ STRUCTURE ============
/*
lib/
├── blocs/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
├── screens/
│   ├── login_screen.dart          (UPDATED)
│   ├── register_screen.dart       (UPDATED)
│   └── home_screen.dart           (UPDATED)
├── services/
│   └── auth_service.dart
├── models/
│   └── note_model.dart
├── config/
│   └── app_router.dart
└── main.dart                      (UPDATED)
*/

// ============ TROUBLESHOOTING ============
/*
ISSUE: BLoC state not updating
- Add import for auth_state.dart
- Call add() with correct event
- Check equatable implementation

ISSUE: Widget rebuilds too much
- Use BlocListener for side effects
- Use BlocBuilder for UI updates
- Check equatable props

ISSUE: "Event not handled"
- Ensure on<EventName>() registered in BLoC
- Check event class name match

ISSUE: "Cannot find BLoC"
- Wrap with BlocProvider
- Or use MultiBlocProvider if multiple BLoCs
- Check context.read/watch usage

ISSUE: Memory leak
- Call authBloc.close()
- In tearDown for tests
- Unsubscribe from streams
*/
