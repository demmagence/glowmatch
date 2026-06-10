import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isOfflineMode = true;
  bool get isOfflineMode => _isOfflineMode;

  // Mock Database in-memory cache for offline/fallback mode
  final List<Map<String, dynamic>> _mockShelf = [];
  final List<Map<String, dynamic>> _mockRoutines = [];
  final List<Map<String, dynamic>> _mockJournalEntries = [];

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
        {
          'id': 'item-1',
          'name': 'GlowBomb',
          'brand': 'Glow Recipe',
          'category': 'Serum',
          'price': 42.00,
          'estimated_uses': 60,
          'remaining_uses': 45,
          'indicator_color': '0xFFE040FB', // Pink
          'image_url': 'https://placehold.co/150/pink/white?text=GlowBomb',
          'ingredients': ['Hyaluronic Acid', 'Niacinamide', 'Watermelon Extract']
        },
        {
          'id': 'item-2',
          'name': 'Centella Sunscreen',
          'brand': 'Skin1004',
          'category': 'Sunscreen',
          'price': 20.00,
          'estimated_uses': 50,
          'remaining_uses': 32,
          'indicator_color': '0xFF64DD17', // Green
          'image_url': 'https://placehold.co/150/lightgreen/white?text=Skin1004',
          'ingredients': ['Centella Asiatica', 'Zinc Oxide', 'Titanium Dioxide']
        },
        {
          'id': 'item-3',
          'name': '5% Panthenol Cream',
          'brand': 'Florasis',
          'category': 'Moisturizer',
          'price': 58.00,
          'estimated_uses': 80,
          'remaining_uses': 75,
          'indicator_color': '0xFFD50000', // Red
          'image_url': 'https://placehold.co/150/purple/white?text=Panthenol',
          'ingredients': ['Panthenol', 'Squalane', 'Ceramide NP']
        }
      ]);
    }

    if (_mockRoutines.isEmpty) {
      _mockRoutines.addAll([
        {
          'id': 'r-1',
          'routine_type': 'AM',
          'step_number': 1,
          'name': 'Gentle Cleanser',
          'description': 'Hydrating milk formula',
          'shelf_item_id': 'item-1',
        },
        {
          'id': 'r-2',
          'routine_type': 'AM',
          'step_number': 2,
          'name': 'Peptide Moisturizer',
          'description': 'Barrier repair complex',
          'shelf_item_id': 'item-3',
        },
        {
          'id': 'r-3',
          'routine_type': 'AM',
          'step_number': 3,
          'name': 'SPF 50+ Sunscreen',
          'description': 'Required: High UV Index',
          'shelf_item_id': 'item-2',
        }
      ]);
    }

    if (_mockJournalEntries.isEmpty) {
      _mockJournalEntries.addAll([
        {
          'id': 'j-1',
          'logged_date': 'Today',
          'skin_score': 84,
          'photo_path': 'assets/skin_today.png',
          'notes': 'Skin barrier feels extremely strong today. Redness has completely gone.'
        },
        {
          'id': 'j-2',
          'logged_date': 'Oct 24',
          'skin_score': 80,
          'photo_path': 'assets/skin_oct24.png',
          'notes': 'Slight irritation around the cheeks. Increased moisturizer.'
        },
        {
          'id': 'j-3',
          'logged_date': 'Oct 17',
          'skin_score': 76,
          'photo_path': 'assets/skin_oct17.png',
          'notes': 'Started new routine steps.'
        }
      ]);
    }
  }

  // --- CRUD API ---

  // SHELF ITEMS
  Future<List<Map<String, dynamic>>> getShelfItems(String userId) async {
    if (_isOfflineMode) {
      return List.from(_mockShelf);
    }
    try {
      final response = await Supabase.instance.client
          .from('skincare_shelf')
          .select()
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return List.from(_mockShelf);
    }
  }

  Future<Map<String, dynamic>> addShelfItem(String userId, Map<String, dynamic> item) async {
    final newItem = {
      ...item,
      'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
          .insert(newItem)
          .select()
          .single();
      return response;
    } catch (e) {
      _mockShelf.add(newItem);
      return newItem;
    }
  }

  Future<Map<String, dynamic>?> decrementShelfItemUses(String itemId) async {
    if (_isOfflineMode) {
      final idx = _mockShelf.indexWhere((x) => x['id'] == itemId);
      if (idx != -1) {
        final currentUses = _mockShelf[idx]['remaining_uses'] as int? ?? 0;
        final newUses = (currentUses - 1).clamp(0, 999999);
        _mockShelf[idx]['remaining_uses'] = newUses;
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
      return response;
    } catch (e) {
      debugPrint('Error decrementing shelf item: $e. Falling back to offline.');
      final idx = _mockShelf.indexWhere((x) => x['id'] == itemId);
      if (idx != -1) {
        final currentUses = _mockShelf[idx]['remaining_uses'] as int? ?? 0;
        final newUses = (currentUses - 1).clamp(0, 999999);
        _mockShelf[idx]['remaining_uses'] = newUses;
        return _mockShelf[idx];
      }
      return null;
    }
  }

  Future<bool> deleteShelfItem(String itemId) async {
    if (_isOfflineMode) {
      _mockShelf.removeWhere((x) => x['id'] == itemId);
      return true;
    }

    try {
      await Supabase.instance.client
          .from('skincare_shelf')
          .delete()
          .eq('id', itemId);
      return true;
    } catch (e) {
      debugPrint('Error deleting shelf item: $e. Falling back to offline.');
      _mockShelf.removeWhere((x) => x['id'] == itemId);
      return true;
    }
  }

  // ROUTINES
  Future<List<Map<String, dynamic>>> getRoutines(String userId, String type) async {
    if (_isOfflineMode) {
      return _mockRoutines.where((r) => r['routine_type'] == type).toList();
    }
    try {
      final response = await Supabase.instance.client
          .from('routines')
          .select()
          .eq('user_id', userId)
          .eq('routine_type', type)
          .order('step_number', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return _mockRoutines.where((r) => r['routine_type'] == type).toList();
    }
  }

  Future<void> addRoutineStep(String userId, Map<String, dynamic> step) async {
    final newStep = {
      ...step,
      'id': step['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
    };
    if (_isOfflineMode) {
      _mockRoutines.add(newStep);
      return;
    }
    try {
      await Supabase.instance.client.from('routines').insert(newStep);
    } catch (e) {
      _mockRoutines.add(newStep);
    }
  }

  // JOURNAL ENTRIES
  Future<List<Map<String, dynamic>>> getJournalEntries(String userId) async {
    if (_isOfflineMode) {
      return List.from(_mockJournalEntries);
    }
    try {
      final response = await Supabase.instance.client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('logged_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return List.from(_mockJournalEntries);
    }
  }

  Future<Map<String, dynamic>> addJournalEntry(String userId, Map<String, dynamic> entry) async {
    final newEntry = {
      ...entry,
      'id': entry['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
    };
    if (_isOfflineMode) {
      _mockJournalEntries.insert(0, newEntry);
      return newEntry;
    }
    try {
      final response = await Supabase.instance.client
          .from('journal_entries')
          .insert(newEntry)
          .select()
          .single();
      return response;
    } catch (e) {
      _mockJournalEntries.insert(0, newEntry);
      return newEntry;
    }
  }
}
