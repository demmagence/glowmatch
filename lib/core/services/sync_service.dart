import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../constants.dart';
import 'database_helper.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService? _mockInstance;

  factory SyncService() => _mockInstance ?? _instance;
  SyncService._internal();

  @visibleForTesting
  static set mockInstance(SyncService? mock) => _mockInstance = mock;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<void> syncQueue(String userId) async {
    if (userId == 'offline-guest-user' || userId.isEmpty) return;
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final tasks = await _dbHelper.getPendingSyncTasks(userId);
      if (tasks.isEmpty) return;

      final client = Supabase.instance.client;

      for (final task in tasks) {
        final int taskId = task['id'] as int;
        final String tableName = task['table_name'] as String;
        final String operation = task['operation'] as String;
        final String itemId = task['item_id'] as String;
        final String? serializedData = task['serialized_data'] as String?;

        try {
          if (operation == 'DELETE') {
            await client.from(tableName).delete().eq('id', itemId);
          } else {
            final Map<String, dynamic> data = jsonDecode(serializedData!) as Map<String, dynamic>;
            data['user_id'] = userId;
            
            // Convert ingredients list back to a Postgres array format for insertion
            if (data.containsKey('ingredients') && data['ingredients'] is List) {
              data['ingredients'] = List<String>.from(data['ingredients'] as Iterable);
            }

            if (operation == 'INSERT') {
              await client.from(tableName).insert(data);
            } else if (operation == 'UPDATE') {
              await client.from(tableName).update(data).eq('id', itemId);
            }
          }
          await _dbHelper.deleteSyncTask(taskId);
        } on PostgrestException catch (e) {
          debugPrint('SyncService: PostgrestException syncing task $taskId: ${e.message} (code: ${e.code})');
          if (e.code == '42501') {
            // RLS/Permission error - could be configuration or guest account insert blocked.
            // Discard the task to avoid blocking the queue permanently.
            await _dbHelper.deleteSyncTask(taskId);
          } else if (_isNetworkError(e)) {
            // Stop syncing remaining tasks if we hit a network issue
            break;
          } else {
            // Other Postgres/constraint violations: log and skip so it doesn't block the queue
            await _dbHelper.deleteSyncTask(taskId);
          }
        } catch (e) {
          debugPrint('SyncService: Error syncing task $taskId: $e');
          if (_isNetworkError(e)) {
            break;
          }
          // Discard corrupt/un-processable tasks
          await _dbHelper.deleteSyncTask(taskId);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncAndFetchShelf(String userId) async {
    if (userId == 'offline-guest-user' || userId.isEmpty) return;

    // 1. Process pending offline sync queue
    await syncQueue(userId);

    // 2. Fetch latest items from Supabase
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from(AppConstants.tableSkincareShelf)
          .select()
          .eq('user_id', userId);

      final List<ShelfItem> remoteItems = (response as List)
          .map((x) => ShelfItem.fromJson(x as Map<String, dynamic>))
          .toList();

      // 3. Save remote items to local SQLite database cache
      await _dbHelper.saveShelfItems(userId, remoteItems);
    } catch (e) {
      debugPrint('SyncService: syncAndFetchShelf error fetching remote: $e');
    }
  }

  Future<void> syncAndFetchJournal(String userId) async {
    if (userId == 'offline-guest-user' || userId.isEmpty) return;

    // 1. Process pending offline sync queue
    await syncQueue(userId);

    // 2. Fetch latest entries from Supabase
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from(AppConstants.tableJournalEntries)
          .select()
          .eq('user_id', userId)
          .order('logged_date', ascending: false);

      final List<JournalEntry> remoteEntries = (response as List)
          .map((x) => JournalEntry.fromJson(x as Map<String, dynamic>))
          .toList();

      // 3. Save remote entries to local SQLite database cache
      await _dbHelper.saveJournalEntries(userId, remoteEntries);
    } catch (e) {
      debugPrint('SyncService: syncAndFetchJournal error fetching remote: $e');
    }
  }

  bool _isNetworkError(dynamic e) {
    final str = e.toString().toLowerCase();
    return str.contains('socketexception') ||
        str.contains('clientexception') ||
        str.contains('network') ||
        str.contains('failed host lookup') ||
        str.contains('handshake') ||
        str.contains('timeout') ||
        str.contains('connection failed');
  }
}
