import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimeBlockCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String duration;
  final String title;
  final bool? connected;
  final bool isCompleted;
  final VoidCallback? onDelete;
  final VoidCallback? onCompleted;

  const TimeBlockCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.title,
    this.connected,
    this.isCompleted = false,
    this.onDelete,
    this.onCompleted,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20,right: 20,bottom: 12, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
      top: BorderSide(color: secondaryColor, width: 1),
      right: BorderSide(color: secondaryColor, width: 1),
      bottom: BorderSide(color: secondaryColor, width: 1),
      left: BorderSide(color: secondaryColor, width: 4),
    ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onCompleted,
                  icon: Icon(isCompleted ? Icons.check_box : Icons.check_box_outline_blank_outlined,
                  color: isCompleted ? Colors.black87 : Colors.grey,
                  size: 26),
                ),
                const SizedBox(width: 6),
                Icon(Icons.access_time, color: Colors.black54, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "$startTime–$endTime ($duration)",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.solidTrashCan, color: Colors.red),
                  onPressed: onDelete,
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.circular(30),
                    border: BoxBorder.all(
                      width: 2,
                      color: Colors.green
                    )
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
              )
            else if (connected!)
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
