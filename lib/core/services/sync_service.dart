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
  SyncService._internal() : _dbHelper = DatabaseHelper(), _taskExecutor = null;

  @visibleForTesting
  SyncService.forTesting({
    required DatabaseHelper databaseHelper,
    required Future<void> Function(Map<String, dynamic>, String) taskExecutor,
  }) : _dbHelper = databaseHelper,
       _taskExecutor = taskExecutor;

  @visibleForTesting
  static set mockInstance(SyncService? mock) => _mockInstance = mock;

  final DatabaseHelper _dbHelper;
  final Future<void> Function(Map<String, dynamic>, String)? _taskExecutor;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<void> syncQueue(String userId) async {
    if (userId == 'offline-guest-user' || userId.isEmpty) return;
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final tasks = await _dbHelper.getPendingSyncTasks(userId);
      if (tasks.isEmpty) return;

      for (final task in tasks) {
        final int taskId = task['id'] as int;
        try {
          if (_taskExecutor != null) {
            await _taskExecutor(task, userId);
          } else {
            await _executeTask(Supabase.instance.client, task, userId);
          }
          await _dbHelper.deleteSyncTask(taskId);
        } on PostgrestException catch (e) {
          debugPrint(
            'SyncService: PostgrestException syncing task $taskId: ${e.message} (code: ${e.code})',
          );
          final retryable = _isNetworkError(e) || _isRetryableServerError(e);
          await _dbHelper.markSyncTaskFailed(
            taskId,
            error: '${e.code ?? 'postgres'}: ${e.message}',
            retryable: retryable,
          );
          if (retryable) {
            break;
          }
        } catch (e) {
          debugPrint('SyncService: Error syncing task $taskId: $e');
          final retryable = _isNetworkError(e);
          await _dbHelper.markSyncTaskFailed(
            taskId,
            error: e.toString(),
            retryable: retryable,
          );
          if (retryable) {
            break;
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> retryFailed(String userId) async {
    await _dbHelper.retryFailedSyncTasks(userId);
    await syncQueue(userId);
  }

  Future<void> _executeTask(
    SupabaseClient client,
    Map<String, dynamic> task,
    String userId,
  ) async {
    final tableName = task['table_name'] as String;
    final operation = task['operation'] as String;
    final itemId = task['item_id'] as String;
    if (operation == 'DELETE') {
      await client.from(tableName).delete().eq('id', itemId);
      return;
    }
    final serializedData = task['serialized_data'] as String?;
    if (serializedData == null) {
      throw const FormatException('Missing task data');
    }
    final data = jsonDecode(serializedData) as Map<String, dynamic>;
    data['user_id'] = userId;
    if (data['ingredients'] is List) {
      data['ingredients'] = List<String>.from(data['ingredients'] as Iterable);
    }
    if (operation == 'INSERT') {
      await client.from(tableName).upsert(data);
    } else if (operation == 'UPDATE') {
      await client.from(tableName).update(data).eq('id', itemId);
    } else {
      throw FormatException('Unsupported sync operation: $operation');
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

      var remoteItems = (response as List)
          .map((x) => ShelfItem.fromJson(x as Map<String, dynamic>))
          .toList();

      remoteItems = await _mergePendingShelfChanges(userId, remoteItems);

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

      var remoteEntries = (response as List)
          .map((x) => JournalEntry.fromJson(x as Map<String, dynamic>))
          .toList();

      remoteEntries = await _mergePendingJournalChanges(userId, remoteEntries);

      // 3. Save remote entries to local SQLite database cache
      await _dbHelper.saveJournalEntries(userId, remoteEntries);
    } catch (e) {
      debugPrint('SyncService: syncAndFetchJournal error fetching remote: $e');
    }
  }

  Future<List<ShelfItem>> _mergePendingShelfChanges(
    String userId,
    List<ShelfItem> remote,
  ) async {
    final tasks = (await _dbHelper.getSyncTasks(
      userId,
    )).where((task) => task['table_name'] == AppConstants.tableSkincareShelf);
    final local = {
      for (final item in await _dbHelper.getShelfItems(userId)) item.id: item,
    };
    final merged = {for (final item in remote) item.id: item};
    for (final task in tasks) {
      final id = task['item_id'] as String;
      if (task['operation'] == 'DELETE') {
        merged.remove(id);
      } else if (local[id] != null) {
        merged[id] = local[id]!;
      }
    }
    return merged.values.toList();
  }

  Future<List<JournalEntry>> _mergePendingJournalChanges(
    String userId,
    List<JournalEntry> remote,
  ) async {
    final tasks = (await _dbHelper.getSyncTasks(
      userId,
    )).where((task) => task['table_name'] == AppConstants.tableJournalEntries);
    final local = {
      for (final entry in await _dbHelper.getJournalEntries(userId))
        entry.id: entry,
    };
    final merged = {for (final entry in remote) entry.id: entry};
    for (final task in tasks) {
      final id = task['item_id'] as String;
      if (task['operation'] == 'DELETE') {
        merged.remove(id);
      } else if (local[id] != null) {
        merged[id] = local[id]!;
      }
    }
    return merged.values.toList();
  }

  bool _isRetryableServerError(PostgrestException error) {
    final code = error.code ?? '';
    return code.startsWith('08') || code.startsWith('53') || code == '57014';
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
