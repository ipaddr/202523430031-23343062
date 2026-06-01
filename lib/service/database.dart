import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:betomic/utils/date_format.dart';
import 'package:flutter/material.dart';

class Database {
  Future<void> tambahHabit({
    required String uid,
    required String nama,
    required int target,
    required String deskripsi,
    required String satuan,
    required String tipe,
    required String tanggal,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .add({
          'tipe': tipe,
          'nama': nama,
          'deskripsi': deskripsi,
          'satuan': satuan,
          'target': target,
          'statistik': [
            {
              "tanggal": tanggal,
              'progress': 0,
              'berhasil': tipe == "Kebiasaan Baik" ? false : true,
            },
          ],
        });
  }

  Stream<List<Map<String, dynamic>>> getAllHabits({
    required String uid,
    required String tipe,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .where('tipe', isEqualTo: tipe)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getAllHabitsWoType({required String uid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> updateProgress({
    required String idCard,
    required int progress,
    required String uid,
    required int statIndex,
  }) async {
    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(idCard);

    final doc = await habitRef.get();

    if (!doc.exists) return;

    List statistik = doc['statistik'];
    if (progress >= doc['target']) {
      statistik[statIndex]['berhasil'] = doc["tipe"] == "Kebiasaan Baik"
          ? true
          : false;
    } else {
      statistik[statIndex]['berhasil'] = doc["tipe"] == "Kebiasaan Baik"
          ? false
          : true;
    }
    statistik[statIndex]['progress'] = progress;
    await habitRef.update({'statistik': statistik});
  }

  Future<void> checkAndUpdateDailyProgress({
    required String idCard,
    required String uid,
    required int statIndex,
  }) async {
    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(idCard);

    final doc = await habitRef.get();
    if (!doc.exists) return;

    List statistik = doc['statistik'];
    if (statistik[statIndex]['tanggal'] != formatTanggal(DateTime.now())) {
      await habitRef.update({
        'statistik': FieldValue.arrayUnion([
          {
            'tanggal': formatTanggal(DateTime.now()),
            'progress': 0,
            'berhasil': doc["tipe"] == "Kebiasaan Baik" ? false : true,
          },
        ]),
      });
    }
  }

  Future<void> deleteHabit({
    required String idCard,
    required String uid,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(idCard)
        .delete()
        .then((_) => print("Habits terhapus"))
        .catchError((error) => print("Failed to delete document: $error"));
  }

  Future<void> tambahToDo({
    required String uid,
    required String judul,
    required String deskripsi,
    required String prioritas,
    required DateTime tanggal,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .add({
          'judul': judul,
          'deskripsi': deskripsi,
          'priotias': prioritas,
          'tanggal': formatTanggal(tanggal),
          'selesai': false,
          'connected': false,
          'timeblocking': "",
        });
  }

  Stream<List<Map<String, dynamic>>> getAllToDo({
    required String uid,
    required String priority,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .where('selesai', isEqualTo: false)
        .where(
          'priotias',
          whereIn: priority == 'Semua'
              ? ['Tinggi', 'Sedang', 'Rendah']
              : [priority],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getUndoneAllToDo({required String uid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .where('selesai', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getAllToDoCategory({
    required String uid,
    required String tanggal,
    required String priority,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .where('selesai', isEqualTo: false)
        .where(
          'tanggal',
          whereIn: tanggal == 'Hari ini'
              ? [formatTanggal(DateTime.now())]
              : getDatesThisWeek(),
        )
        .where(
          'priotias',
          whereIn: priority == 'Semua'
              ? ['Tinggi', 'Sedang', 'Rendah']
              : [priority],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getAllDoneToDo({required String uid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .where('selesai', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> deleteToDo({required String idToDo, required String uid}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .doc(idToDo)
        .delete()
        .then((_) => print("ToDo terhapus"))
        .catchError((error) => print("Failed to delete document: $error"));
  }

  Future<void> updateToDo({
    required String idToDo,
    required String uid,
    required bool selesai,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .doc(idToDo)
        .update({'selesai': !selesai});
  }

  Future<void> updateToDoConnect({
    required String idToDo,
    required String uid,
    required String timeblocking,
    required bool connected,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist')
        .doc(idToDo)
        .update({'connected': connected, 'timeblocking': timeblocking});
  }

  Future<void> updateToDoConnectByTime({
    required String uid,
    required String timeblocking,
  }) async {
    CollectionReference tasks = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist');
    QuerySnapshot querySnapshot = await tasks
        .where('timeblocking', isEqualTo: timeblocking)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'connected': false,
          'timeblocking': "",
        }); // Deletes the document
      }
    }
  }

  Future<void> updateDoneToDoConnectByTime({
    required String uid,
    required String timeblocking,
  }) async {
    CollectionReference tasks = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todolist');
    QuerySnapshot querySnapshot = await tasks
        .where('timeblocking', isEqualTo: timeblocking)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'selesai': true}); // Deletes the document
      }
    }
  }

  Future<void> tambahTimeBlocking({
    required String uid,
    required String judul,
    required String startTime,
    required String endTime,
    required bool connected,
  }) async {
    List<String> startTimePart = startTime.split(':');
    List<String> endTimePart = endTime.split(':');

    TimeOfDay startTimeTipe = TimeOfDay(
      hour: int.parse(startTimePart[0]),
      minute: int.parse(startTimePart[1]),
    );
    TimeOfDay endTimeTipe = TimeOfDay(
      hour: int.parse(endTimePart[0]),
      minute: int.parse(endTimePart[1]),
    );

    DateTime timeOfDayToDateTime(TimeOfDay tod) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    }

    Duration calculateDuration(TimeOfDay start, TimeOfDay end) {
      final startDateTime = timeOfDayToDateTime(start);
      var endDateTime = timeOfDayToDateTime(end);

      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(Duration(days: 1));
      }

      return endDateTime.difference(startDateTime);
    }

    Duration durasi = calculateDuration(startTimeTipe, endTimeTipe);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timeblocking')
        .add({
          'judul': judul,
          'mulai': startTime,
          'berakhir': endTime,
          'durasi': "${durasi.inHours} jam, ${durasi.inMinutes % 60} menit",
          'selesai': false,
          'idtodo': '',
          'connected': connected,
        });
  }

  Stream<List<Map<String, dynamic>>> getAllTimeBlocking({required String uid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timeblocking')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getAllUndoneTimeBlocking({
    required String uid,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timeblocking')
        .where('selesai', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> deleteTimeBlocking({
    required String idTimeBlocking,
    required String uid,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timeblocking')
        .doc(idTimeBlocking)
        .delete()
        .then((_) => print("Timeblocking terhapus"))
        .catchError((error) => print("Failed to delete document: $error"));
  }

  Future<void> deleteTimeBlockingByJudul({
    required String judul,
    required String uid,
  }) async {
    CollectionReference tasks = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timeblocking');
    QuerySnapshot querySnapshot = await tasks
        .where('judul', isEqualTo: judul)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete(); // Deletes the document
        print("Deleted task with title: $judul, ID: ${doc.id}");
      }
    } else {
      print("No task found with title: $judul");
    }
  }

  Future<void> updateDoneTimeBlockingByJudul({
    required String judul,
    required String uid,
  }) async {
    CollectionReference tasks = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timeblocking');
    QuerySnapshot querySnapshot = await tasks
        .where('judul', isEqualTo: judul)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'selesai': true}); // Deletes the document
      }
    } else {}
  }

  Future<void> updateTimeBlocking({
    required String idTimeBlocking,
    required String uid,
    required bool complete,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timeblocking')
        .doc(idTimeBlocking)
        .update({'selesai': !complete});
  }

  // Group Tasks Methods
  Future<void> tambahGroupTask({
    required String uid,
    required String namaAnggota,
    required String namaTugas,
    required String deskripsi,
    required DateTime waktuPengerjaan,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('group_tasks')
        .add({
          'namaAnggota': namaAnggota,
          'namaTugas': namaTugas,
          'deskripsi': deskripsi,
          'waktuPengerjaan': waktuPengerjaan,
          'isCompleted': false,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
  }

  Stream<List<Map<String, dynamic>>> getAllGroupTasks({required String uid}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('group_tasks')
        .orderBy('waktuPengerjaan', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> updateGroupTask({
    required String uid,
    required String taskId,
    required String namaAnggota,
    required String namaTugas,
    required String deskripsi,
    required DateTime waktuPengerjaan,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('group_tasks')
        .doc(taskId)
        .update({
          'namaAnggota': namaAnggota,
          'namaTugas': namaTugas,
          'deskripsi': deskripsi,
          'waktuPengerjaan': waktuPengerjaan,
          'updatedAt': DateTime.now(),
        });
  }

  Future<void> updateGroupTaskStatus({
    required String uid,
    required String taskId,
    required bool isCompleted,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('group_tasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted, 'updatedAt': DateTime.now()});
  }

  Future<void> deleteGroupTask({
    required String uid,
    required String taskId,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('group_tasks')
        .doc(taskId)
        .delete()
        .then((_) => print("Group task terhapus"))
        .catchError((error) => print("Failed to delete group task: $error"));
  }
}
