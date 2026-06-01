class GroupTask {
  final String id;
  final String namaAnggota;
  final String namaTugas;
  final String deskripsi;
  final DateTime waktuPengerjaan;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupTask({
    required this.id,
    required this.namaAnggota,
    required this.namaTugas,
    required this.deskripsi,
    required this.waktuPengerjaan,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupTask.fromMap(Map<String, dynamic> data, String id) {
    return GroupTask(
      id: id,
      namaAnggota: data['namaAnggota'] ?? '',
      namaTugas: data['namaTugas'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      waktuPengerjaan:
          (data['waktuPengerjaan'] as dynamic)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaAnggota': namaAnggota,
      'namaTugas': namaTugas,
      'deskripsi': deskripsi,
      'waktuPengerjaan': waktuPengerjaan,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  GroupTask copyWith({
    String? id,
    String? namaAnggota,
    String? namaTugas,
    String? deskripsi,
    DateTime? waktuPengerjaan,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupTask(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      namaTugas: namaTugas ?? this.namaTugas,
      deskripsi: deskripsi ?? this.deskripsi,
      waktuPengerjaan: waktuPengerjaan ?? this.waktuPengerjaan,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
