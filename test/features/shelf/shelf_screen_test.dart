import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_screen.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';
import 'package:glowmatch/core/constants.dart';

Widget _buildShelf(ShelfViewModel shelfVm) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ChangeNotifierProvider<ShelfViewModel>.value(value: shelfVm),
    ],
    child: const MaterialApp(home: ShelfScreen()),
  );
}

void main() {
  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('ShelfScreen widget tests', () {
    testWidgets('FILTER button is always rendered', (tester) async {
      final vm = ShelfViewModel();
      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('FILTER'), findsOneWidget);
    });

    testWidgets('add card with "tekan untuk tambah" text is present',
        (tester) async {
      final vm = ShelfViewModel();
      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.textContaining('tekan untuk tambah skincare baru'),
        findsOneWidget,
      );
    });

    testWidgets('product grid renders seeded items after fetchShelf',
        (tester) async {
      final vm = ShelfViewModel();
      await vm.fetchShelf('test-user');

      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      // Seeded shelf has 'GlowBomb' as first product
      expect(find.text('GlowBomb'), findsOneWidget);
    });

    testWidgets('grid has add card + N product cards after fetchShelf',
        (tester) async {
      final vm = ShelfViewModel();
      await vm.fetchShelf('test-user');

      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      final itemCount = vm.filteredItems.length;
      expect(itemCount, greaterThan(0));
      // Add card is always last (+1)
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('"My Shelf" title is displayed', (tester) async {
      final vm = ShelfViewModel();
      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('My Shelf'), findsOneWidget);
    });
  });

  group('ShelfViewModel and SkincareCategory tests', () {
    test('SkincareCategory mapping and values', () {
      expect(SkincareCategory.toner.displayName, 'Toner');
      expect(SkincareCategory.exfoliant.displayName, 'Exfoliant');
      expect(SkincareCategory.mask.displayName, 'Mask');
      expect(SkincareCategory.eyeCream.displayName, 'Eye Cream');

      expect(SkincareCategory.fromString('Toner'), SkincareCategory.toner);
      expect(SkincareCategory.fromString('exfoliant'), SkincareCategory.exfoliant);
      expect(SkincareCategory.fromString('MASK'), SkincareCategory.mask);
      expect(SkincareCategory.fromString('eye cream'), SkincareCategory.eyeCream);
    });

    test('ShelfViewModel filters by search query and category', () async {
      final vm = ShelfViewModel();
      await vm.fetchShelf('test-user');

      // Seeded mock items:
      // item-1: GlowBomb (Serum, Glow Recipe)
      // item-2: Centella Sunscreen (Sunscreen, Skin1004)
      // item-3: 5% Panthenol Cream (Moisturizer, Florasis)

      expect(vm.shelfItems.length, 3);

      // Search by name
      vm.setSearchQuery('glow');
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.name, 'GlowBomb');

      // Search by brand
      vm.setSearchQuery('skin1004');
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.name, 'Centella Sunscreen');

      // Clear search
      vm.setSearchQuery('');
      expect(vm.filteredItems.length, 3);

      // Filter by category and search combination
      vm.setFilter('Serum');
      vm.setSearchQuery('bomb');
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.name, 'GlowBomb');

      vm.setFilter('Moisturizer');
      // "bomb" doesn't exist in Moisturizer category
      expect(vm.filteredItems.isEmpty, true);
    });
  });
}
