import 'package:flutter/material.dart';
import 'package:betomic/service/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:betomic/service/database.dart';
import 'package:betomic/utils/date_format.dart';

class AddHabitDialog extends StatefulWidget {
  final Color mainColor;
  final String selectedHabbit;
  const AddHabitDialog({
    super.key,
    required this.mainColor,
    required this.selectedHabbit,
  });

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final TextEditingController satuanController = TextEditingController();

  String habbitErrorPesan = '';
  bool habbitError = false;
  void tambahHabit() async {
    try {
      await Database().tambahHabit(
        tanggal: formatTanggal(DateTime.now()),
        tipe: widget.selectedHabbit,
        nama: namaController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
        target: int.parse(targetController.text.trim()),
        satuan: satuanController.text,
        uid: authService.value.currentUser!.uid,
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Tambah Kebiasaan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Nama Kebiasaan
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nama Kebiasaan",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 6),
              _inputField("Contoh: Membaca Buku", namaController),

              const SizedBox(height: 16),

              // Deskripsi
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Deskripsi",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 6),
              _inputField("Deskripsi Singkat (Opsional)", deskripsiController),

              const SizedBox(height: 16),

              // Target & Satuan
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Target",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        _inputField("30", targetController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Satuan",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        _inputField("Halaman", satuanController),
                      ],
                    ),
                  ),
                ],
              ),

              Text(
                habbitError ? habbitErrorPesan : "",
                style: TextStyle(color: Colors.red),
              ),

              // Submit Button
              Align(
                alignment: AlignmentGeometry.center,
                child: ElevatedButton(
                  onPressed: () {
                    if (namaController.text.isEmpty) {
                      setState(() {
                        habbitError = true;
                        habbitErrorPesan = "Masukkan Kebiasaan";
                      });
                      return;
                    }
                    if (targetController.text.isEmpty) {
                      setState(() {
                        habbitError = true;
                        habbitErrorPesan = "Masukkan Target";
                      });
                      return;
                    }
                    if (int.tryParse(targetController.text.trim()) == null) {
                      setState(() {
                        habbitError = true;
                        habbitErrorPesan = "Target harus angka!";
                      });
                      return;
                    }
                    if (satuanController.text.isEmpty) {
                      setState(() {
                        habbitError = true;
                        habbitErrorPesan = "Masukkan Satuan";
                      });

                      return;
                    }
                    setState(() {
                      habbitError = false;
                      habbitErrorPesan = "";
                    });
                    tambahHabit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.mainColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tambah",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        isDense: true,
        fillColor: const Color(0xffEDEDED),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
