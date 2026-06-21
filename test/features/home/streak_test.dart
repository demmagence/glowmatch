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

  group('Acceptance Criteria – Issue #75', () {
    // AC1: Completing all routine steps triggers recordRoutineCompletion
    //       exactly once per day.
    test('AC1: recordRoutineCompletion triggers exactly once per day', () async {
      // First completion creates the streak
      final first = await svc.recordRoutineCompletion('ac1-user');
      expect(first.currentStreak, equals(1));
      expect(first.totalCompletions, equals(1));

      // Second call on the same day is a no-op
      final second = await svc.recordRoutineCompletion('ac1-user');
      expect(second.currentStreak, equals(1));
      expect(second.totalCompletions, equals(1));

      // Third call on the same day is still a no-op
      final third = await svc.recordRoutineCompletion('ac1-user');
      expect(third.currentStreak, equals(1));
      expect(third.totalCompletions, equals(1));
    });

    // AC2: Streak increments correctly across multiple logins on the same day.
    test('AC2: streak data persists correctly across re-reads (simulating re-login)', () async {
      // Complete the routine
      final completed = await svc.recordRoutineCompletion('ac2-user');
      expect(completed.currentStreak, equals(1));
      expect(completed.totalCompletions, equals(1));

      // Simulate re-login: re-read streak from service
      final reloaded = await svc.getStreakData('ac2-user');
      expect(reloaded.currentStreak, equals(1));
      expect(reloaded.totalCompletions, equals(1));
      expect(reloaded.lastCompletedDate, isNotNull);

      // Attempt to complete again on same day after re-read
      final secondAttempt = await svc.recordRoutineCompletion('ac2-user');
      expect(secondAttempt.currentStreak, equals(1));
      expect(secondAttempt.totalCompletions, equals(1));
    });

    // AC4: Streak data loads from DB correctly on app start.
    test('AC4: getStreakData returns persisted data after recordRoutineCompletion', () async {
      // Record a completion
      await svc.recordRoutineCompletion('ac4-user');

      // Fetch it back (simulates app start loading streak)
      final loaded = await svc.getStreakData('ac4-user');
      expect(loaded.currentStreak, equals(1));
      expect(loaded.longestStreak, equals(1));
      expect(loaded.totalCompletions, equals(1));
      expect(loaded.lastCompletedDate, isNotNull);

      // Verify the date is today (local time)
      final now = DateTime.now();
      final lastLocal = loaded.lastCompletedDate!.toLocal();
      expect(lastLocal.year, equals(now.year));
      expect(lastLocal.month, equals(now.month));
      expect(lastLocal.day, equals(now.day));
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

    test(
      'completeRoutine called twice on same day does not double-increment',
      () async {
        await routineVm.init('user-double');
        await routineVm.completeRoutine('user-double');
        expect(routineVm.streakData?.currentStreak, equals(1));
        expect(routineVm.streakData?.totalCompletions, equals(1));

        // Second call should be a no-op
        await routineVm.completeRoutine('user-double');
        expect(routineVm.streakData?.currentStreak, equals(1));
        expect(routineVm.streakData?.totalCompletions, equals(1));
      },
    );

    test(
      'completeRoutine after simulated re-login (re-init) still prevents duplicate',
      () async {
        await routineVm.init('user-relogin');
        await routineVm.completeRoutine('user-relogin');
        expect(routineVm.completedToday, isTrue);
        expect(routineVm.streakData?.currentStreak, equals(1));

        // Simulate re-login by creating a new ViewModel and re-initializing
        final freshVm = RoutineViewModel();
        await freshVm.init('user-relogin');

        // completedToday should be true from loaded streak data
        expect(freshVm.completedToday, isTrue);

        // Attempting to complete again should be a no-op
        await freshVm.completeRoutine('user-relogin');
        expect(freshVm.streakData?.currentStreak, equals(1));
        expect(freshVm.streakData?.totalCompletions, equals(1));
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
