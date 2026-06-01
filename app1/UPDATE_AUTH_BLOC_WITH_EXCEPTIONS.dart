/// How to Update Current Auth BLoC with Exception Handling
///
/// Panduan untuk upgrade auth_bloc.dart yang sudah ada

// ============ CURRENT STATE ============
/*
File: lib/blocs/auth_bloc.dart

Current _onLoginRequested implementation:

Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    emit(const AuthLoading());
    
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

    if (userCredential.user != null) {
      // ... get user profile from Firestore
      emit(AuthSuccess(...));
    }
  } on FirebaseAuthException catch (e) {
    String message = 'Login gagal';
    if (e.code == 'user-not-found') {
      message = 'User tidak ditemukan';
    } else if (e.code == 'wrong-password') {
      message = 'Password salah';
    } else if (e.code == 'invalid-email') {
      message = 'Email tidak valid';
    }
    emit(AuthError(message: message, errorCode: e.code));
  } catch (e) {
    emit(AuthError(message: 'Error: $e'));
  }
}

Issues dengan current implementation:
❌ Tidak validate input sebelum Firebase
❌ Error messages tidak lengkap
❌ Tidak handle semua error cases
❌ Messages tidak user-friendly
*/

// ============ IMPROVED VERSION ============
/*
File: lib/blocs/auth_bloc.dart

STEP 1: Add import untuk exceptions
import '../exceptions/auth_exceptions.dart';

STEP 2: Update _onLoginRequested method

Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    emit(const AuthLoading());

    // VALIDATE INPUT FIRST
    final validationErrors = AuthExceptionHandler.validateLoginForm(
      event.email,
      event.password,
    );

    if (validationErrors.isNotEmpty) {
      final error = validationErrors.first;
      emit(AuthError(message: error.message, errorCode: error.errorCode));
      return;  // Stop here, don't call Firebase
    }

    // SIGN IN WITH FIREBASE
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: event.email.trim(),
          password: event.password,
        );

    if (userCredential.user != null) {
      final user = userCredential.user!;

      // GET USER PROFILE FROM FIRESTORE
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
        emit(
          AuthSuccess(
            userId: user.uid,
            email: user.email ?? 'Unknown',
            name: user.displayName,
            photoUrl: user.photoURL,
          ),
        );
      }
    }

    // HANDLE FIREBASE EXCEPTIONS
  } on FirebaseAuthException catch (e) {
    // Use custom exception handler
    final exception = AuthExceptionHandler.handleFirebaseException(e);
    emit(AuthError(message: exception.message, errorCode: exception.errorCode));

    // HANDLE CUSTOM EXCEPTIONS
  } on AuthException catch (e) {
    emit(AuthError(message: e.message, errorCode: e.errorCode));

    // HANDLE UNKNOWN EXCEPTIONS
  } catch (e) {
    final exception = AuthExceptionHandler.handleFirebaseException(e);
    emit(AuthError(message: exception.message, errorCode: exception.errorCode));
  }
}
*/

// ============ STEP-BY-STEP UPDATE GUIDE ============
/*
1. Create exception classes
   File: lib/exceptions/auth_exceptions.dart
   - Copy dari auth_exceptions.dart file yang sudah dibuat

2. Import di auth_bloc.dart
   Line 1-10, add:
   import '../exceptions/auth_exceptions.dart';

3. Update _onLoginRequested method
   Find: Future<void> _onLoginRequested(...)
   Replace: Entire method dengan improved version di atas

4. Do the same untuk methods lain:
   - _onRegisterRequested
   - _onResetPasswordRequested
   - Semua method yang terhubung dengan Firebase

5. Test dengan berbagai scenarios:
   - Empty email
   - Invalid email format
   - Empty password
   - Wrong password
   - User not found
   - Network error (offline mode)
   - Weak password (saat register)
   - Duplicate email (saat register)
*/

// ============ MINIMAL UPDATE (Quick Fix) ============
/*
Jika ingin minimal changes saja:

1. Add import:
   import '../exceptions/auth_exceptions.dart';

2. Replace error mapping di _onLoginRequested:

   OLD:
   } on FirebaseAuthException catch (e) {
     String message = 'Login gagal';
     if (e.code == 'user-not-found') {
       message = 'User tidak ditemukan';
     } else if (e.code == 'wrong-password') {
       message = 'Password salah';
     } else if (e.code == 'invalid-email') {
       message = 'Email tidak valid';
     }
     emit(AuthError(message: message, errorCode: e.code));
   }

   NEW:
   } on FirebaseAuthException catch (e) {
     final exception = AuthExceptionHandler.handleFirebaseException(e);
     emit(AuthError(message: exception.message, errorCode: exception.errorCode));
   }

3. That's it! Exception handling now centralized
*/

// ============ VALIDATION HELPER METHOD ============
/*
Add this method ke AuthBloc class:

/// Validate login form before Firebase call
bool _validateLoginForm(
  String email,
  String password,
  Emitter<AuthState> emit,
) {
  final validationErrors = AuthExceptionHandler.validateLoginForm(email, password);

  if (validationErrors.isNotEmpty) {
    final error = validationErrors.first;
    emit(AuthError(message: error.message, errorCode: error.errorCode));
    return false;
  }

  return true;
}

// Usage in _onLoginRequested:
if (!_validateLoginForm(event.email, event.password, emit)) {
  return;  // Validation failed
}

// Continue with Firebase call...
*/

// ============ ALL FIREBASE METHODS UPDATED ============
/*
Apply same pattern untuk all methods:

1. _onAuthCheckRequested:
   } on FirebaseAuthException catch (e) {
     final exception = AuthExceptionHandler.handleFirebaseException(e);
     emit(AuthError(message: exception.message));
   }

2. _onLoginRequested:
   // Validate input first
   // Then try Firebase
   // Handle exceptions dengan handler

3. _onRegisterRequested:
   // Add validation untuk password strength
   // Try Firebase
   // Handle duplicate email

4. _onLogoutRequested:
   // Try Firebase signOut
   // Handle exceptions

5. _onUpdateProfileRequested:
   // Try Firebase update
   // Handle exceptions

6. _onResetPasswordRequested:
   // Validate email
   // Try Firebase
   // Handle exceptions
*/

// ============ TESTING THE UPDATED CODE ============
/*
Test scenarios untuk verify exception handling:

Test Case 1: Empty Email
Input: email = "", password = "password"
Expected: AuthError with message "Email tidak boleh kosong"
Verify: emit(AuthError) happens immediately, Firebase not called

Test Case 2: Invalid Email Format
Input: email = "invalid-format", password = "password"
Expected: AuthError with message "Format email tidak benar"
Verify: Validation catches it, Firebase not called

Test Case 3: Empty Password
Input: email = "test@test.com", password = ""
Expected: AuthError with message "Password tidak boleh kosong"
Verify: Validation catches it, Firebase not called

Test Case 4: Valid Input but User Not Found
Input: email = "notexist@test.com", password = "correctpass"
Expected: Firebase called, return error 'user-not-found'
Expected: AuthError with message "User tidak ditemukan..."
Verify: Firebase error mapped correctly

Test Case 5: Valid Input but Wrong Password
Input: email = "test@test.com", password = "wrongpass"
Expected: Firebase called, return error 'wrong-password'
Expected: AuthError with message "Password salah..."
Verify: User can retry

Test Case 6: Network Error
Scenario: Turn off wifi, try login
Expected: FirebaseAuthException with code 'network-request-failed'
Expected: AuthError with message "Network error..."
Verify: User sees network message, can retry when online

Test Case 7: Successful Login
Input: email = "test@test.com", password = "correctpass"
Expected: emit(AuthLoading), then emit(AuthSuccess(...))
Verify: State changes correctly

Run these 7 tests:
✅ All validation errors caught before Firebase
✅ All Firebase errors mapped to friendly messages
✅ Successful login works
✅ User can retry on network error
*/

// ============ BEFORE vs AFTER ============
/*
BEFORE (Old Implementation):
User Input
   ↓
Firebase Call (no validation)
   ↓
Basic error mapping (few cases)
   ↓
Generic error message
   ↓
Better than nothing but:
❌ Cannot validate locally (waste Firebase quota)
❌ Error messages incomplete
❌ User confusion on some errors

AFTER (With Exception Handling):
User Input
   ↓
Client Validation ← Catches most errors early
   ↓
Show Validation Error ← User fixes immediately
   ↓
Firebase Call (only valid inputs)
   ↓
Complete error mapping (all cases)
   ↓
Friendly, helpful error message
   ↓
Benefits:
✅ Fast local validation
✅ Complete error coverage
✅ User-friendly messages
✅ Save Firebase quota (no invalid calls)
✅ Better UX overall
*/

// ============ TIPS FOR IMPLEMENTATION ============
/*
1. Start with one method (e.g., _onLoginRequested)
   - Test thoroughly
   - Then apply to others

2. Keep old code commented out
   - Easier to compare/revert if needed

3. Test on real Firebase
   - Validation only works against actual data
   - Test both existing and non-existing users

4. Update test files
   - If test/auth_bloc_test.dart exists
   - Update expected exceptions

5. Add BlocObserver for debugging
   - See all states emitted
   - Help troubleshoot issues

6. Create error log
   - Track which errors occur most
   - Improve error messages if needed

7. Version control
   - Commit after each method updated
   - Easier to track changes
*/

// ============ COMMON PITFALLS TO AVOID ============
/*
❌ WRONG: Always call Firebase even with validation errors
// Wastes quota, slow

❌ WRONG: Only catch FirebaseAuthException
// Miss other errors like network issues

❌ WRONG: Show raw error codes to user
// User doesn't understand 'user-not-found'

❌ WRONG: Ignore validation errors
// User frustrated with cryptic Firebase errors

❌ WRONG: Retry automatically on all errors
// User not in control, might create infinite loop

✅ RIGHT: Validate first, catch all exceptions
✅ RIGHT: Map errors to user-friendly messages
✅ RIGHT: Show context-specific help
✅ RIGHT: Let user decide when to retry
✅ RIGHT: Log errors for debugging
*/

// ============ FINAL CHECKLIST ============
/*
Before deploying:

☐ auth_exceptions.dart created with all custom exceptions
☐ AuthExceptionHandler utility class complete
☐ _onLoginRequested updated with validation + exception handling
☐ _onRegisterRequested updated
☐ _onResetPasswordRequested updated
☐ _onLogoutRequested updated
☐ Tested with empty email
☐ Tested with invalid email format
☐ Tested with empty password
☐ Tested with wrong password
☐ Tested with user not found
☐ Tested with network offline
☐ Tested with weak password (register)
☐ Tested with duplicate email (register)
☐ All error messages user-friendly
☐ Exception handling logged (dev mode)
☐ UI shows loading state properly
☐ UI shows error messages clearly
☐ Unit tests updated/passing
☐ Code review completed
☐ Ready for production ✅
*/
