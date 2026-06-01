/// Exception Handling - Practical Examples & Patterns
///
/// Kumpulan contoh kode untuk berbagai error handling scenarios

// ============ EXAMPLE 1: Simple Error Display ============
/*
Menampilkan error paling simple:

BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: LoginForm(),
)

Result: Error muncul di bawah screen, user bisa tutup dengan swipe
*/

// ============ EXAMPLE 2: Error with Retry Button ============
/*
Tambah retry button untuk network errors:

BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError && state.isRetryable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          action: SnackBarAction(
            label: 'Coba Lagi',
            onPressed: _handleLogin,
          ),
        ),
      );
    }
  },
  child: LoginForm(),
)

Result: Retry button langsung di snackbar, lebih cepat
*/

// ============ EXAMPLE 3: Error Dialog with Link ============
/*
Dialog dengan link ke register untuk user-not-found:

if (state is AuthError) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Email Tidak Terdaftar'),
      content: const Text('Email ini belum terdaftar. Daftar sekarang?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to register screen
            Navigator.pushNamed(context, '/register');
          },
          child: const Text('Daftar'),
        ),
      ],
    ),
  );
}

Result: User bisa langsung navigate ke register dari error dialog
*/

// ============ EXAMPLE 4: Show Error in TextField ============
/*
Validation error muncul di bawah TextField:

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

Result: User lihat error langsung di field, tidak perlu scroll
*/

// ============ EXAMPLE 5: Multiple Validation Errors ============
/*
Show semua validation errors sekaligus:

List<String> _getValidationErrors() {
  final errors = <String>[];
  
  final emailError = AuthExceptionHandler.validateEmail(_email);
  if (emailError != null) errors.add(emailError.message);
  
  final passwordError = AuthExceptionHandler.validatePassword(_password);
  if (passwordError != null) errors.add(passwordError.message);
  
  return errors;
}

void _handleLogin() {
  final errors = _getValidationErrors();
  
  if (errors.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors
              .map((e) => Text('• $e'))
              .toList(),
        ),
      ),
    );
    return;
  }
  
  // Login
  context.read<AuthBloc>().add(LoginRequested(...));
}

Result: User lihat semua error sekaligus, bisa fix semua di sekali
*/

// ============ EXAMPLE 6: Loading State with Disabled Inputs ============
/*
Disable input dan button saat loading:

BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    bool isLoading = state is AuthLoading;

    return Column(
      children: [
        TextField(
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: Icon(
              Icons.email,
              color: isLoading ? Colors.grey : Colors.deepPurple,
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : _handleLogin,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Login'),
        ),
      ],
    );
  },
)

Result: User tidak bisa input atau tap button saat loading
*/

// ============ EXAMPLE 7: Error with Inline Message ============
/*
Show error message inline di dalam widget:

BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return Column(
      children: [
        // Form inputs...
        SizedBox(height: 16),
        if (state is AuthError)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _handleLogin,
          child: const Text('Login'),
        ),
      ],
    );
  },
)

Result: Error muncul di tengah form, user lihat dengan jelas
*/

// ============ EXAMPLE 8: Toast Notification ============
/*
Simple toast notification untuk error:

if (state is AuthError) {
  Future.microtask(() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.red,
      ),
    );
  });
}

Result: Toast muncul di atas UI (floating), auto hide setelah 3 detik
*/

// ============ EXAMPLE 9: Error Counter with Lock ============
/*
Lock login setelah 5 percobaan gagal:

class _LoginScreenState extends State<LoginScreen> {
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  bool get _isLocked {
    if (_lockedUntil == null) return false;
    if (DateTime.now().isBefore(_lockedUntil!)) return true;
    
    setState(() {
      _lockedUntil = null;
      _failedAttempts = 0;
    });
    return false;
  }

  void _handleLoginFailure() {
    setState(() {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _lockedUntil = DateTime.now().add(Duration(minutes: 5));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _handleLoginFailure();
          
          if (_isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Terlalu banyak percobaan. Coba lagi dalam 5 menit',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${state.message} (${_failedAttempts}/5)')),
            );
          }
        } else if (state is AuthSuccess) {
          _failedAttempts = 0;
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              enabled: !_isLocked,
              decoration: InputDecoration(
                hintText: 'Email',
                suffixIcon: _isLocked
                    ? const Icon(Icons.lock, color: Colors.red)
                    : null,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLocked ? null : _handleLogin,
              child: Text(_isLocked ? 'Terkunci' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}

Result: Account terkunci setelah 5 percobaan gagal untuk keamanan
*/

// ============ EXAMPLE 10: Error with Suggestion ============
/*
Show error dengan helpful suggestion:

Map<String, String> _errorSuggestions = {
  'user-not-found': 'Belum punya akun? Daftar sekarang',
  'wrong-password': 'Lupa password? Reset di sini',
  'network-request-failed': 'Periksa koneksi internet',
  'too-many-requests': 'Tunggu beberapa menit sebelum coba lagi',
};

if (state is AuthError) {
  final suggestion = _errorSuggestions[state.errorCode];
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.message),
          if (suggestion != null) ...[
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Tip: $suggestion',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Result: User dapat hint/suggestion untuk fix masalah
*/

// ============ EXAMPLE 11: Custom Error Widget ============
/*
Create reusable error widget:

class ErrorMessage extends StatelessWidget {
  final String message;
  final String? errorCode;
  final VoidCallback? onRetry;

  const ErrorMessage({
    required this.message,
    this.errorCode,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Usage:
if (state is AuthError) {
  ErrorMessage(
    message: state.message,
    errorCode: state.errorCode,
    onRetry: state.isRetryable ? _handleLogin : null,
  )
}

Result: Reusable component, consistent error display
*/

// ============ EXAMPLE 12: Error Logging ============
/*
Log errors untuk debugging (dev mode only):

if (state is AuthError) {
  if (kDebugMode) {
    print('🔴 Auth Error: ${state.message}');
    print('   Code: ${state.errorCode}');
    print('   Retryable: ${state.isRetryable}');
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}

atau lebih advanced:

class AuthErrorLogger {
  static void log(AuthError error) {
    if (kDebugMode) {
      print('═ AUTH ERROR ═════════════════════════════════');
      print('Message: ${error.message}');
      print('Code: ${error.errorCode}');
      print('Timestamp: ${DateTime.now()}');
      print('═══════════════════════════════════════════════');
    }
  }
}

Result: Track errors untuk debugging tanpa influence production
*/

// ============ ERROR MESSAGE HELPER ============
/*
Centralized error messages:

class ErrorMessages {
  static const Map<String, String> messages = {
    'user-not-found': 'Email tidak terdaftar',
    'wrong-password': 'Password salah',
    'weak-password': 'Password terlalu lemah',
    'email-already-in-use': 'Email sudah terdaftar',
    'invalid-email': 'Email tidak valid',
    'network-request-failed': 'Network error',
    'too-many-requests': 'Terlalu banyak percobaan',
    'user-disabled': 'Akun dinonaktifkan',
  };

  static String get(String? errorCode, {String defaultMessage = 'Terjadi error'}) {
    return messages[errorCode] ?? defaultMessage;
  }
}

// Usage:
final message = ErrorMessages.get(state.errorCode);
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(message)),
);

Result: Centralized source of truth untuk error messages
*/

// ============ BOOLEAN GETTERS FOR ERROR STATES ============
/*
extension AuthErrorExtension on AuthError {
  bool get isUserNotFound => errorCode == 'user-not-found';
  bool get isWrongPassword => errorCode == 'wrong-password';
  bool get isWeakPassword => errorCode == 'weak-password';
  bool get isEmailInUse => errorCode == 'email-already-in-use';
  bool get isInvalidEmail => errorCode == 'invalid-email';
  bool get isNetworkError => errorCode == 'network-request-failed';
  bool get isTooManyAttempts => errorCode == 'too-many-requests';
  bool get isUserDisabled => errorCode == 'user-disabled';

  bool get isRetryable => isNetworkError || isTooManyAttempts;
  bool get shouldPromptRegister => isUserNotFound || isEmailInUse;
}

// Usage:
if (state is AuthError) {
  if (state.isUserNotFound) {
    // Show register button
  } else if (state.isNetworkError) {
    // Show retry button
  } else if (state.isWeakPassword) {
    // Show password requirements
  }
}

Result: Readable condition checks, easy to maintain
*/

// ============ CHECKLIST UNTUK IMPLEMENTASI ============
/*
☐ Create auth_exceptions.dart dengan custom exception classes
☐ Create AuthExceptionHandler utility class
☐ Update AuthBloc with complete try-catch blocks
☐ Add validateLoginForm method untuk client validation
☐ Show validation errors di TextField errorText
☐ Show Firebase exceptions di SnackBar/Dialog
☐ Implement retry logic untuk network errors
☐ Show register prompt untuk user-not-found
☐ Show loading indicator saat processing
☐ Test dengan invalid email
☐ Test dengan wrong password
☐ Test dengan network disconnection
☐ Test dengan duplicate email (register)
☐ Test dengan weak password (register)
☐ Test edge cases (empty fields, etc)
*/
