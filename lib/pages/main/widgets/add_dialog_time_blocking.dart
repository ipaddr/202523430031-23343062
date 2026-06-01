import 'package:betomic/service/auth.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:betomic/service/database.dart';

class AddTimeBlockingDialog extends StatefulWidget {
  final bool? todo;
  final String? todoTitle;
  final String? idToDo;
  const AddTimeBlockingDialog({super.key, this.todo, this.todoTitle, this.idToDo});

  @override
  State<AddTimeBlockingDialog> createState() => _AddTimeBlockingDialogState();
}

class _AddTimeBlockingDialogState extends State<AddTimeBlockingDialog> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _mulaiController = TextEditingController();
  final TextEditingController _selesaiController = TextEditingController();
  String uid = authService.value.currentUser!.uid;
  bool judulError = false;
  String judulErrorPesan = "";
  TimeOfDay _selectedStart = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedEnd = TimeOfDay(hour: 0, minute: 0);
  bool todo = false;

  @override
  void initState() {
    super.initState();
    todo = widget.todo ?? false;
  }

  Future<void> _pilihWaktu(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _selectedStart : _selectedEnd,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStart = picked;
          _mulaiController.text = picked.format(context);
        } else {
          _selectedEnd = picked;
          _selesaiController.text = picked.format(context);
        }
      });
    }
  }

  void tambahTimeBlocking() async {
    await Database().tambahTimeBlocking(
      uid: uid,
      startTime:
          "${_selectedStart.hour.toString().padLeft(2, '0')}:${_selectedStart.minute.toString().padLeft(2, '0')}",
      endTime:
          "${_selectedEnd.hour.toString().padLeft(2, '0')}:${_selectedEnd.minute.toString().padLeft(2, '0')}",
      judul: todo ? widget.todoTitle! : _judulController.text,
      connected: todo ? true : false
    );

    if (todo) {
      await Database().updateToDoConnect(idToDo: widget.idToDo!, uid: uid, timeblocking: "${_selectedStart.hour.toString().padLeft(2, '0')}:${_selectedStart.minute.toString().padLeft(2, '0')}-${_selectedEnd.hour.toString().padLeft(2, '0')}:${_selectedEnd.minute.toString().padLeft(2, '0')}", connected: true );
    }
    Navigator.pop(context);
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
              Center(
                child: Text(
                  "Tambah Time Blocking",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              /// JUDUL
              const Text(
                "Judul",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                enabled: todo ? false : true,
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: todo ? widget.todoTitle : "Contoh: Kerjakan Tugas",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),

              Text(
                judulError ? judulErrorPesan : "",
                style: TextStyle(color: Colors.red),
              ),

              /// WAKTU MULAI - SELESAI
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mulai",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _mulaiController,
                          readOnly: true,
                          onTap: () => _pilihWaktu(context, true),
                          decoration: InputDecoration(
                            hintText: "00:00",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
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
                        const Text(
                          "Selesai",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _selesaiController,
                          readOnly: true,
                          onTap: () => _pilihWaktu(context, false),
                          decoration: InputDecoration(
                            hintText: "00:00",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    minimumSize: const Size(140, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_judulController.text.isEmpty && !todo) {
                      setState(() {
                        judulError = true;
                        judulErrorPesan = 'Masukkan Judul!';
                      });
                      return;
                    }

                    setState(() {
                      judulError = false;
                      judulErrorPesan = '';
                    });

                    tambahTimeBlocking();
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
