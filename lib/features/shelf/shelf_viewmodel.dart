import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/models.dart';

class ShelfViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<ShelfItem> _shelfItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';

  List<ShelfItem> get shelfItems => _shelfItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get searchQuery => _searchQuery;

  // Filtered shelf items based on selection and search query
  List<ShelfItem> get filteredItems {
    Iterable<ShelfItem> items = _shelfItems;
    if (_selectedCategoryFilter != 'All') {
      items = items.where((item) => item.category == _selectedCategoryFilter);
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      items = items.where((item) =>
          item.name.toLowerCase().contains(query) ||
          item.brand.toLowerCase().contains(query));
    }
    return items.toList();
  }

  Future<void> fetchShelf(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
}

