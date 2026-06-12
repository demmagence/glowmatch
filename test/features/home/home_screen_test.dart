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

      // Both toggle buttons are visible
      expect(find.text('AM'), findsWidgets);
      expect(find.text('PM'), findsWidgets);
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

      // 'Gentle Cleanser' is the first seeded AM step
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
  });
}
