/// Auth BLoC Exception Handling - Complete Guide
///
/// Panduan lengkap untuk handle exceptions saat login

// ============ OVERVIEW ============
/*
Exception handling saat login adalah crucial untuk:
1. Show user-friendly error messages
2. Guide user untuk fix masalah
3. Retry failed operations
4. Provide clear feedback

Flow:
User Input → Validation → Firebase Call → Exception → Map Exception → Show Error → User

*/

// ============ STEP 1: Define Custom Exceptions ============
/*
File: lib/exceptions/auth_exceptions.dart

Define custom exceptions untuk semua error cases:
- UserNotFoundException (email tidak terdaftar)
- WrongPasswordException (password salah)
- WeakPasswordException (password terlalu lemah)
- EmailAlreadyInUseException (email sudah terdaftar)
- InvalidEmailException (format email salah)
- NetworkException (internet tidak ada)
- TooManyAttemptsException (terlalu banyak percobaan gagal)
- And more...

Keuntungan:
✅ Type-safe exception handling
✅ Easy to map to UI messages
✅ Reusable across app
✅ Easy to test
*/

// ============ STEP 2: Exception Handler Utility ============
/*
Create utility class untuk convert Firebase exceptions:

class AuthExceptionHandler {
  static AuthException handleFirebaseException(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseException(error.code);
    }
    return UnknownAuthException();
  }

  static AuthException _mapFirebaseException(String code) {
    return switch (code) {
      'user-not-found' => UserNotFoundException(),
      'wrong-password' => WrongPasswordException(),
      'weak-password' => WeakPasswordException(),
      'email-already-in-use' => EmailAlreadyInUseException(),
      _ => UnknownAuthException(),
    };
  }

  static AuthException? validateEmail(String email) {
    if (email.isEmpty) return EmptyEmailException();
    if (!email.contains('@')) return InvalidEmailFormatException();
    return null;
  }
}
*/

// ============ STEP 3: Update Auth BLoC ============
/*
Enhanced _onLoginRequested dengan exception handling:

Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    emit(const AuthLoading());

    // 1. Validate input first
    final validationErrors = AuthExceptionHandler.validateLoginForm(
      event.email,
      event.password,
    );

    if (validationErrors.isNotEmpty) {
      final error = validationErrors.first;
      emit(AuthError(message: error.message, errorCode: error.errorCode));
      return;
    }

    // 2. Try sign in
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: event.email.trim(),
      password: event.password,
    );

    // 3. Get user profile from Firestore
    if (userCredential.user != null) {
      final user = userCredential.user!;
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        emit(
          AuthSuccess(
            userId: user.uid,
            email: user.email ?? 'Unknown',
            name: userData['name'] as String?,
            photoUrl: userData['photoUrl'] as String?,
          ),
        );
      } else {
        emit(AuthSuccess(
          userId: user.uid,
          email: user.email ?? 'Unknown',
          name: user.displayName,
          photoUrl: user.photoURL,
        ));
      }
    }

  } on FirebaseAuthException catch (e) {
    // Firebase auth error
    final exception = AuthExceptionHandler.handleFirebaseException(e);
    emit(AuthError(message: exception.message, errorCode: exception.errorCode));

  } on AuthException catch (e) {
    // Custom exception
    emit(AuthError(message: e.message, errorCode: e.errorCode));

  } catch (e) {
    // Unknown error
    final exception = AuthExceptionHandler.handleFirebaseException(e);
    emit(AuthError(message: exception.message, errorCode: exception.errorCode));
  }
}
*/

// ============ STEP 4: Handle Exceptions in UI ============
/*
A. Show error dengan SnackBar:

BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: LoginForm(),
)

B. Show error dengan AlertDialog:

if (state is AuthError) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Login Gagal'),
      content: Text(state.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

C. Show validation error di TextField:

TextField(
  decoration: InputDecoration(
    hintText: 'Email',
    errorText: _emailError,  // Show validation error
    border: OutlineInputBorder(),
  ),
)

D. Retry option untuk network errors:

if (state.errorCode == 'network-request-failed') {
  // Show retry dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Network Error'),
      content: const Text('Check internet and retry'),
      actions: [
        ElevatedButton(
          onPressed: () => _handleLogin(),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
*/

// ============ STEP 5: Validation Before Firebase Call ============
/*
Validate email/password sebelum kirim ke Firebase:

// Option 1: Client-side validation
void _validateForm() {
  final emailError = AuthExceptionHandler.validateEmail(_emailController.text);
  final passwordError = AuthExceptionHandler.validatePassword(
    _passwordController.text,
  );

  if (emailError != null || passwordError != null) {
    setState(() {
      _emailError = emailError?.message;
      _passwordError = passwordError?.message;
    });
    return;  // Don't call Firebase
  }

  // Call BLoC
  context.read<AuthBloc>().add(LoginRequested(...));
}

// Option 2: Validation inside BLoC
Future<void> _onLoginRequested(...) async {
  final validationErrors = AuthExceptionHandler.validateLoginForm(
    event.email,
    event.password,
  );

  if (validationErrors.isNotEmpty) {
    emit(AuthError(message: validationErrors.first.message));
    return;
  }

  // Proceed with Firebase
}
*/

// ============ STEP 6: Different Error Messages ============
/*
Show different messages berdasarkan error code:

String _getErrorMessage(String? errorCode) {
  return switch (errorCode) {
    'user-not-found' => 'Email tidak terdaftar. Daftar sekarang',
    'wrong-password' => 'Password salah. Coba lagi',
    'invalid-email' => 'Format email tidak benar',
    'weak-password' => 'Password minimal 6 karakter',
    'email-already-in-use' => 'Email sudah digunakan',
    'network-request-failed' => 'Network error. Periksa internet',
    'too-many-requests' => 'Terlalu banyak percobaan. Coba nanti',
    'user-disabled' => 'Akun sudah dinonaktifkan',
    _ => 'Login gagal. Coba lagi',
  };
}
*/

// ============ STEP 7: Custom Exception Extension Methods ============
/*
Extend AuthError untuk helper methods:

extension AuthErrorExtension on AuthError {
  bool get isNetworkError => errorCode == 'network-request-failed';

  bool get isAuthError =>
      errorCode == 'wrong-password' ||
      errorCode == 'user-not-found';

  bool get isRetryable =>
      isNetworkError || errorCode == 'too-many-requests';

  bool get shouldPromptRegister => errorCode == 'user-not-found';
}

Usage:
if (state is AuthError) {
  if (state.isNetworkError) {
    // Show retry button
  } else if (state.shouldPromptRegister) {
    // Show "Daftar sekarang" button
  }
}
*/

// ============ STEP 8: Real-Time Validation ============
/*
Validate while user typing:

TextField(
  onChanged: (value) {
    if (_emailError != null) {
      // Validate again jika ada error sebelumnya
      setState(() {
        _emailError = AuthExceptionHandler
            .validateEmail(value)
            ?.message;
      });
    }
  },
  decoration: InputDecoration(
    errorText: _emailError,
    border: OutlineInputBorder(),
  ),
)

Benefit:
✅ User gets immediate feedback
✅ Can fix error sambil typing
✅ Better UX
*/

// ============ STEP 9: Loading State ============
/*
Show loading indicator during login:

BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    bool isLoading = state is AuthLoading;

    return Column(
      children: [
        TextField(enabled: !isLoading),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : _handleLogin,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Login'),
        ),
      ],
    );
  },
)
*/

// ============ STEP 10: Success Feedback ============
/*
Show success message setelah login berhasil:

if (state is AuthSuccess) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Login berhasil! 🎉'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
  
  // Navigate to home
  Future.delayed(const Duration(seconds: 1), () {
    Navigator.pushReplacementNamed(context, '/home');
  });
}
*/

// ============ COMPLETE LOGIN FLOW ============
/*
1. User taps Login button
   ↓
2. Validate email/password on client
   ↓
3. Show validation errors jika ada
   ↓
4. If valid, emit LoginRequested event
   ↓
5. AuthBloc receive event
   ↓
6. Emit AuthLoading
   ↓
7. Validate lagi inside BLoC
   ↓
8. Call Firebase signInWithEmailAndPassword()
   ↓
9. Catch FirebaseAuthException
   ↓
10. Map error code to custom exception
   ↓
11. Emit AuthError(message, errorCode)
   ↓
12. BlocListener receives error
   ↓
13. Show error SnackBar/Dialog/Alert
   ↓
14. Offer retry untuk network errors
   ↓
15. Show register prompt untuk user-not-found
   ↓
16. User retry atau navigate to register
*/

// ============ TESTING EXCEPTIONS ============
/*
Test exception handling dengan bloc_test:

void main() {
  group('AuthBloc - Exception Handling', () {
    late AuthBloc authBloc;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    // Test wrong password
    blocTest<AuthBloc, AuthState>(
      'emits AuthError when wrong password',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        LoginRequested(
          email: 'test@test.com',
          password: 'wrongpass',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>()
            .having((e) => e.errorCode, 'errorCode', 'wrong-password'),
      ],
    );

    // Test validation error
    blocTest<AuthBloc, AuthState>(
      'emits AuthError for invalid email',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        LoginRequested(
          email: 'invalid-email',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>()
            .having((e) => e.errorCode, 'errorCode', 'invalid-email'),
      ],
    );

    // Test network error
    blocTest<AuthBloc, AuthState>(
      'emits AuthError on network failure',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        LoginRequested(
          email: 'test@test.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>()
            .having((e) => e.isNetworkError, 'isNetworkError', true),
      ],
    );
  });
}
*/

// ============ CHECKLIST ============
/*
Exception Handling Implementation:

☐ Create custom exception classes
☐ Create AuthExceptionHandler utility
☐ Update AuthBloc with try-catch blocks
☐ Map Firebase error codes to custom exceptions
☐ Add client-side validation
☐ Show validation errors in TextField
☐ Show error messages with SnackBar/Dialog
☐ Offer retry option untuk network errors
☐ Show register prompt untuk user-not-found
☐ Show loading state during login
☐ Show success message after login
☐ Test exception handling cases
☐ Handle edge cases (null values, etc)
☐ Test on real Firebase
*/

// ============ COMMON EXCEPTIONS TO HANDLE ============
/*
Firebase Authentication Exceptions:

1. user-not-found
   → Email tidak terdaftar
   → Action: Prompt user to register

2. wrong-password
   → Password salah
   → Action: Show error, allow retry

3. invalid-email
   → Email format salah
   → Action: Show validation error

4. weak-password
   → Password terlalu pendek/sederhana (< 6 chars)
   → Action: Show password requirements

5. email-already-in-use
   → Email sudah terdaftar (saat register)
   → Action: Ask to login atau gunakan email lain

6. network-request-failed
   → Internet tidak ada/lambat
   → Action: Show retry button

7. too-many-requests
   → Terlalu banyak percobaan login gagal
   → Action: Lock login, show cooldown timer

8. user-disabled
   → Akun sudah dinonaktifkan admin
   → Action: Show message, contact support

9. operation-not-allowed
   → Email/password auth tidak diaktifkan di Firebase
   → Action: Contact support

10. credential-already-in-use
    → Credential sudah digunakan user lain
    → Action: Show error, allow reconnect
*/

// ============ TIPS & BEST PRACTICES ============
/*
✅ DO:
- Validate input BEFORE calling Firebase
- Show clear, user-friendly error messages
- Offer retry untuk network errors
- Prompt register untuk user-not-found
- Use try-catch for synchronous operations
- Use try-on-catch for async operations
- Test edge cases
- Log errors untuk debugging (tidak di produksi)
- Handle loading state properly
- Show success feedback

❌ DON'T:
- Show raw Firebase error codes (user-not-found)
- Expose sensitive information (email is invalid)
- Call Firebase without validation
- Ignore network errors
- Show technical messages
- Block UI without loading indicator
- Retry endlessly on network error
- Forget to catch exceptions
- Assume Firebase always succeeds
- Mix BLoC logic dengan UI logic
*/
