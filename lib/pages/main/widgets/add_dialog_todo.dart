import 'package:betomic/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:betomic/service/database.dart';

class AddToDoDialog extends StatefulWidget {
  const AddToDoDialog({super.key});

  @override
  State<AddToDoDialog> createState() => _AddToDoDialogState();
}

class _AddToDoDialogState extends State<AddToDoDialog> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  String uid = authService.value.currentUser!.uid;

  String _prioritas = "Tinggi";
  String judulErrorPesan = "";
  bool judulError = false;
  DateTime _selectedDate = DateTime.now();

  void tambahToDo() async {
    await Database().tambahToDo(
      uid: uid,
      judul: _judulController.text,
      deskripsi: _deskripsiController.text,
      prioritas: _prioritas,
      tanggal: _selectedDate,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tanggalController.text =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  "Tambah To Do",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Judul"),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: 
              TextField(
                controller: _judulController,
                decoration: InputDecoration(
                 filled: true,
    fillColor: Colors.grey.shade200,
                  hintText: "Contoh: Kerjakan Tugas",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              ),
              Text(judulError ? judulErrorPesan : "", style: TextStyle(color: Colors.red),),
              const Text("Deskripsi"),
              const SizedBox(height: 6),
                ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: 
              TextField(

                controller: _deskripsiController,
                decoration: InputDecoration(
                                filled: true,
    fillColor: Colors.grey.shade200,
                  hintText: "Deskripsi Singkat (Opsional)",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                maxLines: 2,
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Prioritas"),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color:  Colors.grey.shade200,                            border: BoxBorder.all(width: 0),
                            borderRadius: BorderRadius.circular(8),
                            
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _prioritas,
                              items: ["Tinggi", "Sedang", "Rendah"]
                                  .map(
                                    (String value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _prioritas = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tanggal"),
                        const SizedBox(height: 6),
                          ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: 
                        TextField(
                          controller: _tanggalController,
                          readOnly: true,
                          onTap: () => _pilihTanggal(context),
                          decoration: InputDecoration(
                                          filled: true,
    fillColor: Colors.grey.shade200,
                            suffixIcon: const Icon(Icons.calendar_today),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF138D9C),
                    minimumSize: const Size(120, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_judulController.text.isEmpty) {
                      setState(() {
                      judulError = true;
                      judulErrorPesan = "Masukkan Judul!";
                      });
                      return;
                    }else{
                    setState(() {
                      judulError = false;
                      judulErrorPesan = "";
                      });
                    }
                    tambahToDo();
                  },
                  child: const Text(
                    "Tambah",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
