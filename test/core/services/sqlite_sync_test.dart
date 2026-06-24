import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/services/database_helper.dart';
import 'package:glowmatch/core/services/sync_service.dart';
import 'package:glowmatch/core/models/models.dart';

import 'sqlite_sync_test.mocks.dart';

@GenerateMocks([DatabaseHelper, SyncService])
void main() {
  late SupabaseService supabaseService;
  late MockDatabaseHelper mockDbHelper;
  late MockSyncService mockSyncService;

  setUp(() {
    supabaseService = SupabaseService();
    supabaseService.resetForTesting();
    supabaseService.isOfflineMode = false;

    mockDbHelper = MockDatabaseHelper();
    mockSyncService = MockSyncService();

    DatabaseHelper.mockInstance = mockDbHelper;
    SyncService.mockInstance = mockSyncService;
  });

  tearDown(() {
    DatabaseHelper.mockInstance = null;
    SyncService.mockInstance = null;
  });

  group('SupabaseService with SQLite Caching', () {
    final testItem = ShelfItem(
      id: 'test-item-id',
      name: 'Test Product',
      brand: 'Test Brand',
      category: 'Serum',
      price: 15.0,
      estimatedUses: 30,
      remainingUses: 30,
      indicatorColor: '0xFFE040FB',
      ingredients: const ['Water', 'Niacinamide'],
    );

    final testEntry = JournalEntry(
      id: 'test-entry-id',
      loggedDate: 'Jun 24',
      skinScore: 85,
      notes: 'Skin looks clean.',
    );

    test('getShelfItems returns items from SQLite cache and triggers sync', () async {
      when(mockDbHelper.getShelfItems('user-123'))
          .thenAnswer((_) async => [testItem]);
      when(mockSyncService.syncAndFetchShelf('user-123'))
          .thenAnswer((_) async {});

      final result = await supabaseService.getShelfItems('user-123');

      expect(result, isNotEmpty);
      expect(result.first.id, equals('test-item-id'));
      verify(mockDbHelper.getShelfItems('user-123')).called(1);
      verify(mockSyncService.syncAndFetchShelf('user-123')).called(1);
    });

    test('addShelfItem saves to SQLite and queues sync', () async {
      when(mockDbHelper.insertShelfItem(any, any)).thenAnswer((_) async {});
      when(mockDbHelper.queueSyncTask(
        userId: anyNamed('userId'),
        tableName: anyNamed('tableName'),
        operation: anyNamed('operation'),
        itemId: anyNamed('itemId'),
        data: anyNamed('data'),
      )).thenAnswer((_) async {});
      when(mockSyncService.syncQueue('user-123')).thenAnswer((_) async {});

      final result = await supabaseService.addShelfItem('user-123', testItem);

      expect(result.name, equals('Test Product'));
      verify(mockDbHelper.insertShelfItem('user-123', any)).called(1);
      verify(mockDbHelper.queueSyncTask(
        userId: 'user-123',
        tableName: 'skincare_shelf',
        operation: 'INSERT',
        itemId: anyNamed('itemId'),
        data: anyNamed('data'),
      )).called(1);
    });

    test('getJournalEntries returns entries from SQLite cache and triggers sync', () async {
      when(mockDbHelper.getJournalEntries('user-123'))
          .thenAnswer((_) async => [testEntry]);
      when(mockSyncService.syncAndFetchJournal('user-123'))
          .thenAnswer((_) async {});

      final result = await supabaseService.getJournalEntries('user-123');

      expect(result, isNotEmpty);
      expect(result.first.id, equals('test-entry-id'));
      verify(mockDbHelper.getJournalEntries('user-123')).called(1);
      verify(mockSyncService.syncAndFetchJournal('user-123')).called(1);
    });

    test('addJournalEntry saves to SQLite and queues sync', () async {
      when(mockDbHelper.insertJournalEntry(any, any)).thenAnswer((_) async {});
      when(mockDbHelper.queueSyncTask(
        userId: anyNamed('userId'),
        tableName: anyNamed('tableName'),
        operation: anyNamed('operation'),
        itemId: anyNamed('itemId'),
        data: anyNamed('data'),
      )).thenAnswer((_) async {});
      when(mockSyncService.syncQueue('user-123')).thenAnswer((_) async {});

      final result = await supabaseService.addJournalEntry('user-123', testEntry);

      expect(result.skinScore, equals(85));
      verify(mockDbHelper.insertJournalEntry('user-123', any)).called(1);
      verify(mockDbHelper.queueSyncTask(
        userId: 'user-123',
        tableName: 'journal_entries',
        operation: 'INSERT',
        itemId: anyNamed('itemId'),
        data: anyNamed('data'),
      )).called(1);
    });

    test('migrateLocalData calls migrateGuestData and triggers sync', () async {
      when(mockDbHelper.migrateGuestData('old-id', 'new-id'))
          .thenAnswer((_) async {});
      when(mockSyncService.syncQueue('new-id')).thenAnswer((_) async {});

      await supabaseService.migrateLocalData('old-id', 'new-id');

      verify(mockDbHelper.migrateGuestData('old-id', 'new-id')).called(1);
    });
  });
}
