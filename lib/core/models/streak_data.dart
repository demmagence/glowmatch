class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final int totalCompletions;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    required this.totalCompletions,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.tryParse(json['last_completed_date'] as String)
          : null,
      totalCompletions: json['total_completions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_date': lastCompletedDate?.toIso8601String(),
      'total_completions': totalCompletions,
    };
  }

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? totalCompletions,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
    );
  }
}
