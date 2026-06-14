import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/features/splash/splash_screen.dart';
import 'package:glowmatch/features/onboarding/onboarding_screen.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/core/viewmodels/theme_viewmodel.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';
import 'package:glowmatch/features/budget/budget_viewmodel.dart';
import 'package:glowmatch/features/scanner/scanner_viewmodel.dart';
import 'package:glowmatch/features/journal/journal_viewmodel.dart';
import 'package:glowmatch/core/services/supabase_service.dart';

Widget _buildSplash({required bool hasSeenOnboarding}) {
  SharedPreferences.setMockInitialValues({
    'has_seen_onboarding': hasSeenOnboarding,
  });
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => RoutineViewModel()),
      ChangeNotifierProvider(create: (_) => ShelfViewModel()),
      ChangeNotifierProxyProvider<ShelfViewModel, BudgetViewModel>(
        create: (_) => BudgetViewModel(),
        update: (_, shelf, budget) =>
            budget!..updateFromShelf(shelf.shelfItems),
      ),
      ChangeNotifierProvider(create: (_) => ScannerViewModel()),
      ChangeNotifierProvider(create: (_) => JournalViewModel()),
    ],
    child: const MaterialApp(home: SplashScreen()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('SplashScreen', () {
    testWidgets('renders GlowMatch logo and text', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSplash(hasSeenOnboarding: false));
      await tester.pump();

      expect(find.text('GlowMatch'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to OnboardingScreen on first run', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSplash(hasSeenOnboarding: false));
      await tester.pump();

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Track Your Glow'), findsOneWidget);
    });

    testWidgets('navigates to MainLayout for returning user', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSplash(hasSeenOnboarding: true));
      await tester.pump();

      await tester.pump(const Duration(seconds: 3));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Shelf'), findsWidgets);
    });
  });
}
