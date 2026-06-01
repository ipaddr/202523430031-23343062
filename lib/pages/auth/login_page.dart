import 'package:betomic/service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String errorMessage = '';
  String errorMessageEmail = '';
  String errorMessagePassword = '';

  bool emailError = false;
  bool logInError = false;
  bool passwordError = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() => isLoading = true);
    try {
      await authService.value.signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!emailError && !passwordError) {
        setState(() {
          logInError = true;
          switch (e.code) {
            case 'invalid-credential':
              errorMessage =
                  "Akun tidak ditemukan, silakan cek email dan password";
              break;
            case 'too-many-requests':
              errorMessage = "Terlalu banyak percobaan login. Coba lagi nanti.";
              break;
            default:
              errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
          }
        });
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/authBg.svg',
              alignment: Alignment.topCenter,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Masuk",
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Image.asset('assets/images/logo.png', width: 150),
                            const SizedBox(height: 16),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: emailError
                                        ? Colors.red.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: emailController,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: emailError
                                        ? Colors.redAccent
                                        : primaryColor,
                                    size: 20,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  labelText: "Email",
                                  labelStyle: TextStyle(
                                    color: emailError
                                        ? Colors.redAccent
                                        : Colors.grey.shade600,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: emailError
                                          ? Colors.redAccent
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: emailError
                                          ? Colors.redAccent
                                          : primaryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    setState(() {
                                      emailError = true;
                                      errorMessageEmail = 'Masukkan Email!';
                                    });
                                    return null;
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    setState(() {
                                      emailError = true;
                                      errorMessageEmail =
                                          'Format email tidak valid!';
                                    });
                                    return null;
                                  }
                                  setState(() {
                                    emailError = false;
                                    errorMessageEmail = '';
                                  });
                                  return null;
                                },
                              ),
                            ),
                            Text(
                              emailError ? errorMessageEmail : '',
                              style: const TextStyle(color: Colors.redAccent),
                            ),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: passwordError
                                        ? Colors.red.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: passwordError
                                        ? Colors.redAccent
                                        : primaryColor,
                                    size: 20,
                                  ),
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                    color: passwordError
                                        ? Colors.redAccent
                                        : Colors.grey.shade600,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordError
                                          ? Colors.redAccent
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordError
                                          ? Colors.redAccent
                                          : primaryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    setState(() {
                                      passwordError = true;
                                      errorMessagePassword =
                                          'Password wajib diisi';
                                    });
                                    return null;
                                  }
                                  if (value.length < 8) {
                                    setState(() {
                                      passwordError = true;
                                      errorMessagePassword =
                                          'Password minimal 8 karakter';
                                    });
                                    return null;
                                  }
                                  if (!RegExp(
                                    r'^(?=.*[A-Za-z])(?=.*\d)',
                                  ).hasMatch(value)) {
                                    setState(() {
                                      passwordError = true;
                                      errorMessagePassword =
                                          'Password harus mengandung huruf dan angka';
                                    });
                                    return null;
                                  }
                                  setState(() {
                                    passwordError = false;
                                    errorMessagePassword = '';
                                  });
                                  return null;
                                },
                              ),
                            ),
                            Text(
                              passwordError ? errorMessagePassword : '',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            Text(
                              logInError ? errorMessage : '',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 4,
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Raleway',
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _formKey.currentState!.validate();
                                      setState(() {
                                        logInError = false;
                                        errorMessage = '';
                                      });
                                      if (emailError || passwordError) return;
                                      signIn();
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text("Masuk"),
                            ),

                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/forgot'),
                                child: const Text(
                                  "Lupa Sandi?",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.only(top: 70),
                        child: Column(
                          children: [
                            const Text(
                              "Belum punya akun?",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                "Daftar Akun",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
