/// Quick Reference: BLoC Patterns & Common Usage
///
/// Kumpulan code snippets yang sering digunakan

// ============ 1. Dispatch Event dari Button ============
/*
void _handleLogin() {
  context.read<AuthBloc>().add(
    LoginRequested(
      email: _emailController.text,
      password: _passwordController.text,
    ),
  );
}
*/

// ============ 2. Listen to State Changes & Navigate ============
/*
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
*/

// ============ 3. Build UI Based on State ============
/*
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    } else if (state is AuthSuccess) {
      return Text('Welcome, ${state.name}');
    } else if (state is AuthError) {
      return Text('Error: ${state.message}');
    }
    return Text('Login to continue');
  },
)
*/

// ============ 4. Combine BlocListener + BlocBuilder ============
/*
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    // Handle side effects (navigation, snackbars)
    if (state is AuthSuccess) {
      Navigator.pushNamed(context, '/home');
    }
  },
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      // Build UI based on state
      return isLoading
          ? LoadingWidget()
          : SuccessWidget();
    },
  ),
)
*/

// ============ 5. Get Current State (One-time) ============
/*
final currentState = context.read<AuthBloc>().state;
if (currentState is AuthSuccess) {
  print('User: ${currentState.email}');
}
*/

// ============ 6. Watch State (Reactive) ============
/*
final state = context.watch<AuthBloc>().state;
// This widget rebuilds when state changes
// Only use inside BlocBuilder/BlocListener or with watchAll
*/

// ============ 7. Create Simple Event ============
/*
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
  
  @override
  List<Object?> get props => [];
}

// Emit in BLoC:
event.listen(
  (event) {
    if (event is LogoutRequested) {
      emit(AuthUnauthenticated());
    }
  },
);
*/

// ============ 8. Create Event with Data ============
/*
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object?> get props => [email, password];
}

// Use:
context.read<AuthBloc>().add(
  LoginRequested(email: 'test@test.com', password: 'pass123'),
);
*/

// ============ 9. State with Data ============
/*
class AuthSuccess extends AuthState {
  final String userId;
  final String email;
  final String? name;
  
  const AuthSuccess({
    required this.userId,
    required this.email,
    this.name,
  });
  
  @override
  List<Object?> get props => [userId, email, name];
}

// Access:
if (state is AuthSuccess) {
  print('User: ${state.name}');
  print('Email: ${state.email}');
}
*/

// ============ 10. Error State ============
/*
class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  
  const AuthError({
    required this.message,
    this.errorCode,
  });
  
  @override
  List<Object?> get props => [message, errorCode];
}

// Show error:
if (state is AuthError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
*/

// ============ 11. Handle Multiple States in Builder ============
/*
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return switch (state) {
      AuthInitial() => _buildInitial(),
      AuthLoading() => _buildLoading(),
      AuthSuccess() => _buildSuccess(state),
      AuthError() => _buildError(state),
      AuthUnauthenticated() => _buildLogin(),
      _ => SizedBox.shrink(),
    };
  },
)

// Or if/else version:
if (state is AuthSuccess) { ... }
else if (state is AuthError) { ... }
else if (state is AuthLoading) { ... }
*/

// ============ 12. Logout ============
/*
void _handleLogout() {
  context.read<AuthBloc>().add(const LogoutRequested());
}

// BLoC handler:
on<LogoutRequested>((event, emit) async {
  try {
    emit(AuthLoading());
    await _authService.logout();
    emit(AuthUnauthenticated());
  } catch (e) {
    emit(AuthError(message: 'Logout failed'));
  }
});
*/

// ============ 13. Persist User on App Start ============
/*
void main() {
  final authBloc = AuthBloc(authService: AuthService());
  
  // Check if user still logged in
  authBloc.add(const AuthCheckRequested());
  
  runApp(MyApp(authBloc: authBloc));
}
*/

// ============ 14. Use BLoC in Multiple Screens ============
/*
// Option A: Share same BLoC instance (BlocProvider.value)
BlocProvider<AuthBloc>.value(
  value: authBloc,
  child: HomeScreen(),
)

// Option B: Create new instance (rarely needed)
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc(),
  child: HomeScreen(),
)

// Option C: Multi-Screen App
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>.value(value: authBloc),
    BlocProvider<NoteBloc>.value(value: noteBloc),
  ],
  child: MyApp(),
)
*/

// ============ 15. Show Loading Dialog ============
/*
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  },
  child: LoginForm(),
)
*/

// ============ 16. Update Profile ============
/*
void _updateProfile() {
  context.read<AuthBloc>().add(
    UpdateProfileRequested(
      name: _nameController.text,
      photoUrl: _photoUrl,
    ),
  );
}

Listen for:
if (state is ProfileUpdateSuccess) {
  showSnackBar('Profile updated!');
}
*/

// ============ 17. Reset Password ============
/*
void _resetPassword() {
  context.read<AuthBloc>().add(
    ResetPasswordRequested(email: _emailController.text),
  );
}

Listen for:
if (state is ResetPasswordEmailSent) {
  showSnackBar('Email sent to ${state.email}');
}
*/

// ============ 18. Check Auth Status Without Building ============
/*
final authBloc = context.read<AuthBloc>();
if (authBloc.state is AuthSuccess) {
  // User is logged in
  final authState = authBloc.state as AuthSuccess;
  print('User ID: ${authState.userId}');
}
*/

// ============ 19. Conditional Navigation based on Auth ============
/*
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return SplashScreen();
        } else if (state is AuthSuccess) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
*/

// ============ 20. Test: Mock AuthBloc ============
/*
void main() {
  testWidgets('Login button shows loading', (tester) async {
    final mockAuthBloc = MockAuthBloc();
    
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    
    await tester.tap(find.byText('Login'));
    await tester.pump();
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
*/

// ============ COMMON PATTERNS ============
/*
Pattern 1: Init + Success Flow
main() -> AuthCheckRequested -> AuthSuccess -> HomeScreen

Pattern 2: Login Flow
LoginScreen -> LoginRequested -> AuthLoading -> AuthSuccess -> HomeScreen

Pattern 3: Register Flow
RegisterScreen -> RegisterRequested -> AuthLoading -> AuthSuccess -> HomeScreen

Pattern 4: Logout Flow
HomeScreen -> LogoutRequested -> AuthLoading -> AuthUnauthenticated -> LoginScreen

Pattern 5: Error Handling
Any Action -> AuthLoading -> Error (network/validation) -> AuthError -> show SnackBar

Pattern 6: Profile Update
ProfileScreen -> UpdateProfileRequested -> AuthLoading -> ProfileUpdateSuccess + AuthSuccess updated
*/

// ============ IMPORTS NEEDED ============
/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
*/

// ============ DO's ✅ ============
/*
✅ Use BlocListener for side effects (navigation, dialogs, snackbars)
✅ Use BlocBuilder for rebuilding UI
✅ Call context.read() inside event handlers
✅ Use Equatable props for proper state comparison
✅ Emit AuthLoading before async operations
✅ Handle errors with mapped messages
✅ Close BLoC in cleanup
✅ Test BLoC with bloc_test
✅ Use MultiBlocProvider for multiple BLoCs
✅ Pass dependencies via BLoC constructor
*/

// ============ DON'Ts ❌ ============
/*
❌ Call context.watch() outside BlocBuilder/BlocListener
❌ Emit multiple states in one handler
❌ Do async work without AuthLoading first
❌ Mix BLoC with setState
❌ Handle navigation in BLoC (use BlocListener instead)
❌ Share BLoC state across unrelated screens
❌ Forget to add props to Equatable classes
❌ Emit same state multiple times (inefficient)
❌ Block main thread with long operations
❌ Ignore stream cleanup (memory leaks)
*/
