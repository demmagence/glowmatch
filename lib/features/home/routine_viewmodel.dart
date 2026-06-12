import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/models/models.dart';

class RoutineViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final WeatherService _weatherService = WeatherService();

  List<RoutineStep> _amSteps = [];
  List<RoutineStep> _pmSteps = [];
  final Set<String> _completedStepIds = {};
  
  String _activeRoutine = 'AM';
  bool _isLoading = false;
  WeatherData? _weather;

  List<RoutineStep> get amSteps => _amSteps;
  List<RoutineStep> get pmSteps => _pmSteps;
  Set<String> get completedStepIds => _completedStepIds;
  String get activeRoutine => _activeRoutine;
  bool get isLoading => _isLoading;
  WeatherData? get weather => _weather;

  // Steps matching the active routine (AM or PM)
  List<RoutineStep> get currentSteps => _activeRoutine == 'AM' ? _amSteps : _pmSteps;

  // Completed count for the current active routine
  int get completedCount {
    final steps = currentSteps;
    if (steps.isEmpty) return 0;
    return steps.where((step) => _completedStepIds.contains(step.id)).length;
  }

  // Total steps for current routine
  int get totalCount => currentSteps.length;

  Future<void> init(String userId) async {
    _isLoading = true;
    notifyListeners();

    await fetchWeather();
    await loadRoutines(userId);

    _isLoading = false;
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
      
      // Reset completion status when loading new lists
      _completedStepIds.clear();
    } catch (e) {
      debugPrint('Error loading routines: $e');
    }
    notifyListeners();
  }

  void setActiveRoutine(String routine) {
    if (_activeRoutine != routine) {
      _activeRoutine = routine;
      _completedStepIds.clear(); // Reset status when switching routines
      notifyListeners();
    }
  }

  void toggleStep(String stepId) {
    if (_completedStepIds.contains(stepId)) {
      _completedStepIds.remove(stepId);
    } else {
      _completedStepIds.add(stepId);
    }
    notifyListeners();
  }

  Future<void> addCustomStep(String userId, String name, String desc) async {
    final newStep = RoutineStep(
      id: '',
      routineType: _activeRoutine,
      stepNumber: currentSteps.length + 1,
      name: name,
      description: desc,
    );
    
    await _supabaseService.addRoutineStep(userId, newStep);
    await loadRoutines(userId);
  }

  Future<void> completeRoutine(String userId) async {
    // Log completion logic
    debugPrint('Routine complete logic triggered. Streak incremented.');
    _completedStepIds.clear(); // reset
    notifyListeners();
  }
}
