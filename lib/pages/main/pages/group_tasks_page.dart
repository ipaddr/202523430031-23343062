import 'package:betomic/pages/main/pages/group_tasks_serial_page.dart';
import 'package:betomic/pages/main/pages/group_tasks_parallel_page.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';

class GroupTasksPage extends StatefulWidget {
  const GroupTasksPage({super.key});

  @override
  State<GroupTasksPage> createState() => _GroupTasksPageState();
}

class _GroupTasksPageState extends State<GroupTasksPage> {
  String selectedGroupTaskMode = "Seri";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tugas Kelompok',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kelola jadwal pekerjaan anggota kelompok',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Buttons untuk Tugas Seri dan Tugas Paralel
                  Row(
                    children: [
                      Expanded(
                        child: _buildGroupTaskModeButton(
                          label: 'Tugas Seri',
                          isSelected: selectedGroupTaskMode == "Seri",
                          onTap: () {
                            setState(() {
                              selectedGroupTaskMode = "Seri";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGroupTaskModeButton(
                          label: 'Tugas Paralel',
                          isSelected: selectedGroupTaskMode == "Paralel",
                          onTap: () {
                            setState(() {
                              selectedGroupTaskMode = "Paralel";
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Content based on selected mode
          Expanded(
            child: selectedGroupTaskMode == "Seri"
                ? const GroupTasksSerialPage()
                : const GroupTasksParallelPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTaskModeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color.fromARGB(240, 255, 255, 255)],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isSelected ? primaryColor : Colors.white,
              fontFamily: 'Raleway',
            ),
          ),
        ),
      ),
    );
  }
}
