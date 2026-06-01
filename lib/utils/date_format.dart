import 'package:intl/intl.dart';

final DateFormat shortDateFormat = DateFormat('d MMM', 'id_ID');

final DateFormat longDateFormat = DateFormat('d MMMM', 'id_ID');

String formatTanggal(DateTime date, {bool panjang = false}) {
  return (panjang ? longDateFormat : shortDateFormat).format(date);
}

List<String> getDatesThisWeek() {
  DateTime now = DateTime.now();
  DateTime startOfWeek =  now.subtract(Duration(days: now.weekday - 1));

  
  List<String> weekDates = [];
  for (int i = 0; i < 7; i++) {
    weekDates.add(formatTanggal( startOfWeek.add(Duration(days: i))));
  }

  return weekDates;
}
