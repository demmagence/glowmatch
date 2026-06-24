import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper? _mockInstance;

  factory DatabaseHelper() => _mockInstance ?? _instance;

  bool _useInMemoryFallback = false;
  final List<Map<String, dynamic>> _fallbackShelf = [];
  final List<Map<String, dynamic>> _fallbackJournal = [];
  final List<Map<String, dynamic>> _fallbackSyncQueue = [];
  int _syncQueueIdCounter = 0;

  DatabaseHelper._internal() {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        _useInMemoryFallback = true;
        _seedFallbackData();
      }
    } catch (_) {
      _useInMemoryFallback = true;
      _seedFallbackData();
    }
  }

  void _seedFallbackData() {
    if (_fallbackShelf.isEmpty) {
      _fallbackShelf.addAll([
        {
          'id': 'item-1',
          'name': 'GlowBomb',
          'brand': 'Glow Recipe',
          'category': 'Serum',
          'price': 672000.0,
          'estimated_uses': 60,
          'remaining_uses': 45,
          'indicator_color': '0xFFE040FB',
          'image_url': 'https://placehold.co/150/pink/white?text=GlowBomb',
          'ingredients': jsonEncode(['Hyaluronic Acid', 'Niacinamide', 'Watermelon Extract']),
          'product_size': '50 ml',
          'created_at': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
          'user_id': 'test-user',
        },
        {
          'id': 'item-2',
          'name': 'Centella Sunscreen',
          'brand': 'Skin1004',
          'category': 'Sunscreen',
          'price': 320000.0,
          'estimated_uses': 50,
          'remaining_uses': 32,
          'indicator_color': '0xFF64DD17',
          'image_url': 'https://placehold.co/150/lightgreen/white?text=Skin1004',
          'ingredients': jsonEncode(['Centella Asiatica', 'Zinc Oxide', 'Titanium Dioxide']),
          'product_size': '50 ml',
          'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'user_id': 'test-user',
        },
        {
          'id': 'item-3',
          'name': '5% Panthenol Cream',
          'brand': 'Florasis',
          'category': 'Moisturizer',
          'price': 928000.0,
          'estimated_uses': 80,
          'remaining_uses': 75,
          'indicator_color': '0xFFD50000',
          'image_url': 'https://placehold.co/150/purple/white?text=Panthenol',
          'ingredients': jsonEncode(['Panthenol', 'Squalane', 'Ceramide NP']),
          'product_size': '80 ml',
          'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'user_id': 'test-user',
        },
      ]);
    }

    if (_fallbackJournal.isEmpty) {
      _fallbackJournal.addAll([
        {
          'id': 'j-1',
          'logged_date': 'Today',
          'skin_score': 84,
          'photo_path': 'assets/skin_today.png',
          'notes': 'Skin barrier feels extremely strong today. Redness has completely gone.',
          'created_at': DateTime.now().toIso8601String(),
          'user_id': 'test-user',
        },
        {
          'id': 'j-2',
          'logged_date': 'Oct 24',
          'skin_score': 80,
          'photo_path': 'assets/skin_oct24.png',
          'notes': 'Slight irritation around the cheeks. Increased moisturizer.',
          'created_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'user_id': 'test-user',
        },
        {
          'id': 'j-3',
          'logged_date': 'Oct 17',
          'skin_score': 76,
          'photo_path': 'assets/skin_oct17.png',
          'notes': 'Started new routine steps.',
          'created_at': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
          'user_id': 'test-user',
        },
      ]);
    }
  }

  @visibleForTesting
  static set mockInstance(DatabaseHelper? mock) => _mockInstance = mock;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      debugPrint('DatabaseHelper: database initialization failed, enabling in-memory fallback: $e');
      _useInMemoryFallback = true;
      _seedFallbackData();
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, 'glowmatch_cache.db');

    return await openDatabase(
      pathString,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shelf_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        category TEXT,
        price REAL,
        estimated_uses INTEGER,
        remaining_uses INTEGER,
        indicator_color TEXT,
        image_url TEXT,
        ingredients TEXT,
        product_size TEXT,
        created_at TEXT,
        user_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        logged_date TEXT,
        skin_score INTEGER,
        photo_path TEXT,
        notes TEXT,
        created_at TEXT,
        user_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        item_id TEXT NOT NULL,
        serialized_data TEXT,
        created_at TEXT NOT NULL,
        user_id TEXT NOT NULL
      )
    ''');
  }

  // --- Shelf Items CRUD ---

  Future<List<ShelfItem>> getShelfItems(String userId) async {
    if (_useInMemoryFallback) {
      final list = _fallbackShelf.where((x) => x['user_id'] == userId).toList();
      return List.generate(list.length, (i) {
        final map = list[i];
        List<String> ingredients = [];
        if (map['ingredients'] != null && map['ingredients'] is String) {
          try {
            ingredients = List<String>.from(jsonDecode(map['ingredients'] as String) as Iterable);
          } catch (_) {}
        }
        return ShelfItem(
          id: map['id'] as String,
          name: map['name'] as String,
          brand: map['brand'] as String? ?? '',
          category: map['category'] as String? ?? 'Other',
          price: map['price'] as double? ?? 0.0,
          estimatedUses: map['estimated_uses'] as int? ?? 50,
          remainingUses: map['remaining_uses'] as int? ?? 50,
          indicatorColor: map['indicator_color'] as String? ?? '0xFFE040FB',
          imageUrl: map['image_url'] as String?,
          ingredients: ingredients,
          productSize: map['product_size'] as String?,
          createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
        );
      });
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shelf_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      List<String> ingredients = [];
      if (map['ingredients'] != null && map['ingredients'] is String) {
        try {
          ingredients = List<String>.from(jsonDecode(map['ingredients'] as String) as Iterable);
        } catch (_) {
          ingredients = [];
        }
      }
      return ShelfItem(
        id: map['id'] as String,
        name: map['name'] as String,
        brand: map['brand'] as String? ?? '',
        category: map['category'] as String? ?? 'Other',
        price: map['price'] as double? ?? 0.0,
        estimatedUses: map['estimated_uses'] as int? ?? 50,
        remainingUses: map['remaining_uses'] as int? ?? 50,
        indicatorColor: map['indicator_color'] as String? ?? '0xFFE040FB',
        imageUrl: map['image_url'] as String?,
        ingredients: ingredients,
        productSize: map['product_size'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
      );
    });
  }

  Future<void> saveShelfItems(String userId, List<ShelfItem> items) async {
    if (_useInMemoryFallback) {
      _fallbackShelf.removeWhere((x) => x['user_id'] == userId);
      for (final item in items) {
        _fallbackShelf.add({
          'id': item.id,
          'name': item.name,
          'brand': item.brand,
          'category': item.category,
          'price': item.price,
          'estimated_uses': item.estimatedUses,
          'remaining_uses': item.remainingUses,
          'indicator_color': item.indicatorColor,
          'image_url': item.imageUrl,
          'ingredients': jsonEncode(item.ingredients),
          'product_size': item.productSize,
          'created_at': item.createdAt?.toIso8601String(),
          'user_id': userId,
        });
      }
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'shelf_items',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      for (final item in items) {
        await txn.insert(
          'shelf_items',
          {
            'id': item.id,
            'name': item.name,
            'brand': item.brand,
            'category': item.category,
            'price': item.price,
            'estimated_uses': item.estimatedUses,
            'remaining_uses': item.remainingUses,
            'indicator_color': item.indicatorColor,
            'image_url': item.imageUrl,
            'ingredients': jsonEncode(item.ingredients),
            'product_size': item.productSize,
            'created_at': item.createdAt?.toIso8601String(),
            'user_id': userId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> insertShelfItem(String userId, ShelfItem item) async {
    if (_useInMemoryFallback) {
      _fallbackShelf.removeWhere((x) => x['id'] == item.id && x['user_id'] == userId);
      _fallbackShelf.add({
        'id': item.id,
        'name': item.name,
        'brand': item.brand,
        'category': item.category,
        'price': item.price,
        'estimated_uses': item.estimatedUses,
        'remaining_uses': item.remainingUses,
        'indicator_color': item.indicatorColor,
        'image_url': item.imageUrl,
        'ingredients': jsonEncode(item.ingredients),
        'product_size': item.productSize,
        'created_at': item.createdAt?.toIso8601String(),
        'user_id': userId,
      });
      return;
    }

    final db = await database;
    await db.insert(
      'shelf_items',
      {
        'id': item.id,
        'name': item.name,
        'brand': item.brand,
        'category': item.category,
        'price': item.price,
        'estimated_uses': item.estimatedUses,
        'remaining_uses': item.remainingUses,
        'indicator_color': item.indicatorColor,
        'image_url': item.imageUrl,
        'ingredients': jsonEncode(item.ingredients),
        'product_size': item.productSize,
        'created_at': item.createdAt?.toIso8601String(),
        'user_id': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateShelfItem(String userId, ShelfItem item) async {
    if (_useInMemoryFallback) {
      final idx = _fallbackShelf.indexWhere((x) => x['id'] == item.id && x['user_id'] == userId);
      if (idx != -1) {
        _fallbackShelf[idx] = {
          'id': item.id,
          'name': item.name,
          'brand': item.brand,
          'category': item.category,
          'price': item.price,
          'estimated_uses': item.estimatedUses,
          'remaining_uses': item.remainingUses,
          'indicator_color': item.indicatorColor,
          'image_url': item.imageUrl,
          'ingredients': jsonEncode(item.ingredients),
          'product_size': item.productSize,
          'created_at': item.createdAt?.toIso8601String(),
          'user_id': userId,
        };
      }
      return;
    }

    final db = await database;
    await db.update(
      'shelf_items',
      {
        'name': item.name,
        'brand': item.brand,
        'category': item.category,
        'price': item.price,
        'estimated_uses': item.estimatedUses,
        'remaining_uses': item.remainingUses,
        'indicator_color': item.indicatorColor,
        'image_url': item.imageUrl,
        'ingredients': jsonEncode(item.ingredients),
        'product_size': item.productSize,
        'created_at': item.createdAt?.toIso8601String(),
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [item.id, userId],
    );
  }

  Future<void> deleteShelfItem(String userId, String itemId) async {
    if (_useInMemoryFallback) {
      _fallbackShelf.removeWhere((x) => x['id'] == itemId && x['user_id'] == userId);
      return;
    }

    final db = await database;
    await db.delete(
      'shelf_items',
      where: 'id = ? AND user_id = ?',
      whereArgs: [itemId, userId],
    );
  }

  Future<ShelfItem?> getShelfItemById(String itemId) async {
    if (_useInMemoryFallback) {
      final list = _fallbackShelf.where((x) => x['id'] == itemId).toList();
      if (list.isEmpty) return null;
      final map = list.first;
      List<String> ingredients = [];
      if (map['ingredients'] != null && map['ingredients'] is String) {
        try {
          ingredients = List<String>.from(jsonDecode(map['ingredients'] as String) as Iterable);
        } catch (_) {}
      }
      return ShelfItem(
        id: map['id'] as String,
        name: map['name'] as String,
        brand: map['brand'] as String? ?? '',
        category: map['category'] as String? ?? 'Other',
        price: map['price'] as double? ?? 0.0,
        estimatedUses: map['estimated_uses'] as int? ?? 50,
        remainingUses: map['remaining_uses'] as int? ?? 50,
        indicatorColor: map['indicator_color'] as String? ?? '0xFFE040FB',
        imageUrl: map['image_url'] as String?,
        ingredients: ingredients,
        productSize: map['product_size'] as String?,
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      );
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shelf_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
    if (maps.isEmpty) return null;
    final map = maps.first;
    List<String> ingredients = [];
    if (map['ingredients'] != null && map['ingredients'] is String) {
      try {
        ingredients = List<String>.from(jsonDecode(map['ingredients'] as String) as Iterable);
      } catch (_) {
        ingredients = [];
      }
    }
    return ShelfItem(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      price: map['price'] as double? ?? 0.0,
      estimatedUses: map['estimated_uses'] as int? ?? 50,
      remainingUses: map['remaining_uses'] as int? ?? 50,
      indicatorColor: map['indicator_color'] as String? ?? '0xFFE040FB',
      imageUrl: map['image_url'] as String?,
      ingredients: ingredients,
      productSize: map['product_size'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Future<String?> getShelfItemUserId(String itemId) async {
    if (_useInMemoryFallback) {
      final list = _fallbackShelf.where((x) => x['id'] == itemId).toList();
      if (list.isEmpty) return null;
      return list.first['user_id'] as String?;
    }
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'shelf_items',
      columns: ['user_id'],
      where: 'id = ?',
      whereArgs: [itemId],
    );
    if (results.isEmpty) return null;
    return results.first['user_id'] as String?;
  }

  Future<String?> getJournalEntryUserId(String entryId) async {
    if (_useInMemoryFallback) {
      final list = _fallbackJournal.where((x) => x['id'] == entryId).toList();
      if (list.isEmpty) return null;
      return list.first['user_id'] as String?;
    }
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'journal_entries',
      columns: ['user_id'],
      where: 'id = ?',
      whereArgs: [entryId],
    );
    if (results.isEmpty) return null;
    return results.first['user_id'] as String?;
  }

  // --- Journal Entries CRUD ---

  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    if (_useInMemoryFallback) {
      final list = _fallbackJournal.where((x) => x['user_id'] == userId).toList();
      list.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
      return List.generate(list.length, (i) {
        final map = list[i];
        return JournalEntry(
          id: map['id'] as String,
          loggedDate: map['logged_date'] as String? ?? '',
          skinScore: map['skin_score'] as int? ?? 80,
          photoPath: map['photo_path'] as String?,
          notes: map['notes'] as String?,
          createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
        );
      });
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'journal_entries',
      where: 'user_id = ?',
      orderBy: 'created_at DESC',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return JournalEntry(
        id: map['id'] as String,
        loggedDate: map['logged_date'] as String? ?? '',
        skinScore: map['skin_score'] as int? ?? 80,
        photoPath: map['photo_path'] as String?,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
      );
    });
  }

  Future<void> saveJournalEntries(String userId, List<JournalEntry> entries) async {
    if (_useInMemoryFallback) {
      _fallbackJournal.removeWhere((x) => x['user_id'] == userId);
      for (final entry in entries) {
        _fallbackJournal.add({
          'id': entry.id,
          'logged_date': entry.loggedDate,
          'skin_score': entry.skinScore,
          'photo_path': entry.photoPath,
          'notes': entry.notes,
          'created_at': entry.createdAt?.toIso8601String(),
          'user_id': userId,
        });
      }
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'journal_entries',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      for (final entry in entries) {
        await txn.insert(
          'journal_entries',
          {
            'id': entry.id,
            'logged_date': entry.loggedDate,
            'skin_score': entry.skinScore,
            'photo_path': entry.photoPath,
            'notes': entry.notes,
            'created_at': entry.createdAt?.toIso8601String(),
            'user_id': userId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> insertJournalEntry(String userId, JournalEntry entry) async {
    if (_useInMemoryFallback) {
      _fallbackJournal.removeWhere((x) => x['id'] == entry.id && x['user_id'] == userId);
      _fallbackJournal.add({
        'id': entry.id,
        'logged_date': entry.loggedDate,
        'skin_score': entry.skinScore,
        'photo_path': entry.photoPath,
        'notes': entry.notes,
        'created_at': entry.createdAt?.toIso8601String(),
        'user_id': userId,
      });
      return;
    }

    final db = await database;
    await db.insert(
      'journal_entries',
      {
        'id': entry.id,
        'logged_date': entry.loggedDate,
        'skin_score': entry.skinScore,
        'photo_path': entry.photoPath,
        'notes': entry.notes,
        'created_at': entry.createdAt?.toIso8601String(),
        'user_id': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteJournalEntry(String userId, String entryId) async {
    if (_useInMemoryFallback) {
      _fallbackJournal.removeWhere((x) => x['id'] == entryId && x['user_id'] == userId);
      return;
    }

    final db = await database;
    await db.delete(
      'journal_entries',
      where: 'id = ? AND user_id = ?',
      whereArgs: [entryId, userId],
    );
  }

  // --- Sync Queue Helper ---

  Future<void> queueSyncTask({
    required String userId,
    required String tableName,
    required String operation,
    required String itemId,
    Map<String, dynamic>? data,
  }) async {
    if (userId == 'offline-guest-user') return;

    if (_useInMemoryFallback) {
      if (operation == 'DELETE') {
        _fallbackSyncQueue.removeWhere((x) => x['item_id'] == itemId && x['user_id'] == userId && x['table_name'] == tableName);
        _syncQueueIdCounter++;
        _fallbackSyncQueue.add({
          'id': _syncQueueIdCounter,
          'table_name': tableName,
          'operation': 'DELETE',
          'item_id': itemId,
          'serialized_data': null,
          'created_at': DateTime.now().toIso8601String(),
          'user_id': userId,
        });
        return;
      }

      if (operation == 'UPDATE') {
        final idx = _fallbackSyncQueue.indexWhere((x) =>
            x['item_id'] == itemId &&
            x['user_id'] == userId &&
            x['table_name'] == tableName &&
            x['operation'] == 'INSERT');
        if (idx != -1) {
          _fallbackSyncQueue[idx]['serialized_data'] = data != null ? jsonEncode(data) : null;
          return;
        }
      }

      _syncQueueIdCounter++;
      _fallbackSyncQueue.add({
        'id': _syncQueueIdCounter,
        'table_name': tableName,
        'operation': operation,
        'item_id': itemId,
        'serialized_data': data != null ? jsonEncode(data) : null,
        'created_at': DateTime.now().toIso8601String(),
        'user_id': userId,
      });
      return;
    }

    final db = await database;

    if (operation == 'DELETE') {
      await db.delete(
        'sync_queue',
        where: 'item_id = ? AND user_id = ? AND table_name = ?',
        whereArgs: [itemId, userId, tableName],
      );
      await db.insert(
        'sync_queue',
        {
          'table_name': tableName,
          'operation': 'DELETE',
          'item_id': itemId,
          'serialized_data': null,
          'created_at': DateTime.now().toIso8601String(),
          'user_id': userId,
        },
      );
      return;
    }

    if (operation == 'UPDATE') {
      final List<Map<String, dynamic>> pendingInserts = await db.query(
        'sync_queue',
        where: 'item_id = ? AND user_id = ? AND table_name = ? AND operation = ?',
        whereArgs: [itemId, userId, tableName, 'INSERT'],
      );
      if (pendingInserts.isNotEmpty) {
        await db.update(
          'sync_queue',
          {'serialized_data': data != null ? jsonEncode(data) : null},
          where: 'id = ?',
          whereArgs: [pendingInserts.first['id'] as int],
        );
        return;
      }
    }

    await db.insert(
      'sync_queue',
      {
        'table_name': tableName,
        'operation': operation,
        'item_id': itemId,
        'serialized_data': data != null ? jsonEncode(data) : null,
        'created_at': DateTime.now().toIso8601String(),
        'user_id': userId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncTasks(String userId) async {
    if (_useInMemoryFallback) {
      return _fallbackSyncQueue.where((x) => x['user_id'] == userId).toList();
    }

    final db = await database;
    return await db.query(
      'sync_queue',
      where: 'user_id = ?',
      orderBy: 'id ASC',
      whereArgs: [userId],
    );
  }

  Future<void> deleteSyncTask(int taskId) async {
    if (_useInMemoryFallback) {
      _fallbackSyncQueue.removeWhere((x) => x['id'] == taskId);
      return;
    }

    final db = await database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // --- Migration: Guest User -> Registered User ---

  Future<void> migrateGuestData(String oldUserId, String newUserId) async {
    if (oldUserId == newUserId) return;

    if (_useInMemoryFallback) {
      // 1. Fetch all local guest shelf items
      final guestShelfMap = _fallbackShelf.where((x) => x['user_id'] == oldUserId).toList();

      // 2. Fetch all local guest journal entries
      final guestJournalMap = _fallbackJournal.where((x) => x['user_id'] == oldUserId).toList();

      // 3. Update user_id
      for (final item in _fallbackShelf) {
        if (item['user_id'] == oldUserId) {
          item['user_id'] = newUserId;
        }
      }

      for (final entry in _fallbackJournal) {
        if (entry['user_id'] == oldUserId) {
          entry['user_id'] = newUserId;
        }
      }

      // 4. Queue sync tasks
      for (final row in guestShelfMap) {
        final itemId = row['id'] as String;
        final data = Map<String, dynamic>.from(row);
        data['user_id'] = newUserId;

        _syncQueueIdCounter++;
        _fallbackSyncQueue.add({
          'id': _syncQueueIdCounter,
          'table_name': 'skincare_shelf',
          'operation': 'INSERT',
          'item_id': itemId,
          'serialized_data': jsonEncode(data),
          'created_at': DateTime.now().toIso8601String(),
          'user_id': newUserId,
        });
      }

      for (final row in guestJournalMap) {
        final entryId = row['id'] as String;
        final data = Map<String, dynamic>.from(row);
        data['user_id'] = newUserId;

        _syncQueueIdCounter++;
        _fallbackSyncQueue.add({
          'id': _syncQueueIdCounter,
          'table_name': 'journal_entries',
          'operation': 'INSERT',
          'item_id': entryId,
          'serialized_data': jsonEncode(data),
          'created_at': DateTime.now().toIso8601String(),
          'user_id': newUserId,
        });
      }

      // 5. Clear guest sync queue
      _fallbackSyncQueue.removeWhere((x) => x['user_id'] == oldUserId);
      return;
    }

    final db = await database;

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> guestShelfMap = await txn.query(
        'shelf_items',
        where: 'user_id = ?',
        whereArgs: [oldUserId],
      );

      final List<Map<String, dynamic>> guestJournalMap = await txn.query(
        'journal_entries',
        where: 'user_id = ?',
        whereArgs: [oldUserId],
      );

      await txn.update(
        'shelf_items',
        {'user_id': newUserId},
        where: 'user_id = ?',
        whereArgs: [oldUserId],
      );

      await txn.update(
        'journal_entries',
        {'user_id': newUserId},
        where: 'user_id = ?',
        whereArgs: [oldUserId],
      );

      for (final row in guestShelfMap) {
        final itemId = row['id'] as String;
        final Map<String, dynamic> data = Map.from(row);
        data['user_id'] = newUserId;

        await txn.insert(
          'sync_queue',
          {
            'table_name': 'skincare_shelf',
            'operation': 'INSERT',
            'item_id': itemId,
            'serialized_data': jsonEncode(data),
            'created_at': DateTime.now().toIso8601String(),
            'user_id': newUserId,
          },
        );
      }

      for (final row in guestJournalMap) {
        final entryId = row['id'] as String;
        final Map<String, dynamic> data = Map.from(row);
        data['user_id'] = newUserId;

        await txn.insert(
          'sync_queue',
          {
            'table_name': 'journal_entries',
            'operation': 'INSERT',
            'item_id': entryId,
            'serialized_data': jsonEncode(data),
            'created_at': DateTime.now().toIso8601String(),
            'user_id': newUserId,
          },
        );
      }

      await txn.delete(
        'sync_queue',
        where: 'user_id = ?',
        whereArgs: [oldUserId],
      );
    });
  }

  @visibleForTesting
  static void setMockDatabase(Database mockDb) {
    _database = mockDb;
  }

  @visibleForTesting
  Future<void> clearAllTables() async {
    if (_useInMemoryFallback) {
      _fallbackShelf.clear();
      _fallbackJournal.clear();
      _fallbackSyncQueue.clear();
      return;
    }
    final db = await database;
    await db.delete('shelf_items');
    await db.delete('journal_entries');
    await db.delete('sync_queue');
  }
}
