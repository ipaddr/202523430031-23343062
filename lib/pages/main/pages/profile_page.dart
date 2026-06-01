import 'package:betomic/service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = authService.value.currentUser!.email ?? "user@gmail.com";
  String foto = "assets/images/pp.jpg"; // bisa diganti NetworkImage nanti
  String nama = authService.value.currentUser!.displayName ?? 'User';
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kataSandiController = TextEditingController();
  final TextEditingController _kataSandiBaruController =
      TextEditingController();
  final TextEditingController _ulangKataSandiBaruController =
      TextEditingController();

  bool kataSandiBaruError = false;
  bool kataSandiError = false;
  bool kataSandiErrorCredential = false;
  bool ulangKataSandiBaruError = false;
  String ulangKataSandiBaruErrorPesan = "";
  String kataSandiBaruErrorPesan = '';
  String kataSandiErrorPesan = '';
  String kataSandiErrorPesanCredential = '';
  @override
  void dispose() {
    _namaController.dispose();
    _kataSandiController.dispose();
    _kataSandiBaruController.dispose();
    _ulangKataSandiBaruController.dispose();
    super.dispose();
  }

  void updateUsername() async {
    try {
      await authService.value.updateUsername(username: _namaController.text);
    } catch (e) {}
  }

  void updatePassowrd() async {
    setState(() {
      kataSandiErrorCredential = false;
      kataSandiErrorPesanCredential = "";
    });
    try {
      await authService.value.resetPasswordFromCurrentPassword(
        currentPassword: _kataSandiController.text,
        newPassword: _kataSandiBaruController.text,
        email: email,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      kataSandiErrorCredential = true;
      if (e.code == 'invalid-credential') {
        setState(() {
          kataSandiErrorPesanCredential = "Kata Sandi Salah";
        });
      } else if (e.code == 'too-many-requests') {
        kataSandiErrorPesanCredential =
            "Terlalu banyak percobaan login. Coba lagi nanti.";
      }
      print(kataSandiErrorPesan);
    }
  }

  void logout() async {
    try {
      await authService.value.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/auth_layout',
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  void _editNamaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Nama",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    hintText: "Masukkan Nama Baru",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE53950),
                      ),
                      onPressed: () {
                        setState(() {
                          nama = _namaController.text;
                        });
                        updateUsername();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editKataSandi() {
    _kataSandiController.clear();
    _kataSandiBaruController.clear();
    _ulangKataSandiBaruController.clear();
    kataSandiBaruError = false;
    kataSandiError = false;
    kataSandiErrorCredential = false;
    ulangKataSandiBaruError = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Ubah Kata Sandi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _kataSandiController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: "Kata Sandi Saat Ini",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    Text(
                      kataSandiError ? kataSandiErrorPesan : '',
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextField(
                      controller: _kataSandiBaruController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: "Kata Sandi Baru",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    Text(
                      kataSandiBaruError ? kataSandiBaruErrorPesan : '',
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextField(
                      controller: _ulangKataSandiBaruController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: "Ulangi Kata Sandi Baru",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    Text(
                      ulangKataSandiBaruError
                          ? ulangKataSandiBaruErrorPesan
                          : '',
                      style: const TextStyle(color: Colors.red),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53950),
                          ),
                          onPressed: () {
                            // gunakan setStateDialog di sini!
                            if (_kataSandiController.text.isEmpty) {
                              setStateDialog(() {
                                kataSandiError = true;
                                kataSandiErrorPesan = "Masukkan kata sandi";
                              });
                              return;
                            } else if (kataSandiErrorCredential) {
                              setStateDialog(() {
                                kataSandiError = true;
                                kataSandiErrorPesan =
                                    kataSandiErrorPesanCredential;
                              });
                              return;
                            } else {
                              setStateDialog(() {
                                kataSandiError = false;
                                kataSandiErrorPesan = "";
                              });
                            }

                            if (_kataSandiBaruController.text.length < 8) {
                              setStateDialog(() {
                                kataSandiBaruError = true;
                                kataSandiBaruErrorPesan =
                                    "Kata sandi minimal 8 karakter";
                              });
                              return;
                            } else {
                              setStateDialog(() {
                                kataSandiBaruError = false;
                                kataSandiBaruErrorPesan = "";
                              });
                            }

                            if (_kataSandiBaruController.text !=
                                _ulangKataSandiBaruController.text) {
                              setStateDialog(() {
                                ulangKataSandiBaruError = true;
                                ulangKataSandiBaruErrorPesan =
                                    "Kata sandi tidak sama";
                              });
                              return;
                            } else {
                              setStateDialog(() {
                                ulangKataSandiBaruError = false;
                                ulangKataSandiBaruErrorPesan = "";
                              });
                            }

                            updatePassowrd();
                          },
                          child: const Text(
                            "Simpan",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Konfirmasi"),
          content: const Text("Apakah kamu yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53950),
              ),
              onPressed: () {
                logout();
              },
              child: const Text(
                "Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,

          child: Column(
            children: [
              /// HEADER
              Container(
                width: double.infinity,
                height: 200,
                color: const Color(0xFF138D9C),
              ),

              /// PROFILE OVERLAY
              Transform.translate(
                offset: const Offset(0, -60),
                child: Column(
                  children: [
                    /// FOTO
                    GestureDetector(
                      onTap: () {
                        // TODO: ubah foto (image picker)
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 6),
                          image: DecorationImage(
                            image: AssetImage(foto),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withAlpha(100),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// NAMA + EDIT
                    GestureDetector(
                      onTap: _editNamaDialog,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit, size: 18),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              /// EMAIL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Email"),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1, height: 20),
                  ],
                ),
              ),

              const Spacer(),

              /// BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 100,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        iconColor: Colors.white,
                        backgroundColor: const Color(0xFFE53950),
                        minimumSize: const Size(140, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Keluar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        iconColor: Colors.white,
                        backgroundColor: const Color(0xFF138D9C),
                        minimumSize: const Size(170, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _editKataSandi();
                      },
                      icon: const FaIcon(FontAwesomeIcons.lock),
                      label: const Text(
                        "Ubah Kata Sandi",
                        style: TextStyle(color: Colors.white),
                      ),
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
