import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/widgets/glowmatch_header.dart';

void main() {
  group('GlowMatchHeader Widget Tests', () {
    testWidgets('renders GlowMatch text and profile button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GlowMatchHeader())),
      );

      final richTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('GlowMatch'),
      );
      expect(richTextFinder, findsOneWidget);

      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });

    testWidgets('calls onProfileTap when profile button is pressed', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlowMatchHeader(
              onProfileTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      final button = find.byType(IconButton);
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
