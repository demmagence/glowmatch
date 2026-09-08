import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/models/shelf_item.dart';
import 'package:glowmatch/core/services/database_helper.dart';
import '../../../integration_test/staging_config.dart';

void main() {
  group('StagingConfig Tests', () {
    test('isConfigured is false for empty or placeholder values', () {
      const config1 = StagingConfig(url: '', anonKey: '');
      expect(config1.isConfigured, isFalse);

      const config2 = StagingConfig(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
      expect(config2.isConfigured, isFalse);

      const config3 = StagingConfig(
        url: 'https://YOUR_PROJECT.supabase.co',
        anonKey: 'YOUR_KEY',
      );
      expect(config3.isConfigured, isFalse);
    });

    test('isConfigured is true for real URL and anonKey', () {
      const config = StagingConfig(
        url: 'https://xyzcompany.supabase.co',
        anonKey: 'sample-anon-key-12345',
      );
      expect(config.isConfigured, isTrue);
    });

    test('loadOrThrow fails clearly with TestFailure when not configured', () {
      // In an environment where url is empty, loadOrThrow throws TestFailure
      // StagingConfig.tryLoad() returns existing secrets.json if present
      final config = StagingConfig.tryLoad();
      if (config == null) {
        expect(() => StagingConfig.loadOrThrow(), throwsA(isA<TestFailure>()));
      } else {
        expect(config.isConfigured, isTrue);
        expect(config.url, startsWith('http'));
      }
    });
  });

  group('Targeted Local Cleanup Tests', () {
    test(
      'targeted cleanup removes only scoped test user data while preserving unrelated device cache',
      () async {
        final dbHelper = DatabaseHelper();
        const testUserId = 'e2e_test_user_target_clean';
        const testItemId = 'e2e_shelf_item_target_clean';

        const unrelatedUserId = 'real_user_on_device_456';
        const unrelatedItemId = 'real_shelf_item_on_device_789';

        // 1. Seed unrelated user data (simulating pre-existing cache on device/emulator)
        await dbHelper.saveShelfItems(unrelatedUserId, [
          ShelfItem(
            id: unrelatedItemId,
            name: 'Real User Moisturizer',
            brand: 'Real Brand',
            category: 'Moisturizer',
            price: 50000,
            estimatedUses: 60,
            remainingUses: 60,
            indicatorColor: '0xFF4CAF50',
            ingredients: const [],
          ),
        ]);
        await dbHelper.queueSyncTask(
          userId: unrelatedUserId,
          tableName: 'skincare_shelf',
          operation: 'INSERT',
          itemId: unrelatedItemId,
          data: {'name': 'Real User Moisturizer'},
        );

        // 2. Seed test user data created by an integration test run
        await dbHelper.saveShelfItems(testUserId, [
          ShelfItem(
            id: testItemId,
            name: 'E2E Disposable Toner',
            brand: 'E2E Brand',
            category: 'Toner',
            price: 25000,
            estimatedUses: 30,
            remainingUses: 30,
            indicatorColor: '0xFF2196F3',
            ingredients: const [],
          ),
        ]);
        await dbHelper.queueSyncTask(
          userId: testUserId,
          tableName: 'skincare_shelf',
          operation: 'UPDATE',
          itemId: testItemId,
          data: {'name': 'E2E Disposable Toner'},
        );

        // 3. Verify both exist before cleanup
        final testShelfBefore = await dbHelper.getShelfItems(testUserId);
        final unrelatedShelfBefore = await dbHelper.getShelfItems(
          unrelatedUserId,
        );
        expect(testShelfBefore.any((i) => i.id == testItemId), isTrue);
        expect(
          unrelatedShelfBefore.any((i) => i.id == unrelatedItemId),
          isTrue,
        );

        final testTasksBefore = await dbHelper.getSyncTasks(testUserId);
        final unrelatedTasksBefore = await dbHelper.getSyncTasks(
          unrelatedUserId,
        );
        expect(testTasksBefore.any((t) => t['item_id'] == testItemId), isTrue);
        expect(
          unrelatedTasksBefore.any((t) => t['item_id'] == unrelatedItemId),
          isTrue,
        );

        // 4. Execute targeted teardown scoped strictly to testUserId and testItemId
        await dbHelper.deleteShelfItem(testUserId, testItemId);
        final testTasks = await dbHelper.getSyncTasks(testUserId);
        for (final task in testTasks) {
          final taskId = task['id'];
          final itemId = task['item_id'];
          if (taskId is int &&
              (itemId == testItemId ||
                  (itemId is String && itemId.startsWith('e2e_')))) {
            await dbHelper.deleteSyncTask(taskId);
          }
        }

        // 5. Assert test data was completely removed
        final testShelfAfter = await dbHelper.getShelfItems(testUserId);
        expect(testShelfAfter.any((i) => i.id == testItemId), isFalse);

        final testTasksAfter = await dbHelper.getSyncTasks(testUserId);
        expect(testTasksAfter.any((t) => t['item_id'] == testItemId), isFalse);

        // 6. Assert unrelated user data is strictly PRESERVED
        final unrelatedShelfAfter = await dbHelper.getShelfItems(
          unrelatedUserId,
        );
        expect(unrelatedShelfAfter.any((i) => i.id == unrelatedItemId), isTrue);

        final unrelatedTasksAfter = await dbHelper.getSyncTasks(
          unrelatedUserId,
        );
        expect(
          unrelatedTasksAfter.any((t) => t['item_id'] == unrelatedItemId),
          isTrue,
        );
      },
    );
  });
}
