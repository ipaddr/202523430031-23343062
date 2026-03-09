/// BLoC Troubleshooting & Common Errors
///
/// Solusi untuk error yang sering terjadi

// ============ ERROR 1: "BLoC not found in context" ============
/*
ERROR:
  BLoC not found in context. Make sure you have provided BLocProvider or MultiBlocProvider.

CAUSE:
  Widget berusaha mengakses BLoC tapi BLoC tidak di-provide ke widget tree

SOLUTION:

// ❌ WRONG:
@override
Widget build(BuildContext context) {
  context.read<AuthBloc>();  // BLoC not in context!
}

// ✅ CORRECT:
void main() {
  final authBloc = AuthBloc(authService: AuthService());
  runApp(
    BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MyApp(),
    ),
  );
}

// Or wrap specific screens:
BlocProvider<AuthBloc>.value(
  value: authBloc,
  child: LoginScreen(),
)
*/

// ============ ERROR 2: "Event not handled" ============
/*
ERROR:
  E/BLoC: Unhandled event: LoginRequested instance of 'LoginRequested'

CAUSE:
  Event handler tidak di-register di BLoC constructor

SOLUTION:

// ❌ WRONG:
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authService}) : super(AuthInitial());
  
  // Forgot to register handler!
}

// ✅ CORRECT:
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authService}) : super(AuthInitial()) {
    // Register handler
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // handle event
  }
}
*/

// ============ ERROR 3: "State not updating in UI" ============
/*
ERROR:
  Widget tidak rebuild ketika BLoC emit state baru

CAUSE:
  Equatable props tidak include semua fields

SOLUTION:

// ❌ WRONG:
class AuthSuccess extends AuthState {
  final String userId;
  final String email;
  
  const AuthSuccess({required this.userId, required this.email});
  
  @override
  List<Object?> get props => [];  // Props kosong!
}

// ✅ CORRECT:
class AuthSuccess extends AuthState {
  final String userId;
  final String email;
  
  const AuthSuccess({required this.userId, required this.email});
  
  @override
  List<Object?> get props => [userId, email];  // Include all fields
}

// Atau versi yang lebih simple:
class AuthSuccess extends AuthState {
  final String userId;
  final String email;
  
  const AuthSuccess({required this.userId, required this.email});
  
  @override
  List<Object?> get props => [userId, email];
}

// When emitting, buat instance baru:
emit(AuthSuccess(userId: uid, email: email));
*/

// ============ ERROR 4: "Multiple rebuilds / widget rebuilds too often" ============
/*
ERROR:
  BlocBuilder rebuild terlalu banyak kali (infinite loop?)

CAUSE:
  - State emit multiple times dalam satu event handler
  - BlocBuilder tidak punya proper state comparison

SOLUTION:

// ❌ WRONG:
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) {
  emit(AuthLoading());
  emit(AuthLoading());  // Duplicate emit!
  emit(AuthLoading());
}

// ✅ CORRECT:
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) {
  emit(AuthLoading());
  // ... do work ...
  emit(AuthSuccess(...));
}

// ❌ WRONG: Emit duplicate state
emit(AuthSuccess(userId: id));
emit(AuthSuccess(userId: id));  // Exact same state

// ✅ CORRECT: Equatable prevents duplicate rebuilds
// Same props = no rebuild
emit(AuthSuccess(userId: id));
emit(AuthSuccess(userId: id));  // No rebuild because props same
*/

// ============ ERROR 5: "Cannot call context.watch outside BlocBuilder" ============
/*
ERROR:
  'watch' called outside of BlocBuilder or BlocListener

CAUSE:
  context.watch() hanya bisa dipakai inside BlocBuilder/BlocListener

SOLUTION:

// ❌ WRONG:
void _handleLogin() {
  final state = context.watch<AuthBloc>().state;  // ERROR!
}

// ✅ CORRECT:
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    // Can access state here
    return Container();
  },
)

// Or use context.read (one-time access):
final state = context.read<AuthBloc>().state;  // OK at any time
*/

// ============ ERROR 6: "Memory leak - BLoC not closed" ============
/*
ERROR:
  BLoC resources not released, memory leak detected

CAUSE:
  BLoC tidak di-close, streams masih active

SOLUTION:

// ❌ WRONG:
void main() {
  final authBloc = AuthBloc(...);
  runApp(MyApp(authBloc: authBloc));
  // No close!
}

// ✅ CORRECT:
void main() async {
  final authBloc = AuthBloc(...);
  runApp(MyApp(authBloc: authBloc));
  
  // Later when app closes:
  authBloc.close();  // Clean up resources
}

// Or in test:
void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    
    setUp(() {
      authBloc = AuthBloc(...);
    });
    
    tearDown(() {
      authBloc.close();  // Always close
    });
  });
}
*/

// ============ ERROR 7: "Type 'X' is not a subtype of type 'Y'" ============
/*
ERROR:
  Type mismatch antara event/state class

CAUSE:
  Event type tidak sesuai dengan handler signature

SOLUTION:

// ❌ WRONG:
on<LoginRequested>((event, emit) {
  // event tipe seharusnya LoginRequested
});

// But added:
context.read<AuthBloc>().add(LogoutRequested());  // Wrong event!

// ✅ CORRECT:
on<LoginRequested>((event, emit) {
  // event is LoginRequested
});

// Add matching event:
context.read<AuthBloc>().add(LoginRequested(...));
*/

// ============ ERROR 8: "Null safety error: nullable state" ============
/*
ERROR:
  Unsafe access to potentially null state

CAUSE:
  State null check tidak dilakukan

SOLUTION:

// ❌ WRONG:
if (state is AuthSuccess) {
  print(state.userId);  // Assuming state not null
}

// ✅ CORRECT:
final currentState = context.read<AuthBloc>().state;
if (currentState is AuthSuccess) {
  print(currentState.userId);
}

// Or in BlocBuilder (state guaranteed not null):
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthSuccess) {
      return Text(state.userId);
    }
    return Text('Not logged in');
  },
)
*/

// ============ ERROR 9: "Navigation inside BLoC" ============
/*
ERROR:
  Navigator not available inside BLoC (no context)

CAUSE:
  BLoC tidak punya access ke BuildContext

SOLUTION:

// ❌ WRONG:
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) {
  // ...
  Navigator.pushNamed(context, '/home');  // No context in BLoC!
}

// ✅ CORRECT: Navigate di UI layer (BlocListener/BlocBuilder)
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.pushNamed(context, '/home');  // Navigate here
    }
  },
  child: LoginForm(),
)

// Or, BLoC emit state, UI handles navigation:
// BLoC: emit(AuthSuccess(...))
// UI: Listen and navigate based on state
*/

// ============ ERROR 10: "Firebase exception not handled" ============
/*
ERROR:
  FirebaseAuthException saat login tapi tidak ditangani

CAUSE:
  try-catch tidak menangkap exception

SOLUTION:

// ❌ WRONG:
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) {
  emit(AuthLoading());
  
  final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: event.email,
    password: event.password,
  );  // Can throw FirebaseAuthException!
  
  emit(AuthSuccess(...));  // Assume always success
}

// ✅ CORRECT:
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) {
  try {
    emit(AuthLoading());
    
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    
    // Fetch Firestore profile...
    
    emit(AuthSuccess(...));
  } on FirebaseAuthException catch (e) {
    final message = _getAuthErrorMessage(e.code);
    emit(AuthError(message: message, errorCode: e.code));
  } catch (e) {
    emit(AuthError(message: 'An error occurred'));
  }
}

String _getAuthErrorMessage(String code) {
  return switch (code) {
    'user-not-found' => 'User not found',
    'wrong-password' => 'Wrong password',
    'weak-password' => 'Password too weak',
    'email-already-in-use' => 'Email already registered',
    'invalid-email' => 'Invalid email',
    _ => 'Login failed',
  };
}
*/

// ============ ERROR 11: "BLoC accessed before initialization" ============
/*
ERROR:
  Trycatch akses BLoC sebelum di-provide

CAUSE:
  Widget tree struktur tidak benar

SOLUTION:

// ❌ WRONG:
void main() {
  runApp(
    MaterialApp(
      home: LoginScreen(),  // LoginScreen tries to read AuthBloc
      // But AuthBloc not in context!
    ),
  );
}

// ✅ CORRECT:
void main() {
  final authBloc = AuthBloc(authService: AuthService());
  
  runApp(
    BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(
        home: AuthWrapper(),  // Now BLoC available
      ),
    ),
  );
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // BLoC available here
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) return HomeScreen();
        return LoginScreen();
      },
    );
  }
}
*/

// ============ ERROR 12: "setState called during build" ============
/*
ERROR:
  setState called during build phase

CAUSE:
  Mencoba emit state dari inside build method

SOLUTION:

// ❌ WRONG:
@override
Widget build(BuildContext context) {
  // Jangan dispatch event di build!
  context.read<AuthBloc>().add(AuthCheckRequested());
  
  return Scaffold(...);
}

// ✅ CORRECT:
@override
void initState() {
  super.initState();
  // Dispatch event di initState atau sebelum build
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AuthBloc>().add(AuthCheckRequested());
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(...);
}

// Atau lebih simple:
void main() {
  final authBloc = AuthBloc(...);
  authBloc.add(const AuthCheckRequested());  // Before runApp
  runApp(MyApp(authBloc: authBloc));
}
*/

// ============ ERROR 13: "Bloc is already closed" ============
/*
ERROR:
  Cannot add event to closed BLoC

CAUSE:
  BLoC di-close tapi masih coba add event

SOLUTION:

// ❌ WRONG:
authBloc.close();
authBloc.add(LoginRequested(...));  // BLoC already closed!

// ✅ CORRECT:
authBloc.add(LoginRequested(...));
// Later when done
authBloc.close();

// In widgets, BLoC provider handles close:
// Tidak perlu manual close jika pakai BlocProvider
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc(...),
  child: LoginScreen(),  // Provider auto-closes when removed
)
*/

// ============ ERROR 14: "State instance mismatch" ============
/*
ERROR:
  BlocBuilder tidak rebuild meskipun state emit

CAUSE:
  Equatable props tidak identik, atau state tidak extends Equatable properly

SOLUTION:

// ❌ WRONG:
class AuthSuccess extends AuthState {
  final String userId;
  
  const AuthSuccess({required this.userId});
  
  // Lupa Equatable
}

// ✅ CORRECT:
class AuthSuccess extends AuthState {
  final String userId;
  
  const AuthSuccess({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

// And use const constructors:
emit(const AuthSuccess(userId: '123'));  // Use const
*/

// ============ ERROR 15: "Race condition - events processed out of order" ============
/*
ERROR:
  Events diproses dengan urutan tidak terduga

CAUSE:
  Multiple events di-add bersamaan tanpa handling concurrency

SOLUTION:

// ❌ WRONG:
void _handleLoginAndLogout() {
  context.read<AuthBloc>().add(LoginRequested(...));
  context.read<AuthBloc>().add(LogoutRequested());  // Race!
}

// ✅ CORRECT:
// Option 1: Sequential (event handler tunggu sebelum next)
void _handleLogin() {
  context.read<AuthBloc>().add(LoginRequested(...));
}

// Only add logout after login successful
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Future.delayed(Duration(seconds: 2), () {
        context.read<AuthBloc>().add(LogoutRequested());
      });
    }
  },
)

// Option 2: Pipeline events dengan BLoC event transformer
// (Advanced - use EventTransformer dalam on<>)
*/

// ============ DEBUGGING TIPS ============
/*
1. Add BLocObserver:
@override
void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('Event: $event');
  }
  
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('Change: ${change.currentState} -> ${change.nextState}');
  }
}

2. Add logs dalam event handler:
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) {
  print('LOGIN: Starting login with ${event.email}');
  emit(AuthLoading());
  // ...
  print('LOGIN: Success');
  emit(AuthSuccess(...));
}

3. Use Flutter DevTools:
- Run: flutter run --devtools
- Tab: Bloc
- Lihat event flow dan state transitions

4. Test dengan bloc_test:
blocTest<AuthBloc, AuthState>(
  'test login',
  build: () => AuthBloc(...),
  act: (bloc) => bloc.add(LoginRequested(...)),
  expect: () => [AuthLoading(), AuthSuccess(...)],
)
*/

// ============ CHECKLIST TROUBLESHOOTING ============
/*
Sebelum claim error:

☐ BLoC di-provide dengan BlocProvider?
☐ Event handler di-register dalam BLoC constructor?
☐ Equatable props include semua fields?
☐ State emit dari correct event handler?
☐ Navigation di BlocListener, bukan di BLoC?
☐ Firebase exception di-catch?
☐ No setState dalam build method?
☐ BLoC closed properly?
☐ Context available di widget?
☐ Event class matches handler type?
☐ No async work tanpa emit AuthLoading?
☐ Stream cleanup di close()?
*/
