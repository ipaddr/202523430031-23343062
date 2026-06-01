import 'package:flutter/material.dart';
import '../../theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

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
                alignment: Alignment.topCenter,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 30, right: 30 ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // vertical center
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Kata Sandi Baru",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                margin: const EdgeInsets.only(bottom:70 ),
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
                      child: Column(
                        children: [
                         Text(
                          "Masukkan Kata Sandi Baru",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                         ),
                          SizedBox(height: 10),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(29, 16, 23, 32),
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  spreadRadius: -1.0,
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outlined),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                labelText: "Kata Sandi Baru",
                                labelStyle: TextStyle(
                                  color: const Color.fromARGB(59, 16, 23, 32),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 15),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(29, 16, 23, 32),
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  spreadRadius: -1.0,
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outlined),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                labelText: "Ulangi Kata Sandi Baru",
                                labelStyle: TextStyle(
                                  color: const Color.fromARGB(59, 16, 23, 32),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
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
                            onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                            child: const Text("Kirim"),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.only(top: 150),
                        child: Column(
                          children: [
                            Text(
                              "Sudah punya akun?",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                "Daftar",
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
