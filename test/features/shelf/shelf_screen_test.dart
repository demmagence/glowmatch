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

Widget _buildShelfDark(ShelfViewModel shelfVm) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ChangeNotifierProvider<ShelfViewModel>.value(value: shelfVm),
    ],
    child: MaterialApp(theme: ThemeData.dark(), home: const ShelfScreen()),
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

    testWidgets('add card with "tekan untuk tambah" text is present', (
      tester,
    ) async {
      final vm = ShelfViewModel();
      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.textContaining('tekan untuk tambah skincare baru'),
        findsOneWidget,
      );
    });

    testWidgets('product grid renders seeded items after fetchShelf', (
      tester,
    ) async {
      final vm = ShelfViewModel();
      await vm.fetchShelf('test-user');

      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('GlowBomb'), findsOneWidget);
    });

    testWidgets('grid has add card + N product cards after fetchShelf', (
      tester,
    ) async {
      final vm = ShelfViewModel();
      await vm.fetchShelf('test-user');

      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      final itemCount = vm.filteredItems.length;
      expect(itemCount, greaterThan(0));

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('"My Shelf" title is displayed', (tester) async {
      final vm = ShelfViewModel();
      await tester.pumpWidget(_buildShelf(vm));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('My Shelf'), findsOneWidget);
    });

    testWidgets(
      'renders correctly in dark mode and verifies theme-aware colors',
      (tester) async {
        final vm = ShelfViewModel();
        await tester.pumpWidget(_buildShelfDark(vm));
        await tester.pump(const Duration(milliseconds: 300));

        final BuildContext context = tester.element(find.byType(ShelfScreen));
        expect(Theme.of(context).brightness, equals(Brightness.dark));

        final Text myShelfText = tester.widget<Text>(find.text('My Shelf'));
        expect(myShelfText.style?.color, equals(Colors.white));
      },
    );
  });

  group('ShelfViewModel and SkincareCategory tests', () {
    test('SkincareCategory mapping and values', () {
      expect(SkincareCategory.toner.displayName, 'Toner');
      expect(SkincareCategory.exfoliant.displayName, 'Exfoliant');
      expect(SkincareCategory.mask.displayName, 'Mask');
      expect(SkincareCategory.eyeCream.displayName, 'Eye Cream');

      expect(SkincareCategory.fromString('Toner'), SkincareCategory.toner);
      expect(
        SkincareCategory.fromString('exfoliant'),
        SkincareCategory.exfoliant,
      );
      expect(SkincareCategory.fromString('MASK'), SkincareCategory.mask);
      expect(
        SkincareCategory.fromString('eye cream'),
        SkincareCategory.eyeCream,
      );
    });

    test('ShelfViewModel filters by search query and category', () async {
      final vm = ShelfViewModel();
      await vm.fetchShelf('test-user');

      expect(vm.shelfItems.length, 3);

      vm.setSearchQuery('glow');
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.name, 'GlowBomb');

      vm.setSearchQuery('skin1004');
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.name, 'Centella Sunscreen');

      vm.setSearchQuery('');
      expect(vm.filteredItems.length, 3);

      vm.setFilter('Serum');
      vm.setSearchQuery('bomb');
      expect(vm.filteredItems.length, 1);
      expect(vm.filteredItems.first.name, 'GlowBomb');

      vm.setFilter('Moisturizer');

      expect(vm.filteredItems.isEmpty, true);
    });

    test('ShelfViewModel addProduct and editProduct handles productSize and createdAt', () async {
      final vm = ShelfViewModel();
      await vm.fetchShelf('test-user');
      final initialCount = vm.shelfItems.length;

      await vm.addProduct(
        userId: 'test-user',
        name: 'New Product',
        brand: 'New Brand',
        category: 'Serum',
        price: 15.0,
        estimatedUses: 50,
        colorHex: '0xFFE040FB',
        productSize: '30 ml',
      );

      expect(vm.shelfItems.length, initialCount + 1);
      final addedItem = vm.shelfItems.last;
      expect(addedItem.name, 'New Product');
      expect(addedItem.productSize, '30 ml');
      expect(addedItem.createdAt, isNotNull);

      final originalCreatedAt = addedItem.createdAt;
      await vm.editProduct(
        itemId: addedItem.id,
        name: 'Updated Product',
        brand: 'New Brand',
        category: 'Serum',
        price: 18.0,
        estimatedUses: 50,
        remainingUses: 48,
        colorHex: '0xFFE040FB',
        productSize: '35 ml',
      );

      final editedItem = vm.shelfItems.firstWhere((x) => x.id == addedItem.id);
      expect(editedItem.name, 'Updated Product');
      expect(editedItem.productSize, '35 ml');
      expect(editedItem.createdAt, equals(originalCreatedAt));
    });
  });
}
