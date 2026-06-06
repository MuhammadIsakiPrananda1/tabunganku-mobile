class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int colorValue;
  final bool isPinned;
  final bool isFavorite;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.colorValue = 0xFFFFFFFF,
    this.isPinned = false,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      colorValue: json['colorValue'] as int? ?? 0xFFFFFFFF,
      isPinned: json['isPinned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    int? colorValue,
    bool? isPinned,
    bool? isFavorite,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
