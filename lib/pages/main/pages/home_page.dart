import 'package:betomic/theme.dart';
import 'package:betomic/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:betomic/service/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nama = authService.value.currentUser!.displayName ?? 'User';
  String uid = authService.value.currentUser!.uid;
  late String monthName;
  late String dayName;
  late int day;
  late int year;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    int month = now.month;
    int weekday = now.weekday;
    day = now.day;
    year = now.year;

    List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    List<String> days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];

    monthName = months[month - 1];
    dayName = days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 160, 244, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, Color(0xFF0D6973)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(30, 20, 138, 154),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hallo, $nama!",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Raleway',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$dayName, $day $monthName $year",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(230, 255, 255, 255),
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ROW STAT CARDS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: .5, // Rasio tinggi-lebar
                      child: StreamBuilder(
                        stream: Database().getUndoneAllToDo(uid: uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const StatCard(
                              value: "0",
                              label: "Sisa ToDo List",
                            );
                          }
                          final todos = snapshot.data!;

                          return StatCard(
                            value: "${todos.length}",
                            label: "Sisa ToDo List",
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 0.5,
                      child: StreamBuilder(
                        stream: Database().getAllHabitsWoType(uid: uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const StatCard(
                              value: "0",
                              label: "Kebiasaan",
                            );
                          }
                          final habits = snapshot.data!;

                          return StatCard(
                            value: "${habits.length}",
                            label: "Kebiasaan",
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 0.5,
                      child: StreamBuilder(
                        stream: Database().getAllUndoneTimeBlocking(uid: uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const StatCard(
                              value: "0",
                              label: "Sisa Time\nBlocking",
                            );
                          }
                          final timeBlocking = snapshot.data!;

                          return StatCard(
                            value: "${timeBlocking.length}",
                            label: "Sisa Time\nBlocking",
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // QUOTE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [secondaryColor, Color(0xFFB50D45)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(25, 216, 17, 89),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  "\"Semua hal besar berawal dari hal-hal kecil. Benih setiap kebiasaan adalah sebuah keputusan kecil. Namun, seiring keputusan itu diulang, sebuah kebiasaan akan tumbuh dan semakin kuat.\" \n\n- James Clear",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Raleway',
                    height: 1.6,
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

// Widget terpisah untuk kartu statistik
class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color(0xFF0D6973)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 20, 138, 154),
            blurRadius: 12,
            offset: Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Raleway',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Raleway',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
