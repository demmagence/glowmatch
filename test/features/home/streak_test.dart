import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/models/models.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';
import 'package:glowmatch/features/journal/journal_viewmodel.dart';

void main() {
  late SupabaseService svc;

  setUp(() async {
    svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
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

    test('AC5: Streak breaks (resets to 0) when user misses a day', () async {
      // Seed a streak that completed 2 days ago
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final oldStreak = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        lastCompletedDate: twoDaysAgo,
        totalCompletions: 8,
      );
      svc.setMockStreak('ac5-user', oldStreak);

      // Load it back - should detect the missed day and reset currentStreak to 0
      final loaded = await svc.getStreakData('ac5-user');
      expect(loaded.currentStreak, equals(0));
      expect(loaded.longestStreak, equals(10)); // Longest streak is preserved
      expect(loaded.totalCompletions, equals(8));
      expect(loaded.lastCompletedDate, equals(twoDaysAgo)); // Date remains the same
    });

    test('AC6: Incomplete routine steps do not trigger completion', () async {
      final routineVm = RoutineViewModel();
      final shelfVm = ShelfViewModel();
      await routineVm.init('ac6-user');
      expect(routineVm.completedToday, isFalse);

      // Toggling only the first step (not all steps)
      await routineVm.toggleStep(routineVm.currentSteps.first.id, shelfVm);
      expect(routineVm.completedToday, isFalse);

      // Call completeRoutine manually - should be blocked by guard
      await routineVm.completeRoutine('ac6-user');
      expect(routineVm.completedToday, isFalse);
      expect(routineVm.streakData?.currentStreak, equals(0));
    });
  });

  group('RoutineViewModel Streak Integration', () {
    late RoutineViewModel routineVm;
    late ShelfViewModel shelfVm;

    setUp(() async {
      routineVm = RoutineViewModel();
      shelfVm = ShelfViewModel();
    });

    test('completedToday is false initially', () {
      expect(routineVm.completedToday, isFalse);
    });

    test(
      'completeRoutine updates streak and marks completedToday as true when all steps are completed',
      () async {
        await routineVm.init('user-2');
        expect(routineVm.completedToday, isFalse);

        // Toggle all steps to complete
        for (final step in routineVm.currentSteps) {
          await routineVm.toggleStep(step.id, shelfVm);
        }

        expect(routineVm.completedToday, isTrue);
        expect(routineVm.streakData?.currentStreak, equals(1));
      },
    );

    test(
      'completeRoutine called twice on same day does not double-increment',
      () async {
        await routineVm.init('user-double');
        
        // Complete all steps first
        for (final step in routineVm.currentSteps) {
          await routineVm.toggleStep(step.id, shelfVm);
        }
        
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
        
        // Complete all steps
        for (final step in routineVm.currentSteps) {
          await routineVm.toggleStep(step.id, shelfVm);
        }
        
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

      expect(journalVm.currentScore, equals(88));
    });
  });
}
