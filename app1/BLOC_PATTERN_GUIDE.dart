/// Converting Auth Process to BLoC Pattern
///
/// Panduan lengkap tentang implementasi BLoC untuk authentication

// ============ WHAT IS BLOC? ============
/*
BLoC = Business Logic Component

Adalah design pattern untuk Flutter yang memisahkan UI logic dari business logic.

Keuntungan BLoC:
✓ Separation of concerns (UI vs Logic)
✓ Testable - mudah di-test
✓ Reusable - logic bisa dipakai di multiple places
✓ Easy state management
✓ Reactive programming
✓ Hot reload friendly

Architecture:
┌─────────────┐
│   UI Layer  │ (Screens, Widgets)
└──────┬──────┘
       │ dispatch events
┌──────▼──────────────┐
│   BLoC Layer        │ (Business Logic)
│  - Events           │
│  - States           │
│  - Logic            │
└──────┬──────────────┘
       │ emit states
┌──────▼──────────────┐
│ Data/Repository     │ (Services, API calls)
└─────────────────────┘
*/

// ============ BLOC COMPONENTS ============
/*
1. EVENT - User action / external trigger
   - What user does
   - What system should do
   - Example: LoginRequested, LogoutRequested

2. STATE - Current state of the system
   - Loading, Success, Error
   - Data yang di-hold
   - Example: AuthSuccess, AuthLoading, AuthError

3. BLOC - The business logic
   - Takes events
   - Produces states
   - Handle logic
   - Calls services/repositories

Flow:
User Action → Event → BLoC → State → UI Update
*/

// ============ AUTH BLOC COMPONENTS ============
/*
AuthEvent (auth_event.dart):
- AuthCheckRequested      → Check apakah user sudah login
- LoginRequested          → Login dengan email/password
- RegisterRequested       → Register user baru
- LogoutRequested         → Logout
- UpdateProfileRequested  → Update profile
- ResetPasswordRequested  → Reset password

AuthState (auth_state.dart):
- AuthInitial             → State awal
- AuthLoading             → Sedang process
- AuthSuccess             → User authenticated (berisi userId, email, name)
- AuthUnauthenticated     → User tidak login
- AuthError               → Ada error (berisi message)
- ProfileUpdateSuccess    → Profile update berhasil
- ResetPasswordEmailSent  → Email reset dikirim

AuthBloc (auth_bloc.dart):
- Terima AuthEvent
- Handle logic (call AuthService, Firebase)
- Emit AuthState
*/

// ============ HOW TO USE ============
/*
1. SETUP di main.dart:

import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth_bloc.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Create AuthBloc
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
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const HomePage(),
      ),
    );
  }
}

2. LISTEN TO STATE di Widget:

import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Navigate to home
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthError) {
          // Show error dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Column(
            children: [
              TextField(controller: _emailController),
              TextField(controller: _passwordController),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    LoginRequested(
                      email: _emailController.text,
                      password: _passwordController.text,
                    ),
                  );
                },
                child: Text('Login'),
              ),
            ],
          );
        },
      ),
    );
  }
}

3. DISPATCH EVENT:

// Dari anywhere dalam app yang punya access ke BLoC:
context.read<AuthBloc>().add(LoginRequested(
  email: 'user@example.com',
  password: 'password123',
));

// Atau:
BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
*/

// ============ DETAILED FLOW ============
/*
LOGIN FLOW:

1. User tap Login button
   ↓
2. Dispatch LoginRequested event
   context.read<AuthBloc>().add(LoginRequested(...))
   ↓
3. BLoC receives event _onLoginRequested()
   ↓
4. Emit AuthLoading()
   UI: Show spinner
   ↓
5. Call Firebase signInWithEmailAndPassword()
   ↓
6. Success: 
   - Get user from Firebase
   - Fetch user profile from Firestore
   - Emit AuthSuccess(userId, email, name)
   UI: Navigate to home
   ↓
   Error:
   - Emit AuthError(message)
   UI: Show error message
*/

// ============ BLOCLISTENER VS BLOCBUILDER ============
/*
BlocListener:
- Listen to state changes
- ONE-TIME actions (navigate, show dialog, etc)
- Does NOT rebuild UI
Usage: Handle navigation, show snackbar, analytics

Example:
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.push(...);
    }
  },
  child: SomeWidget(),
)

BlocBuilder:
- Listen to state changes
- REBUILD UI
- Depends on state
Usage: Show different widgets based on state

Example:
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    } else if (state is AuthSuccess) {
      return WelcomeScreen();
    } else {
      return LoginScreen();
    }
  },
)

BEST PRACTICE:
- Use BlocListener for side effects (navigation, dialogs)
- Use BlocBuilder for UI changes
- Combine both together
*/

// ============ PUBSPEC.YAML DEPENDENCIES ============
/*
Add these to pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  
  # BLoC
  flutter_bloc: ^8.1.0
  bloc: ^8.1.0
  equatable: ^2.0.5  # For easy state comparison

  # Firebase (already added)
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Testing BLoC
  bloc_test: ^9.0.0
  mocktail: ^0.3.0
*/

// ============ DIRECTORY STRUCTURE ============
/*
lib/
├── blocs/                          (NEW)
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
├── screens/
│   ├── login_screen.dart           (UPDATE: use BLoC)
│   ├── register_screen.dart        (UPDATE: use BLoC)
│   ├── home_screen.dart            (UPDATE: use BLoC)
│   └── ...
├── services/
│   ├── auth_service.dart
│   ├── firestore_notes_service.dart
│   └── ...
├── models/
│   └── note_model.dart
└── main.dart                       (UPDATE: setup BLoC)
*/

// ============ COMPARISON: BEFORE vs AFTER ============
/*
BEFORE (Without BLoC):
┌──────────────────────────┐
│   LoginScreen            │
├──────────────────────────┤
│ - _emailController       │
│ - _passwordController    │
│ - _isLoading             │
│ - _loginUser() { // 30   │
│   await authService...   │
│   setState...            │
│   navigate...            │
│ }                        │
└──────────────────────────┘

Logic campur dengan UI ❌
Sulit di-test ❌
State management kompleks ❌

AFTER (With BLoC):
┌──────────────────────────┐
│   LoginScreen            │  UI ONLY
│   (Simple & Clean)       │
├──────────────────────────┤
│ - BlocListener (nav)     │
│ - BlocBuilder (state)    │
│ - onPressed: dispatch    │
│   event                  │
└──────────────────────────┘
           ↓
┌──────────────────────────┐
│   AuthBloc               │  LOGIC ONLY
├──────────────────────────┤
│ - _onLoginRequested()    │
│ - call authService       │
│ - emit states            │
│ - error handling         │
└──────────────────────────┘
           ↓
┌──────────────────────────┐
│   AuthService            │  SERVICES
│   (Firebase calls)       │
└──────────────────────────┘

Separation of concerns ✓
Easy to test ✓
Simple state management ✓
*/

// ============ TESTING EXAMPLE ============
/*
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('AuthBloc', () {
    late MockAuthService mockAuthService;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login successful',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        LoginRequested(
          email: 'test@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        AuthLoading(),
        isA<AuthSuccess>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        LoginRequested(
          email: 'test@example.com',
          password: 'wrong',
        ),
      ),
      expect: () => [
        AuthLoading(),
        isA<AuthError>(),
      ],
    );
  });
}
*/

// ============ DEBUGGING TIPS ============
/*
1. Enable BLoC observer untuk debug:

import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    print('${bloc.runtimeType} - $change');
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} - ERROR: $error');
    super.onError(bloc, error, stackTrace);
  }
}

main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

2. Inspect state changes di console/logs:
BLoC observer akan print:
- AuthBloc - Change { currentState: AuthInitial, event: AuthCheckRequested, nextState: AuthLoading }
- AuthBloc - Change { currentState: AuthLoading, event: AuthCheckRequested, nextState: AuthSuccess(...) }

3. Use DevTools BLoC extension
4. Check equatable @override List<Object?> get props
*/

// ============ COMMON MISTAKES ============
/*
❌ MISTAKE 1: Emit state di UI
event.add(LoginRequested(...)) // OK
setState(() { ... }) // DON'T - use BLoC instead

✓ CORRECT:
context.read<AuthBloc>().add(LoginRequested(...))

❌ MISTAKE 2: Not implementing Equatable
class AuthState {} // Problem: state always notified

✓ CORRECT:
class AuthState extends Equatable {
  @override
  List<Object?> get props => [...];
}

❌ MISTAKE 3: Too many states
class ProfileUpdatingState {}
class ProfileUpdatedState {}
class ProfileErrorState {}
// Can combine into single ProfileUpdateSuccess

✓ CORRECT:
One state per unique condition

❌ MISTAKE 4: Blocking operations
await heavyLoading(); // Don't do this
emit(state); // Will freeze UI

✓ CORRECT:
Use async operations, emit states early

❌ MISTAKE 5: Not handling all cases
on<LoginRequested>(...); // What if already authenticated?

✓ CORRECT:
Check current state, handle all scenarios
*/

// ============ NEXT STEPS ============
/*
After implementing AuthBloc:

1. Update LoginScreen to use BLoC
2. Update RegisterScreen to use BLoC
3. Update HomeScreen to use BLoC
4. Add NoteBloc untuk notes CRUD
5. Add SearchBloc untuk search functionality
6. Write unit tests untuk BLoCs
7. Add BLoC observer di main.dart
8. Document BLoC events dan states
*/

// ============ SUMMARY ============
/*
✓ BLoC pattern separates logic from UI
✓ Events trigger BLoC logic
✓ BLoC emits States
✓ UI listens to states and updates
✓ Easy to test
✓ Reusable across app
✓ Simple to understand once setup
✓ Great for complex state management

Files created:
1. lib/blocs/auth_event.dart       - Events
2. lib/blocs/auth_state.dart       - States
3. lib/blocs/auth_bloc.dart        - BLoC logic
4. pubspec.yaml updated            - Dependencies
5. main.dart updated               - Setup BLoC
6. *_screen.dart updated           - Use BLoC

Ready to integrate! 🚀
*/
