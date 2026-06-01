import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:betomic/service/database.dart';

class HabitCard extends StatefulWidget {
  final VoidCallback onStatistikKebiasaan;
  final Color mainColor;
  final String nama;
  final String satuan;
  final int target;
  final int progress;
  final String deskripsi;
  final String idCard;
  final String uid;
  final int statIndex;
  final int strike;
  final bool status;

  const HabitCard({
    super.key,
    required this.mainColor,
    required this.onStatistikKebiasaan,
    required this.nama,
    required this.satuan,
    required this.idCard,
    required this.target,
    required this.progress,
    required this.deskripsi,
    required this.uid,
    required this.statIndex,
    required this.strike,
    required this.status,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  final TextEditingController progressController = TextEditingController();
  bool progressError = false;
  String progressErrorPesan = "";
  late int strike;
  void updateProgress(int updatedProgress) async {
    await Database().updateProgress(
      idCard: widget.idCard,
      progress: updatedProgress,
      uid: widget.uid,
      statIndex: widget.statIndex,
    );
    progressController.clear();
  }

  @override
  void initState() {
    super.initState();
    strike = widget.strike;
    Database().checkAndUpdateDailyProgress(uid:widget.uid, idCard: widget.idCard, statIndex:widget.statIndex);
  }

  void deleteHabit() async {
    await Database().deleteHabit(idCard: widget.idCard, uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: const Color.fromARGB(25, 0, 0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nama,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.deskripsi,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.fire,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.status? "${strike+1}" : "$strike",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.chartLine),
                    color: Colors.black87,
                    iconSize: 18,
                    onPressed: widget.onStatistikKebiasaan,
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.solidTrashCan),
                    color: Colors.redAccent,
                    iconSize: 18,
                    onPressed: () {
                      deleteHabit();
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Progress Bar Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress Hari Ini",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                "${widget.progress}/${widget.target} ${widget.satuan}",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Progress Bar UI
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: widget.progress / widget.target,
              minHeight: 15,
              backgroundColor: widget.mainColor.withAlpha(100),
              valueColor: AlwaysStoppedAnimation(widget.mainColor),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: progressController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Masukkan Progress",
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 184, 184, 184),
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: const Color(0xffEDEDED),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              /// Button Tambah Progress
              ElevatedButton(
                onPressed: () {
                  if (int.tryParse(progressController.text) == null) {
                    setState(() {
                      progressError = true;
                      progressErrorPesan = "Masukkan Angka";
                    });

                    return;
                  }
                  setState(() {
                    progressError = false;
                    progressErrorPesan = "";
                  });
                  updateProgress(
                    widget.progress + int.parse(progressController.text.trim()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.mainColor,
                  minimumSize: const Size(45, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
          ),

          Text(
            progressError ? progressErrorPesan : "",
            style: TextStyle(color: Colors.red),
          ),

          /// Finish Button
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (widget.progress < widget.target) {
                  updateProgress(widget.target);
                } else {
                  updateProgress(widget.progress + 0);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff008000),
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Selesai",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
