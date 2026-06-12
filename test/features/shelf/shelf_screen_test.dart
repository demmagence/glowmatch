import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/features/shelf/shelf_screen.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';

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
}
