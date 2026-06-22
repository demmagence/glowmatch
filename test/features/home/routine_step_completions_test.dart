import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';

void main() {
  late SupabaseService svc;

  setUp(() async {
    svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('SupabaseService Routine Step Completions', () {
    test('getRoutineStepCompletions returns empty initially when no logs', () async {
      final logs = await svc.getRoutineStepCompletions('user-1', DateTime.now());
      expect(logs, isEmpty);
    });

    test('insertRoutineStepCompletion and getRoutineStepCompletions work', () async {
      final today = DateTime.now();
      await svc.insertRoutineStepCompletion('user-1', 'step-1', today);

      final logs = await svc.getRoutineStepCompletions('user-1', today);
      expect(logs, hasLength(1));
      expect(logs.first, equals('step-1'));
    });

    test('deleteRoutineStepCompletion removes completed step log', () async {
      final today = DateTime.now();
      await svc.insertRoutineStepCompletion('user-1', 'step-1', today);
      await svc.deleteRoutineStepCompletion('user-1', 'step-1', today);

      final logs = await svc.getRoutineStepCompletions('user-1', today);
      expect(logs, isEmpty);
    });
  });

  group('RoutineViewModel Routine Step Completions Integration', () {
    late RoutineViewModel routineVm;
    late ShelfViewModel shelfVm;

    setUp(() {
      routineVm = RoutineViewModel();
      shelfVm = ShelfViewModel();
    });

    test('RoutineViewModel loads today\'s step completions on init', () async {
      final today = DateTime.now();
      svc.setMockRoutineStepCompletions('user-2', ['r-1', 'r-3'], today);

      await routineVm.init('user-2');

      expect(routineVm.completedStepIds, containsAll(['r-1', 'r-3']));
      expect(routineVm.completedStepIds, hasLength(2));
    });

    test('toggleStep persists completions in database', () async {
      await routineVm.init('user-toggle');
      expect(routineVm.completedStepIds, isEmpty);

      // Toggle step r-1 to completed
      await routineVm.toggleStep('r-1', shelfVm);
      expect(routineVm.completedStepIds, contains('r-1'));

      final dbLogs = await svc.getRoutineStepCompletions('user-toggle', DateTime.now());
      expect(dbLogs, contains('r-1'));

      // Toggle step r-1 back to uncompleted
      await routineVm.toggleStep('r-1', shelfVm);
      expect(routineVm.completedStepIds, isNot(contains('r-1')));

      final dbLogsAfter = await svc.getRoutineStepCompletions('user-toggle', DateTime.now());
      expect(dbLogsAfter, isNot(contains('r-1')));
    });

    test('switching active routine AM/PM retains completion states', () async {
      final today = DateTime.now();
      svc.setMockRoutineStepCompletions('user-switch', ['r-1', 'r-pm-2'], today);

      await routineVm.init('user-switch');

      // AM active initially
      expect(routineVm.activeRoutine, equals('AM'));
      expect(routineVm.completedStepIds, contains('r-1'));

      // Switch to PM
      routineVm.setActiveRoutine('PM');
      expect(routineVm.activeRoutine, equals('PM'));
      expect(routineVm.completedStepIds, contains('r-pm-2'));
      expect(routineVm.completedStepIds, isNot(contains('r-1')));

      // Switch back to AM
      routineVm.setActiveRoutine('AM');
      expect(routineVm.activeRoutine, equals('AM'));
      expect(routineVm.completedStepIds, contains('r-1'));
      expect(routineVm.completedStepIds, isNot(contains('r-pm-2')));
    });

    test('routine completion preserves checked states in RoutineViewModel', () async {
      await routineVm.init('user-completion');
      expect(routineVm.completedCount, equals(0));

      // Toggle all steps in AM (r-1, r-2, r-3)
      for (final step in routineVm.currentSteps) {
        await routineVm.toggleStep(step.id, shelfVm);
      }

      // Verification: routine completed today
      expect(routineVm.completedToday, isTrue);

      // Verify checklist items are NOT cleared and remain in _completedStepIds
      expect(routineVm.completedStepIds, containsAll(['r-1', 'r-2', 'r-3']));
    });
  });
}
