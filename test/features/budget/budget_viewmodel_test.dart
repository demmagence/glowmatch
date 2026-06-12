import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/features/budget/budget_viewmodel.dart';

void main() {
  group('BudgetViewModel', () {
    late BudgetViewModel vm;

    setUp(() => vm = BudgetViewModel());

    // ── efficiencyMetric ──────────────────────────────────────────────────

    test('efficiencyMetric: 120 / 60 = 2.00', () {
      // Default values are price=120, uses=60
      expect(vm.efficiencyMetric, closeTo(2.00, 0.001));
    });

    test('efficiencyMetric: 50 / 25 = 2.00', () {
      vm.updateCalculator(price: 50.0, uses: 25);
      expect(vm.efficiencyMetric, closeTo(2.00, 0.001));
    });

    test('efficiencyMetric returns 0.0 when uses is 0', () {
      vm.updateCalculator(uses: 0);
      expect(vm.efficiencyMetric, equals(0.0));
    });

    test('efficiencyMetric: 42 / 60 ≈ 0.70', () {
      vm.updateCalculator(price: 42.0, uses: 60);
      expect(vm.efficiencyMetric, closeTo(0.70, 0.001));
    });

    // ── updateFromShelf / allocation grouping ────────────────────────────

    test('updateFromShelf groups items by category and sums amounts', () {
      vm.updateFromShelf([
        {'category': 'Serum', 'price': 42.0},
        {'category': 'Serum', 'price': 18.0},
        {'category': 'Moisturizer', 'price': 58.0},
      ]);

      final serum = vm.allocations.firstWhere((a) => a.category == 'Serum');
      final moist = vm.allocations.firstWhere((a) => a.category == 'Moisturizer');
      expect(serum.amount, closeTo(60.0, 0.001));
      expect(moist.amount, closeTo(58.0, 0.001));
    });

    test('updateFromShelf assigns correct colorHex per category', () {
      vm.updateFromShelf([
        {'category': 'Sunscreen', 'price': 20.0},
        {'category': 'Cleanser', 'price': 15.0},
      ]);

      final sun = vm.allocations.firstWhere((a) => a.category == 'Sunscreen');
      final clean = vm.allocations.firstWhere((a) => a.category == 'Cleanser');
      expect(sun.colorHex, equals('0xFF64DD17'));
      expect(clean.colorHex, equals('0xFF29B6F6'));
    });

    test('updateFromShelf sorts allocations descending by amount', () {
      vm.updateFromShelf([
        {'category': 'Cleanser', 'price': 10.0},
        {'category': 'Moisturizer', 'price': 58.0},
        {'category': 'Serum', 'price': 42.0},
      ]);

      final amounts = vm.allocations.map((a) => a.amount).toList();
      for (int i = 0; i < amounts.length - 1; i++) {
        expect(amounts[i] >= amounts[i + 1], isTrue);
      }
    });

    // ── totalMonthlySpend ─────────────────────────────────────────────────

    test('totalMonthlySpend sums all allocation amounts', () {
      vm.updateFromShelf([
        {'category': 'Serum', 'price': 42.0},
        {'category': 'Sunscreen', 'price': 20.0},
        {'category': 'Moisturizer', 'price': 58.0},
      ]);
      expect(vm.totalMonthlySpend, closeTo(120.0, 0.001));
    });

    test('totalMonthlySpend is 0.0 when shelf is empty', () {
      vm.updateFromShelf([]);
      expect(vm.totalMonthlySpend, equals(0.0));
    });

    // ── updateCalculator ──────────────────────────────────────────────────

    test('updateCalculator updates productPrice only', () {
      vm.updateCalculator(price: 200.0);
      expect(vm.productPrice, equals(200.0));
      expect(vm.estimatedUses, equals(60)); // unchanged
    });

    test('updateCalculator updates estimatedUses only', () {
      vm.updateCalculator(uses: 100);
      expect(vm.estimatedUses, equals(100));
      expect(vm.productPrice, equals(120.0)); // unchanged
    });
  });
}
