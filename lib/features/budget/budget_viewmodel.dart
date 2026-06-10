import 'package:flutter/foundation.dart';

class CategoryAllocation {
  final String category;
  final double amount;
  final String colorHex;

  CategoryAllocation({
    required this.category,
    required this.amount,
    required this.colorHex,
  });
}

class BudgetViewModel extends ChangeNotifier {
  // Calculator inputs
  double _productPrice = 120.00;
  int _estimatedUses = 60;

  double get productPrice => _productPrice;
  int get estimatedUses => _estimatedUses;

  // Calculates the Cost-Per-Apply efficiency metric
  double get efficiencyMetric {
    if (_estimatedUses <= 0) return 0.0;
    return _productPrice / _estimatedUses;
  }

  // Dynamic monthly categories and allocations
  List<CategoryAllocation> _allocations = [];
  List<Map<String, dynamic>> _shelfItems = [];

  List<CategoryAllocation> get allocations => _allocations;
  List<Map<String, dynamic>> get shelfItems => _shelfItems;

  // Calculates total monthly spend
  double get totalMonthlySpend {
    return _allocations.fold(0.0, (sum, item) => sum + item.amount);
  }

  void updateFromShelf(List<Map<String, dynamic>> items) {
    _shelfItems = items;
    _recalculateAllocations();
  }

  void _recalculateAllocations() {
    final Map<String, double> totals = {};
    for (final item in _shelfItems) {
      final category = item['category'] ?? 'Other';
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      totals[category] = (totals[category] ?? 0.0) + price;
    }

    final Map<String, String> categoryColors = {
      'Serum': '0xFFE040FB',      // Purple
      'Sunscreen': '0xFF64DD17',  // Green
      'Moisturizer': '0xFFD50000', // Red
      'Cleanser': '0xFF29B6F6',    // Blue
    };

    _allocations = totals.entries.map((entry) {
      final colorHex = categoryColors[entry.key] ?? '0xFF9E9E9E';
      return CategoryAllocation(
        category: entry.key,
        amount: entry.value,
        colorHex: colorHex,
      );
    }).toList();

    // Sort allocations descending by amount so concentric rings render nicely
    _allocations.sort((a, b) => b.amount.compareTo(a.amount));
    notifyListeners();
  }

  void updateCalculator({double? price, int? uses}) {
    if (price != null) {
      _productPrice = price;
    }
    if (uses != null) {
      _estimatedUses = uses;
    }
    notifyListeners();
  }
}
