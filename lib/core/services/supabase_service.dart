import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isOfflineMode = true;
  bool get isOfflineMode => _isOfflineMode;

  final List<ShelfItem> _mockShelf = [];
  final List<RoutineStep> _mockRoutines = [];
  final List<JournalEntry> _mockJournalEntries = [];
  final Map<String, StreakData> _mockStreaks = {};
  final List<SkincareCategory> _mockCategories = [];
  final List<Map<String, dynamic>> _mockDailyCompletionLogs = [];
  final List<Map<String, dynamic>> _mockRoutineStepCompletions = [];



  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (url.isEmpty ||
        url.startsWith('YOUR_') ||
        anonKey.isEmpty ||
        anonKey.startsWith('YOUR_')) {
      debugPrint(
        'Supabase: Running in Offline/Mock mode due to placeholder credentials.',
      );
      _isOfflineMode = true;
      _seedMockData();
      return;
    }

    try {
      await Supabase.initialize(url: url, publishableKey: anonKey);
      _isOfflineMode = false;
      debugPrint('Supabase: Successfully initialized in online cloud mode.');
    } catch (e) {
      debugPrint(
        'Supabase initialization failed: $e. Falling back to Offline mode.',
      );
      _isOfflineMode = true;
      _seedMockData();
    }
  }

  Future<User?> getOrCreateUser() async {
    if (_isOfflineMode) {
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      if (session != null) {
        return session.user;
      }

      final AuthResponse response = await client.auth.signInAnonymously();
      return response.user;
    } catch (e) {
      debugPrint('Supabase Auth error: $e. Falling back to offline user.');
      return null;
    }
  }

  void _seedMockData() {
    if (_mockCategories.isEmpty) {
      _mockCategories.addAll([
        SkincareCategory(id: 'cat-1', name: 'Serum', color: '0xFFE040FB', isDefault: true),
        SkincareCategory(id: 'cat-2', name: 'Sunscreen', color: '0xFF64DD17', isDefault: true),
        SkincareCategory(id: 'cat-3', name: 'Moisturizer', color: '0xFFD50000', isDefault: true),
        SkincareCategory(id: 'cat-4', name: 'Cleanser', color: '0xFF29B6F6', isDefault: true),
        SkincareCategory(id: 'cat-5', name: 'Toner', color: '0xFFFFD600', isDefault: true),
        SkincareCategory(id: 'cat-6', name: 'Exfoliant', color: '0xFFFF6D00', isDefault: true),
        SkincareCategory(id: 'cat-7', name: 'Mask', color: '0xFF00BFA5', isDefault: true),
        SkincareCategory(id: 'cat-8', name: 'Eye Cream', color: '0xFFFF4081', isDefault: true),
      ]);
    }

    if (_mockShelf.isEmpty) {
      _mockShelf.addAll([
        ShelfItem(
          id: 'item-1',
          name: 'GlowBomb',
          brand: 'Glow Recipe',
          category: 'Serum',
          price: 672000.0,
          estimatedUses: 60,
          remainingUses: 45,
          indicatorColor: '0xFFE040FB',
          imageUrl: 'https://placehold.co/150/pink/white?text=GlowBomb',
          ingredients: const [
            'Hyaluronic Acid',
            'Niacinamide',
            'Watermelon Extract',
          ],
          productSize: '50 ml',
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        ShelfItem(
          id: 'item-2',
          name: 'Centella Sunscreen',
          brand: 'Skin1004',
          category: 'Sunscreen',
          price: 320000.0,
          estimatedUses: 50,
          remainingUses: 32,
          indicatorColor: '0xFF64DD17',
          imageUrl: 'https://placehold.co/150/lightgreen/white?text=Skin1004',
          ingredients: const [
            'Centella Asiatica',
            'Zinc Oxide',
            'Titanium Dioxide',
          ],
          productSize: '50 ml',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ShelfItem(
          id: 'item-3',
          name: '5% Panthenol Cream',
          brand: 'Florasis',
          category: 'Moisturizer',
          price: 928000.0,
          estimatedUses: 80,
          remainingUses: 75,
          indicatorColor: '0xFFD50000',
          imageUrl: 'https://placehold.co/150/purple/white?text=Panthenol',
          ingredients: const ['Panthenol', 'Squalane', 'Ceramide NP'],
          productSize: '80 ml',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ]);
    }

    if (_mockRoutines.isEmpty) {
      _mockRoutines.addAll([
        RoutineStep(
          id: 'r-1',
          routineType: 'AM',
          stepNumber: 1,
          name: 'Gentle Cleanser',
          description: 'Hydrating milk formula',
          shelfItemId: 'item-1',
        ),
        RoutineStep(
          id: 'r-2',
          routineType: 'AM',
          stepNumber: 2,
          name: 'Peptide Moisturizer',
          description: 'Barrier repair complex',
          shelfItemId: 'item-3',
        ),
        RoutineStep(
          id: 'r-3',
          routineType: 'AM',
          stepNumber: 3,
          name: 'SPF 50+ Sunscreen',
          description: 'Required: High UV Index',
          shelfItemId: 'item-2',
        ),
        RoutineStep(
          id: 'r-pm-1',
          routineType: 'PM',
          stepNumber: 1,
          name: 'Makeup Remover',
          description: 'Cleansing balm formula',
          shelfItemId: 'item-1',
        ),
        RoutineStep(
          id: 'r-pm-2',
          routineType: 'PM',
          stepNumber: 2,
          name: 'Night Serum',
          description: 'Active cell renewal treatment',
          shelfItemId: 'item-1',
        ),
        RoutineStep(
          id: 'r-pm-3',
          routineType: 'PM',
          stepNumber: 3,
          name: 'Sleeping Mask',
          description: 'Overnight deep hydration booster',
          shelfItemId: 'item-3',
        ),
      ]);
    }

    if (_mockJournalEntries.isEmpty) {
      _mockJournalEntries.addAll([
        JournalEntry(
          id: 'j-1',
          loggedDate: 'Today',
          skinScore: 84,
          photoPath: 'assets/skin_today.png',
          notes:
              'Skin barrier feels extremely strong today. Redness has completely gone.',
          createdAt: DateTime.now(),
        ),
        JournalEntry(
          id: 'j-2',
          loggedDate: 'Oct 24',
          skinScore: 80,
          photoPath: 'assets/skin_oct24.png',
          notes: 'Slight irritation around the cheeks. Increased moisturizer.',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        JournalEntry(
          id: 'j-3',
          loggedDate: 'Oct 17',
          skinScore: 76,
          photoPath: 'assets/skin_oct17.png',
          notes: 'Started new routine steps.',
          createdAt: DateTime.now().subtract(const Duration(days: 9)),
        ),
      ]);
    }

    if (_mockDailyCompletionLogs.isEmpty) {
      final now = DateTime.now();
      // Seeding a current 4-day streak ending yesterday
      final dates = [
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
        now.subtract(const Duration(days: 3)),
        now.subtract(const Duration(days: 4)),
        
        // Seeding a past 15-day streak from day 7 to day 21
        now.subtract(const Duration(days: 7)),
        now.subtract(const Duration(days: 8)),
        now.subtract(const Duration(days: 9)),
        now.subtract(const Duration(days: 10)),
        now.subtract(const Duration(days: 11)),
        now.subtract(const Duration(days: 12)),
        now.subtract(const Duration(days: 13)),
        now.subtract(const Duration(days: 14)),
        now.subtract(const Duration(days: 15)),
        now.subtract(const Duration(days: 16)),
        now.subtract(const Duration(days: 17)),
        now.subtract(const Duration(days: 18)),
        now.subtract(const Duration(days: 19)),
        now.subtract(const Duration(days: 20)),
        now.subtract(const Duration(days: 21)),
      ];

      for (final date in dates) {
        _mockDailyCompletionLogs.add({
          'user_id': '', // default user id
          'completion_date': date.toIso8601String().split('T')[0],
        });
      }

      // Also seed user streak data: current streak 4, longest streak 15, total completions 19
      _mockStreaks[''] = StreakData(
        currentStreak: 4,
        longestStreak: 15,
        totalCompletions: 19,
        lastCompletedDate: now.subtract(const Duration(days: 1)),
      );
    }
  }


  void _handlePostgrestException(String operation, PostgrestException e) {
    if (e.code == '42501') {
      debugPrint(
        'Supabase Security: [RLS/Permission Denied] in $operation. Code: ${e.code}, Message: ${e.message}, Details: ${e.details}',
      );
    } else {
      debugPrint(
        'Supabase PostgrestException in $operation. Code: ${e.code}, Message: ${e.message}, Details: ${e.details}',
      );
    }
  }

  void _handleStorageException(String operation, StorageException e) {
    debugPrint(
      'Supabase StorageException in $operation. Code: ${e.statusCode}, Message: ${e.message}',
    );
  }

  void _handleGenericException(String operation, dynamic e) {
    debugPrint('Supabase Generic Exception in $operation: $e');
  }

  Future<List<ShelfItem>> getShelfItems(String userId) async {
    if (_isOfflineMode) {
      return List.from(_mockShelf);
    }
    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableSkincareShelf)
          .select()
          .eq('user_id', userId);
      return (response as List)
          .map((x) => ShelfItem.fromJson(x as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      _handlePostgrestException('getShelfItems', e);
      return List.from(_mockShelf);
    } catch (e) {
      _handleGenericException('getShelfItems', e);
      return List.from(_mockShelf);
    }
  }

  Future<ShelfItem> addShelfItem(String userId, ShelfItem item) async {
    final String id = item.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : item.id;
    final now = DateTime.now();
    final newItem = item.copyWith(
      id: id,
      createdAt: item.createdAt ?? now,
    );
    final newItemMap = {
      ...newItem.toJson(),
      'user_id': userId,
      'created_at': newItem.createdAt!.toIso8601String(),
    };

    if (_isOfflineMode) {
      _mockShelf.add(newItem);
      return newItem;
    }

    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableSkincareShelf)
          .insert(newItemMap)
          .select()
          .single();
      return ShelfItem.fromJson(response);
    } on PostgrestException catch (e) {
      _handlePostgrestException('addShelfItem', e);
      _mockShelf.add(newItem);
      return newItem;
    } catch (e) {
      _handleGenericException('addShelfItem', e);
      _mockShelf.add(newItem);
      return newItem;
    }
  }

  Future<ShelfItem?> updateShelfItem(String itemId, ShelfItem updates) async {
    final newItemMap = {...updates.toJson(), 'id': itemId};

    if (_isOfflineMode) {
      final idx = _mockShelf.indexWhere((x) => x.id == itemId);
      if (idx != -1) {
        _mockShelf[idx] = updates.copyWith(id: itemId);
        return _mockShelf[idx];
      }
      return null;
    }

    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableSkincareShelf)
          .update(newItemMap)
          .eq('id', itemId)
          .select()
          .single();
      return ShelfItem.fromJson(response);
    } on PostgrestException catch (e) {
      _handlePostgrestException('updateShelfItem', e);
      final idx = _mockShelf.indexWhere((x) => x.id == itemId);
      if (idx != -1) {
        _mockShelf[idx] = updates.copyWith(id: itemId);
        return _mockShelf[idx];
      }
      return null;
    } catch (e) {
      _handleGenericException('updateShelfItem', e);
      final idx = _mockShelf.indexWhere((x) => x.id == itemId);
      if (idx != -1) {
        _mockShelf[idx] = updates.copyWith(id: itemId);
        return _mockShelf[idx];
      }
      return null;
    }
  }

  Future<ShelfItem?> decrementShelfItemUses(String itemId) async {
    if (_isOfflineMode) {
      final idx = _mockShelf.indexWhere((x) => x.id == itemId);
      if (idx != -1) {
        final currentUses = _mockShelf[idx].remainingUses;
        final newUses = (currentUses - 1).clamp(0, 999999);
        _mockShelf[idx] = _mockShelf[idx].copyWith(remainingUses: newUses);
        return _mockShelf[idx];
      }
      return null;
    }

    try {
      final currentResponse = await Supabase.instance.client
          .from(AppConstants.tableSkincareShelf)
          .select('remaining_uses')
          .eq('id', itemId)
          .single();
      final currentUses = currentResponse['remaining_uses'] as int? ?? 0;
      final newUses = (currentUses - 1).clamp(0, 999999);

      final response = await Supabase.instance.client
          .from(AppConstants.tableSkincareShelf)
          .update({'remaining_uses': newUses})
          .eq('id', itemId)
          .select()
          .single();
      return ShelfItem.fromJson(response);
    } on PostgrestException catch (e) {
      _handlePostgrestException('decrementShelfItemUses', e);
      final idx = _mockShelf.indexWhere((x) => x.id == itemId);
      if (idx != -1) {
        final currentUses = _mockShelf[idx].remainingUses;
        final newUses = (currentUses - 1).clamp(0, 999999);
        _mockShelf[idx] = _mockShelf[idx].copyWith(remainingUses: newUses);
        return _mockShelf[idx];
      }
      return null;
    } catch (e) {
      _handleGenericException('decrementShelfItemUses', e);
      final idx = _mockShelf.indexWhere((x) => x.id == itemId);
      if (idx != -1) {
        final currentUses = _mockShelf[idx].remainingUses;
        final newUses = (currentUses - 1).clamp(0, 999999);
        _mockShelf[idx] = _mockShelf[idx].copyWith(remainingUses: newUses);
        return _mockShelf[idx];
      }
      return null;
    }
  }

  Future<bool> deleteShelfItem(String itemId) async {
    if (_isOfflineMode) {
      _mockShelf.removeWhere((x) => x.id == itemId);
      return true;
    }

    try {
      await Supabase.instance.client
          .from(AppConstants.tableSkincareShelf)
          .delete()
          .eq('id', itemId);
      return true;
    } on PostgrestException catch (e) {
      _handlePostgrestException('deleteShelfItem', e);
      _mockShelf.removeWhere((x) => x.id == itemId);
      return true;
    } catch (e) {
      _handleGenericException('deleteShelfItem', e);
      _mockShelf.removeWhere((x) => x.id == itemId);
      return true;
    }
  }

  Future<List<SkincareCategory>> getCategories(String userId) async {
    if (_isOfflineMode) {
      return List.from(_mockCategories);
    }
    try {
      final response = await Supabase.instance.client
          .from('skincare_categories')
          .select();
      return (response as List)
          .map((x) => SkincareCategory.fromJson(x as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      _handlePostgrestException('getCategories', e);
      return List.from(_mockCategories);
    } catch (e) {
      _handleGenericException('getCategories', e);
      return List.from(_mockCategories);
    }
  }

  Future<SkincareCategory> addCategory(
    String userId,
    SkincareCategory category,
  ) async {
    final String id = category.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : category.id;
    final newCategory = category.copyWith(
      id: id,
      userId: userId,
      isDefault: false,
    );
    final newCategoryMap = {
      ...newCategory.toJson(),
      'user_id': userId,
    };

    if (_isOfflineMode) {
      _mockCategories.add(newCategory);
      return newCategory;
    }

    try {
      final response = await Supabase.instance.client
          .from('skincare_categories')
          .insert(newCategoryMap)
          .select()
          .single();
      return SkincareCategory.fromJson(response);
    } on PostgrestException catch (e) {
      _handlePostgrestException('addCategory', e);
      _mockCategories.add(newCategory);
      return newCategory;
    } catch (e) {
      _handleGenericException('addCategory', e);
      _mockCategories.add(newCategory);
      return newCategory;
    }
  }

  Future<SkincareCategory?> updateCategory(
    String categoryId,
    SkincareCategory updates,
  ) async {
    final newCategoryMap = {...updates.toJson(), 'id': categoryId};

    if (_isOfflineMode) {
      final idx = _mockCategories.indexWhere((x) => x.id == categoryId);
      if (idx != -1) {
        _mockCategories[idx] = updates.copyWith(id: categoryId);
        return _mockCategories[idx];
      }
      return null;
    }

    try {
      final response = await Supabase.instance.client
          .from('skincare_categories')
          .update(newCategoryMap)
          .eq('id', categoryId)
          .select()
          .single();
      return SkincareCategory.fromJson(response);
    } on PostgrestException catch (e) {
      _handlePostgrestException('updateCategory', e);
      final idx = _mockCategories.indexWhere((x) => x.id == categoryId);
      if (idx != -1) {
        _mockCategories[idx] = updates.copyWith(id: categoryId);
        return _mockCategories[idx];
      }
      return null;
    } catch (e) {
      _handleGenericException('updateCategory', e);
      final idx = _mockCategories.indexWhere((x) => x.id == categoryId);
      if (idx != -1) {
        _mockCategories[idx] = updates.copyWith(id: categoryId);
        return _mockCategories[idx];
      }
      return null;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    if (_isOfflineMode) {
      _mockCategories.removeWhere((x) => x.id == categoryId);
      return true;
    }

    try {
      await Supabase.instance.client
          .from('skincare_categories')
          .delete()
          .eq('id', categoryId);
      return true;
    } on PostgrestException catch (e) {
      _handlePostgrestException('deleteCategory', e);
      _mockCategories.removeWhere((x) => x.id == categoryId);
      return true;
    } catch (e) {
      _handleGenericException('deleteCategory', e);
      _mockCategories.removeWhere((x) => x.id == categoryId);
      return true;
    }
  }

  Future<List<RoutineStep>> getRoutines(String userId, String type) async {
    if (_isOfflineMode) {
      return _mockRoutines.where((r) => r.routineType == type).toList();
    }
    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableRoutines)
          .select()
          .eq('user_id', userId)
          .eq('routine_type', type)
          .order('step_number', ascending: true);
      return (response as List)
          .map((x) => RoutineStep.fromJson(x as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      _handlePostgrestException('getRoutines', e);
      return _mockRoutines.where((r) => r.routineType == type).toList();
    } catch (e) {
      _handleGenericException('getRoutines', e);
      return _mockRoutines.where((r) => r.routineType == type).toList();
    }
  }

  Future<void> addRoutineStep(String userId, RoutineStep step) async {
    final String id = step.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : step.id;
    final newStep = step.copyWith(id: id);
    final newStepMap = {...newStep.toJson(), 'user_id': userId};
    if (_isOfflineMode) {
      _mockRoutines.add(newStep);
      return;
    }
    try {
      await Supabase.instance.client
          .from(AppConstants.tableRoutines)
          .insert(newStepMap);
    } on PostgrestException catch (e) {
      _handlePostgrestException('addRoutineStep', e);
      _mockRoutines.add(newStep);
    } catch (e) {
      _handleGenericException('addRoutineStep', e);
      _mockRoutines.add(newStep);
    }
  }

  Future<void> updateRoutineStep(String userId, RoutineStep step) async {
    final stepMap = {...step.toJson(), 'user_id': userId};
    if (_isOfflineMode) {
      final idx = _mockRoutines.indexWhere((x) => x.id == step.id);
      if (idx != -1) {
        _mockRoutines[idx] = step;
      }
      return;
    }
    try {
      await Supabase.instance.client
          .from(AppConstants.tableRoutines)
          .update(stepMap)
          .eq('id', step.id);
    } on PostgrestException catch (e) {
      _handlePostgrestException('updateRoutineStep', e);
      final idx = _mockRoutines.indexWhere((x) => x.id == step.id);
      if (idx != -1) {
        _mockRoutines[idx] = step;
      }
    } catch (e) {
      _handleGenericException('updateRoutineStep', e);
      final idx = _mockRoutines.indexWhere((x) => x.id == step.id);
      if (idx != -1) {
        _mockRoutines[idx] = step;
      }
    }
  }

  Future<void> deleteRoutineStep(String userId, String stepId) async {
    if (_isOfflineMode) {
      _mockRoutines.removeWhere((x) => x.id == stepId);
      return;
    }
    try {
      await Supabase.instance.client
          .from(AppConstants.tableRoutines)
          .delete()
          .eq('id', stepId);
    } on PostgrestException catch (e) {
      _handlePostgrestException('deleteRoutineStep', e);
      _mockRoutines.removeWhere((x) => x.id == stepId);
    } catch (e) {
      _handleGenericException('deleteRoutineStep', e);
      _mockRoutines.removeWhere((x) => x.id == stepId);
    }
  }

  Future<void> updateRoutineStepsOrder(
    String userId,
    List<RoutineStep> steps,
  ) async {
    if (_isOfflineMode) {
      for (final step in steps) {
        final idx = _mockRoutines.indexWhere((x) => x.id == step.id);
        if (idx != -1) {
          _mockRoutines[idx] = step;
        }
      }
      return;
    }
    try {
      final List<Map<String, dynamic>> stepsMap = steps.map((step) {
        return {...step.toJson(), 'user_id': userId};
      }).toList();

      await Supabase.instance.client
          .from(AppConstants.tableRoutines)
          .upsert(stepsMap);
    } on PostgrestException catch (e) {
      _handlePostgrestException('updateRoutineStepsOrder', e);
      for (final step in steps) {
        final idx = _mockRoutines.indexWhere((x) => x.id == step.id);
        if (idx != -1) {
          _mockRoutines[idx] = step;
        }
      }
    } catch (e) {
      _handleGenericException('updateRoutineStepsOrder', e);
      for (final step in steps) {
        final idx = _mockRoutines.indexWhere((x) => x.id == step.id);
        if (idx != -1) {
          _mockRoutines[idx] = step;
        }
      }
    }
  }

  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    if (_isOfflineMode) {
      return List.from(_mockJournalEntries);
    }
    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableJournalEntries)
          .select()
          .eq('user_id', userId)
          .order('logged_date', ascending: false);
      return (response as List)
          .map((x) => JournalEntry.fromJson(x as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      _handlePostgrestException('getJournalEntries', e);
      return List.from(_mockJournalEntries);
    } catch (e) {
      _handleGenericException('getJournalEntries', e);
      return List.from(_mockJournalEntries);
    }
  }

  Future<JournalEntry> addJournalEntry(
    String userId,
    JournalEntry entry,
  ) async {
    final String id = entry.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : entry.id;
    final now = DateTime.now();
    final newEntry = entry.copyWith(
      id: id,
      createdAt: entry.createdAt ?? now,
    );
    final newEntryMap = {
      ...newEntry.toJson(),
      'user_id': userId,
      'created_at': newEntry.createdAt!.toIso8601String(),
    };
    if (_isOfflineMode) {
      _mockJournalEntries.insert(0, newEntry);
      return newEntry;
    }
    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableJournalEntries)
          .insert(newEntryMap)
          .select()
          .single();
      return JournalEntry.fromJson(response);
    } on PostgrestException catch (e) {
      _handlePostgrestException('addJournalEntry', e);
      _mockJournalEntries.insert(0, newEntry);
      return newEntry;
    } catch (e) {
      _handleGenericException('addJournalEntry', e);
      _mockJournalEntries.insert(0, newEntry);
      return newEntry;
    }
  }

  Future<bool> deleteJournalEntry(String entryId) async {
    if (_isOfflineMode) {
      _mockJournalEntries.removeWhere((x) => x.id == entryId);
      return true;
    }

    try {
      await Supabase.instance.client
          .from(AppConstants.tableJournalEntries)
          .delete()
          .eq('id', entryId);
      return true;
    } on PostgrestException catch (e) {
      _handlePostgrestException('deleteJournalEntry', e);
      _mockJournalEntries.removeWhere((x) => x.id == entryId);
      return true;
    } catch (e) {
      _handleGenericException('deleteJournalEntry', e);
      _mockJournalEntries.removeWhere((x) => x.id == entryId);
      return true;
    }
  }

  Future<StreakData> getStreakData(String userId) async {
    if (_isOfflineMode || userId.isEmpty) {
      final raw = _mockStreaks[userId] ??
          StreakData(currentStreak: 0, longestStreak: 0, totalCompletions: 0);
      return _checkAndResetBrokenStreak(userId, raw);
    }

    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableUserStreaks)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return StreakData(
          currentStreak: 0,
          longestStreak: 0,
          totalCompletions: 0,
        );
      }
      final raw = StreakData.fromJson(response);
      return _checkAndResetBrokenStreak(userId, raw);
    } on PostgrestException catch (e) {
      _handlePostgrestException('getStreakData', e);
      final raw = _mockStreaks[userId] ??
          StreakData(currentStreak: 0, longestStreak: 0, totalCompletions: 0);
      return _checkAndResetBrokenStreak(userId, raw);
    } catch (e) {
      _handleGenericException('getStreakData', e);
      final raw = _mockStreaks[userId] ??
          StreakData(currentStreak: 0, longestStreak: 0, totalCompletions: 0);
      return _checkAndResetBrokenStreak(userId, raw);
    }
  }

  StreakData _checkAndResetBrokenStreak(String userId, StreakData data) {
    if (data.lastCompletedDate == null) return data;

    final now = DateTime.now();
    final last = data.lastCompletedDate!;

    if (!_isSameDay(last, now) && !_isYesterday(last, now)) {
      final resetData = data.copyWith(currentStreak: 0);
      _mockStreaks[userId] = resetData;
      if (!_isOfflineMode && userId.isNotEmpty) {
        _asyncResetStreakInDb(userId);
      }
      return resetData;
    }
    return data;
  }

  Future<void> _asyncResetStreakInDb(String userId) async {
    try {
      await Supabase.instance.client
          .from(AppConstants.tableUserStreaks)
          .update({'current_streak': 0})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error resetting broken streak in DB: $e');
    }
  }

  Future<StreakData> recordRoutineCompletion(String userId) async {
    final now = DateTime.now();
    final current = await getStreakData(userId);

    if (current.lastCompletedDate != null) {
      if (_isSameDay(current.lastCompletedDate!, now)) {
        return current;
      }
    }

    int nextStreak;
    if (current.lastCompletedDate == null) {
      nextStreak = 1;
    } else if (_isYesterday(current.lastCompletedDate!, now)) {
      nextStreak = current.currentStreak + 1;
    } else {
      nextStreak = 1;
    }

    final nextLongest = nextStreak > current.longestStreak
        ? nextStreak
        : current.longestStreak;
    final nextTotal = current.totalCompletions + 1;

    final updated = StreakData(
      currentStreak: nextStreak,
      longestStreak: nextLongest,
      lastCompletedDate: now,
      totalCompletions: nextTotal,
    );

    final completionDateStr = now.toIso8601String().split('T')[0];

    if (_isOfflineMode || userId.isEmpty) {
      _mockStreaks[userId] = updated;
      _mockDailyCompletionLogs.add({
        'user_id': userId,
        'completion_date': completionDateStr,
      });
      return updated;
    }

    try {
      final logMap = {
        'user_id': userId,
        'completion_date': completionDateStr,
      };

      await Supabase.instance.client
          .from(AppConstants.tableDailyCompletionLog)
          .upsert(logMap, onConflict: 'user_id,completion_date');

      final dataMap = {
        'id': userId,
        'user_id': userId,
        'current_streak': nextStreak,
        'longest_streak': nextLongest,
        'last_completed_date': now.toIso8601String(),
        'total_completions': nextTotal,
      };

      final response = await Supabase.instance.client
          .from(AppConstants.tableUserStreaks)
          .upsert(dataMap, onConflict: 'user_id')
          .select()
          .single();

      return StreakData.fromJson(response);
    } on PostgrestException catch (e) {
      _handlePostgrestException('recordRoutineCompletion', e);
      _mockStreaks[userId] = updated;
      _mockDailyCompletionLogs.add({
        'user_id': userId,
        'completion_date': completionDateStr,
      });
      return updated;
    } catch (e) {
      _handleGenericException('recordRoutineCompletion', e);
      _mockStreaks[userId] = updated;
      _mockDailyCompletionLogs.add({
        'user_id': userId,
        'completion_date': completionDateStr,
      });
      return updated;
    }
  }

  Future<List<DateTime>> getDailyCompletionLogs(String userId) async {
    if (_isOfflineMode || userId.isEmpty) {
      final logs = _mockDailyCompletionLogs
          .where((log) => log['user_id'] == userId)
          .map((log) => DateTime.parse(log['completion_date'] as String))
          .toList();
      logs.sort((a, b) => a.compareTo(b));
      return logs;
    }

    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableDailyCompletionLog)
          .select('completion_date')
          .eq('user_id', userId)
          .order('completion_date', ascending: true);

      final List<DateTime> dates = [];
      for (final row in response as List) {
        final dateStr = row['completion_date'] as String;
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          dates.add(date);
        }
      }
      return dates;
    } on PostgrestException catch (e) {
      _handlePostgrestException('getDailyCompletionLogs', e);
      final logs = _mockDailyCompletionLogs
          .where((log) => log['user_id'] == userId)
          .map((log) => DateTime.parse(log['completion_date'] as String))
          .toList();
      logs.sort((a, b) => a.compareTo(b));
      return logs;
    } catch (e) {
      _handleGenericException('getDailyCompletionLogs', e);
      final logs = _mockDailyCompletionLogs
          .where((log) => log['user_id'] == userId)
          .map((log) => DateTime.parse(log['completion_date'] as String))
          .toList();
      logs.sort((a, b) => a.compareTo(b));
      return logs;
    }
  }


  bool _isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year && localA.month == localB.month && localA.day == localB.day;
  }

  bool _isYesterday(DateTime lastDate, DateTime currentDate) {
    final localLast = lastDate.toLocal();
    final localCurrent = currentDate.toLocal();
    final yesterday = localCurrent.subtract(const Duration(days: 1));
    return localLast.year == yesterday.year &&
        localLast.month == yesterday.month &&
        localLast.day == yesterday.day;
  }

  Future<String> uploadJournalPhoto({
    required String userId,
    required String localFilePath,
  }) async {
    if (_isOfflineMode) {
      debugPrint(
        'SupabaseService [OFFLINE]: Returning local path as photo URL.',
      );
      return localFilePath;
    }

    try {
      final file = File(localFilePath);
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      const bucketName = AppConstants.bucketJournalPhotos;

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      debugPrint('SupabaseService: Photo uploaded → $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      _handleStorageException('uploadJournalPhoto', e);
      return localFilePath;
    } catch (e) {
      _handleGenericException('uploadJournalPhoto', e);
      return localFilePath;
    }
  }

  Future<String> uploadProductPhoto({
    required String userId,
    required String localFilePath,
  }) async {
    if (_isOfflineMode) {
      debugPrint(
        'SupabaseService [OFFLINE]: Returning local path as product photo URL.',
      );
      return localFilePath;
    }

    try {
      final file = File(localFilePath);
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      const bucketName = AppConstants.bucketProductPhotos;

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      debugPrint('SupabaseService: Product photo uploaded → $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      _handleStorageException('uploadProductPhoto', e);
      return localFilePath;
    } catch (e) {
      _handleGenericException('uploadProductPhoto', e);
      return localFilePath;
    }
  }

  Future<List<String>> getRoutineStepCompletions(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    if (_isOfflineMode || userId.isEmpty) {
      return _mockRoutineStepCompletions
          .where((row) => row['user_id'] == userId && row['completion_date'] == dateStr)
          .map((row) => row['step_id'] as String)
          .toList();
    }

    try {
      final response = await Supabase.instance.client
          .from(AppConstants.tableRoutineStepCompletions)
          .select('step_id')
          .eq('user_id', userId)
          .eq('completion_date', dateStr);

      final List<String> stepIds = [];
      for (final row in response as List) {
        final stepId = row['step_id'] as String?;
        if (stepId != null) {
          stepIds.add(stepId);
        }
      }
      return stepIds;
    } on PostgrestException catch (e) {
      _handlePostgrestException('getRoutineStepCompletions', e);
      return _mockRoutineStepCompletions
          .where((row) => row['user_id'] == userId && row['completion_date'] == dateStr)
          .map((row) => row['step_id'] as String)
          .toList();
    } catch (e) {
      _handleGenericException('getRoutineStepCompletions', e);
      return _mockRoutineStepCompletions
          .where((row) => row['user_id'] == userId && row['completion_date'] == dateStr)
          .map((row) => row['step_id'] as String)
          .toList();
    }
  }

  Future<void> insertRoutineStepCompletion(String userId, String stepId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    if (_isOfflineMode || userId.isEmpty) {
      final exists = _mockRoutineStepCompletions.any((row) =>
          row['user_id'] == userId &&
          row['step_id'] == stepId &&
          row['completion_date'] == dateStr);
      if (!exists) {
        _mockRoutineStepCompletions.add({
          'user_id': userId,
          'step_id': stepId,
          'completion_date': dateStr,
        });
      }
      return;
    }

    try {
      final data = {
        'user_id': userId,
        'step_id': stepId,
        'completion_date': dateStr,
      };
      await Supabase.instance.client
          .from(AppConstants.tableRoutineStepCompletions)
          .upsert(data, onConflict: 'user_id,step_id,completion_date');
    } on PostgrestException catch (e) {
      _handlePostgrestException('insertRoutineStepCompletion', e);
      final exists = _mockRoutineStepCompletions.any((row) =>
          row['user_id'] == userId &&
          row['step_id'] == stepId &&
          row['completion_date'] == dateStr);
      if (!exists) {
        _mockRoutineStepCompletions.add({
          'user_id': userId,
          'step_id': stepId,
          'completion_date': dateStr,
        });
      }
    } catch (e) {
      _handleGenericException('insertRoutineStepCompletion', e);
      final exists = _mockRoutineStepCompletions.any((row) =>
          row['user_id'] == userId &&
          row['step_id'] == stepId &&
          row['completion_date'] == dateStr);
      if (!exists) {
        _mockRoutineStepCompletions.add({
          'user_id': userId,
          'step_id': stepId,
          'completion_date': dateStr,
        });
      }
    }
  }

  Future<void> deleteRoutineStepCompletion(String userId, String stepId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    if (_isOfflineMode || userId.isEmpty) {
      _mockRoutineStepCompletions.removeWhere((row) =>
          row['user_id'] == userId &&
          row['step_id'] == stepId &&
          row['completion_date'] == dateStr);
      return;
    }

    try {
      await Supabase.instance.client
          .from(AppConstants.tableRoutineStepCompletions)
          .delete()
          .eq('user_id', userId)
          .eq('step_id', stepId)
          .eq('completion_date', dateStr);
    } on PostgrestException catch (e) {
      _handlePostgrestException('deleteRoutineStepCompletion', e);
      _mockRoutineStepCompletions.removeWhere((row) =>
          row['user_id'] == userId &&
          row['step_id'] == stepId &&
          row['completion_date'] == dateStr);
    } catch (e) {
      _handleGenericException('deleteRoutineStepCompletion', e);
      _mockRoutineStepCompletions.removeWhere((row) =>
          row['user_id'] == userId &&
          row['step_id'] == stepId &&
          row['completion_date'] == dateStr);
    }
  }

  @visibleForTesting
  void resetForTesting() {
    _mockShelf.clear();
    _mockRoutines.clear();
    _mockJournalEntries.clear();
    _mockStreaks.clear();
    _mockCategories.clear();
    _mockDailyCompletionLogs.clear();
    _mockRoutineStepCompletions.clear();
    _isOfflineMode = true;
  }



  @visibleForTesting
  void setMockStreak(String userId, StreakData streak) {
    _mockStreaks[userId] = streak;
  }

  @visibleForTesting
  void setMockDailyCompletionLogs(String userId, List<DateTime> dates) {
    _mockDailyCompletionLogs.removeWhere((log) => log['user_id'] == userId);
    for (final date in dates) {
      _mockDailyCompletionLogs.add({
        'user_id': userId,
        'completion_date': date.toIso8601String().split('T')[0],
      });
    }
  }

  @visibleForTesting
  void setMockRoutineStepCompletions(String userId, List<String> stepIds, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    _mockRoutineStepCompletions.removeWhere((row) => row['user_id'] == userId && row['completion_date'] == dateStr);
    for (final stepId in stepIds) {
      _mockRoutineStepCompletions.add({
        'user_id': userId,
        'completion_date': dateStr,
        'step_id': stepId,
      });
    }
  }
}
