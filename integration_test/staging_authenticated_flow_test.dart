import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glowmatch/core/services/database_helper.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/services/sync_service.dart';
import 'staging_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late final StagingConfig stagingConfig;
  late final SupabaseService supabaseService;

  // Disposable tracking for teardown
  final List<String> createdItemIds = [];
  String? authenticatedUserId;

  setUpAll(() async {
    // 1. Fail clearly if staging configuration is absent
    stagingConfig = StagingConfig.loadOrThrow();

    // 2. Initialize real Supabase client with non-committed staging secrets
    supabaseService = SupabaseService();
    supabaseService.resetForTesting();
    await supabaseService.initialize(
      url: stagingConfig.url,
      anonKey: stagingConfig.anonKey,
    );
  });

  tearDownAll(() async {
    final client = Supabase.instance.client;
    final dbHelper = DatabaseHelper();

    // 1. Guaranteed teardown of disposable staging data on remote Supabase
    for (final itemId in createdItemIds) {
      try {
        await client.from('skincare_shelf').delete().eq('id', itemId);
      } catch (_) {}
    }

    // 2. Targeted teardown of local SQLite database caches scoped strictly
    // to the test user and disposable e2e_* items created by this suite.
    // Preserves unrelated cached rows on connected devices/emulators.
    if (authenticatedUserId != null) {
      final userId = authenticatedUserId!;

      // Remove only shelf items created by this suite
      for (final itemId in createdItemIds) {
        try {
          await dbHelper.deleteShelfItem(userId, itemId);
        } catch (_) {}
      }

      // Remove only sync queue entries created for this test user / e2e_* items
      try {
        final tasks = await dbHelper.getSyncTasks(userId);
        for (final task in tasks) {
          final taskId = task['id'];
          final itemId = task['item_id'];
          final isTestItem =
              createdItemIds.contains(itemId) ||
              (itemId is String && itemId.startsWith('e2e_'));
          if (taskId is int && isTestItem) {
            await dbHelper.deleteSyncTask(taskId);
          }
        }
      } catch (_) {}
    }

    // 3. Sign out test session
    try {
      await client.auth.signOut();
    } catch (_) {}
  });

  group('Real Authenticated Staging Flow Tests', () {
    testWidgets(
      'Authenticated user performs CRUD, offline sync, and teardown against real Supabase',
      (tester) async {
        final client = Supabase.instance.client;
        final runId = DateTime.now().millisecondsSinceEpoch;

        // --- Step 1: Authentication against Supabase ---
        if (stagingConfig.hasTestCredentials) {
          final authRes = await client.auth.signInWithPassword(
            email: stagingConfig.testEmail!,
            password: stagingConfig.testPassword!,
          );
          expect(authRes.user, isNotNull);
          authenticatedUserId = authRes.user!.id;
        } else {
          final disposableEmail = 'e2e_runner_$runId@glowmatch.local';
          const disposablePassword = 'E2eTestPassword123!_#';

          try {
            final authRes = await client.auth.signUp(
              email: disposableEmail,
              password: disposablePassword,
            );
            if (authRes.user != null) {
              authenticatedUserId = authRes.user!.id;
            }
          } on AuthException catch (e) {
            // If signup requires pre-configured user or hits rate limits,
            // provide actionable failure message
            throw TestFailure(
              'Supabase staging authentication failed: ${e.message} (code: ${e.statusCode}).\n'
              'For staging environments requiring email confirmation or subject to rate limits,\n'
              'supply pre-verified credentials via SUPABASE_TEST_EMAIL and SUPABASE_TEST_PASSWORD\n'
              'in secrets.json or CI secrets.',
            );
          }
        }

        expect(
          authenticatedUserId,
          isNotNull,
          reason: 'Authenticated user ID must be present for staging CRUD',
        );
        final userId = authenticatedUserId!;

        // --- Step 2: Real Authenticated CRUD Operations ---
        final testItemId = 'e2e_shelf_$runId';
        createdItemIds.add(testItemId);

        // CREATE: Insert product into real staging skincare_shelf
        await client.from('skincare_shelf').insert({
          'id': testItemId,
          'user_id': userId,
          'name': 'E2E Disposable Hydrating Toner',
          'brand': 'GlowMatch Staging Lab',
          'category': 'Toner',
          'price': 125000.0,
          'estimated_uses': 45,
          'remaining_uses': 45,
          'indicator_color': '0xFF4CAF50',
          'ingredients': ['Centella Asiatica', 'Hyaluronic Acid'],
          'product_size': '150 ml',
        });

        // READ: Verify item was written to real database
        final selectRes = await client
            .from('skincare_shelf')
            .select()
            .eq('id', testItemId);
        expect(selectRes, isNotEmpty);
        final fetched = (selectRes as List).first as Map<String, dynamic>;
        expect(fetched['name'], 'E2E Disposable Hydrating Toner');
        expect(fetched['remaining_uses'], 45);

        // UPDATE: Mutate property and verify update persistence
        await client
            .from('skincare_shelf')
            .update({'remaining_uses': 44})
            .eq('id', testItemId);

        final updatedRes = await client
            .from('skincare_shelf')
            .select('remaining_uses')
            .eq('id', testItemId)
            .single();
        expect(updatedRes['remaining_uses'], 44);

        // --- Step 3: Offline-to-Online Sync Scenario ---
        final dbHelper = DatabaseHelper();
        final syncService = SyncService();

        // 3a. Queue an offline update while disconnected
        await dbHelper.queueSyncTask(
          userId: userId,
          tableName: 'skincare_shelf',
          operation: 'UPDATE',
          itemId: testItemId,
          data: {
            'id': testItemId,
            'user_id': userId,
            'name': 'E2E Disposable Hydrating Toner (Synced)',
            'remaining_uses': 40,
          },
        );

        final pendingBefore = await dbHelper.getPendingSyncTasks(userId);
        expect(
          pendingBefore.any((t) => t['item_id'] == testItemId),
          isTrue,
          reason: 'Task must be queued in local SQLite storage',
        );

        // 3b. Trigger real syncQueue to flush mutations to Supabase staging
        await syncService.syncQueue(userId);

        // 3c. Verify local queue was cleared upon successful transmission
        final pendingAfter = await dbHelper.getPendingSyncTasks(userId);
        expect(
          pendingAfter.any((t) => t['item_id'] == testItemId),
          isFalse,
          reason: 'Local queue must be cleared after online sync succeeds',
        );

        // 3d. Verify mutation is persisted in remote Supabase
        final syncedRemote = await client
            .from('skincare_shelf')
            .select('name, remaining_uses')
            .eq('id', testItemId)
            .single();
        expect(syncedRemote['name'], 'E2E Disposable Hydrating Toner (Synced)');
        expect(syncedRemote['remaining_uses'], 40);

        // --- Step 4: DELETE (CRUD Cleanup) ---
        // 4a. Remote deletion from Supabase staging
        await client.from('skincare_shelf').delete().eq('id', testItemId);
        final deletedCheck = await client
            .from('skincare_shelf')
            .select('id')
            .eq('id', testItemId);
        expect((deletedCheck as List).isEmpty, isTrue);

        // 4b. Local targeted deletion for shelf item
        await dbHelper.deleteShelfItem(userId, testItemId);
      },
    );
  });
}
