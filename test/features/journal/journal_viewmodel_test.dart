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

  group('JournalViewModel – _formatDate', () {
    test('addEntry stores date in "Mon DD" format', () async {
      await vm.addEntry(
        userId: 'test-user',
        photoPath: 'assets/test.png',
        notes: 'Format check',
      );
      final date = vm.entries.first.loggedDate;

      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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

  group('JournalViewModel – deletion and photo entry', () {
    test('deleteEntry removes the entry', () async {
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
