import 'package:flutter/material.dart';
import 'package:app1/services/auth_service.dart';
import 'package:app1/widgets/custom_text_field.dart';

/// Registration Screen - Sign Up Page
class RegistrationScreen extends StatefulWidget {
  final VoidCallback? onSignUpSuccess;
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus setuju dengan syarat dan ketentuan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registrasi berhasil! Selamat datang ${_nameController.text}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() => _agreeToTerms = false);

        // Callback on success
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          widget.onSignUpSuccess?.call();
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                        onPressed: _isLoading ? null : _handleSignUp,
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
                            : const Text(
                                'Daftar',
                                style: TextStyle(
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
