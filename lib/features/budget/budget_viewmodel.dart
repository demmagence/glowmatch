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

  // Predefined or dynamic monthly categories and allocations
  final List<CategoryAllocation> _allocations = [
    CategoryAllocation(category: 'Serums', amount: 154.00, colorHex: '0xFFE040FB'),       // Pink / Purple
    CategoryAllocation(category: 'Moisturizers', amount: 108.00, colorHex: '0xFFE91E63'),  // Neon Pink
    CategoryAllocation(category: 'Cleansers', amount: 80.00, colorHex: '0xFF000000'),      // Black
  ];

  List<CategoryAllocation> get allocations => _allocations;

  // Calculates total monthly spend
  double get totalMonthlySpend {
    return _allocations.fold(0.0, (sum, item) => sum + item.amount);
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
