import 'package:flutter/material.dart';
import 'package:app1/services/auth_service.dart';
import 'package:app1/widgets/custom_text_field.dart';
import 'package:app1/config/error_handler.dart';
import 'package:app1/config/exceptions.dart';
import 'package:app1/widgets/error_widgets.dart';
import 'registration_success_screen.dart';

/// Registration Screen - Sign Up Page
class RegistrationScreen extends StatefulWidget {
  final Function(String)? onSignUpSuccess; // Pass email to callback
  final VoidCallback? onLoginTap;

  const RegistrationScreen({super.key, this.onSignUpSuccess, this.onLoginTap});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers untuk form fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  bool _agreeToTerms = false;
  String? _errorMessage;
  bool _showError = false;
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 5;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validator untuk confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Validator untuk nama
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  /// Handle Sign Up
  Future<void> _handleSignUp() async {
    // Check if already locked out
    if (_failedAttempts >= _maxFailedAttempts) {
      _showErrorMessage(
        'Terlalu banyak percobaan pendaftaran gagal. Coba lagi dalam beberapa menit.',
        showLocked: true,
      );
      return;
    }

    // Clear previous error
    _clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showErrorMessage('Anda harus setuju dengan syarat dan ketentuan');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // Reset failed attempts on success
        _failedAttempts = 0;

        // Store email before clearing
        final String userEmail = _emailController.text.trim();
        final String userName = _nameController.text.trim();

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() => _agreeToTerms = false);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registrasi berhasil! Selamat datang $userName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Navigate to success screen then verification
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationSuccessScreen(
                email: userEmail,
                name: userName,
                onContinue: () {
                  widget.onSignUpSuccess?.call(userEmail);
                },
              ),
            ),
          );
        }
      } else {
        // Handle auth error
        _failedAttempts++;
        final message =
            result.message ?? 'Registrasi gagal. Silakan coba lagi.';
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
      debugPrint('Registration error: $e');
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              if (_failedAttempts > 0 && _failedAttempts < _maxFailedAttempts)
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

              // Header
              const SizedBox(height: 20),
              const Text(
                'Daftar Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buat akun baru untuk memulai',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nama Field
                    CustomTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap Anda',
                      controller: _nameController,
                      validator: _validateName,
                      keyboardType: TextInputType.name,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Masukkan email Anda',
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),

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

                    // Confirm Password Field
                    CustomTextField(
                      label: 'Konfirmasi Password',
                      hint: 'Masukkan ulang password',
                      controller: _confirmPasswordController,
                      validator: _validateConfirmPassword,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    const SizedBox(height: 20),

                    // Terms and Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value ?? false);
                          },
                          activeColor: Colors.deepPurple,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _agreeToTerms = !_agreeToTerms);
                            },
                            child: Text(
                              'Saya setuju dengan syarat dan ketentuan',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            (_isLoading ||
                                _failedAttempts >= _maxFailedAttempts)
                            ? null
                            : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          disabledBackgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _failedAttempts >= _maxFailedAttempts
                                    ? 'Akun Terkunci'
                                    : 'Daftar',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onLoginTap,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
