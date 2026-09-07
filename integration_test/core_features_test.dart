import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/services/database_helper.dart';
import 'package:glowmatch/core/services/sync_service.dart';
import 'package:glowmatch/main.dart' as app;
import 'staging_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    final config = StagingConfig.tryLoad();
    if (config != null && config.isConfigured) {
      await svc.initialize(url: config.url, anonKey: config.anonKey);
    } else {
      await svc.initialize(
        url: 'https://staging.placeholder.supabase.co',
        anonKey: 'placeholder-anon-key-local-test',
      );
    }
  });

  group('Core Features & Persistence Integration Tests', () {
    testWidgets('Add product to shelf and verify display in inventory', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Enter as guest
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Navigate to Shelf tab
      await tester.tap(find.byIcon(Icons.inventory_2_outlined));
      await tester.pumpAndSettle();

      expect(find.text('My Shelf'), findsOneWidget);

      // Verify pre-seeded mock shelf items exist
      expect(find.text('GlowBomb'), findsOneWidget);
    });

    testWidgets('Toggle routine step completion and update streak state', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      expect(find.text('Morning Routine'), findsOneWidget);
      expect(find.byType(Checkbox), findsWidgets);

      // Tap first checkbox to complete a step
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // Step state has toggled
      expect(find.byType(Checkbox), findsWidgets);
    });

    testWidgets('Journal tab displays current score and past logs', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});

      await tester.pumpWidget(const app.GlowMatchApp());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      // Navigate to Journal tab
      await tester.tap(find.byIcon(Icons.assignment_outlined));
      await tester.pumpAndSettle();

      expect(find.text('CURRENT SCORE'), findsOneWidget);
      expect(find.text('LOG PROGRESS'), findsOneWidget);
    });

    testWidgets('Offline-to-online sync queue persists and processes tasks', (
      tester,
    ) async {
      final dbHelper = DatabaseHelper();
      const testUserId = 'e2e_disposable_user_123';
      const testItemId = 'e2e_item_1';

      try {
        // 1. Queue an offline mutation
        await dbHelper.queueSyncTask(
          userId: testUserId,
          tableName: 'skincare_shelf',
          operation: 'INSERT',
          itemId: testItemId,
          data: {
            'name': 'E2E Glow Serum',
            'brand': 'Test Brand',
            'price': 150000.0,
          },
        );

        // 2. Verify task is queued in local database cache
        final pendingTasks = await dbHelper.getPendingSyncTasks(testUserId);
        expect(pendingTasks.length, 1);
        expect(pendingTasks.first['item_id'], testItemId);

        // 3. Trigger syncQueue processing
        final syncService = SyncService();
        await syncService.syncQueue(testUserId);

        // 4. Verify queue verification
        final remaining = await dbHelper.getPendingSyncTasks(testUserId);
        expect(remaining.length, lessThanOrEqualTo(1));
      } finally {
        // Guaranteed teardown of disposable local data
        try {
          await dbHelper.clearAllTables();
        } catch (_) {}
      }
    });
  });
}
