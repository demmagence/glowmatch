import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/features/shelf/shelf_viewmodel.dart';
import 'package:glowmatch/features/journal/journal_viewmodel.dart';
import 'package:glowmatch/features/home/routine_viewmodel.dart';
import 'package:glowmatch/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Guest Sign Out – clearState tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      SupabaseService().resetForTesting();
      await SupabaseService().initialize(url: '', anonKey: '');
    });

    test('ShelfViewModel clearState clears all items and resets query/filters', () async {
      final shelfVm = ShelfViewModel();
      await shelfVm.fetchShelf('test-user');

      expect(shelfVm.shelfItems, isNotEmpty);

      shelfVm.setFilter('Moisturizer');
      shelfVm.setSearchQuery('Glow');
      shelfVm.clearState();

      expect(shelfVm.shelfItems, isEmpty);
      expect(shelfVm.selectedCategoryFilter, equals('All'));
      expect(shelfVm.searchQuery, isEmpty);
    });

    test('JournalViewModel clearState clears all entries', () async {
      final journalVm = JournalViewModel();
      await journalVm.fetchJournal('test-user');

      expect(journalVm.entries, isNotEmpty);

      journalVm.clearState();

      expect(journalVm.entries, isEmpty);
    });

    test('RoutineViewModel clearState clears AM/PM steps and resets fields', () async {
      final routineVm = RoutineViewModel();
      await routineVm.init('test-user');

      expect(routineVm.amSteps, isNotEmpty);
      expect(routineVm.pmSteps, isNotEmpty);

      routineVm.clearState();

      expect(routineVm.amSteps, isEmpty);
      expect(routineVm.pmSteps, isEmpty);
      expect(routineVm.completedStepIds, isEmpty);
      expect(routineVm.activeRoutine, equals('AM'));
      expect(routineVm.weather, isNull);
      expect(routineVm.streakData, isNull);
    });
  });
}
