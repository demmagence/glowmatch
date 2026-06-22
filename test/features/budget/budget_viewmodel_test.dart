import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/models/models.dart';
import 'package:glowmatch/features/budget/budget_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BudgetViewModel vm;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vm = BudgetViewModel();
  });

  group('BudgetViewModel Tests', () {
    test('default values are set correctly', () {
      expect(vm.budgetLimit, equals(2460000.0));
      expect(vm.productPrice, equals(1968000.0));
      expect(vm.estimatedUses, equals(60));
      expect(vm.allocations, isEmpty);
      expect(vm.totalMonthlySpend, equals(0.0));
    });

    test('efficiencyMetric is calculated correctly: $120 / 60 = $2.00', () {
      expect(vm.efficiencyMetric, closeTo(32800.00, 0.001));
    });

    test('efficiencyMetric returns 0.0 when uses is 0', () {
      vm.updateCalculator(uses: 0);
      expect(vm.efficiencyMetric, equals(0.0));
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

    test('updateFromShelf sort allocations descending by amount', () {
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

    test('spendingHistory includes dynamic spending history', () {
      final now = DateTime.now();
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
          createdAt: now,
        ),
      ]);
      expect(vm.spendingHistory.length, equals(6));
      expect(vm.spendingHistory.last, equals(42.0 * 16400.0));
    });

    test('spendingHistoryLabels contains exactly 6 chronological months', () {
      expect(vm.spendingHistoryLabels.length, equals(6));
    });

    test('selectedPeriodDays default is 30, and updating it recalculates allocations based on item createdAt', () {
      expect(vm.selectedPeriodDays, equals(30));

      final now = DateTime.now();
      vm.updateFromShelf([
        ShelfItem(
          id: 'recent',
          category: 'Serum',
          price: 50.0,
          name: 'S1',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        ShelfItem(
          id: 'old',
          category: 'Serum',
          price: 100.0,
          name: 'S2',
          brand: '',
          estimatedUses: 50,
          remainingUses: 50,
          indicatorColor: '0xFFE040FB',
          ingredients: const [],
          createdAt: now.subtract(const Duration(days: 45)),
        ),
      ]);

      // With default 30 days, only 'recent' (5 days ago) is counted
      expect(vm.totalMonthlySpend, equals(50.0));

      // Change to 90 days, both should be counted
      vm.setPeriodDays(90);
      expect(vm.selectedPeriodDays, equals(90));
      expect(vm.totalMonthlySpend, equals(150.0));

      // Change to All Time (0 days), both should be counted
      vm.setPeriodDays(0);
      expect(vm.selectedPeriodDays, equals(0));
      expect(vm.totalMonthlySpend, equals(150.0));
    });

    test('spendingHistory groups entries by calendar month dynamically', () {
      final now = DateTime.now();
      final itemThisMonth = ShelfItem(
        id: 'this-month',
        category: 'Serum',
        price: 100.0 * 16400.0,
        name: 'Product 1',
        brand: '',
        estimatedUses: 50,
        remainingUses: 50,
        indicatorColor: '0xFFE040FB',
        ingredients: const [],
        createdAt: now,
      );
      final itemPrevMonth = ShelfItem(
        id: 'prev-month',
        category: 'Serum',
        price: 50.0 * 16400.0,
        name: 'Product 2',
        brand: '',
        estimatedUses: 50,
        remainingUses: 50,
        indicatorColor: '0xFFE040FB',
        ingredients: const [],
        createdAt: DateTime(now.year, now.month - 1, 15),
      );

      vm.updateFromShelf([itemThisMonth, itemPrevMonth]);

      expect(vm.spendingHistory.length, equals(6));
      expect(vm.spendingHistory.last, equals(100.0 * 16400.0));
      expect(vm.spendingHistory[vm.spendingHistory.length - 2], equals(50.0 * 16400.0));
    });
  });
}
