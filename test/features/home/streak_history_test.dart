import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';


void main() {
  late SupabaseService svc;

  setUp(() async {
    svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('SupabaseService Daily Completion Logs', () {
    test('getDailyCompletionLogs returns empty initially when no logs', () async {
      final logs = await svc.getDailyCompletionLogs('user-1');
      expect(logs, isEmpty);
    });

    test('recordRoutineCompletion inserts completion date to logs', () async {
      final data = await svc.recordRoutineCompletion('user-1');
      expect(data.currentStreak, equals(1));

      final logs = await svc.getDailyCompletionLogs('user-1');
      expect(logs, hasLength(1));

      final today = DateTime.now();
      expect(logs.first.year, equals(today.year));
      expect(logs.first.month, equals(today.month));
      expect(logs.first.day, equals(today.day));
    });
  });

  group('RoutineViewModel Streak Segment Calculation', () {
    late RoutineViewModel routineVm;

    setUp(() {
      routineVm = RoutineViewModel();
    });

    test('streakSegments is empty when no completion logs', () {
      expect(routineVm.streakSegments, isEmpty);
    });

    test('streakSegments correctly groups contiguous dates and ignores duplicates', () async {
      final now = DateTime.now();
      final day1 = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 5));
      final day2 = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 4));
      final day3 = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 3));
      // gap on day - 2
      final day4 = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      final day5 = DateTime(now.year, now.month, now.day);

      svc.setMockDailyCompletionLogs('test-user', [day1, day2, day3, day4, day5]);

      await routineVm.init('test-user');

      final segments = routineVm.streakSegments;
      // Expect 2 segments:
      // Segment 1: day4 to day5 (length 2)
      // Segment 2: day1 to day3 (length 3)
      expect(segments, hasLength(2));

      expect(segments[0].length, equals(2));
      expect(segments[0].startDate.year, equals(day4.year));
      expect(segments[0].startDate.month, equals(day4.month));
      expect(segments[0].startDate.day, equals(day4.day));
      expect(segments[0].endDate.year, equals(day5.year));
      expect(segments[0].endDate.month, equals(day5.month));
      expect(segments[0].endDate.day, equals(day5.day));

      expect(segments[1].length, equals(3));
      expect(segments[1].startDate.year, equals(day1.year));
      expect(segments[1].startDate.month, equals(day1.month));
      expect(segments[1].startDate.day, equals(day1.day));
      expect(segments[1].endDate.year, equals(day3.year));
      expect(segments[1].endDate.month, equals(day3.month));
      expect(segments[1].endDate.day, equals(day3.day));
    });

    test('streakSegments sorts segments descending by end date', () async {
      final now = DateTime.now();
      final oldDay = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 10));
      final recentDay = DateTime(now.year, now.month, now.day);

      svc.setMockDailyCompletionLogs('test-user-sort', [oldDay, recentDay]);

      await routineVm.init('test-user-sort');

      final segments = routineVm.streakSegments;
      expect(segments, hasLength(2));
      // Should sort recent first
      expect(segments[0].startDate.year, equals(recentDay.year));
      expect(segments[0].startDate.month, equals(recentDay.month));
      expect(segments[0].startDate.day, equals(recentDay.day));

      expect(segments[1].startDate.year, equals(oldDay.year));
      expect(segments[1].startDate.month, equals(oldDay.month));
      expect(segments[1].startDate.day, equals(oldDay.day));
    });
  });
}
