import 'package:betomic/service/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  String errorMessageEmail = '';
  String errorMessagePassword = '';

  bool emailError = false;
  bool namaError = false;
  bool passwordError = false;
  bool regErr = false;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void register() async {
    try {
      final credential = await authService.value.createAccount(
        email: emailController.text,
        password: passwordController.text,
      );
      await authService.value.updateUsername(username: nameController.text);

      // Simpan profil user ke Firestore agar bisa dicari via email
      // oleh fitur tambah anggota kelompok
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'uid': credential.user!.uid,
            'nama': nameController.text.trim(),
            'email': emailController.text.trim().toLowerCase(),
            'displayName': nameController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.pushNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
       if (!namaError && !emailError && !passwordError) {
        setState(() {
          regErr = true;
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = "Email sudah digunakan";
              break;
            default:
              errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
          }
        });
      }
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
              // fit: BoxFit.COVE,  // agar memenuhi layar
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
                  mainAxisAlignment:
                      MainAxisAlignment.center, // vertical center
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Daftar",
                        style: TextStyle(
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
                            SizedBox(height: 10),
                            const SizedBox(height: 16),

                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: namaError
                                        ? Colors.redAccent
                                        : const Color.fromARGB(29, 16, 23, 32),
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    spreadRadius: -1.0,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: nameController,
                                style: TextStyle(
                                  color: namaError
                                      ? Colors.redAccent
                                      : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person_outlined,
                                    color: namaError
                                        ? Colors.redAccent
                                        : Colors.black,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  labelText: "Nama",
                                  labelStyle: TextStyle(
                                    color: const Color.fromARGB(59, 16, 23, 32),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    setState(() => namaError = true);
                                    return null;
                                  }
                                  setState(() => namaError = false);
                                  return null;
                                },
                              ),
                            ),
                            Text(
                              namaError ? "Masukkan Nama!" : '',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: emailError
                                        ? Colors.redAccent
                                        : const Color.fromARGB(29, 16, 23, 32),
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    spreadRadius: -1.0,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: emailController,
                                style: TextStyle(
                                  color: emailError
                                      ? Colors.redAccent
                                      : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: emailError
                                        ? Colors.redAccent
                                        : Colors.black,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  labelText: "Email",
                                  labelStyle: TextStyle(
                                    color: const Color.fromARGB(59, 16, 23, 32),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12),
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

                                  // REGEX pengecekan format email
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
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: passwordError
                                        ? Colors.redAccent
                                        : const Color.fromARGB(29, 16, 23, 32),
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    spreadRadius: -1.0,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                style: TextStyle(
                                  color: passwordError
                                      ? Colors.redAccent
                                      : Colors.black,
                                ),
                                obscureText: true,
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: passwordError
                                        ? Colors.redAccent
                                        : Colors.black,
                                  ),
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                    color: const Color.fromARGB(59, 16, 23, 32),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12),
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
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            Text(
                              regErr ? errorMessage : '',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 3,
                                backgroundColor: primaryColor,
                                foregroundColor: Color(0xFFFFFFFF),
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                _formKey.currentState!.validate();
                                  setState(() {
                                  regErr = false;
                                  errorMessage = '';
                                });
                                if (namaError || emailError || passwordError) {
                                  return;
                                }
                                register();
                              },
                              child: const Text("Daftar"),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.only(top: 70),
                        child: Column(
                          children: [
                            Text(
                              "Sudah punya akun?",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),

                              child: const Text(
                                "Masuk",
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
        ],
      ),
    );
  }
}
