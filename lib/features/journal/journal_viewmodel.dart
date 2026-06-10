import 'package:flutter/foundation.dart';
import '../../core/services/supabase_service.dart';

class JournalViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = false;
  int _currentScore = 84; // Matches mockup current score of 84

  List<Map<String, dynamic>> get entries => _entries;
  bool get isLoading => _isLoading;
  int get currentScore => _currentScore;

  Future<void> fetchJournal(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _supabaseService.getJournalEntries(userId);
      _calculateCurrentScore();
    } catch (e) {
      debugPrint('Error fetching journal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateCurrentScore() {
    // Score based on routine logs + initial values. Default to 84 as seen in mockup.
    if (_entries.isEmpty) {
      _currentScore = 80;
    } else {
      // Scale score based on entry count/consistency
      _currentScore = (80 + (_entries.length * 2)).clamp(1, 100);
    }
  }

  Future<void> addEntry({
    required String userId,
    required String photoPath,
    required int score,
    required String notes,
  }) async {
    final entry = {
      'logged_date': 'Oct ${15 + _entries.length * 2}', // Mock date generation
      'skin_score': score,
      'photo_path': photoPath,
      'notes': notes,
    };

    try {
      final addedEntry = await _supabaseService.addJournalEntry(userId, entry);
      _entries.insert(0, addedEntry);
      _calculateCurrentScore();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding journal entry: $e');
    }
  }
}
