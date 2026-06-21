class JournalEntry {
  final String id;
  final String loggedDate;
  final int skinScore;
  final String? photoPath;
  final String? notes;
  final DateTime? createdAt;

  JournalEntry({
    required this.id,
    required this.loggedDate,
    required this.skinScore,
    this.photoPath,
    this.notes,
    this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      loggedDate: json['logged_date'] as String? ?? '',
      skinScore: json['skin_score'] as int? ?? 80,
      photoPath: json['photo_path'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logged_date': loggedDate,
      'skin_score': skinScore,
      'photo_path': photoPath,
      'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? loggedDate,
    int? skinScore,
    String? photoPath,
    String? notes,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      loggedDate: loggedDate ?? this.loggedDate,
      skinScore: skinScore ?? this.skinScore,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
