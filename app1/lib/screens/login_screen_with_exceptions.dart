/// Login Screen dengan Exception Handling
///
/// Contoh screen yang menampilkan error handling dengan baik

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../exceptions/auth_exceptions.dart';

class LoginScreenWithExceptionHandling extends StatefulWidget {
  const LoginScreenWithExceptionHandling({super.key});

  @override
  State<LoginScreenWithExceptionHandling> createState() =>
      _LoginScreenWithExceptionHandlingState();
}

class _LoginScreenWithExceptionHandlingState
    extends State<LoginScreenWithExceptionHandling> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==================== VALIDATION ====================

  void _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final emailError = AuthExceptionHandler.validateEmail(
      _emailController.text,
    );
    if (emailError != null) {
      setState(() => _emailError = emailError.message);
    }

    final passwordError = AuthExceptionHandler.validatePassword(
      _passwordController.text,
    );
    if (passwordError != null) {
      setState(() => _passwordError = passwordError.message);
    }
  }

  // ==================== LOGIN ====================

  void _handleLogin() {
    _validateForm();

    if (_emailError == null && _passwordError == null) {
      // No validation errors, proceed with login
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  // ==================== ERROR DIALOG ====================

  void _showErrorDialog(String message, String? errorCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (errorCode == 'user-not-found')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to register screen
              },
              child: const Text('Daftar'),
            ),
        ],
      ),
    );
  }

  // ==================== ERROR SNACKBAR ====================

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // ==================== RETRY BUTTON ====================

  void _showRetryOption(AuthError errorState) {
    if (errorState.isRetryable) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Terjadi Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorState.message),
              const SizedBox(height: 8),
              if (errorState.isNetworkError)
                const Text(
                  'Periksa koneksi internet Anda dan coba lagi',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleLogin();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
  }

  // ==================== BUILD ====================

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
          if (state is AuthSuccess) {
            // Navigate to home
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login berhasil! 🎉'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            // Show error
            _showErrorSnackBar(state.message);

            // If error is retryable, offer retry
            if (state.isRetryable) {
              _showRetryOption(state);
            }
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
                    'Selamat datang kembali',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login untuk melanjutkan',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // ==================== EMAIL INPUT ====================
                  TextField(
                    controller: _emailController,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_emailError != null) {
                        _validateForm();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText: _emailError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==================== PASSWORD INPUT ====================
                  TextField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: !_showPassword,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        _validateForm();
                      }
                    },
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
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                      errorText: _passwordError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==================== FORGOT PASSWORD ====================
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              // Navigate to forgot password screen
                            },
                      child: Text(
                        'Lupa password?',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                          decoration: isLoading
                              ? TextDecoration.none
                              : TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ==================== LOGIN BUTTON ====================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
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

                  // ==================== REGISTER LINK ====================
                  Center(
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              // Navigate to register
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
                                decoration: isLoading
                                    ? TextDecoration.none
                                    : TextDecoration.underline,
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
