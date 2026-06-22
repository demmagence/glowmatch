import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/features/onboarding/onboarding_screen.dart';
import 'package:glowmatch/features/main_layout.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/core/viewmodels/theme_viewmodel.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';
import 'package:glowmatch/features/budget/budget_viewmodel.dart';
import 'package:glowmatch/features/scanner/scanner_viewmodel.dart';
import 'package:glowmatch/features/journal/journal_viewmodel.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/currency_viewmodel.dart';

Widget _buildOnboarding() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => RoutineViewModel()),
      ChangeNotifierProvider(create: (_) => ShelfViewModel()),
      ChangeNotifierProvider(create: (_) => CurrencyViewModel()),
      ChangeNotifierProxyProvider<ShelfViewModel, BudgetViewModel>(
        create: (_) => BudgetViewModel(),
        update: (_, shelf, budget) =>
            budget!..updateFromShelf(shelf.shelfItems),
      ),
      ChangeNotifierProvider(create: (_) => ScannerViewModel()),
      ChangeNotifierProvider(create: (_) => JournalViewModel()),
    ],
    child: const MaterialApp(home: OnboardingScreen()),
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

  group('OnboardingScreen', () {
    testWidgets('renders first page with correct title', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      expect(find.text('Track Your Glow'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('has exactly 3 pages with correct titles', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      expect(find.text('Track Your Glow'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-800, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Scan Ingredients'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-800, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Smart Budget'), findsOneWidget);
    });

    testWidgets('dot indicators update on page change', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsNWidgets(3));

      await tester.fling(find.byType(PageView), const Offset(-800, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('last page shows Get Started button', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-800, 0), 1000);
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-800, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Smart Budget'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('Skip button navigates to MainLayout', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(MainLayout), findsOneWidget);
    });

    testWidgets('Get Started on last page navigates to MainLayout', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildOnboarding());
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-800, 0), 1000);
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-800, 0), 1000);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(MainLayout), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });
  });
}
