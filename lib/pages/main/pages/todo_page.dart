import 'package:betomic/pages/main/widgets/add_dialog_time_blocking.dart';
import 'package:betomic/pages/main/widgets/add_dialog_todo.dart';
import 'package:betomic/pages/main/widgets/todo_list_view.dart';
import 'package:betomic/pages/main/widgets/time_block_card.dart';
import 'package:betomic/service/auth.dart';
import 'package:betomic/service/database.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  String selectedMenu = "To Do List";
  Color color = primaryColor;
  bool selectedTimeBlocking = false;
  String selectedFilterTanggal = "Tanggal";
  String selectedFilterKategori = "Semua";
  String uid = authService.value.currentUser!.uid;
  Widget buildMenuButton(
    String title,
    Color color,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
  ) {
    final bool isSelectedMenu = title == selectedMenu;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isSelectedMenu ? color : Color(0xffEDEDED),
        foregroundColor: isSelectedMenu ? Color(0xFFFFFFFF) : Color(0xff101720),
        minimumSize: const Size(170, 50),
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
          selectedMenu = title;
          this.color = color;
          if (title == "Time Blocking") {
            selectedTimeBlocking = true;
          } else {
            selectedTimeBlocking = false;
          }
        });
      },
      child: Text(title),
    );
  }

  Widget buildDropdown(
    String selectedValue,
    List<String> items,
    bool isTanggal,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (value) {
            setState(() {
              if (isTanggal) {
                selectedFilterTanggal = value!;
              } else {
                selectedFilterKategori = value!;
              }
            });
          },
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }

  Widget titleMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          selectedMenu,
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
              builder: (_) => selectedTimeBlocking
                  ? AddTimeBlockingDialog()
                  : AddToDoDialog(),
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
                            buildMenuButton(
                              "To Do List",
                              primaryColor,
                              30,
                              10,
                              30,
                              10,
                            ),
                            buildMenuButton(
                              "Time Blocking",
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
                    Column(
                      children: [
                        titleMenu(),
                        SizedBox(height: 20),
                        Column(
                          children: selectedTimeBlocking
                              ? [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "    Jadwal Hari Ini",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  StreamBuilder(
                                    stream: Database().getAllTimeBlocking(
                                      uid: uid,
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
                                          padding: const EdgeInsets.only(
                                            top: 50,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Tidak Ada Time Blocking",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      final timeBlockings = snapshot.data!;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: timeBlockings.length,
                                        itemBuilder: (context, index) {
                                          final timeBlocking =
                                              timeBlockings[index];
                                          return TimeBlockCard(
                                            startTime: timeBlocking['mulai'],
                                            endTime: timeBlocking['berakhir'],
                                            duration: timeBlocking['durasi'],
                                            title: timeBlocking['judul'],
                                            isCompleted:
                                                timeBlocking['selesai'],
                                            onDelete: () async {
                                              await Database()
                                                  .deleteTimeBlocking(
                                                    idTimeBlocking:
                                                        timeBlocking['id'],
                                                    uid: uid,
                                                  );
                                              if (timeBlocking['connected']) {
                                                await Database()
                                                    .updateToDoConnectByTime(
                                                      uid: uid,
                                                      timeblocking:
                                                          "${timeBlocking['mulai']}-${timeBlocking['berakhir']}",
                                                    );
                                              }
                                            },
                                            onCompleted: () async {
                                              await Database()
                                                  .updateTimeBlocking(
                                                    idTimeBlocking:
                                                        timeBlocking['id'],
                                                    uid: uid,
                                                    complete:
                                                        timeBlocking['selesai'],
                                                  );
                                              if (timeBlocking['connected']) {
                                                await Database()
                                                    .updateDoneToDoConnectByTime(
                                                      uid: uid,
                                                      timeblocking:
                                                          "${timeBlocking['mulai']}-${timeBlocking['berakhir']}",
                                                    );
                                              }
                                            },
                                            connected:
                                                timeBlocking['connected'],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ]
                              : [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: buildDropdown(
                                            selectedFilterTanggal,
                                            [
                                              "Tanggal",
                                              "Hari ini",
                                              "Minggu ini",
                                            ],
                                            true,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: buildDropdown(
                                            selectedFilterKategori,
                                            [
                                              "Semua",
                                              "Tinggi",
                                              "Sedang",
                                              "Rendah",
                                            ],
                                            false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ToDoListView(
                                    tanggalCategory: selectedFilterTanggal,
                                    priorityCategory: selectedFilterKategori,
                                  ),
                                ],
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
