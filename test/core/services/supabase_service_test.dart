import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';

void main() {
  late SupabaseService service;

  setUp(() async {
    service = SupabaseService();
    service.resetForTesting();
    // Trigger offline/seed mode with placeholder credentials
    await service.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('SupabaseService – offline CRUD', () {
    // ── SHELF ────────────────────────────────────────────────────────────────

    test('getShelfItems returns seeded mock shelf in offline mode', () async {
      final items = await service.getShelfItems('test-user');
      expect(items, isNotEmpty);
      expect(items.any((i) => i['name'] == 'GlowBomb'), isTrue);
    });

    test('addShelfItem persists item to mock shelf and returns it', () async {
      final before = await service.getShelfItems('test-user');
      final result = await service.addShelfItem('test-user', {
        'id': 'new-1',
        'name': 'Test Serum',
        'brand': 'TestBrand',
        'category': 'Serum',
        'price': 25.0,
        'estimated_uses': 30,
        'remaining_uses': 30,
      });
      final after = await service.getShelfItems('test-user');
      expect(result['name'], equals('Test Serum'));
      expect(after.length, equals(before.length + 1));
    });

    test('decrementShelfItemUses reduces remaining_uses by 1', () async {
      // item-1 from seed has remaining_uses = 45
      final updated = await service.decrementShelfItemUses('item-1');
      expect(updated, isNotNull);
      expect(updated!['remaining_uses'], equals(44));
    });

    test('decrementShelfItemUses returns null for unknown id', () async {
      final result = await service.decrementShelfItemUses('no-such-id');
      expect(result, isNull);
    });

    test('deleteShelfItem removes item from mock shelf', () async {
      final before = await service.getShelfItems('test-user');
      final result = await service.deleteShelfItem('item-2');
      final after = await service.getShelfItems('test-user');
      expect(result, isTrue);
      expect(after.length, equals(before.length - 1));
      expect(after.any((i) => i['id'] == 'item-2'), isFalse);
    });

    // ── ROUTINES ─────────────────────────────────────────────────────────────

    test('getRoutines returns AM steps from seeded data', () async {
      final steps = await service.getRoutines('test-user', 'AM');
      expect(steps, isNotEmpty);
      expect(steps.every((s) => s['routine_type'] == 'AM'), isTrue);
    });

    test('getRoutines returns empty list for PM (none seeded)', () async {
      final steps = await service.getRoutines('test-user', 'PM');
      expect(steps, isEmpty);
    });

    test('addRoutineStep persists step to mock routines', () async {
      final before = await service.getRoutines('test-user', 'PM');
      await service.addRoutineStep('test-user', {
        'routine_type': 'PM',
        'step_number': 1,
        'name': 'Night Cream',
        'description': 'Apply before sleep',
      });
      final after = await service.getRoutines('test-user', 'PM');
      expect(after.length, equals(before.length + 1));
      expect(after.any((s) => s['name'] == 'Night Cream'), isTrue);
    });

    // ── JOURNAL ──────────────────────────────────────────────────────────────

    test('getJournalEntries returns seeded journal entries', () async {
      final entries = await service.getJournalEntries('test-user');
      expect(entries, isNotEmpty);
      expect(entries.any((e) => e['skin_score'] == 84), isTrue);
    });

    test('addJournalEntry inserts entry at front of list', () async {
      final before = await service.getJournalEntries('test-user');
      final result = await service.addJournalEntry('test-user', {
        'logged_date': 'Jun 12',
        'skin_score': 90,
        'photo_path': 'assets/test.png',
        'notes': 'Test entry',
      });
      final after = await service.getJournalEntries('test-user');
      expect(result['skin_score'], equals(90));
      expect(after.length, equals(before.length + 1));
      expect(after.first['skin_score'], equals(90));
    });
  });
}
