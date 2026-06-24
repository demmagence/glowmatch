import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/models/models.dart';
import '../shelf/shelf_viewmodel.dart';

class RoutineViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final WeatherService _weatherService = WeatherService();

  String? _userId;
  String? get userId => _userId;

  List<RoutineStep> _amSteps = [];
  List<RoutineStep> _pmSteps = [];
  final Set<String> _completedStepIds = {};
  final Set<String> _todayCompletedStepIds = {};

  String _activeRoutine = 'AM';
  bool _isLoading = false;
  String? _errorMessage;
  WeatherData? _weather;
  StreakData? _streakData;
  List<DateTime> _dailyCompletionLogs = [];

  List<RoutineStep> get amSteps => _amSteps;
  List<RoutineStep> get pmSteps => _pmSteps;
  Set<String> get completedStepIds => _completedStepIds;
  String get activeRoutine => _activeRoutine;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WeatherData? get weather => _weather;
  StreakData? get streakData => _streakData;
  List<DateTime> get dailyCompletionLogs => _dailyCompletionLogs;

  List<StreakSegment> get streakSegments {
    if (_dailyCompletionLogs.isEmpty) return [];

    final uniqueSortedDates = _dailyCompletionLogs
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (uniqueSortedDates.isEmpty) return [];

    final List<StreakSegment> segments = [];
    DateTime segmentStart = uniqueSortedDates[0];
    DateTime segmentEnd = uniqueSortedDates[0];

    for (int i = 1; i < uniqueSortedDates.length; i++) {
      final currentDate = uniqueSortedDates[i];
      final diff = currentDate.difference(segmentEnd).inDays;

      if (diff == 1) {
        segmentEnd = currentDate;
      } else if (diff > 1) {
        final length = segmentEnd.difference(segmentStart).inDays + 1;
        segments.add(StreakSegment(
          startDate: segmentStart,
          endDate: segmentEnd,
          length: length,
        ));
        segmentStart = currentDate;
        segmentEnd = currentDate;
      }
    }

    final lastLength = segmentEnd.difference(segmentStart).inDays + 1;
    segments.add(StreakSegment(
      startDate: segmentStart,
      endDate: segmentEnd,
      length: lastLength,
    ));

    segments.sort((a, b) => b.endDate.compareTo(a.endDate));
    return segments;
  }

  bool _amCompletedToday = false;
  bool _pmCompletedToday = false;

  bool get amCompletedToday => _amCompletedToday;
  bool get pmCompletedToday => _pmCompletedToday;

  String _getRoutinePrefsKey(String type, DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'completed_${type}_$dateStr';
  }

  Future<void> _loadLocalCompletionStates() async {
    final prefs = await SharedPreferences.getInstance();
    final amKey = _getRoutinePrefsKey('AM', DateTime.now());
    final pmKey = _getRoutinePrefsKey('PM', DateTime.now());
    _amCompletedToday = prefs.getBool(amKey) ?? false;
    _pmCompletedToday = prefs.getBool(pmKey) ?? false;
    notifyListeners();
  }

  bool get completedToday {
    return _activeRoutine == 'AM' ? _amCompletedToday : _pmCompletedToday;
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
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await fetchWeather();
      await loadRoutines(userId);
      await loadStreakData(userId);
      await _loadLocalCompletionStates();
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
      _dailyCompletionLogs = await _supabaseService.getDailyCompletionLogs(userId);
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
    _userId = userId;
    try {
      _amSteps = await _supabaseService.getRoutines(userId, 'AM');
      _pmSteps = await _supabaseService.getRoutines(userId, 'PM');

      _completedStepIds.clear();
      _todayCompletedStepIds.clear();
      final todayCompletions = await _supabaseService.getRoutineStepCompletions(userId, DateTime.now());
      _todayCompletedStepIds.addAll(todayCompletions);

      final activeSteps = _activeRoutine == 'AM' ? _amSteps : _pmSteps;
      for (final step in activeSteps) {
        if (_todayCompletedStepIds.contains(step.id)) {
          _completedStepIds.add(step.id);
        }
      }
      await _loadLocalCompletionStates();
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
      final activeSteps = _activeRoutine == 'AM' ? _amSteps : _pmSteps;
      for (final step in activeSteps) {
        if (_todayCompletedStepIds.contains(step.id)) {
          _completedStepIds.add(step.id);
        }
      }
      notifyListeners();
    }
  }

  Future<void> toggleStep(String stepId, ShelfViewModel shelfVm) async {
    if (_completedStepIds.contains(stepId)) {
      return;
    }

    _completedStepIds.add(stepId);
    _todayCompletedStepIds.add(stepId);
    if (_userId != null) {
      await _supabaseService.insertRoutineStepCompletion(_userId!, stepId, DateTime.now());
    }

    final stepIdx = currentSteps.indexWhere((x) => x.id == stepId);
    if (stepIdx != -1) {
      final step = currentSteps[stepIdx];
      if (step.shelfItemId != null && step.shelfItemId!.isNotEmpty) {
        await shelfVm.useProduct(step.shelfItemId!);
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
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    await reorderStepsDirect(userId, oldIndex, newIndex);
  }

  Future<void> reorderStepsDirect(String userId, int oldIndex, int newIndex) async {
    final steps = _activeRoutine == 'AM'
        ? List<RoutineStep>.from(_amSteps)
        : List<RoutineStep>.from(_pmSteps);
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
    _isLoading = true;
    notifyListeners();

    try {
      // Re-fetch streak data from service to ensure we have the latest
      // persisted state (handles re-login / app restart scenarios).
      await loadStreakData(userId);

      if (completedToday) {
        return;
      }

      if (completedCount < totalCount || totalCount == 0) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final key = _getRoutinePrefsKey(_activeRoutine, DateTime.now());
      await prefs.setBool(key, true);

      if (_activeRoutine == 'AM') {
        _amCompletedToday = true;
      } else {
        _pmCompletedToday = true;
      }

      _streakData = await _supabaseService.recordRoutineCompletion(userId);
      _dailyCompletionLogs = await _supabaseService.getDailyCompletionLogs(userId);
    } catch (e) {
      debugPrint('Error completing routine: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _amSteps = [];
    _pmSteps = [];
    _completedStepIds.clear();
    _amCompletedToday = false;
    _pmCompletedToday = false;
    _activeRoutine = 'AM';
    _isLoading = false;
    _errorMessage = null;
    _weather = null;
    _streakData = null;
    notifyListeners();
  }
}
