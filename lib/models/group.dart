import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMember {
  final String uid;
  final String nama;
  final String email;
  final String role; // 'admin' | 'member'

  GroupMember({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
  });

  factory GroupMember.fromMap(Map<String, dynamic> data) {
    return GroupMember(
      uid: data['uid'] ?? '',
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
}

class Group {
  final String id;
  final String nama;
  final String deskripsi;
  final String createdBy; // uid pembuat
  final DateTime createdAt;
  final List<GroupMember> members;

  Group({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.createdBy,
    required this.createdAt,
    required this.members,
  });

  factory Group.fromMap(Map<String, dynamic> data, String id) {
    final rawMembers = data['members'] as List<dynamic>? ?? [];
    return Group(
      id: id,
      nama: data['nama'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      members: rawMembers
          .map((m) => GroupMember.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'members': members.map((m) => m.toMap()).toList(),
    };
  }

  /// Cek apakah uid tertentu adalah admin kelompok ini
  bool isAdmin(String uid) =>
      members.any((m) => m.uid == uid && m.role == 'admin');

  /// Cek apakah uid tertentu anggota kelompok ini
  bool isMember(String uid) => members.any((m) => m.uid == uid);

  Group copyWith({
    String? id,
    String? nama,
    String? deskripsi,
    String? createdBy,
    DateTime? createdAt,
    List<GroupMember>? members,
  }) {
    return Group(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }
}
