import 'package:betomic/service/auth.dart';
import 'package:betomic/service/database.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:betomic/pages/main/widgets/add_dialog_time_blocking.dart';

class ToDoListView extends StatefulWidget {
  final String tanggalCategory;
  final String priorityCategory;

  const ToDoListView({
    Key? key,
    this.tanggalCategory = '',
    this.priorityCategory = '',
  }) : super(key: key);

  @override
  State<ToDoListView> createState() => _ToDoListViewState();
}

class _ToDoListViewState extends State<ToDoListView> {
  String uid = authService.value.currentUser!.uid;
  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'tinggi':
        return Color(0xFFFF4D4D);
      case 'sedang':
        return Color(0xFFFFC107);
      case 'rendah':
        return Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  void deleteToDo({required String idToDo, required String uid}) async {
    await Database().deleteToDo(idToDo: idToDo, uid: uid);
  }

  void updateToDo({
    required String idToDo,
    required String uid,
    required bool selesai,
  }) async {
    await Database().updateToDo(idToDo: idToDo, uid: uid, selesai: selesai);
  }

  List<Map<dynamic, dynamic>> toDo = [{}];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aktif ${widget.tanggalCategory == "Tanggal" ? "Semua" : widget.tanggalCategory}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: widget.tanggalCategory != "Tanggal"
                    ? Database().getAllToDoCategory(
                        uid: uid,
                        tanggal: widget.tanggalCategory,
                        priority: widget.priorityCategory,
                      )
                    : Database().getAllToDo(
                        uid: uid,
                        priority: widget.priorityCategory,
                      ),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }

                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  final todos = snapshot.data!.isNotEmpty
                      ? snapshot.data!
                      : [{}];
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (toDo.length != todos.length || toDo[0] != todos[0]) {
                      setState(() {
                        toDo = todos;
                      });
                    }
                  });

                  return SizedBox.shrink();
                },
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: toDo.length,
                itemBuilder: (context, index) {
                  final todo = toDo[index];

                  if (toDo[0]['judul'] == null) {
                    return Center(
                      child: Text(
                        "Tidak Ada To Do",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  } else {
                    return buildTaskCard(
                      idToDo: todo['id'],
                      title: todo['judul'],
                      subtitle: todo['deskripsi'],
                      label: todo['priotias'],
                      labelColor: getPriorityColor(todo['priotias']),
                      borderColor: primaryColor,
                      date: todo['tanggal'],
                      showSchedule: todo['connected'],
                      isLink: todo['connected'],
                      selesai: todo['selesai'],
                      scheduleText: todo['connected']
                          ? todo['timeblocking']
                          : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Selesai",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: Database().getAllDoneToDo(uid: uid),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          "Tidak Ada To Do Selesai",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }

                  final todos = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return buildDoneTaskCard(
                        title: todo['judul'],
                        idToDo: todo['id'],
                        subtitle: todo['deskripsi'],
                        date: todo['tanggal'],
                        selesai: todo['selesai'],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateUnconnected({
    required String idToDo,
    required String judul,
  }) async {
    await Database().updateToDoConnect(
      idToDo: idToDo,
      uid: uid,
      timeblocking: "",
      connected: false,
    );

    await Database().deleteTimeBlockingByJudul(judul: judul, uid: uid);
  }

  void updateDoneTimeBlocking({
    required String idToDo,
    required String judul,
  }) async {
    await Database().updateDoneTimeBlockingByJudul(uid: uid, judul: judul);
  }

  Widget buildTaskCard({
    required String idToDo,
    required String title,
    required String subtitle,
    required String label,
    required Color labelColor,
    required Color borderColor,
    required String date,
    required bool selesai,
    bool showSchedule = false,
    String? scheduleText,
    required bool isLink,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: primaryColor, width: 1),
          right: BorderSide(color: primaryColor, width: 1),
          bottom: BorderSide(color: primaryColor, width: 1),
          left: BorderSide(color: primaryColor, width: 4),
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      updateToDo(idToDo: idToDo, uid: uid, selesai: selesai);
                      updateDoneTimeBlocking(idToDo: idToDo, judul: title);
                    },
                    icon: Icon(
                      Icons.check_box_outline_blank,
                      size: 24,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      isLink
                          ? updateUnconnected(idToDo: idToDo, judul: title)
                          : showDialog(
                              context: context,
                              builder: (_) => AddTimeBlockingDialog(
                                todo: true,
                                todoTitle: title,
                                idToDo: idToDo,
                              ),
                            );
                    },
                    icon: FaIcon(
                      isLink
                          ? FontAwesomeIcons.linkSlash
                          : FontAwesomeIcons.link,
                      color: isLink ? Colors.red : Colors.green,
                      size: 16,
                    ),
                  ),

                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      deleteToDo(idToDo: idToDo, uid: uid);
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.solidTrashCan,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "             $subtitle",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),

          if (showSchedule)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 209, 253, 207),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1,
                  color: Color.fromARGB(255, 13, 190, 0),
                ),
              ),
              child: Text(
                "Terjadwal : $scheduleText",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 13, 190, 0),
                ),
              ),
            ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                width: 70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: labelColor.withAlpha(100),
                  border: Border.all(color: labelColor, width: 1.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDoneTaskCard({
    required String idToDo,
    required String title,
    required String subtitle,
    required String date,
    required bool selesai,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          top: BorderSide(color: Colors.black.withAlpha(100), width: 1),
          right: BorderSide(color: Colors.black.withAlpha(100), width: 1),
          bottom: BorderSide(color: Colors.black.withAlpha(100), width: 1),
          left: BorderSide(color: Colors.black.withAlpha(100), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.check_box, size: 28, color: Colors.black54),
            onPressed: () {
              updateToDo(idToDo: idToDo, uid: uid, selesai: selesai);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () {
                  deleteToDo(idToDo: idToDo, uid: uid);
                },
                icon: FaIcon(
                  FontAwesomeIcons.solidTrashCan,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
