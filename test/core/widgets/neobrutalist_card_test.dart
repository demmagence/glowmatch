import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/widgets/neobrutalist_card.dart';

void main() {
  group('NeobrutalistCard Widget Tests', () {
    testWidgets('renders child content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NeobrutalistCard(child: Text('Card Content'))),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('custom styling parameters are reflected', (
      WidgetTester tester,
    ) async {
      const customBg = Colors.yellow;
      const customShadow = Colors.red;
      const customBorderRadius = 10.0;
      const customBorderWidth = 3.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeobrutalistCard(
              backgroundColor: customBg,
              shadowColor: customShadow,
              borderRadius: customBorderRadius,
              borderWidth: customBorderWidth,
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(customBg));
      expect(
        decoration.borderRadius,
        equals(BorderRadius.circular(customBorderRadius)),
      );
      expect(decoration.border!.top.width, equals(customBorderWidth));
      expect(decoration.boxShadow!.first.color, equals(customShadow));
    });

    testWidgets('triggers onTap callback when pressed', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeobrutalistCard(
              onTap: () {
                tapped = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
