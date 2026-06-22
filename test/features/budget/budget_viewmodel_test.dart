import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/features/budget/budget_viewmodel.dart';
import 'package:glowmatch/core/models/models.dart';

void main() {
  group('BudgetViewModel', () {
    late BudgetViewModel vm;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      vm = BudgetViewModel();
    });

    test('efficiencyMetric: 1968000 / 60 = 32800.00', () {
      expect(vm.efficiencyMetric, closeTo(32800.00, 0.001));
    });

    test('efficiencyMetric: 50 * 16000 / 25 = 32800.00', () {
      vm.updateCalculator(price: 50.0 * 16400.0, uses: 25);
      expect(vm.efficiencyMetric, closeTo(32800.00, 0.001));
    });

    test('efficiencyMetric returns 0.0 when uses is 0', () {
      vm.updateCalculator(uses: 0);
      expect(vm.efficiencyMetric, equals(0.0));
    });

    test('efficiencyMetric: 42 * 16000 / 60 ≈ 11480.00', () {
      vm.updateCalculator(price: 42.0 * 16400.0, uses: 60);
      expect(vm.efficiencyMetric, closeTo(11480.00, 0.001));
    });

    test('updateFromShelf groups items by category and sums amounts', () {
      vm.updateFromShelf([
        ShelfItem(
          id: '1',
          category: 'Serum',
          price: 42.0 * 16400.0,
          name: 'S1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
        ),
        ShelfItem(
          id: '2',
          category: 'Serum',
          price: 18.0 * 16400.0,
          name: 'S2',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
        ),
        ShelfItem(
          id: '3',
          category: 'Moisturizer',
          price: 58.0 * 16400.0,
          name: 'M1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFD50000',
          ingredients: const [],
        ),
      ]);

      final serum = vm.allocations.firstWhere((a) => a.category == 'Serum');
      final moist = vm.allocations.firstWhere(
        (a) => a.category == 'Moisturizer',
      );
      expect(serum.amount, closeTo(60.0 * 16400.0, 0.001));
      expect(moist.amount, closeTo(58.0 * 16400.0, 0.001));
    });

    test('updateFromShelf assigns correct colorHex per category', () {
      vm.updateFromShelf([
        ShelfItem(
          id: '1',
          category: 'Sunscreen',
          price: 20.0 * 16400.0,
          name: 'Sun1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFF64DD17',
          ingredients: const [],
        ),
        ShelfItem(
          id: '2',
          category: 'Cleanser',
          price: 15.0 * 16400.0,
          name: 'C1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFF29B6F6',
          ingredients: const [],
        ),
      ]);

      final sun = vm.allocations.firstWhere((a) => a.category == 'Sunscreen');
      final clean = vm.allocations.firstWhere((a) => a.category == 'Cleanser');
      expect(sun.colorHex, equals('0xFF64DD17'));
      expect(clean.colorHex, equals('0xFF29B6F6'));
    });

    test('updateFromShelf sorts allocations descending by amount', () {
      vm.updateFromShelf([
        ShelfItem(
          id: '1',
          category: 'Cleanser',
          price: 10.0 * 16400.0,
          name: 'C1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFF29B6F6',
          ingredients: const [],
        ),
        ShelfItem(
          id: '2',
          category: 'Moisturizer',
          price: 58.0 * 16400.0,
          name: 'M1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFD50000',
          ingredients: const [],
        ),
        ShelfItem(
          id: '3',
          category: 'Serum',
          price: 42.0 * 16400.0,
          name: 'S1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
        ),
      ]);

      final amounts = vm.allocations.map((a) => a.amount).toList();
      for (int i = 0; i < amounts.length - 1; i++) {
        expect(amounts[i] >= amounts[i + 1], isTrue);
      }
    });

    test('totalMonthlySpend sums all allocation amounts', () {
      vm.updateFromShelf([
        ShelfItem(
          id: '1',
          category: 'Serum',
          price: 42.0 * 16400.0,
          name: 'S1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
        ),
        ShelfItem(
          id: '2',
          category: 'Sunscreen',
          price: 20.0 * 16400.0,
          name: 'Sun1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFF64DD17',
          ingredients: const [],
        ),
        ShelfItem(
          id: '3',
          category: 'Moisturizer',
          price: 58.0 * 16400.0,
          name: 'M1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFD50000',
          ingredients: const [],
        ),
      ]);
      expect(vm.totalMonthlySpend, closeTo(120.0 * 16400.0, 0.001));
    });

    test('totalMonthlySpend is 0.0 when shelf is empty', () {
      vm.updateFromShelf([]);
      expect(vm.totalMonthlySpend, equals(0.0));
    });

    test('updateCalculator updates productPrice only', () {
      vm.updateCalculator(price: 200.0 * 16400.0);
      expect(vm.productPrice, equals(200.0 * 16400.0));
      expect(vm.estimatedUses, equals(60));
    });

    test('updateCalculator updates estimatedUses only', () {
      vm.updateCalculator(uses: 100);
      expect(vm.estimatedUses, equals(100));
      expect(vm.productPrice, equals(1968000.0));
    });

    test('loadBudgetLimit returns default 2460000.0 when not set', () async {
      await vm.loadBudgetLimit();
      expect(vm.budgetLimit, equals(2460000.0));
    });

    test('setBudgetLimit sets and persists the limit', () async {
      await vm.setBudgetLimit(3200000.0);
      expect(vm.budgetLimit, equals(3200000.0));

      final vm2 = BudgetViewModel();
      await vm2.loadBudgetLimit();
      expect(vm2.budgetLimit, equals(3200000.0));
    });

    test('spendingHistory includes mock months plus total dynamic spend', () {
      vm.updateFromShelf([
        ShelfItem(
          id: '1',
          category: 'Serum',
          price: 42.0 * 16400.0,
          name: 'S1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
        ),
      ]);
      expect(vm.spendingHistory.length, equals(6));
      expect(vm.spendingHistory.last, equals(42.0 * 16400.0));
    });

    test('spendingHistoryLabels contains exactly 6 chronological months', () {
      expect(vm.spendingHistoryLabels.length, equals(6));
    });

    test(
      'smartAlerts is empty when totalMonthlySpend is 0 and products are healthy',
      () {
        vm.updateFromShelf([]);
        expect(vm.smartAlerts, isEmpty);
      },
    );

    test(
      'smartAlerts generates danger alert when budget is exceeded',
      () async {
        await vm.setBudgetLimit(100.0 * 16400.0);
        vm.updateFromShelf([
          ShelfItem(
            id: '1',
            category: 'Serum',
            price: 120.0 * 16400.0,
            name: 'S1',
            brand: 'B1',
            estimatedUses: 100,
            remainingUses: 100,
            indicatorColor: '0xFFE040FB',
            ingredients: const [],
          ),
        ]);

        final dangerAlerts = vm.smartAlerts
            .where((a) => a.type == 'danger')
            .toList();
        expect(dangerAlerts.length, equals(1));
        expect(dangerAlerts.first.title, contains('Budget Exceeded'));
      },
    );

    test(
      'smartAlerts generates warning alert when spend is > 80% of budget limit',
      () async {
        await vm.setBudgetLimit(100.0 * 16400.0);
        vm.updateFromShelf([
          ShelfItem(
            id: '1',
            category: 'Serum',
            price: 85.0 * 16400.0,
            name: 'S1',
            brand: 'B1',
            estimatedUses: 100,
            remainingUses: 100,
            indicatorColor: '0xFFE040FB',
            ingredients: const [],
          ),
        ]);

        final warningAlerts = vm.smartAlerts
            .where((a) => a.type == 'warning')
            .toList();
        expect(warningAlerts.length, equals(1));
        expect(warningAlerts.first.title, contains('Approaching Budget Limit'));
      },
    );

    test('smartAlerts generates low stock warning when remainingUses <= 5', () {
      vm.updateFromShelf([
        ShelfItem(
          id: '1',
          category: 'Serum',
          price: 30.0 * 16400.0,
          name: 'Low Stock Product',
          brand: 'B1',
          estimatedUses: 50,
          remainingUses: 4,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
        ),
      ]);

      final stockAlerts = vm.smartAlerts
          .where((a) => a.title.contains('Low Uses Remaining'))
          .toList();
      expect(stockAlerts.length, equals(1));
      expect(
        stockAlerts.first.description,
        contains('Only 4 applications left'),
      );
    });

    test(
      'smartAlerts generates high cost-per-apply warning when metric > 1.50',
      () {
        vm.updateFromShelf([
          ShelfItem(
            id: '1',
            category: 'Serum',
            price: 80.0 * 16400.0,
            name: 'Expensive Serum',
            brand: 'B1',
            estimatedUses: 40,
            remainingUses: 40,
            indicatorColor: '0xFFE040FB',
            ingredients: const [],
          ),
        ]);

        final efficiencyAlerts = vm.smartAlerts
            .where((a) => a.title.contains('High Cost-Per-Apply'))
            .toList();
        expect(efficiencyAlerts.length, equals(1));
        expect(
          efficiencyAlerts.first.description,
          contains('costs \$2.00 per application'),
        );
      },
    );
  });
}
