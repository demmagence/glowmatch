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
import 'package:glowmatch/features/splash/splash_screen.dart';
import 'package:glowmatch/features/onboarding/onboarding_screen.dart';
import 'package:glowmatch/features/main_layout.dart';

Widget _buildSplash() {
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
      home: SplashScreen(),
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

  group('SplashScreen Widget Tests', () {
    testWidgets('renders GlowMatch logo and text', (tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      await tester.pumpWidget(_buildSplash());

      // Should render the 'GlowMatch' text
      expect(find.text('GlowMatch'), findsOneWidget);
      // Should render the auto_awesome icon
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('navigates to MainLayout after 2-second delay if onboarding has been seen', (tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      await tester.pumpWidget(_buildSplash());
      await tester.pumpAndSettle();

      // Wait 2 seconds for navigation
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(MainLayout), findsOneWidget);
    });

    testWidgets('navigates to OnboardingScreen after 2-second delay if onboarding has not been seen', (tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
      await tester.pumpWidget(_buildSplash());
      await tester.pumpAndSettle();

      // Wait 2 seconds for navigation
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
