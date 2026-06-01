import 'package:betomic/service/auth.dart';
import 'package:betomic/theme.dart';
import 'package:betomic/pages/main/widgets/habbit_card.dart';
import 'package:betomic/pages/main/widgets/add_dialog.dart';
import 'package:betomic/pages/main/pages/statistik_kebiasaan_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:betomic/service/database.dart';

class HabbitPage extends StatefulWidget {
  const HabbitPage({super.key});

  @override
  State<HabbitPage> createState() => _HabbitPageState();
}

class _HabbitPageState extends State<HabbitPage> {
  String selectedHabbit = "Kebiasaan Baik";
  Color color = primaryColor;
  bool statistikKebiasaan = false;
  bool status = false;
  String uid = authService.value.currentUser!.uid;
  String kebiasaan = '';
  int strike = 0;
  int target = 0;
  String satuan = "";
  List<dynamic> statistik = [{}];
  Widget buildHabbitButton(
    String title,
    Color color,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
  ) {
    final bool isSelectedHabbit = title == selectedHabbit;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isSelectedHabbit ? color : Color(0xffEDEDED),
        foregroundColor: isSelectedHabbit
            ? Color(0xFFFFFFFF)
            : Color(0xff101720),
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            topRight: Radius.circular(topRight),
            bottomLeft: Radius.circular(bottomLeft),
            bottomRight: Radius.circular(bottomRight),
          ),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        setState(() {
          selectedHabbit = title;
          statistikKebiasaan = false;
          this.color = color;
        });
      },
      child: Text(title),
    );
  }

  Widget titleHabbit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          selectedHabbit,
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 60),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AddHabitDialog(
                mainColor: color,
                selectedHabbit: selectedHabbit,
              ),
            );
          },
          icon: FaIcon(FontAwesomeIcons.plus, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: color, // Background langsung
            foregroundColor: Colors.white, // Warna icon
            padding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            elevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      secondaryColor,
                      const Color.fromARGB(200, 20, 138, 154),
                    ],
                    stops: [0.3, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: const Color.fromARGB(200, 20, 138, 154),
              child: Container(
                padding: EdgeInsets.only(
                  left: 0,
                  top: 10,
                  right: 0,
                  bottom: 150,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Column(
                  spacing: 10,
                  children: [
                    IntrinsicWidth(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xffEDEDED),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildHabbitButton(
                              "Kebiasaan Baik",
                              primaryColor,
                              30,
                              10,
                              30,
                              10,
                            ),
                            buildHabbitButton(
                              "Kebiasaan Buruk",
                              secondaryColor,
                              10,
                              30,
                              10,
                              30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    statistikKebiasaan
                        ? StatistikKebiasaanPage(
                            onBack: () {
                              setState(() {
                                statistikKebiasaan = false;
                              });
                            },
                            color: color,
                            kebiasaan: kebiasaan,
                            strike: strike,
                            status: status,
                            statistik: statistik.length > 7 ? statistik.sublist(statistik.length-7):statistik ,
                            satuan: satuan,
                            target : target
                          )
                        : Column(
                            children: [
                              titleHabbit(),
                              StreamBuilder(
                                stream: Database().getAllHabits(
                                  uid: uid,
                                  tipe: selectedHabbit,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 50),
                                      child: Center(
                                        child: Text(
                                          "Tidak ada kebiasaan",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final habits = snapshot.data!;
                                  int localStrike = 0;
                                  Map<String, dynamic> habitStrike = {};
                                  for (var habit in habits) {
                                    localStrike = 0;
                                    for (
                                      var i = 0;
                                      i < habit['statistik'].length - 1;
                                      i++
                                    ) {
                                      var strike = habit['statistik'][i];
                                      if (strike['berhasil'] == true) {
                                        localStrike++;
                                      } else {
                                        localStrike = 0;
                                      }
                                    }

                                    habitStrike[habit["nama"]] = localStrike;
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: habits.length,
                                    itemBuilder: (context, index) {
                                      final habit = habits[index];
                                      return HabitCard(
                                        strike: habitStrike[habit["nama"]],
                                        status:
                                            habit['statistik'][habit['statistik']
                                                    .length -
                                                1]['berhasil'],
                                        uid: uid,
                                        statIndex:
                                            habit['statistik'].length - 1,
                                        idCard: habit['id'],
                                        mainColor: color,
                                        nama: habit['nama'],
                                        deskripsi: habit['deskripsi'],
                                        target: habit['target'],
                                        satuan: habit['satuan'],
                                        progress:
                                            habit['statistik'][habit['statistik']
                                                    .length -
                                                1]['progress'],
                                        onStatistikKebiasaan: () => {
                                          setState(() {
                                            statistikKebiasaan = true;
                                            kebiasaan = habit['nama'];
                                            strike = habitStrike[habit["nama"]];
                                            status =
                                                habit['statistik'][habit['statistik']
                                                        .length -
                                                    1]['berhasil'];
                                            statistik = habit['statistik'];
                                            satuan = habit['satuan'];
                                            target = habit['target'];
                                          }),
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
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
