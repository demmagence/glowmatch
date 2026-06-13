import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/main_layout.dart';
import 'package:glowmatch/features/splash/splash_screen.dart';
import 'package:glowmatch/features/onboarding/onboarding_screen.dart';
import 'package:glowmatch/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('GlowMatch App Integration Tests', () {
    testWidgets('App launch to Splash to Onboarding (first run) to Home', (tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
      
      // Start the app
      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      // Check Splash screen renders 'GlowMatch'
      expect(find.text('GlowMatch'), findsOneWidget);

      // Wait for splash delay (2 seconds) to finish and navigate to Onboarding
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check we are on OnboardingScreen
      expect(find.text('Track Your Glow'), findsOneWidget);

      // Click Skip to navigate to Home (MainLayout)
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Check we are now on MainLayout (HomeScreen)
      expect(find.text('Morning Routine'), findsOneWidget);
    });

    testWidgets('App launch to Splash to Home (returning user)', (tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      
      // Start the app
      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      // Check Splash screen renders 'GlowMatch'
      expect(find.text('GlowMatch'), findsOneWidget);

      // Wait for splash delay (2 seconds) to finish and navigate to Home (MainLayout)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check we are on MainLayout (HomeScreen)
      expect(find.text('Morning Routine'), findsOneWidget);
    });

    testWidgets('Navigation through all bottom tabs', (tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      
      // Start the app and settle
      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Default is Home tab
      expect(find.text('Morning Routine'), findsOneWidget);

      // Tap Budget tab
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      expect(find.text('MONTHLY SPEND vs LIMIT'), findsOneWidget);

      // Tap Journal tab
      await tester.tap(find.byIcon(Icons.assignment_outlined));
      await tester.pumpAndSettle();
      expect(find.text('CURRENT SCORE'), findsOneWidget);

      // Tap Shelf tab
      await tester.tap(find.byIcon(Icons.inventory_2_outlined));
      await tester.pumpAndSettle();
      expect(find.text('My Shelf'), findsOneWidget);

      // Tap Home tab
      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Morning Routine'), findsOneWidget);
    });
  });
}
