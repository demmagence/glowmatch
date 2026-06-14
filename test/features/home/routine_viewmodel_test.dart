import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';

void main() {
  late RoutineViewModel vm;
  late ShelfViewModel shelfVm;

  setUpAll(() async {
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
      vm.setActiveRoutine('AM');
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

  group('RoutineViewModel – CRUD, Reordering, and Shelf Linking', () {
    test(
      'addCustomStep with shelfItemId links the product correctly',
      () async {
        await vm.loadRoutines('test-user');
        final initialCount = vm.amSteps.length;
        await vm.addCustomStep(
          'test-user',
          'Linked Toner',
          'Use cotton pad',
          shelfItemId: 'item-2',
        );

        expect(vm.amSteps.length, equals(initialCount + 1));
        final newStep = vm.amSteps.last;
        expect(newStep.name, equals('Linked Toner'));
        expect(newStep.shelfItemId, equals('item-2'));
      },
    );

    test('updateStep persists updated name and description', () async {
      await vm.loadRoutines('test-user');
      final step = vm.amSteps.first;
      final updatedStep = step.copyWith(
        name: 'Super Hydrator',
        description: 'Apply 4 drops',
      );

      await vm.updateStep('test-user', updatedStep);

      expect(vm.amSteps.first.name, equals('Super Hydrator'));
      expect(vm.amSteps.first.description, equals('Apply 4 drops'));
    });

    test(
      'deleteStep removes step and shifts stepNumbers sequentially',
      () async {
        await vm.loadRoutines('test-user');

        while (vm.amSteps.length < 3) {
          await vm.addCustomStep('test-user', 'Temp Step', 'Desc');
        }

        final stepIdToDelete = vm.amSteps[1].id;
        final initialCount = vm.amSteps.length;

        await vm.deleteStep('test-user', stepIdToDelete);

        expect(vm.amSteps.length, equals(initialCount - 1));

        for (int i = 0; i < vm.amSteps.length; i++) {
          expect(vm.amSteps[i].stepNumber, equals(i + 1));
        }
      },
    );

    test(
      'reorderSteps shifts elements and updates stepNumbers correctly',
      () async {
        await vm.loadRoutines('test-user');

        while (vm.amSteps.length < 3) {
          await vm.addCustomStep('test-user', 'Temp Step', 'Desc');
        }

        final step0Id = vm.amSteps[0].id;
        final step1Id = vm.amSteps[1].id;

        await vm.reorderSteps('test-user', 0, 2);

        expect(vm.amSteps[1].id, equals(step0Id));
        expect(vm.amSteps[0].id, equals(step1Id));

        for (int i = 0; i < vm.amSteps.length; i++) {
          expect(vm.amSteps[i].stepNumber, equals(i + 1));
        }
      },
    );

    test(
      'toggleStep on linked step decrements remainingUses of shelf item',
      () async {
        await shelfVm.fetchShelf('test-user');
        final initialUses = shelfVm.shelfItems
            .firstWhere((item) => item.id == 'item-1')
            .remainingUses;

        await vm.loadRoutines('test-user');

        await vm.addCustomStep(
          'test-user',
          'Linked Serum',
          'Apply it',
          shelfItemId: 'item-1',
        );

        final linkedStep = vm.amSteps.firstWhere(
          (step) => step.shelfItemId == 'item-1',
        );
        await vm.toggleStep(linkedStep.id, shelfVm);

        expect(vm.completedStepIds.contains(linkedStep.id), isTrue);
        expect(
          shelfVm.shelfItems
              .firstWhere((item) => item.id == 'item-1')
              .remainingUses,
          equals(initialUses - 1),
        );
      },
    );
  });
}
