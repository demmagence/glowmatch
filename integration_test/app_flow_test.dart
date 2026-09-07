import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/main.dart' as app;
import 'staging_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    final config = StagingConfig.tryLoad();
    if (config != null && config.isConfigured) {
      await svc.initialize(url: config.url, anonKey: config.anonKey);
    } else {
      await svc.initialize(
        url: 'https://staging.placeholder.supabase.co',
        anonKey: 'placeholder-anon-key-local-test',
      );
    }
  });

  group('GlowMatch App Integration Tests', () {
    testWidgets('App launch to Splash to Onboarding (first run) to Home', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});

      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      expect(find.text('GlowMatch'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Track Your Glow'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Morning Routine'), findsOneWidget);
    });

    testWidgets(
      'App launch to Splash to SignInScreen (returning unauthenticated user)',
      (tester) async {
        SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

        await tester.pumpWidget(const app.GlowMatchApp());
        await tester.pumpAndSettle();

        expect(find.text('GlowMatch'), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Returning unauthenticated users must be routed to SignInScreen
        expect(find.text('Sign In'), findsWidgets);
        expect(find.text('Continue as Guest'), findsOneWidget);
      },
    );

    testWidgets('Navigation through all bottom tabs after guest sign-in', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Continue as Guest'), findsOneWidget);
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      expect(find.text('Morning Routine'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      expect(find.text('MONTHLY SPEND vs LIMIT'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.assignment_outlined));
      await tester.pumpAndSettle();
      expect(find.text('CURRENT SCORE'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.inventory_2_outlined));
      await tester.pumpAndSettle();
      expect(find.text('My Shelf'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Morning Routine'), findsOneWidget);
    });
  });
}
