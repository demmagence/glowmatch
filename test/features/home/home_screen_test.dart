import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/features/home/home_screen.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';

Widget _buildHome(RoutineViewModel routineVm) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ChangeNotifierProvider<ShelfViewModel>(create: (_) => ShelfViewModel()),
      ChangeNotifierProvider<RoutineViewModel>.value(value: routineVm),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

Widget _buildHomeDark(RoutineViewModel routineVm) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ChangeNotifierProvider<ShelfViewModel>(create: (_) => ShelfViewModel()),
      ChangeNotifierProvider<RoutineViewModel>.value(value: routineVm),
    ],
    child: MaterialApp(theme: ThemeData.dark(), home: const HomeScreen()),
  );
}

void main() {
  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('HomeScreen widget tests', () {
    testWidgets('AM/PM toggle renders both labels', (tester) async {
      final vm = RoutineViewModel();
      await tester.pumpWidget(_buildHome(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });

    testWidgets('"Click to add" card is always present', (tester) async {
      final vm = RoutineViewModel();
      await tester.pumpWidget(_buildHome(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Click to add'), findsOneWidget);
    });

    testWidgets('step cards render after loadRoutines', (tester) async {
      final vm = RoutineViewModel();
      await vm.loadRoutines('test-user');

      await tester.pumpWidget(_buildHome(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Gentle Cleanser'), findsOneWidget);
    });

    testWidgets('steps progress badge shows 0/N Completed', (tester) async {
      final vm = RoutineViewModel();
      await vm.loadRoutines('test-user');

      await tester.pumpWidget(_buildHome(vm));
      await tester.pump(const Duration(milliseconds: 300));

      final total = vm.totalCount;
      expect(find.textContaining('0/$total Completed'), findsOneWidget);
    });

    testWidgets('default active routine is AM', (tester) async {
      final vm = RoutineViewModel();
      await tester.pumpWidget(_buildHome(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Morning Routine'), findsOneWidget);
    });

    testWidgets('shows ErrorStateWidget when currentSteps is empty', (
      tester,
    ) async {
      final vm = RoutineViewModel();

      await tester.pumpWidget(_buildHome(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('No routine steps yet. Tap below to add your first step!'),
        findsOneWidget,
      );
      expect(find.text('Complete Routine'), findsNothing);
    });

    testWidgets(
      'renders in dark mode and applies theme-aware white text color',
      (tester) async {
        final vm = RoutineViewModel();

        await tester.pumpWidget(_buildHomeDark(vm));
        await tester.pump(const Duration(milliseconds: 300));

        final BuildContext context = tester.element(find.byType(HomeScreen));
        expect(Theme.of(context).brightness, equals(Brightness.dark));

        final Text morningRoutineText = tester.widget<Text>(
          find.text('Morning Routine'),
        );
        expect(morningRoutineText.style?.color, equals(Colors.white));
      },
    );

    testWidgets('completed step card displays checkmark and grey state styling', (tester) async {
      final vm = RoutineViewModel();
      await vm.loadRoutines('test-user');
      final stepId = vm.currentSteps.first.id;

      await tester.pumpWidget(_buildHome(vm));
      await tester.pump(const Duration(milliseconds: 300));

      final containerFinder = find.byKey(ValueKey('inner_$stepId'));
      expect(containerFinder, findsOneWidget);

      Container container = tester.widget<Container>(containerFinder);
      BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));

      // Tap on the step text to toggle/complete it
      await tester.tap(find.text('Gentle Cleanser'));
      await tester.pump(const Duration(milliseconds: 300));

      container = tester.widget<Container>(containerFinder);
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.grey.shade100));
      expect((decoration.border as Border).top.color, equals(Colors.grey.shade300));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
