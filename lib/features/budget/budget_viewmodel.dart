import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/models.dart';
import '../../core/constants.dart';

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

class SmartAlert {
  final String title;
  final String description;
  final String type; // 'danger', 'warning', 'info'

  SmartAlert({
    required this.title,
    required this.description,
    required this.type,
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

  // Budget Limit
  double _budgetLimit = 150.0;
  double get budgetLimit => _budgetLimit;

  Future<void> loadBudgetLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _budgetLimit = prefs.getDouble('budget_limit') ?? 150.0;
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
  List<ShelfItem> _shelfItems = [];

  List<CategoryAllocation> get allocations => _allocations;
  List<ShelfItem> get shelfItems => _shelfItems;

  // Calculates total monthly spend
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

  // Spending History
  List<double> get spendingHistory {
    return [45.0, 78.0, 62.0, 110.0, 95.0, totalMonthlySpend];
  }

  List<String> get spendingHistoryLabels {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final labels = <String>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      labels.add(months[date.month - 1]);
    }
    return labels;
  }

  // Smart alerts calculation
  List<SmartAlert> get smartAlerts {
    final alerts = <SmartAlert>[];

    // 1. Over budget limit alert
    if (totalMonthlySpend > _budgetLimit) {
      final diff = totalMonthlySpend - _budgetLimit;
      alerts.add(SmartAlert(
        title: 'Skincare Budget Exceeded',
        description: 'Your current spending of \$${totalMonthlySpend.toStringAsFixed(2)} exceeds your monthly limit of \$${_budgetLimit.toStringAsFixed(2)} by \$${diff.toStringAsFixed(2)}.',
        type: 'danger',
      ));
    }
    // 2. Approaching limit alert (used more than 80%)
    else if (totalMonthlySpend > _budgetLimit * 0.8) {
      final pct = (totalMonthlySpend / _budgetLimit * 100).toStringAsFixed(0);
      alerts.add(SmartAlert(
        title: 'Approaching Budget Limit',
        description: 'You have used $pct% of your monthly skincare budget limit (\$${totalMonthlySpend.toStringAsFixed(2)} of \$${_budgetLimit.toStringAsFixed(2)}).',
        type: 'warning',
      ));
    }

    // 3. Low Remaining Uses Alert (Stock Warning)
    for (final item in _shelfItems) {
      if (item.remainingUses <= 5 && item.remainingUses > 0) {
        alerts.add(SmartAlert(
          title: 'Low Uses Remaining: ${item.name}',
          description: 'Only ${item.remainingUses} applications left for ${item.brand.isEmpty ? 'this product' : item.brand}. Repurchasing this item will cost \$${item.price.toStringAsFixed(2)}.',
          type: 'info',
        ));
      }
    }

    // 4. Efficiency Alert (High cost per apply)
    for (final item in _shelfItems) {
      if (item.estimatedUses > 0) {
        final costPerApply = item.price / item.estimatedUses;
        if (costPerApply > 1.50) {
          alerts.add(SmartAlert(
            title: 'High Cost-Per-Apply: ${item.name}',
            description: '${item.name} (${item.brand}) costs \$${costPerApply.toStringAsFixed(2)} per application, which is above the recommended efficiency threshold.',
            type: 'info',
          ));
        }
      }
    }

    return alerts;
  }
}
