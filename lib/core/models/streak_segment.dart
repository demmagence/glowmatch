class StreakSegment {
  final DateTime startDate;
  final DateTime endDate;
  final int length;

  StreakSegment({
    required this.startDate,
    required this.endDate,
    required this.length,
  });

  factory StreakSegment.fromJson(Map<String, dynamic> json) {
    return StreakSegment(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      length: json['length'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'length': length,
    };
  }
}
