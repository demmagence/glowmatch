import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/models.dart';

class ShelfViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<ShelfItem> _shelfItems = [];
  List<SkincareCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';

  List<ShelfItem> get shelfItems => _shelfItems;
  List<SkincareCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get searchQuery => _searchQuery;

  List<ShelfItem> get filteredItems {
    Iterable<ShelfItem> items = _shelfItems;
    if (_selectedCategoryFilter != 'All') {
      items = items.where((item) => item.category == _selectedCategoryFilter);
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      items = items.where(
        (item) =>
            item.name.toLowerCase().contains(query) ||
            item.brand.toLowerCase().contains(query),
      );
    }
    return items.toList();
  }

  Future<void> fetchShelf(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _supabaseService.getCategories(userId);
      _shelfItems = await _supabaseService.getShelfItems(userId);
    } catch (e) {
      debugPrint('Error fetching shelf items: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addProduct({
    required String userId,
    required String name,
    required String brand,
    required String category,
    required double price,
    required int estimatedUses,
    required String colorHex,
    String? localImagePath,
    List<String>? ingredients,
    String? productSize,
  }) async {
    String? imageUrl;
    if (localImagePath != null && localImagePath.isNotEmpty) {
      try {
        imageUrl = await _supabaseService.uploadProductPhoto(
          userId: userId,
          localFilePath: localImagePath,
        );
      } catch (e) {
        debugPrint('Error uploading product photo: $e');
      }
    }

    final ShelfItem item = ShelfItem(
      id: '',
      name: name,
      brand: brand,
      category: category,
      price: price,
      estimatedUses: estimatedUses,
      remainingUses: estimatedUses,
      indicatorColor: colorHex,
      imageUrl: imageUrl,
      ingredients: ingredients ?? <String>[],
      productSize: productSize,
    );

    try {
      final addedItem = await _supabaseService.addShelfItem(userId, item);
      _shelfItems.add(addedItem);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding shelf product: $e');
    }
  }

  Future<void> editProduct({
    required String itemId,
    required String name,
    required String brand,
    required String category,
    required double price,
    required int estimatedUses,
    required int remainingUses,
    required String colorHex,
    String? currentImageUrl,
    String? localImagePath,
    String? userId,
    List<String>? ingredients,
    String? productSize,
  }) async {
    String? imageUrl = currentImageUrl;
    if (localImagePath != null && localImagePath.isNotEmpty && userId != null) {
      try {
        imageUrl = await _supabaseService.uploadProductPhoto(
          userId: userId,
          localFilePath: localImagePath,
        );
      } catch (e) {
        debugPrint('Error uploading product photo: $e');
      }
    }

    final idx = _shelfItems.indexWhere((x) => x.id == itemId);
    final DateTime? createdAt = idx != -1 ? _shelfItems[idx].createdAt : null;

    final ShelfItem item = ShelfItem(
      id: itemId,
      name: name,
      brand: brand,
      category: category,
      price: price,
      estimatedUses: estimatedUses,
      remainingUses: remainingUses,
      indicatorColor: colorHex,
      imageUrl: imageUrl,
      ingredients: ingredients ?? <String>[],
      productSize: productSize,
      createdAt: createdAt,
    );

    try {
      final updatedItem = await _supabaseService.updateShelfItem(itemId, item);
      if (updatedItem != null) {
        final idx = _shelfItems.indexWhere((x) => x.id == itemId);
        if (idx != -1) {
          _shelfItems[idx] = updatedItem;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error editing shelf product: $e');
    }
  }

  Future<void> useProduct(String itemId) async {
    try {
      final updatedItem = await _supabaseService.decrementShelfItemUses(itemId);
      if (updatedItem != null) {
        final idx = _shelfItems.indexWhere((x) => x.id == itemId);
        if (idx != -1) {
          _shelfItems[idx] = updatedItem;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error decrementing product uses in ViewModel: $e');
    }
  }

  Future<void> deleteProduct(String itemId) async {
    try {
      final success = await _supabaseService.deleteShelfItem(itemId);
      if (success) {
        _shelfItems.removeWhere((x) => x.id == itemId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting product in ViewModel: $e');
    }
  }

  Future<void> addCustomCategory({
    required String userId,
    required String name,
    required String colorHex,
  }) async {
    final cat = SkincareCategory(
      id: '',
      userId: userId,
      name: name,
      color: colorHex,
      isDefault: false,
    );
    try {
      final added = await _supabaseService.addCategory(userId, cat);
      _categories.add(added);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category in ViewModel: $e');
    }
  }

  Future<void> renameCustomCategory({
    required String categoryId,
    required String newName,
    required String colorHex,
  }) async {
    final idx = _categories.indexWhere((x) => x.id == categoryId);
    if (idx != -1) {
      final oldName = _categories[idx].name;
      final updated = _categories[idx].copyWith(name: newName, color: colorHex);
      try {
        final result = await _supabaseService.updateCategory(categoryId, updated);
        if (result != null) {
          _categories[idx] = result;
          for (var i = 0; i < _shelfItems.length; i++) {
            if (_shelfItems[i].category == oldName) {
              final productUpdates = _shelfItems[i].copyWith(
                category: newName,
                indicatorColor: colorHex,
              );
              await _supabaseService.updateShelfItem(_shelfItems[i].id, productUpdates);
              _shelfItems[i] = productUpdates;
            }
          }
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error updating category in ViewModel: $e');
      }
    }
  }

  Future<void> deleteCustomCategory(String categoryId) async {
    final idx = _categories.indexWhere((x) => x.id == categoryId);
    if (idx != -1) {
      final oldName = _categories[idx].name;
      try {
        final success = await _supabaseService.deleteCategory(categoryId);
        if (success) {
          _categories.removeAt(idx);
          for (var i = 0; i < _shelfItems.length; i++) {
            if (_shelfItems[i].category == oldName) {
              final productUpdates = _shelfItems[i].copyWith(category: 'Serum');
              await _supabaseService.updateShelfItem(_shelfItems[i].id, productUpdates);
              _shelfItems[i] = productUpdates;
            }
          }
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error deleting category in ViewModel: $e');
      }
    }
  }
}
