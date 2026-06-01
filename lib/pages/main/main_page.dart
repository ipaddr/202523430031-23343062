import 'package:flutter/material.dart';
import 'package:betomic/pages/main/pages/home_page.dart';
import 'package:betomic/pages/main/pages/habit_page.dart';
import 'package:betomic/pages/main/pages/todo_page.dart';
import 'package:betomic/pages/main/pages/group_tasks_page.dart';
import 'package:betomic/pages/main/pages/profile_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    HabbitPage(),
    ToDoPage(),
    GroupTasksPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                112,
                39,
                230,
                255,
              ).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(FontAwesomeIcons.solidHouse, 0),
              _buildNavItem(FontAwesomeIcons.rotate, 1),
              _buildNavItem(FontAwesomeIcons.solidCalendar, 2),
              _buildNavItem(FontAwesomeIcons.tasks, 3),
              _buildNavItem(FontAwesomeIcons.solidUser, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(47, 20, 138, 154)
              : const Color.fromARGB(0, 198, 198, 198),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(
                      47,
                      20,
                      138,
                      154,
                    ).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: FaIcon(
          icon,
          size: isSelected ? 20 : 18,
          color: isSelected
              ? const Color.fromARGB(255, 27, 217, 242)
              : const Color.fromARGB(255, 198, 198, 198),
        ),
      ),
    );
  }
}
