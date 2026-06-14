import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/widgets/error_state_widget.dart';

void main() {
  group('ErrorStateWidget Widget Tests', () {
    testWidgets('renders message and default icon without retry button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders title and optional retry button', (
      WidgetTester tester,
    ) async {
      bool retryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              title: 'Error Title',
              message: 'Failed to sync routines',
              onRetry: () {
                retryClicked = true;
              },
              retryText: 'Try Again',
            ),
          ),
        ),
      );

      expect(find.text('Error Title'), findsOneWidget);
      expect(find.text('Failed to sync routines'), findsOneWidget);

      final retryBtn = find.text('Try Again');
      expect(retryBtn, findsOneWidget);

      await tester.tap(retryBtn);
      await tester.pump();

      expect(retryClicked, isTrue);
    });
  });
}
