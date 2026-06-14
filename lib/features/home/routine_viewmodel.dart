import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/models/models.dart';
import '../shelf/shelf_viewmodel.dart';

class RoutineViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final WeatherService _weatherService = WeatherService();

  List<RoutineStep> _amSteps = [];
  List<RoutineStep> _pmSteps = [];
  final Set<String> _completedStepIds = {};

  String _activeRoutine = 'AM';
  bool _isLoading = false;
  String? _errorMessage;
  WeatherData? _weather;
  StreakData? _streakData;

  List<RoutineStep> get amSteps => _amSteps;
  List<RoutineStep> get pmSteps => _pmSteps;
  Set<String> get completedStepIds => _completedStepIds;
  String get activeRoutine => _activeRoutine;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WeatherData? get weather => _weather;
  StreakData? get streakData => _streakData;

  bool get completedToday {
    if (_streakData == null || _streakData!.lastCompletedDate == null) {
      return false;
    }
    final now = DateTime.now();
    final last = _streakData!.lastCompletedDate!;
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  List<RoutineStep> get currentSteps =>
      _activeRoutine == 'AM' ? _amSteps : _pmSteps;

  int get completedCount {
    final steps = currentSteps;
    if (steps.isEmpty) return 0;
    return steps.where((step) => _completedStepIds.contains(step.id)).length;
  }

  int get totalCount => currentSteps.length;

  Future<void> init(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await fetchWeather();
      await loadRoutines(userId);
      await loadStreakData(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStreakData(String userId) async {
    try {
      _streakData = await _supabaseService.getStreakData(userId);
    } catch (e) {
      debugPrint('Error loading streak data: $e');
    }
    notifyListeners();
  }

  Future<void> fetchWeather() async {
    try {
      _weather = await _weatherService.fetchLocalWeather();
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
    notifyListeners();
  }

  Future<void> loadRoutines(String userId) async {
    try {
      _amSteps = await _supabaseService.getRoutines(userId, 'AM');
      _pmSteps = await _supabaseService.getRoutines(userId, 'PM');

      _completedStepIds.clear();
    } catch (e) {
      debugPrint('Error loading routines: $e');
      _errorMessage = e.toString();
      rethrow;
    }
    notifyListeners();
  }

  void setActiveRoutine(String routine) {
    if (_activeRoutine != routine) {
      _activeRoutine = routine;
      _completedStepIds.clear();
      notifyListeners();
    }
  }

  Future<void> toggleStep(String stepId, ShelfViewModel shelfVm) async {
    if (_completedStepIds.contains(stepId)) {
      _completedStepIds.remove(stepId);
    } else {
      _completedStepIds.add(stepId);

      final stepIdx = currentSteps.indexWhere((x) => x.id == stepId);
      if (stepIdx != -1) {
        final step = currentSteps[stepIdx];
        if (step.shelfItemId != null && step.shelfItemId!.isNotEmpty) {
          await shelfVm.useProduct(step.shelfItemId!);
        }
      }
    }
    notifyListeners();
  }

  Future<void> addCustomStep(
    String userId,
    String name,
    String desc, {
    String? shelfItemId,
  }) async {
    final newStep = RoutineStep(
      id: '',
      routineType: _activeRoutine,
      stepNumber: currentSteps.length + 1,
      name: name,
      description: desc,
      shelfItemId: shelfItemId,
    );

    await _supabaseService.addRoutineStep(userId, newStep);
    await loadRoutines(userId);
  }

  Future<void> updateStep(String userId, RoutineStep step) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseService.updateRoutineStep(userId, step);
      await loadRoutines(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStep(String userId, String stepId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final isAM = _amSteps.any((x) => x.id == stepId);
      await _supabaseService.deleteRoutineStep(userId, stepId);

      final remainingSteps = isAM
          ? _amSteps.where((x) => x.id != stepId).toList()
          : _pmSteps.where((x) => x.id != stepId).toList();

      final reindexedSteps = <RoutineStep>[];
      for (int i = 0; i < remainingSteps.length; i++) {
        reindexedSteps.add(remainingSteps[i].copyWith(stepNumber: i + 1));
      }

      if (reindexedSteps.isNotEmpty) {
        await _supabaseService.updateRoutineStepsOrder(userId, reindexedSteps);
      }

      await loadRoutines(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reorderSteps(String userId, int oldIndex, int newIndex) async {
    final steps = _activeRoutine == 'AM'
        ? List<RoutineStep>.from(_amSteps)
        : List<RoutineStep>.from(_pmSteps);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) return;

    final item = steps.removeAt(oldIndex);
    steps.insert(newIndex, item);

    final updatedSteps = <RoutineStep>[];
    for (int i = 0; i < steps.length; i++) {
      updatedSteps.add(steps[i].copyWith(stepNumber: i + 1));
    }

    if (_activeRoutine == 'AM') {
      _amSteps = updatedSteps;
    } else {
      _pmSteps = updatedSteps;
    }
    notifyListeners();

    try {
      await _supabaseService.updateRoutineStepsOrder(userId, updatedSteps);
    } catch (e) {
      _errorMessage = e.toString();

      await loadRoutines(userId);
    }
  }

  Future<void> completeRoutine(String userId) async {
    if (completedToday) {
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      _streakData = await _supabaseService.recordRoutineCompletion(userId);
      _completedStepIds.clear();
    } catch (e) {
      debugPrint('Error completing routine: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
