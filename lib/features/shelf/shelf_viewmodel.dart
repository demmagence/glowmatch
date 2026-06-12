import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/models.dart';

class ShelfViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<ShelfItem> _shelfItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategoryFilter = 'All';

  List<ShelfItem> get shelfItems => _shelfItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  // Filtered shelf items based on selection
  List<ShelfItem> get filteredItems {
    if (_selectedCategoryFilter == 'All') {
      return _shelfItems;
    }
    return _shelfItems
        .where((item) => item.category == _selectedCategoryFilter)
        .toList();
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

  Future<void> addProduct({
    required String userId,
    required String name,
    required String brand,
    required String category,
    required double price,
    required int estimatedUses,
    required String colorHex,
    List<String>? ingredients,
  }) async {
    final ShelfItem item = ShelfItem(
      id: '',
      name: name,
      brand: brand,
      category: category,
      price: price,
      estimatedUses: estimatedUses,
      remainingUses: estimatedUses,
      indicatorColor: colorHex,
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
    List<String>? ingredients,
  }) async {
    final ShelfItem item = ShelfItem(
      id: itemId,
      name: name,
      brand: brand,
      category: category,
      price: price,
      estimatedUses: estimatedUses,
      remainingUses: remainingUses,
      indicatorColor: colorHex,
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
