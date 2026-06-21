import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/models/models.dart';

void main() {
  late SupabaseService service;

  setUp(() async {
    service = SupabaseService();
    service.resetForTesting();

    await service.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('SupabaseService – offline CRUD', () {
    test('getShelfItems returns seeded mock shelf in offline mode', () async {
      final items = await service.getShelfItems('test-user');
      expect(items, isNotEmpty);
      expect(items.any((i) => i.name == 'GlowBomb'), isTrue);
    });

    test('addShelfItem persists item to mock shelf and returns it', () async {
      final before = await service.getShelfItems('test-user');
      final result = await service.addShelfItem(
        'test-user',
        ShelfItem(
          id: 'new-1',
          name: 'Test Serum',
          brand: 'TestBrand',
          category: 'Serum',
          price: 25.0,
          estimatedUses: 30,
          remainingUses: 30,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
        ),
      );
      final after = await service.getShelfItems('test-user');
      expect(result.name, equals('Test Serum'));
      expect(after.length, equals(before.length + 1));
    });

    test('addShelfItem sets productSize and auto-populates createdAt if null', () async {
      final result = await service.addShelfItem(
        'test-user',
        ShelfItem(
          id: 'new-size-test',
          name: 'Test Size Serum',
          brand: 'TestBrand',
          category: 'Serum',
          price: 25.0,
          estimatedUses: 30,
          remainingUses: 30,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
          productSize: '100 ml',
        ),
      );
      expect(result.productSize, equals('100 ml'));
      expect(result.createdAt, isNotNull);
    });

    test('decrementShelfItemUses reduces remaining_uses by 1', () async {
      final updated = await service.decrementShelfItemUses('item-1');
      expect(updated, isNotNull);
      expect(updated!.remainingUses, equals(44));
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
      expect(after.any((i) => i.id == 'item-2'), isFalse);
    });

    test('getRoutines returns AM steps from seeded data', () async {
      final steps = await service.getRoutines('test-user', 'AM');
      expect(steps, isNotEmpty);
      expect(steps.every((s) => s.routineType == 'AM'), isTrue);
    });

    test('getRoutines returns PM steps from seeded data (PM seeded)', () async {
      final steps = await service.getRoutines('test-user', 'PM');
      expect(steps, isNotEmpty);
      expect(steps.every((s) => s.routineType == 'PM'), isTrue);
    });

    test('addRoutineStep persists step to mock routines', () async {
      final before = await service.getRoutines('test-user', 'PM');
      await service.addRoutineStep(
        'test-user',
        RoutineStep(
          id: '',
          routineType: 'PM',
          stepNumber: before.length + 1,
          name: 'Night Cream',
          description: 'Apply before sleep',
        ),
      );
      final after = await service.getRoutines('test-user', 'PM');
      expect(after.length, equals(before.length + 1));
      expect(after.any((s) => s.name == 'Night Cream'), isTrue);
    });

    test('getJournalEntries returns seeded journal entries', () async {
      final entries = await service.getJournalEntries('test-user');
      expect(entries, isNotEmpty);
      expect(entries.any((e) => e.skinScore == 84), isTrue);
    });

    test('addJournalEntry inserts entry at front of list', () async {
      final before = await service.getJournalEntries('test-user');
      final result = await service.addJournalEntry(
        'test-user',
        JournalEntry(
          id: '',
          loggedDate: 'Jun 12',
          skinScore: 90,
          photoPath: 'assets/test.png',
          notes: 'Test entry',
        ),
      );
      final after = await service.getJournalEntries('test-user');
      expect(result.skinScore, equals(90));
      expect(after.length, equals(before.length + 1));
      expect(after.first.skinScore, equals(90));
    });
  });
}
