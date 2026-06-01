import 'package:flutter/material.dart';
import 'package:app1/services/auth_service.dart';
import 'package:app1/widgets/custom_text_field.dart';
import 'package:app1/config/error_handler.dart';
import 'package:app1/config/exceptions.dart';
import 'package:app1/widgets/error_widgets.dart';

/// Login Screen - Sign In Page
class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onSignUpTap;

  const LoginScreen({super.key, this.onLoginSuccess, this.onSignUpTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  bool _showError = false;
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 5;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validator untuk email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validator untuk password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  /// Handle Login
  Future<void> _handleLogin() async {
    // Check if already locked out
    if (_failedAttempts >= _maxFailedAttempts) {
      _showErrorMessage(
        'Terlalu banyak percobaan login gagal. Coba lagi dalam beberapa menit.',
        showLocked: true,
      );
      return;
    }

    // Clear previous error
    _clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // Reset failed attempts on success
        _failedAttempts = 0;

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang ${result.user?.email}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        _emailController.clear();
        _passwordController.clear();

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          widget.onLoginSuccess?.call();
        }
      } else {
        // Handle auth error
        _failedAttempts++;
        final message = result.message ?? 'Login gagal. Silakan coba lagi.';
        _showErrorMessage(message);
      }
    } on AppException catch (e) {
      // Handle custom exceptions
      _failedAttempts++;
      _showErrorMessage(
        ErrorHandler.getErrorMessageWithSuggestion(e),
        showLocked: _failedAttempts >= _maxFailedAttempts,
      );
    } catch (e) {
      // Handle unexpected errors
      _failedAttempts++;
      final appException = ErrorHandler.handleException(e);
      _showErrorMessage(
        ErrorHandler.getErrorMessageWithSuggestion(appException),
        showLocked: _failedAttempts >= _maxFailedAttempts,
      );
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Show error message
  void _showErrorMessage(String message, {bool showLocked = false}) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _showError = true;
      });

      // Auto dismiss error after 6 seconds
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _showError) {
          _clearError();
        }
      });
    }
  }

  /// Clear error message
  void _clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _showError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Error Banner (if error exists)
                  if (_showError && _errorMessage != null)
                    ErrorBanner(
                      message: _errorMessage!,
                      onClose: _clearError,
                      isDismissible: true,
                      icon: Icons.warning_outlined,
                    ),
                  if (_showError && _errorMessage != null)
                    const SizedBox(height: 16),

                  // Locked Out Warning (if max attempts reached)
                  if (_failedAttempts >= _maxFailedAttempts)
                    WarningBanner(
                      message:
                          'Terlalu banyak percobaan gagal. Akun sementara terkunci.',
                      isDismissible: false,
                    ),
                  if (_failedAttempts >= _maxFailedAttempts)
                    const SizedBox(height: 16),

                  // Failed attempts counter
                  if (_failedAttempts > 0 &&
                      _failedAttempts < _maxFailedAttempts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Percobaan gagal: $_failedAttempts/$_maxFailedAttempts',
                        style: TextStyle(
                          color: Colors.yellow[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Logo/App Icon
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.account_circle,
                      size: 60,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Header Text
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk ke akun Anda untuk melanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Main Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Field
                          CustomTextField(
                            label: 'Email',
                            hint: 'Masukkan email Anda',
                            controller: _emailController,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          const SizedBox(height: 24),

                          // Password Field
                          CustomTextField(
                            label: 'Password',
                            hint: 'Masukkan password',
                            controller: _passwordController,
                            validator: _validatePassword,
                            isPassword: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          const SizedBox(height: 16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(
                                        () => _rememberMe = value ?? false,
                                      );
                                    },
                                    activeColor: Colors.deepPurple,
                                  ),
                                  Text(
                                    'Ingat saya',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fitur akan segera tersedia',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed:
                                  (_isLoading ||
                                      _failedAttempts >= _maxFailedAttempts)
                                  ? null
                                  : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                disabledBackgroundColor: Colors.grey[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      _failedAttempts >= _maxFailedAttempts
                                          ? 'Akun Terkunci'
                                          : 'Login',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'atau',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Social Login Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Google login akan segera tersedia',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.g_mobiledata),
                                  label: const Text('Google'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Facebook login akan segera tersedia',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.facebook),
                                  label: const Text('Facebook'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onSignUpTap,
                        child: Text(
                          'Daftar di sini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
