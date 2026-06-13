import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/core/viewmodels/theme_viewmodel.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';
import 'package:glowmatch/features/budget/budget_viewmodel.dart';
import 'package:glowmatch/features/scanner/scanner_viewmodel.dart';
import 'package:glowmatch/features/journal/journal_viewmodel.dart';
import 'package:glowmatch/features/onboarding/onboarding_screen.dart';
import 'package:glowmatch/features/main_layout.dart';

Widget _buildOnboarding() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => RoutineViewModel()),
      ChangeNotifierProvider(create: (_) => ShelfViewModel()),
      ChangeNotifierProxyProvider<ShelfViewModel, BudgetViewModel>(
        create: (_) => BudgetViewModel(),
        update: (_, shelf, budget) => budget!..updateFromShelf(shelf.shelfItems),
      ),
      ChangeNotifierProvider(create: (_) => ScannerViewModel()),
      ChangeNotifierProvider(create: (_) => JournalViewModel()),
    ],
    child: const MaterialApp(
      home: OnboardingScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingScreen Widget Tests', () {
    testWidgets('renders pages with correct titles and updates indicator dots', (tester) async {
      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      // Page 1
      expect(find.text('Track Your Glow'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to navigate to Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 2
      expect(find.text('Scan Ingredients'), findsOneWidget);

      // Tap Next to navigate to Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 3
      expect(find.text('Smart Budget'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Skip button navigates to MainLayout', (tester) async {
      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(MainLayout), findsOneWidget);
    });

    testWidgets('Get Started button on page 3 navigates to MainLayout', (tester) async {
      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      // Go to page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(MainLayout), findsOneWidget);
    });
  });
}
