import 'package:betomic/models/group_task.dart';
import 'package:betomic/pages/main/widgets/add_edit_group_task_dialog.dart';
import 'package:betomic/pages/main/widgets/group_task_card.dart';
import 'package:betomic/service/auth.dart';
import 'package:betomic/service/database.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GroupTasksSerialPage extends StatefulWidget {
  const GroupTasksSerialPage({super.key});

  @override
  State<GroupTasksSerialPage> createState() => _GroupTasksSerialPageState();
}

class _GroupTasksSerialPageState extends State<GroupTasksSerialPage> {
  final Database _database = Database();
  String uid = authService.value.currentUser!.uid;
  String selectedFilter = "Semua";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter dan Add Button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Semua', 'Belum Selesai', 'Selesai']
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value ?? "Semua";
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        // Tasks List
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _database.getAllGroupTasks(uid: uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.clipboardList,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada tugas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan tugas kelompok untuk memulai',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              List<Map<String, dynamic>> tasks = snapshot.data!;

              // Sort tasks berdasarkan waktuPengerjaan (ascending)
              tasks.sort((a, b) {
                final dateA =
                    (a['waktuPengerjaan'] as dynamic)?.toDate() ??
                    DateTime.now();
                final dateB =
                    (b['waktuPengerjaan'] as dynamic)?.toDate() ??
                    DateTime.now();
                return dateA.compareTo(dateB);
              });

              // Filter tasks
              if (selectedFilter != "Semua") {
                if (selectedFilter == "Belum Selesai") {
                  tasks = tasks.where((task) => !task['isCompleted']).toList();
                } else if (selectedFilter == "Selesai") {
                  tasks = tasks.where((task) => task['isCompleted']).toList();
                }
              }

              if (tasks.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada tugas $selectedFilter',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                );
              }

              return ListView.builder(
                itemCount: tasks.length,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                itemBuilder: (context, index) {
                  final taskData = tasks[index];
                  final task = GroupTask.fromMap(taskData, taskData['id']);

                  // Cek apakah task ini bisa di-complete
                  // Tugas hanya bisa di-complete jika semua tugas sebelumnya sudah completed
                  bool canComplete = true;
                  String? blockedByTaskName;

                  for (int i = 0; i < index; i++) {
                    if (!tasks[i]['isCompleted']) {
                      canComplete = false;
                      blockedByTaskName = tasks[i]['namaTugas'] ?? 'Tugas';
                      break;
                    }
                  }

                  return GroupTaskCard(
                    task: task,
                    canComplete: canComplete,
                    blockedByTaskName: blockedByTaskName,
                    onCheckboxChanged: (isCompleted) {
                      _database.updateGroupTaskStatus(
                        uid: uid,
                        taskId: task.id,
                        isCompleted: isCompleted,
                      );
                    },
                    onEdit: () {
                      _showEditDialog(task);
                    },
                    onDelete: () {
                      _showDeleteConfirmation(task);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditGroupTaskDialog(
          onSave: (namaAnggota, namaTugas, deskripsi, waktuPengerjaan) {
            _database.tambahGroupTask(
              uid: uid,
              namaAnggota: namaAnggota,
              namaTugas: namaTugas,
              deskripsi: deskripsi,
              waktuPengerjaan: waktuPengerjaan,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tugas berhasil ditambahkan')),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(GroupTask task) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditGroupTaskDialog(
          task: task,
          onSave: (namaAnggota, namaTugas, deskripsi, waktuPengerjaan) {
            _database.updateGroupTask(
              uid: uid,
              taskId: task.id,
              namaAnggota: namaAnggota,
              namaTugas: namaTugas,
              deskripsi: deskripsi,
              waktuPengerjaan: waktuPengerjaan,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tugas berhasil diubah')),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(GroupTask task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Tugas'),
          content: Text(
            'Apakah Anda yakin ingin menghapus tugas "${task.namaTugas}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _database.deleteGroupTask(uid: uid, taskId: task.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tugas berhasil dihapus')),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
