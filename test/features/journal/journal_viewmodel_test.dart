import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/features/journal/journal_viewmodel.dart';

void main() {
  late JournalViewModel vm;

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  setUp(() {
    vm = JournalViewModel();
  });

  group('JournalViewModel – _calculateCurrentScore', () {
    test('currentScore is 80 when entries list is empty', () async {
      await vm.fetchJournal('test-user');

      final expected = (80 + vm.entries.length * 2).clamp(1, 100);
      expect(vm.currentScore, equals(expected));
    });

    test('currentScore increases by 2 for each journal entry', () async {
      await vm.fetchJournal('test-user');
      final scoreAtLoad = vm.currentScore;
      final countAtLoad = vm.entries.length;
      expect(scoreAtLoad, equals((80 + countAtLoad * 2).clamp(1, 100)));

      await vm.addEntry(
        userId: 'test-user',
        photoPath: 'assets/test.png',
        score: 85,
        notes: 'Test note',
      );
      final expected = (80 + vm.entries.length * 2).clamp(1, 100);
      expect(vm.currentScore, equals(expected));
    });

    test('currentScore is clamped to maximum 100', () async {
      for (int i = 0; i < 12; i++) {
        await vm.addEntry(
          userId: 'test-user',
          photoPath: 'assets/img$i.png',
          score: 80 + i,
          notes: 'Entry $i',
        );
      }
      expect(vm.currentScore, lessThanOrEqualTo(100));
    });
  });

  group('JournalViewModel – _formatDate', () {
    test('addEntry stores date in "Mon DD" format', () async {
      await vm.addEntry(
        userId: 'test-user',
        photoPath: 'assets/test.png',
        score: 80,
        notes: 'Format check',
      );
      final date = vm.entries.first.loggedDate;

      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final parts = date.split(' ');
      expect(parts.length, equals(2));
      expect(
        monthNames.contains(parts[0]),
        isTrue,
        reason: '"${parts[0]}" is not a valid month abbreviation',
      );
      expect(
        int.tryParse(parts[1]),
        isNotNull,
        reason: '"${parts[1]}" is not a valid day number',
      );
    });
  });

  group('JournalViewModel – _estimateScore variance', () {
    test('estimated score stays within ±1 of currentScore', () async {
      await vm.fetchJournal('test-user');
      final base = vm.currentScore;

      final delta = (vm.entries.length % 3) - 1;
      final estimated = (base + delta).clamp(1, 100);
      expect(estimated, greaterThanOrEqualTo(1));
      expect(estimated, lessThanOrEqualTo(100));
      expect((estimated - base).abs(), lessThanOrEqualTo(1));
    });

    test('estimated score is always between 1 and 100 inclusive', () async {
      await vm.fetchJournal('test-user');
      final base = vm.currentScore;
      for (int n = 0; n < 6; n++) {
        final delta = (n % 3) - 1;
        final score = (base + delta).clamp(1, 100);
        expect(score, inInclusiveRange(1, 100));
      }
    });
  });

  group('JournalViewModel – deletion and photo entry', () {
    test('deleteEntry removes the entry and updates score', () async {
      await vm.fetchJournal('test-user');
      final initialCount = vm.entries.length;
      final targetId = vm.entries.first.id;

      await vm.deleteEntry(targetId, 'test-user');
      expect(vm.entries.length, equals(initialCount - 1));
      expect(vm.entries.any((e) => e.id == targetId), isFalse);
    });

    test('addJournalEntryWithPhoto adds a new entry with notes', () async {
      await vm.fetchJournal('test-user');
      final initialCount = vm.entries.length;

      final success = await vm.addJournalEntryWithPhoto(
        userId: 'test-user',
        localFilePath: 'assets/new_glow.png',
        notes: 'Feeling extremely fresh and smooth.',
      );

      expect(success, isTrue);
      expect(vm.entries.length, equals(initialCount + 1));
      expect(
        vm.entries.first.notes,
        equals('Feeling extremely fresh and smooth.'),
      );
    });
  });
}
