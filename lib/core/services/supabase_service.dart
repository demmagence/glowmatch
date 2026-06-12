import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isOfflineMode = true;
  bool get isOfflineMode => _isOfflineMode;

  // Mock Database in-memory cache for offline/fallback mode
  final List<ShelfItem> _mockShelf = [];
  final List<RoutineStep> _mockRoutines = [];
  final List<JournalEntry> _mockJournalEntries = [];

  // Initialize Supabase. If credentials are empty/default, we run in Offline/Fallback Mode.
  Future<void> initialize({required String url, required String anonKey}) async {
    if (url.isEmpty || url.startsWith('YOUR_') || anonKey.isEmpty || anonKey.startsWith('YOUR_')) {
      debugPrint('Supabase: Running in Offline/Mock mode due to placeholder credentials.');
      _isOfflineMode = true;
      _seedMockData();
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey, // ignore: deprecated_member_use
      );
      _isOfflineMode = false;
      debugPrint('Supabase: Successfully initialized in online cloud mode.');
    } catch (e) {
      debugPrint('Supabase initialization failed: $e. Falling back to Offline mode.');
      _isOfflineMode = true;
      _seedMockData();
    }
  }

  // Check if user is authenticated, otherwise perform anonymous sign-in
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
      // Attempt anonymous sign in
      final AuthResponse response = await client.auth.signInAnonymously();
      return response.user;
    } catch (e) {
      debugPrint('Supabase Auth error: $e. Falling back to offline user.');
      return null;
    }
  }

  // Seed mock data for stunning first impression on startup
  void _seedMockData() {
    if (_mockShelf.isEmpty) {
      _mockShelf.addAll([
        ShelfItem(
          id: 'item-1',
          name: 'GlowBomb',
          brand: 'Glow Recipe',
          category: 'Serum',
          price: 42.00,
          estimatedUses: 60,
          remainingUses: 45,
          indicatorColor: '0xFFE040FB', // Pink
          imageUrl: 'https://placehold.co/150/pink/white?text=GlowBomb',
          ingredients: const ['Hyaluronic Acid', 'Niacinamide', 'Watermelon Extract'],
        ),
        ShelfItem(
          id: 'item-2',
          name: 'Centella Sunscreen',
          brand: 'Skin1004',
          category: 'Sunscreen',
          price: 20.00,
          estimatedUses: 50,
          remainingUses: 32,
          indicatorColor: '0xFF64DD17', // Green
          imageUrl: 'https://placehold.co/150/lightgreen/white?text=Skin1004',
          ingredients: const ['Centella Asiatica', 'Zinc Oxide', 'Titanium Dioxide'],
        ),
        ShelfItem(
          id: 'item-3',
          name: '5% Panthenol Cream',
          brand: 'Florasis',
          category: 'Moisturizer',
          price: 58.00,
          estimatedUses: 80,
          remainingUses: 75,
          indicatorColor: '0xFFD50000', // Red
          imageUrl: 'https://placehold.co/150/purple/white?text=Panthenol',
          ingredients: const ['Panthenol', 'Squalane', 'Ceramide NP'],
        )
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
        )
      ]);
    }

    if (_mockJournalEntries.isEmpty) {
      _mockJournalEntries.addAll([
        JournalEntry(
          id: 'j-1',
          loggedDate: 'Today',
          skinScore: 84,
          photoPath: 'assets/skin_today.png',
          notes: 'Skin barrier feels extremely strong today. Redness has completely gone.',
        ),
        JournalEntry(
          id: 'j-2',
          loggedDate: 'Oct 24',
          skinScore: 80,
          photoPath: 'assets/skin_oct24.png',
          notes: 'Slight irritation around the cheeks. Increased moisturizer.',
        ),
        JournalEntry(
          id: 'j-3',
          loggedDate: 'Oct 17',
          skinScore: 76,
          photoPath: 'assets/skin_oct17.png',
          notes: 'Started new routine steps.',
        )
      ]);
    }
  }

  // --- Exception Helpers ---

  void _handlePostgrestException(String operation, PostgrestException e) {
    if (e.code == '42501') {
      debugPrint('Supabase Security: [RLS/Permission Denied] in $operation. Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
    } else {
      debugPrint('Supabase PostgrestException in $operation. Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
    }
  }

  void _handleStorageException(String operation, StorageException e) {
    debugPrint('Supabase StorageException in $operation. Code: ${e.statusCode}, Message: ${e.message}');
  }

  void _handleGenericException(String operation, dynamic e) {
    debugPrint('Supabase Generic Exception in $operation: $e');
  }

  // --- CRUD API ---

  // SHELF ITEMS
  Future<List<ShelfItem>> getShelfItems(String userId) async {
    if (_isOfflineMode) {
      return List.from(_mockShelf);
    }
    try {
      final response = await Supabase.instance.client
          .from('skincare_shelf')
          .select()
          .eq('user_id', userId);
      return (response as List).map((x) => ShelfItem.fromJson(x as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      _handlePostgrestException('getShelfItems', e);
      return List.from(_mockShelf);
    } catch (e) {
      _handleGenericException('getShelfItems', e);
      return List.from(_mockShelf);
    }
  }

  Future<ShelfItem> addShelfItem(String userId, ShelfItem item) async {
    final String id = item.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : item.id;
    final newItem = item.copyWith(id: id);
    final newItemMap = {
      ...newItem.toJson(),
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    if (_isOfflineMode) {
      _mockShelf.add(newItem);
      return newItem;
    }

    try {
      final response = await Supabase.instance.client
          .from('skincare_shelf')
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
          .from('skincare_shelf')
          .select('remaining_uses')
          .eq('id', itemId)
          .single();
      final currentUses = currentResponse['remaining_uses'] as int? ?? 0;
      final newUses = (currentUses - 1).clamp(0, 999999);

      final response = await Supabase.instance.client
          .from('skincare_shelf')
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
          .from('skincare_shelf')
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

  // ROUTINES
  Future<List<RoutineStep>> getRoutines(String userId, String type) async {
    if (_isOfflineMode) {
      return _mockRoutines.where((r) => r.routineType == type).toList();
    }
    try {
      final response = await Supabase.instance.client
          .from('routines')
          .select()
          .eq('user_id', userId)
          .eq('routine_type', type)
          .order('step_number', ascending: true);
      return (response as List).map((x) => RoutineStep.fromJson(x as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      _handlePostgrestException('getRoutines', e);
      return _mockRoutines.where((r) => r.routineType == type).toList();
    } catch (e) {
      _handleGenericException('getRoutines', e);
      return _mockRoutines.where((r) => r.routineType == type).toList();
    }
  }

  Future<void> addRoutineStep(String userId, RoutineStep step) async {
    final String id = step.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : step.id;
    final newStep = step.copyWith(id: id);
    final newStepMap = {
      ...newStep.toJson(),
      'user_id': userId,
    };
    if (_isOfflineMode) {
      _mockRoutines.add(newStep);
      return;
    }
    try {
      await Supabase.instance.client.from('routines').insert(newStepMap);
    } on PostgrestException catch (e) {
      _handlePostgrestException('addRoutineStep', e);
      _mockRoutines.add(newStep);
    } catch (e) {
      _handleGenericException('addRoutineStep', e);
      _mockRoutines.add(newStep);
    }
  }

  // JOURNAL ENTRIES
  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    if (_isOfflineMode) {
      return List.from(_mockJournalEntries);
    }
    try {
      final response = await Supabase.instance.client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('logged_date', ascending: false);
      return (response as List).map((x) => JournalEntry.fromJson(x as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      _handlePostgrestException('getJournalEntries', e);
      return List.from(_mockJournalEntries);
    } catch (e) {
      _handleGenericException('getJournalEntries', e);
      return List.from(_mockJournalEntries);
    }
  }

  Future<JournalEntry> addJournalEntry(String userId, JournalEntry entry) async {
    final String id = entry.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : entry.id;
    final newEntry = entry.copyWith(id: id);
    final newEntryMap = {
      ...newEntry.toJson(),
      'user_id': userId,
    };
    if (_isOfflineMode) {
      _mockJournalEntries.insert(0, newEntry);
      return newEntry;
    }
    try {
      final response = await Supabase.instance.client
          .from('journal_entries')
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

  // STORAGE: Upload journal photo to Supabase Storage bucket
  Future<String> uploadJournalPhoto({
    required String userId,
    required String localFilePath,
  }) async {
    // Offline mode: just return local file path so UI can display it
    if (_isOfflineMode) {
      debugPrint('SupabaseService [OFFLINE]: Returning local path as photo URL.');
      return localFilePath;
    }

    try {
      final file = File(localFilePath);
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      const bucketName = 'journal-photos';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
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
}
