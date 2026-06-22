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

class SmartAlert {
  final String title;
  final String description;
  final String type;

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

  String _selectedPeriod = '30'; // Default to 30 days
  String get selectedPeriod => _selectedPeriod;

  void setSelectedPeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      _recalculateAllocations();
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

  List<ShelfItem> get filteredShelfItemsForPeriod {
    if (_selectedPeriod == 'all') {
      return _shelfItems;
    }
    final int days = int.tryParse(_selectedPeriod) ?? 30;
    final now = DateTime.now();
    final threshold = now.subtract(Duration(days: days));
    return _shelfItems.where((item) {
      final date = item.createdAt ?? now;
      return date.isAfter(threshold);
    }).toList();
  }

  double get totalMonthlySpend {
    return _allocations.fold(0.0, (sum, item) => sum + item.amount);
  }

  void updateFromShelf(List<ShelfItem> items) {
    _shelfItems = items;
    _recalculateAllocations();
  }

  void _recalculateAllocations() {
    final Map<String, double> totals = {};
    final itemsToUse = filteredShelfItemsForPeriod;
    for (final item in itemsToUse) {
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
    final now = DateTime.now();
    final history = <double>[];
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthItems = _shelfItems.where((item) {
        final date = item.createdAt ?? now;
        return date.year == targetDate.year && date.month == targetDate.month;
      });
      final sum = monthItems.fold(0.0, (acc, item) => acc + item.price);
      history.add(sum);
    }
    return history;
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

  List<SmartAlert> get smartAlerts {
    final dummyVm = CurrencyViewModel();
    return getSmartAlerts(dummyVm);
  }

  List<SmartAlert> getSmartAlerts(CurrencyViewModel currencyVm) {
    final alerts = <SmartAlert>[];

    final now = DateTime.now();
    final threshold30 = now.subtract(const Duration(days: 30));
    final spend30Days = _shelfItems.where((item) {
      final date = item.createdAt ?? now;
      return date.isAfter(threshold30);
    }).fold(0.0, (sum, item) => sum + item.price);

    if (spend30Days > _budgetLimit) {
      final diff = spend30Days - _budgetLimit;
      alerts.add(
        SmartAlert(
          title: 'Skincare Budget Exceeded',
          description:
              'Your current spending of ${currencyVm.formatPrice(spend30Days)} exceeds your monthly limit of ${currencyVm.formatPrice(_budgetLimit)} by ${currencyVm.formatPrice(diff)}.',
          type: 'danger',
        ),
      );
    } else if (spend30Days > _budgetLimit * 0.8) {
      final pct = (spend30Days / _budgetLimit * 100).toStringAsFixed(0);
      alerts.add(
        SmartAlert(
          title: 'Approaching Budget Limit',
          description:
              'You have used $pct% of your monthly skincare budget limit (${currencyVm.formatPrice(spend30Days)} of ${currencyVm.formatPrice(_budgetLimit)}).',
          type: 'warning',
        ),
      );
    }

    for (final item in _shelfItems) {
      if (item.remainingUses <= 5 && item.remainingUses > 0) {
        alerts.add(
          SmartAlert(
            title: 'Low Uses Remaining: ${item.name}',
            description:
                'Only ${item.remainingUses} applications left for ${item.brand.isEmpty ? 'this product' : item.brand}. Repurchasing this item will cost ${currencyVm.formatPrice(item.price)}.',
            type: 'info',
          ),
        );
      }
    }

    for (final item in _shelfItems) {
      if (item.estimatedUses > 0) {
        final costPerApply = item.price / item.estimatedUses;
        final threshold = currencyVm.convertUSDToIDR(1.50);
        if (costPerApply > threshold) {
          alerts.add(
            SmartAlert(
              title: 'High Cost-Per-Apply: ${item.name}',
              description:
                  '${item.name} (${item.brand}) costs ${currencyVm.formatPrice(costPerApply)} per application, which is above the recommended efficiency threshold.',
              type: 'info',
            ),
          );
        }
      }
    }

    return alerts;
  }
}
