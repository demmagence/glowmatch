import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';

class ShelfViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _shelfItems = [];
  bool _isLoading = false;
  String _selectedCategoryFilter = 'All';

  List<Map<String, dynamic>> get shelfItems => _shelfItems;
  bool get isLoading => _isLoading;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  // Filtered shelf items based on selection
  List<Map<String, dynamic>> get filteredItems {
    if (_selectedCategoryFilter == 'All') {
      return _shelfItems;
    }
    return _shelfItems
        .where((item) => item['category'] == _selectedCategoryFilter)
        .toList();
  }

  Future<void> fetchShelf(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _shelfItems = await _supabaseService.getShelfItems(userId);
    } catch (e) {
      debugPrint('Error fetching shelf items: $e');
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
  }) async {
    final Map<String, dynamic> item = {
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'estimated_uses': estimatedUses,
      'remaining_uses': estimatedUses,
      'indicator_color': colorHex,
      'ingredients': <String>[],
    };

    try {
      final addedItem = await _supabaseService.addShelfItem(userId, item);
      _shelfItems.add(addedItem);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding shelf product: $e');
    }
  }
}
