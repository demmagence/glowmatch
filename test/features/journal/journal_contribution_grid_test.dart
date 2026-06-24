import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/models/models.dart';
import 'package:glowmatch/features/journal/widgets/journal_contribution_grid.dart';

void main() {
  test('JournalEntry model support for createdAt', () {
    final now = DateTime.now();
    final json = {
      'id': 'j-123',
      'logged_date': 'Today',
      'skin_score': 85,
      'photo_path': 'assets/skin.png',
      'notes': 'Test notes',
      'created_at': now.toIso8601String(),
    };

    final entry = JournalEntry.fromJson(json);
    expect(entry.id, 'j-123');
    expect(entry.loggedDate, 'Today');
    expect(entry.skinScore, 85);
    expect(entry.photoPath, 'assets/skin.png');
    expect(entry.notes, 'Test notes');
    expect(entry.createdAt, isNotNull);
    expect(entry.createdAt!.year, now.year);

    final cloned = entry.copyWith(notes: 'Updated notes');
    expect(cloned.notes, 'Updated notes');
    expect(cloned.createdAt, isNotNull);

    final serialized = entry.toJson();
    expect(serialized['id'], 'j-123');
    expect(serialized['created_at'], now.toIso8601String());
  });

  testWidgets('JournalContributionGrid renders month labels and contribution cells', (tester) async {
    final now = DateTime.now();
    final entries = [
      JournalEntry(
        id: 'j-1',
        loggedDate: 'Today',
        skinScore: 84,
        photoPath: 'assets/skin_today.png',
        notes: 'Redness is gone',
        createdAt: now,
      ),
      JournalEntry(
        id: 'j-2',
        loggedDate: 'Yesterday',
        skinScore: 80,
        photoPath: 'assets/skin_yesterday.png',
        notes: 'Dry skin',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: JournalContributionGrid(entries: entries),
          ),
        ),
      ),
    );

    // Verify title is rendered
    expect(find.text('Glow Activity'), findsOneWidget);

    // Verify weekday labels are rendered
    expect(find.text('M'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);

    // Verify parent scrollable grid exists
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    // Verify tooltip cells exist (which correspond to number of days in the month)
    final tooltipFinder = find.byType(Tooltip);
    final count = tester.widgetList(tooltipFinder).length;
    expect(count >= 28 && count <= 31, isTrue);
  });
}
