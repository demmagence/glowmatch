import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/widgets/loading_overlay.dart';

void main() {
  group('LoadingOverlay Widget Tests', () {
    testWidgets('always renders child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              child: Text('Always Visible'),
            ),
          ),
        ),
      );

      expect(find.text('Always Visible'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows overlay when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              message: 'Custom Message',
              child: SizedBox(
                width: 300,
                height: 300,
                child: Text('Underneath Child'),
              ),
            ),
          ),
        ),
      );

      // Child is still rendered
      expect(find.text('Underneath Child'), findsOneWidget);

      // Spinner and message are rendered
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Custom Message'), findsOneWidget);
    });
  });
}
