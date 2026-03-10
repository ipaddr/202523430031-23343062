/// Model untuk Notes
class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? category;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Convert model ke Map untuk JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  /// Create model dari Map
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'],
      isPinned: json['isPinned'] ?? false,
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  /// Copy with untuk update data tertentu
  NoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() => 'NoteModel(id: $id, title: $title, isPinned: $isPinned)';
}

/// Model untuk Note Category
class NoteCategoryModel {
  final String id;
  final String name;
  final String color;
  final int noteCount;

  NoteCategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.noteCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color, 'noteCount': noteCount};
  }

  factory NoteCategoryModel.fromJson(Map<String, dynamic> json) {
    return NoteCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#000000',
      noteCount: json['noteCount'] ?? 0,
    );
  }
}
