import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/features/auth/confirmation_pending_screen.dart';
import 'package:glowmatch/features/auth/forgot_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final service = SupabaseService();
    service.resetForTesting();
    await service.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  Widget app(Widget child) => ChangeNotifierProvider(
    create: (_) => AuthViewModel(),
    child: MaterialApp(home: child),
  );

  testWidgets('forgot password validates email and reports neutral success', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ForgotPasswordScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('resetEmailField')),
      'user@glowmatch.com',
    );
    await tester.tap(find.byKey(const Key('sendResetButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('If an account exists'), findsOneWidget);
  });

  testWidgets('confirmation pending screen can resend confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const ConfirmationPendingScreen(email: 'user@glowmatch.com')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('resendConfirmationButton')));
    await tester.pumpAndSettle();

    expect(find.text('Confirmation email sent.'), findsOneWidget);
  });
}
