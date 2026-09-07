import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/auth/sign_in_screen.dart';
import 'package:glowmatch/features/auth/sign_up_screen.dart';
import 'package:glowmatch/features/onboarding/onboarding_screen.dart';
import 'package:glowmatch/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('Authentication Lifecycle Integration Tests', () {
    testWidgets('First-time user launch shows Onboarding, skip leads to Home', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});

      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      // Splash delay
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Track Your Glow'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Morning Routine'), findsOneWidget);
    });

    testWidgets(
      'Returning unauthenticated user routes to SignInScreen, not Home',
      (tester) async {
        SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

        await tester.pumpWidget(const app.GlowMatchApp());
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.text('Sign In'), findsWidgets);
        expect(find.text('Continue as Guest'), findsOneWidget);
      },
    );

    testWidgets('Guest entry from SignInScreen successfully reaches Home', (
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
    });

    testWidgets('Navigate between Sign In and Sign Up screens', (tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);

      // Back to Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });
}
