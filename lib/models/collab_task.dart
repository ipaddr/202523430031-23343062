import 'package:cloud_firestore/cloud_firestore.dart';

class CollabTask {
  final String id;
  final String namaTugas;
  final String deskripsi;
  final String assigneeUid;
  final String assigneeNama;
  final DateTime waktuPengerjaan;
  final bool isCompleted;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// Mode pengerjaan: 'paralel' (bebas) | 'seri' (berurutan)
  final String mode;
  /// Urutan dalam antrian seri. Diabaikan untuk mode paralel.
  final int urutan;

  CollabTask({
    required this.id,
    required this.namaTugas,
    required this.deskripsi,
    required this.assigneeUid,
    required this.assigneeNama,
    required this.waktuPengerjaan,
    required this.isCompleted,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.mode = 'paralel',
    this.urutan = 0,
  });

  factory CollabTask.fromMap(Map<String, dynamic> data, String id) {
    return CollabTask(
      id: id,
      namaTugas: data['namaTugas'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      assigneeUid: data['assigneeUid'] ?? '',
      assigneeNama: data['assigneeNama'] ?? '',
      waktuPengerjaan:
          (data['waktuPengerjaan'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mode: data['mode'] ?? 'paralel',
      urutan: (data['urutan'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaTugas': namaTugas,
      'deskripsi': deskripsi,
      'assigneeUid': assigneeUid,
      'assigneeNama': assigneeNama,
      'waktuPengerjaan': waktuPengerjaan,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'mode': mode,
      'urutan': urutan,
    };
  }

  bool get isSeri => mode == 'seri';
  bool get isParalel => mode == 'paralel';

  CollabTask copyWith({
    String? id,
    String? namaTugas,
    String? deskripsi,
    String? assigneeUid,
    String? assigneeNama,
    DateTime? waktuPengerjaan,
    bool? isCompleted,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mode,
    int? urutan,
  }) {
    return CollabTask(
      id: id ?? this.id,
      namaTugas: namaTugas ?? this.namaTugas,
      deskripsi: deskripsi ?? this.deskripsi,
      assigneeUid: assigneeUid ?? this.assigneeUid,
      assigneeNama: assigneeNama ?? this.assigneeNama,
      waktuPengerjaan: waktuPengerjaan ?? this.waktuPengerjaan,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mode: mode ?? this.mode,
      urutan: urutan ?? this.urutan,
    );
  }
}
