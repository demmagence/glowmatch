import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/models.dart';
import '../../core/constants.dart';
import '../../core/viewmodels/currency_viewmodel.dart';

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
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  double _budgetLimit = 2460000.0; // Default $150.0 in IDR
  double get budgetLimit => _budgetLimit;

  Future<void> loadBudgetLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      double limit = prefs.getDouble('budget_limit') ?? 2460000.0;
      // Auto-migrate older USD budget limits to IDR
      if (limit < 1000.0) {
        limit = limit * 16400.0;
        await prefs.setDouble('budget_limit', limit);
      }
      _budgetLimit = limit;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading budget limit: $e');
    }
  }

  Future<void> setBudgetLimit(double limit) async {
    _budgetLimit = limit;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('budget_limit', limit);
    } catch (e) {
      debugPrint('Error saving budget limit: $e');
    }
  }

  double _productPrice = 1968000.0; // Default $120.0 in IDR
  int _estimatedUses = 60;

  double get productPrice => _productPrice;
  int get estimatedUses => _estimatedUses;

  double get efficiencyMetric {
    if (_estimatedUses <= 0) return 0.0;
    return _productPrice / _estimatedUses;
  }

  List<CategoryAllocation> _allocations = [];
  List<ShelfItem> _shelfItems = [];

  List<CategoryAllocation> get allocations => _allocations;
  List<ShelfItem> get shelfItems => _shelfItems;

  double get totalMonthlySpend {
    return _allocations.fold(0.0, (sum, item) => sum + item.amount);
  }

  void updateFromShelf(List<ShelfItem> items) {
    _shelfItems = items;
    _recalculateAllocations();
  }

  void _recalculateAllocations() {
    final Map<String, double> totals = {};
    for (final item in _shelfItems) {
      final category = item.category;
      final price = item.price;
      totals[category] = (totals[category] ?? 0.0) + price;
    }

    _allocations = totals.entries.map((entry) {
      final colorHex = AppConstants.categoryColors[entry.key] ?? '0xFF9E9E9E';
      return CategoryAllocation(
        category: entry.key,
        amount: entry.value,
        colorHex: colorHex,
      );
    }).toList();

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

  List<double> get spendingHistory {
    return [
      45.0 * 16400.0,
      78.0 * 16400.0,
      62.0 * 16400.0,
      110.0 * 16400.0,
      95.0 * 16400.0,
      totalMonthlySpend,
    ];
  }

  List<String> get spendingHistoryLabels {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final labels = <String>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      labels.add(months[date.month - 1]);
    }
    return labels;
  }
}

