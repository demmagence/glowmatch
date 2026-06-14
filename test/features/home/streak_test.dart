import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/journal/journal_viewmodel.dart';

void main() {
  late SupabaseService svc;

  setUpAll(() async {
    svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  setUp(() {
    svc.resetForTesting();
  });

  group('SupabaseService Streak Logic', () {
    test('getStreakData returns default when no data exists', () async {
      final data = await svc.getStreakData('user-1');
      expect(data.currentStreak, equals(0));
      expect(data.longestStreak, equals(0));
      expect(data.totalCompletions, equals(0));
      expect(data.lastCompletedDate, isNull);
    });

    test('recordRoutineCompletion creates a new streak', () async {
      final data = await svc.recordRoutineCompletion('user-1');
      expect(data.currentStreak, equals(1));
      expect(data.longestStreak, equals(1));
      expect(data.totalCompletions, equals(1));
      expect(data.lastCompletedDate, isNotNull);
    });

    test('recordRoutineCompletion on same day is a no-op', () async {
      final data1 = await svc.recordRoutineCompletion('user-1');
      final data2 = await svc.recordRoutineCompletion('user-1');
      expect(data2.currentStreak, equals(data1.currentStreak));
      expect(data2.totalCompletions, equals(data1.totalCompletions));
    });
  });

  group('RoutineViewModel Streak Integration', () {
    late RoutineViewModel routineVm;

    setUp(() {
      routineVm = RoutineViewModel();
    });

    test('completedToday is false initially', () {
      expect(routineVm.completedToday, isFalse);
    });

    test(
      'completeRoutine updates streak and marks completedToday as true',
      () async {
        await routineVm.init('user-2');
        expect(routineVm.completedToday, isFalse);

        await routineVm.completeRoutine('user-2');
        expect(routineVm.completedToday, isTrue);
        expect(routineVm.streakData?.currentStreak, equals(1));
      },
    );
  });

  group('JournalViewModel Score Calculation with Streak', () {
    late JournalViewModel journalVm;

    setUp(() {
      journalVm = JournalViewModel();
    });

    test('currentScore adds streak bonus correctly', () async {
      final svc = SupabaseService();
      final streakData = await svc.recordRoutineCompletion('user-3');
      expect(streakData.currentStreak, equals(1));

      await journalVm.fetchJournal('user-3');

      expect(journalVm.currentScore, equals(82));
    });
  });
}
