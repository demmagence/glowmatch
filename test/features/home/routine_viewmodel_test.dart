import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';

void main() {
  late RoutineViewModel vm;
  late ShelfViewModel shelfVm;

  setUpAll(() async {
    // Seed offline mock data once for the suite
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  setUp(() {
    vm = RoutineViewModel();
    shelfVm = ShelfViewModel();
  });

  group('RoutineViewModel – toggleStep', () {
    test('toggleStep adds stepId to completedStepIds', () {
      vm.toggleStep('step-1', shelfVm);
      expect(vm.completedStepIds.contains('step-1'), isTrue);
    });

    test('toggleStep removes stepId when already completed', () {
      vm.toggleStep('step-1', shelfVm);
      vm.toggleStep('step-1', shelfVm);
      expect(vm.completedStepIds.contains('step-1'), isFalse);
    });

    test('toggling multiple steps tracks each independently', () {
      vm.toggleStep('step-a', shelfVm);
      vm.toggleStep('step-b', shelfVm);
      expect(vm.completedStepIds.contains('step-a'), isTrue);
      expect(vm.completedStepIds.contains('step-b'), isTrue);
      expect(vm.completedStepIds.length, equals(2));
    });
  });

  group('RoutineViewModel – completedCount', () {
    test('completedCount is 0 when no steps are completed', () async {
      await vm.loadRoutines('test-user');
      // clear any pre-existing completions
      for (final id in List.from(vm.completedStepIds)) {
        vm.toggleStep(id, shelfVm);
      }
      expect(vm.completedCount, equals(0));
    });

    test('completedCount reflects number of completed AM steps', () async {
      await vm.loadRoutines('test-user');
      final stepId = vm.amSteps.first.id;
      vm.toggleStep(stepId, shelfVm);
      expect(vm.completedCount, equals(1));
    });

    test('completedCount does not exceed totalCount', () async {
      await vm.loadRoutines('test-user');
      for (final step in vm.amSteps) {
        vm.toggleStep(step.id, shelfVm);
      }
      expect(vm.completedCount, equals(vm.totalCount));
    });
  });

  group('RoutineViewModel – setActiveRoutine', () {
    test('defaults to AM routine', () {
      expect(vm.activeRoutine, equals('AM'));
    });

    test('setActiveRoutine switches to PM', () {
      vm.setActiveRoutine('PM');
      expect(vm.activeRoutine, equals('PM'));
    });

    test('setActiveRoutine clears completedStepIds on switch', () {
      vm.toggleStep('step-x', shelfVm);
      vm.setActiveRoutine('PM');
      expect(vm.completedStepIds, isEmpty);
    });

    test('setActiveRoutine to same value is a no-op', () {
      vm.toggleStep('step-y', shelfVm);
      vm.setActiveRoutine('AM'); // already AM
      expect(vm.completedStepIds.contains('step-y'), isTrue);
    });
  });

  group('RoutineViewModel – addCustomStep', () {
    test('addCustomStep adds a step to the active routine', () async {
      await vm.loadRoutines('test-user');
      final countBefore = vm.amSteps.length;
      await vm.addCustomStep('test-user', 'Vitamin C Serum', 'Apply 3 drops');
      expect(vm.amSteps.length, greaterThan(countBefore));
    });

    test('addCustomStep adds to PM when active routine is PM', () async {
      vm.setActiveRoutine('PM');
      await vm.loadRoutines('test-user');
      final countBefore = vm.pmSteps.length;
      await vm.addCustomStep('test-user', 'Night Oil', 'Press into skin');
      expect(vm.pmSteps.length, greaterThan(countBefore));
    });
  });
}
