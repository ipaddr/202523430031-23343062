import 'package:betomic/models/group_task.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEditGroupTaskDialog extends StatefulWidget {
  final GroupTask? task;
  final Function(
    String namaAnggota,
    String namaTugas,
    String deskripsi,
    DateTime waktuPengerjaan,
  )
  onSave;

  const AddEditGroupTaskDialog({Key? key, this.task, required this.onSave})
    : super(key: key);

  @override
  State<AddEditGroupTaskDialog> createState() => _AddEditGroupTaskDialogState();
}

class _AddEditGroupTaskDialogState extends State<AddEditGroupTaskDialog> {
  late TextEditingController namaAnggotaController;
  late TextEditingController namaTugasController;
  late TextEditingController deskripsiController;
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    namaAnggotaController = TextEditingController(
      text: widget.task?.namaAnggota ?? '',
    );
    namaTugasController = TextEditingController(
      text: widget.task?.namaTugas ?? '',
    );
    deskripsiController = TextEditingController(
      text: widget.task?.deskripsi ?? '',
    );
    selectedDateTime = widget.task?.waktuPengerjaan ?? DateTime.now();
  }

  @override
  void dispose() {
    namaAnggotaController.dispose();
    namaTugasController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.task == null
                    ? 'Tambah Tugas Kelompok'
                    : 'Edit Tugas Kelompok',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Nama Anggota
              TextField(
                controller: namaAnggotaController,
                decoration: InputDecoration(
                  labelText: 'Nama Anggota',
                  hintText: 'Masukkan nama anggota',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              // Nama Tugas
              TextField(
                controller: namaTugasController,
                decoration: InputDecoration(
                  labelText: 'Nama Tugas',
                  hintText: 'Masukkan nama tugas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.assignment),
                ),
              ),
              const SizedBox(height: 16),
              // Deskripsi
              TextField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Tugas',
                  hintText: 'Masukkan deskripsi tugas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              // Waktu Pengerjaan
              GestureDetector(
                onTap: () => _selectDateTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Pengerjaan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'dd MMM yyyy, HH:mm',
                              ).format(selectedDateTime),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_calendar, color: primaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (namaAnggotaController.text.isEmpty ||
                          namaTugasController.text.isEmpty ||
                          deskripsiController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lengkapi semua field')),
                        );
                        return;
                      }
                      widget.onSave(
                        namaAnggotaController.text,
                        namaTugasController.text,
                        deskripsiController.text,
                        selectedDateTime,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
