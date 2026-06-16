import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:betomic/models/group.dart';
import 'package:betomic/models/collab_task.dart';
import 'package:betomic/models/invitation.dart';

/// Semua operasi Firestore untuk fitur Kelompok Kolaboratif.
///
/// Skema Firestore:
///   groups/{groupId}
///     - nama, deskripsi, createdBy, createdAt
///     - members: List<Map> [{uid, nama, email, role}]
///     - memberUids: List<String>   ← indeks cepat untuk query
///     tasks/{taskId}
///
///   invitations/{invitationId}
///     - groupId, groupNama, inviterUid, inviterNama
///     - inviteeUid, inviteeEmail, inviteeNama
///     - status: 'pending' | 'accepted' | 'declined'
///     - createdAt
///
///   users/{uid}
///     - email (field root — untuk lookup)
///     joined_groups/{groupId}
///       - groupId
class GroupDatabase {
  final _db = FirebaseFirestore.instance;

  // ─────────────────────── REFERENCE HELPERS ───────────────────────────────

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groups');

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _db.collection('invitations');

  CollectionReference<Map<String, dynamic>> _tasks(String groupId) =>
      _groups.doc(groupId).collection('tasks');

  DocumentReference<Map<String, dynamic>> _joinedGroupRef(
          String uid, String groupId) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('joined_groups')
          .doc(groupId);

  // ─────────────────────────── GRUP — CRUD ─────────────────────────────────

  /// Buat kelompok baru. Pembuat otomatis menjadi admin.
  Future<String> buatKelompok({
    required String creatorUid,
    required String creatorNama,
    required String creatorEmail,
    required String nama,
    required String deskripsi,
  }) async {
    final member = GroupMember(
      uid: creatorUid,
      nama: creatorNama,
      email: creatorEmail,
      role: 'admin',
    );

    final docRef = await _groups.add({
      'nama': nama,
      'deskripsi': deskripsi,
      'createdBy': creatorUid,
      'createdAt': FieldValue.serverTimestamp(),
      'members': [member.toMap()],
      'memberUids': [creatorUid], // indeks cepat
    });

    // Tulis indeks joined_groups di profil pembuat sendiri
    await _joinedGroupRef(creatorUid, docRef.id).set({'groupId': docRef.id});

    return docRef.id;
  }

  /// Update nama dan deskripsi kelompok.
  Future<void> updateKelompok({
    required String groupId,
    required String nama,
    required String deskripsi,
  }) async {
    await _groups.doc(groupId).update({'nama': nama, 'deskripsi': deskripsi});
  }

  /// Hapus kelompok beserta semua tugas dan undangan terkait.
  Future<void> hapusKelompok({
    required String groupId,
    required List<GroupMember> members,
  }) async {
    // 1. Hapus semua tasks
    final taskSnap = await _tasks(groupId).get();
    final batch = _db.batch();
    for (final doc in taskSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_groups.doc(groupId));
    await batch.commit();

    // 2. Bersihkan joined_groups tiap anggota
    final cleanupBatch = _db.batch();
    for (final m in members) {
      cleanupBatch.delete(_joinedGroupRef(m.uid, groupId));
    }
    await cleanupBatch.commit();

    // 3. Hapus undangan pending terkait kelompok ini
    final invSnap = await _invitations
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'pending')
        .get();
    final invBatch = _db.batch();
    for (final doc in invSnap.docs) {
      invBatch.delete(doc.reference);
    }
    await invBatch.commit();
  }

  // ──────────────────────── UNDANGAN — CRUD ────────────────────────────────

  /// Kirim undangan ke user berdasarkan email.
  /// Lookup dilakukan via field `email` di dokumen root `users/{uid}`.
  /// Mengembalikan pesan error (String) jika gagal, null jika berhasil.
  Future<String?> kirimUndangan({
    required String groupId,
    required String groupNama,
    required String inviterUid,
    required String inviterNama,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // ── Cari user berdasarkan email ──
    // Firestore membutuhkan composite index jika query ini lambat.
    // Alternatif: simpan email sebagai document ID di koleksi emails/.
    QuerySnapshot<Map<String, dynamic>> userQuery;
    try {
      userQuery = await _db
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
    } catch (_) {
      return 'Gagal mencari pengguna. Coba lagi.';
    }

    if (userQuery.docs.isEmpty) {
      return 'Pengguna dengan email "$normalizedEmail" tidak ditemukan.\n'
          'Pastikan mereka sudah terdaftar di aplikasi.';
    }

    final userDoc = userQuery.docs.first;
    final inviteeUid = userDoc.id;
    final inviteeNama =
        userDoc.data()['nama'] ?? userDoc.data()['displayName'] ?? normalizedEmail;

    // ── Cek apakah sudah anggota ──
    final groupDoc = await _groups.doc(groupId).get();
    if (!groupDoc.exists) return 'Kelompok tidak ditemukan.';

    final memberUids =
        List<String>.from(groupDoc.data()!['memberUids'] ?? []);
    if (memberUids.contains(inviteeUid)) {
      return 'Pengguna ini sudah menjadi anggota kelompok.';
    }

    // ── Cek apakah sudah ada undangan pending ──
    final existingInv = await _invitations
        .where('groupId', isEqualTo: groupId)
        .where('inviteeUid', isEqualTo: inviteeUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existingInv.docs.isNotEmpty) {
      return 'Undangan sudah dikirim ke pengguna ini dan sedang menunggu konfirmasi.';
    }

    // ── Buat dokumen undangan ──
    await _invitations.add({
      'groupId': groupId,
      'groupNama': groupNama,
      'inviterUid': inviterUid,
      'inviterNama': inviterNama,
      'inviteeUid': inviteeUid,
      'inviteeEmail': normalizedEmail,
      'inviteeNama': inviteeNama,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return null; // sukses
  }

  /// Terima undangan — user memanggil ini sendiri (menulis ke datanya sendiri).
  Future<void> terimaUndangan({required Invitation invitation}) async {
    final batch = _db.batch();

    // 1. Update status undangan
    batch.update(_invitations.doc(invitation.id), {'status': 'accepted'});

    // 2. Tambahkan member ke array `members` dan `memberUids` di grup
    final newMember = GroupMember(
      uid: invitation.inviteeUid,
      nama: invitation.inviteeNama,
      email: invitation.inviteeEmail,
      role: 'member',
    );
    batch.update(_groups.doc(invitation.groupId), {
      'members': FieldValue.arrayUnion([newMember.toMap()]),
      'memberUids': FieldValue.arrayUnion([invitation.inviteeUid]),
    });

    await batch.commit();

    // 3. User menulis joined_groups di profilnya sendiri (aman dari sisi rules)
    await _joinedGroupRef(invitation.inviteeUid, invitation.groupId)
        .set({'groupId': invitation.groupId});
  }

  /// Tolak undangan.
  Future<void> tolakUndangan({required String invitationId}) async {
    await _invitations.doc(invitationId).update({'status': 'declined'});
  }

  // ──────────────────── STREAM: UNDANGAN MASUK ─────────────────────────────

  /// Stream undangan pending yang diterima oleh uid tertentu.
  /// Sorting dilakukan di sisi Dart untuk menghindari kebutuhan composite index.
  Stream<List<Invitation>> streamUndanganMasuk({required String uid}) {
    return _invitations
        .where('inviteeUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => Invitation.fromMap(doc.data(), doc.id))
              .toList();
          // Sort terbaru di atas
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // ──────────────────────── ANGGOTA — REMOVE ───────────────────────────────

  /// Hapus anggota dari kelompok (oleh admin) atau keluar sendiri.
  Future<void> hapusAnggota({
    required String groupId,
    required GroupMember member,
  }) async {
    final batch = _db.batch();
    batch.update(_groups.doc(groupId), {
      'members': FieldValue.arrayRemove([member.toMap()]),
      'memberUids': FieldValue.arrayRemove([member.uid]),
    });
    await batch.commit();

    // User menghapus joined_groups miliknya sendiri
    await _joinedGroupRef(member.uid, groupId).delete();
  }

  Future<void> keluarKelompok({
    required String groupId,
    required GroupMember member,
  }) async {
    await hapusAnggota(groupId: groupId, member: member);
  }

  // ─────────────────── STREAM: DAFTAR KELOMPOK ─────────────────────────────

  /// Stream semua kelompok yang diikuti user, via indeks joined_groups.
  Stream<List<Group>> getKelompokUser({required String uid}) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('joined_groups')
        .snapshots()
        .asyncMap((indexSnap) async {
      if (indexSnap.docs.isEmpty) return <Group>[];

      final groupIds = indexSnap.docs.map((d) => d.id).toList();

      final groupsSnap = await _groups
          .where(FieldPath.documentId, whereIn: groupIds)
          .get();

      return groupsSnap.docs
          .map((doc) => Group.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Stream satu dokumen kelompok (real-time).
  Stream<Group?> streamKelompok({required String groupId}) {
    return _groups.doc(groupId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Group.fromMap(snap.data()!, snap.id);
    });
  }

  // ──────────────────────────── TUGAS — CRUD ───────────────────────────────

  Future<void> tambahTugas({
    required String groupId,
    required String namaTugas,
    required String deskripsi,
    required String assigneeUid,
    required String assigneeNama,
    required DateTime waktuPengerjaan,
    required String createdBy,
    required String mode, // 'seri' | 'paralel'
    required int urutan,  // urutan dalam antrian (untuk mode seri)
  }) async {
    await _tasks(groupId).add({
      'namaTugas': namaTugas,
      'deskripsi': deskripsi,
      'assigneeUid': assigneeUid,
      'assigneeNama': assigneeNama,
      'waktuPengerjaan': Timestamp.fromDate(waktuPengerjaan),
      'isCompleted': false,
      'createdBy': createdBy,
      'mode': mode,
      'urutan': urutan,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTugas({
    required String groupId,
    required String taskId,
    required String namaTugas,
    required String deskripsi,
    required String assigneeUid,
    required String assigneeNama,
    required DateTime waktuPengerjaan,
    required String mode,
    required int urutan,
  }) async {
    await _tasks(groupId).doc(taskId).update({
      'namaTugas': namaTugas,
      'deskripsi': deskripsi,
      'assigneeUid': assigneeUid,
      'assigneeNama': assigneeNama,
      'waktuPengerjaan': Timestamp.fromDate(waktuPengerjaan),
      'mode': mode,
      'urutan': urutan,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatusTugas({
    required String groupId,
    required String taskId,
    required bool isCompleted,
  }) async {
    await _tasks(groupId).doc(taskId).update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hapusTugas({
    required String groupId,
    required String taskId,
  }) async {
    await _tasks(groupId).doc(taskId).delete();
  }

  // ──────────────────────── STREAM: TUGAS ──────────────────────────────────

  /// Stream semua tugas dalam kelompok (semua mode), urut waktu pengerjaan.
  Stream<List<CollabTask>> streamTugas({required String groupId}) {
    return _tasks(groupId)
        .orderBy('waktuPengerjaan', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CollabTask.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream tugas mode paralel saja, urut waktu pengerjaan.
  Stream<List<CollabTask>> streamTugasParalel({required String groupId}) {
    return _tasks(groupId)
        .where('mode', isEqualTo: 'paralel')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => CollabTask.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.waktuPengerjaan.compareTo(b.waktuPengerjaan));
          return list;
        });
  }

  /// Stream tugas mode seri saja, urut field `urutan`.
  Stream<List<CollabTask>> streamTugasSeri({required String groupId}) {
    return _tasks(groupId)
        .where('mode', isEqualTo: 'seri')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => CollabTask.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.urutan.compareTo(b.urutan));
          return list;
        });
  }

  /// Hitung urutan berikutnya untuk tugas seri dalam kelompok.
  Future<int> getNextUrutanSeri({required String groupId}) async {
    final snap = await _tasks(groupId)
        .where('mode', isEqualTo: 'seri')
        .get();
    if (snap.docs.isEmpty) return 1;
    final maxUrutan = snap.docs
        .map((d) => (d.data()['urutan'] as num?)?.toInt() ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxUrutan + 1;
  }
}
