/// Exception Handling Quick Reference
///
/// Cepat cek Exception Handling patterns & code templates

// ============ EXCEPTION TYPES ============
/*
Custom Exceptions:
- UserNotFoundException
- WrongPasswordException
- WeakPasswordException
- EmailAlreadyInUseException
- InvalidEmailException
- NetworkException
- TooManyAttemptsException
- AccountDisabledException
- OperationNotAllowedException

Validation Exceptions:
- EmptyEmailException
- EmptyPasswordException
- InvalidEmailFormatException
- PasswordTooShortException

Generic:
- UnknownAuthException
*/

// ============ ERROR CODES → FRIENDLY MESSAGES ============
/*
Firebase Code          →    User Message
─────────────────────────────────────────────────────
user-not-found        →    "User tidak ditemukan"
wrong-password        →    "Password salah"
weak-password         →    "Password terlalu lemah"
email-already-in-use  →    "Email sudah digunakan"
invalid-email         →    "Email tidak valid"
network-request-failed →   "Network error"
too-many-requests     →    "Terlalu banyak percobaan"
user-disabled         →    "Akun dinonaktifkan"
operation-not-allowed →    "Operasi tidak diizinkan"
*/

// ============ QUICK CODE SNIPPETS ============

// 1. Import exceptions
import '../exceptions/auth_exceptions.dart';

// 2. Validate login form
final errors = AuthExceptionHandler.validateLoginForm(email, password);
if (errors.isNotEmpty) {
  emit(AuthError(message: errors.first.message));
  return;
}

// 3. Handle Firebase exception
final exception = AuthExceptionHandler.handleFirebaseException(error);
emit(AuthError(message: exception.message, errorCode: exception.errorCode));

// 4. Validate email only
final emailError = AuthExceptionHandler.validateEmail(email);
if (emailError != null) {
  setState(() => _emailError = emailError.message);
}

// 5. Validate password only
final passwordError = AuthExceptionHandler.validatePassword(password);
if (passwordError != null) {
  setState(() => _passwordError = passwordError.message);
}

// 6. Show error snackbar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(state.message)),
);

// 7. Show error dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Error'),
    content: Text(state.message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ],
  ),
);

// 8. Check if error is retryable
if (state.errorCode == 'network-request-failed' ||
    state.errorCode == 'too-many-requests') {
  // Show retry button
}

// 9. Check if should prompt register
if (state.errorCode == 'user-not-found' ||
    state.errorCode == 'email-already-in-use') {
  // Show register prompt
}

// 10. Show validation error in TextField
TextField(
  decoration: InputDecoration(
    errorText: _emailError,
    border: OutlineInputBorder(),
  ),
)

// ============ COMPLETE EVENT HANDLER TEMPLATE ============
/*
Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    emit(const AuthLoading());

    // 1. Validate input
    final errors = AuthExceptionHandler.validateLoginForm(
      event.email,
      event.password,
    );
    if (errors.isNotEmpty) {
      emit(AuthError(message: errors.first.message));
      return;
    }

    // 2. Firebase call
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: event.email.trim(),
      password: event.password,
    );

    // 3. Get user profile
    if (userCredential.user != null) {
      final user = userCredential.user!;
      // ... fetch profile ...
      emit(AuthSuccess(...));
    }

  } on FirebaseAuthException catch (e) {
    final exception = AuthExceptionHandler.handleFirebaseException(e);
    emit(AuthError(message: exception.message, errorCode: exception.errorCode));

  } on AuthException catch (e) {
    emit(AuthError(message: e.message, errorCode: e.errorCode));

  } catch (e) {
    final exception = AuthExceptionHandler.handleFirebaseException(e);
    emit(AuthError(message: exception.message, errorCode: exception.errorCode));
  }
}
*/

// ============ UI PATTERN: Show Error & Retry ============
/*
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      if (state.errorCode == 'network-request-failed') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: _handleLogin,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    }
  },
  child: LoginForm(),
)
*/

// ============ UI PATTERN: Validation Error in TextField ============
/*
String? _emailError;

void _validateEmail() {
  final error = AuthExceptionHandler.validateEmail(_emailController.text);
  setState(() => _emailError = error?.message);
}

TextField(
  controller: _emailController,
  onChanged: (_) {
    if (_emailError != null) _validateEmail();
  },
  decoration: InputDecoration(
    hintText: 'Email',
    errorText: _emailError,
    border: OutlineInputBorder(),
  ),
)
*/

// ============ FILE STRUCTURE ============
/*
lib/
├── exceptions/
│   └── auth_exceptions.dart      ← Custom exceptions
├── blocs/
│   ├── auth_bloc.dart            ← Updated with exception handling
│   ├── auth_event.dart
│   └── auth_state.dart
├── screens/
│   └── login_screen.dart         ← Shows errors
└── services/
    └── auth_service.dart
*/

// ============ FIREBASE ERROR CODES (Complete List) ============
/*
Authentication Errors:
- user-not-found
- wrong-password
- weak-password
- email-already-in-use
- invalid-email
- network-request-failed
- too-many-requests
- user-disabled
- operation-not-allowed
- credential-already-in-use
- invalid-credential
- user-mismatch
- requires-recent-login
- account-exists-with-different-credential

Each needs custom exception + user message
*/

// ============ TESTING CHECKLIST ============
/*
Test Cases:
□ Empty email
□ Invalid email format (no @ or .)
□ Empty password
□ Short password (< 6 chars)
□ Valid input, user not found
□ Valid input, wrong password
□ Valid input, success
□ Offline (network error)
□ Strong email/weak password
□ Weak email/strong password
□ Duplicate email (register)
□ Too many attempts
*/

// ============ PERFORMANCE TIPS ============
/*
✅ Validate locally before Firebase call
✅ Trim email input (spaces matter)
✅ Cache validation results if needed
✅ Show errors immediately (don't delay)
✅ Implement debounce untuk real-time validation
✅ Don't retry automatically on auth errors
✅ Log errors for analytics (anonymized)
✅ Use constants untuk error codes (no typos)

❌ Don't call Firebase unnecessarily
❌ Don't show technical error messages
❌ Don't block UI without loading indicator
❌ Don't ignore network errors
❌ Don't expose sensitive info
*/

// ============ IMPLEMENTATION ORDER ============
/*
1. Create auth_exceptions.dart (30 min)
2. Create AuthExceptionHandler utility (20 min)
3. Update auth_bloc.dart with exceptions (30 min)
4. Update LoginScreen to show errors (20 min)
5. Test all error scenarios (30 min)
6. Update RegisterScreen (20 min)
7. Update other screens (20 min)
8. Final testing (30 min)

Total: ~3 hours

Can do:
- Part 1: Create exceptions + auth_bloc (50 min)
- Part 2: Update screens + test (80 min)
*/

// ============ COMMON MISTAKES ============
/*
❌ Don't:
- Forget try-catch
- Only catch FirebaseAuthException
- Show raw error codes
- Validate after Firebase call
- Ignore validation errors
- Hardcode error messages (not translatable)
- Mix BLoC logic with UI logic
- Retry automatically
- Block UI without indicator
- Ignore edge cases

✅ Do:
- Use try-on-catch properly
- Catch all exception types
- Map errors to messages
- Validate before Firebase
- Respect validation errors
- Use constants for messages
- Separate concerns
- Let user decide retry
- Show loading state
- Test edge cases
*/

// ============ FOR REFERENCE: Extension Methods ============
/*
extension AuthErrorExtension on AuthError {
  bool get isNetworkError => errorCode == 'network-request-failed';
  bool get isAuthError => errorCode == 'wrong-password' || errorCode == 'user-not-found';
  bool get isRetryable => isNetworkError || errorCode == 'too-many-requests';
  bool get isValidationError => errorCode?.startsWith('invalid-') ?? false;
  bool get shouldPromptRegister => errorCode == 'user-not-found';
}

Usage:
if (state is AuthError) {
  if (state.isRetryable) showRetryButton();
  if (state.shouldPromptRegister) showRegisterPrompt();
}
*/

// ============ DEBUGGING TIPS ============
/*
1. Add BlocObserver:
   Bloc.observer = SimpleBlocObserver();

2. Log in auth_bloc.dart:
   if (kDebugMode) print('Event: $event');

3. Use breakpoints at exception handling

4. Test with Firebase emulator

5. Check Firebase auth logs in console

6. Use Flutter DevTools BLoC tab

7. Add Analytics to track errors

8. Create error reports
*/

// ============ DEPLOYMENT CHECKLIST ============
/*
Before going to production:
□ All exception types defined
□ Exception handler complete
□ All error messages user-friendly
□ Tested all error scenarios
□ UI shows errors properly
□ No sensitive info exposed
□ Logging only in debug mode
□ Performance optimized
□ Error messages internationalized (if needed)
□ Unit tests passing
□ Code review completed
□ Ready for production ✅
*/

// ============ QUICK REFERENCE: What to Import ============
/*
In auth_bloc.dart:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../exceptions/auth_exceptions.dart';      ← NEW
import '../services/auth_service.dart';

In login_screen.dart:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../exceptions/auth_exceptions.dart';      ← NEW
*/

// ============ STATE OF THE ART ============
/*
Current approach:
BLoC → try-catch → FirebaseAuthException → Custom exception → Friendly message

Why it works:
✅ Separation of concerns (BLoC handles logic)
✅ Reusable exceptions (can use in other BLoCs)
✅ Type-safe (no raw strings for error codes)
✅ Easy to test (mock exceptions)
✅ Scales well (add new exceptions as needed)
✅ Maintainable (centralized error handling)

Future enhancements:
→ Add error analytics
→ Add error recovery strategies
→ Add user feedback collection
→ Add automatic error reporting
→ Add A/B testing for error messages
*/

// ============ SUCCESS CRITERIA ============
/*
Your exception handling is working when:

✅ User tries empty email → sees validation error
✅ User tries invalid email → sees format error
✅ User tries empty password → sees validation error
✅ User tries non-existent account → sees helpful message + register link
✅ User tries wrong password → sees password error
✅ User goes offline → sees network message + retry button
✅ User tries weak password (register) → sees requirement message
✅ User tries duplicate email (register) → sees in-use message

And all this:
✅ Without app crashing
✅ Without exposing raw Firebase errors
✅ With clear, actionable messages
✅ With proper loading indicators
✅ With retry capability for network errors
*/
