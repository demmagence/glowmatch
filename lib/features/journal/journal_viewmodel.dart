import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/models.dart';

class JournalViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _picker = ImagePicker();

  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  int _currentScore = 84;
  int _currentStreak = 0;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  int get currentScore => _currentScore;
  int get currentStreak => _currentStreak;

  Future<void> fetchJournal(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _supabaseService.getJournalEntries(userId);
      final streak = await _supabaseService.getStreakData(userId);
      _currentStreak = streak.currentStreak;
      _calculateCurrentScore();
    } catch (e) {
      debugPrint('Error fetching journal: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateCurrentScore() {
    int baseScore = 80;
    if (_entries.isNotEmpty) {
      baseScore = 80 + (_entries.length * 2);
    }
    _currentScore = (baseScore + (_currentStreak * 2)).clamp(1, 100);
  }

  /// Pick photo from camera or gallery, upload to Supabase Storage, add journal entry.
  /// Returns true on success, false on cancel/failure.
  Future<bool> pickAndUploadPhoto({
    required String userId,
    required ImageSource source,
    String notes = '',
  }) async {
    try {
      // Step 1: Pick image
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (picked == null) return false; // User cancelled

      _isUploading = true;
      notifyListeners();

      // Step 2: Upload to Supabase Storage (or local path in offline mode)
      final String photoUrl = await _supabaseService.uploadJournalPhoto(
        userId: userId,
        localFilePath: picked.path,
      );

      // Step 3: Build entry with current date
      final now = DateTime.now();
      final dateLabel = _formatDate(now);
      final entry = JournalEntry(
        id: '',
        loggedDate: dateLabel,
        skinScore: _estimateScore(),
        photoPath: photoUrl,
        notes: notes.isEmpty ? 'Progress photo logged on $dateLabel.' : notes,
      );

      // Step 4: Persist entry to Supabase / mock store
      final addedEntry = await _supabaseService.addJournalEntry(userId, entry);
      _entries.insert(0, addedEntry);
      _calculateCurrentScore();

      return true;
    } catch (e) {
      debugPrint('JournalViewModel: pickAndUploadPhoto error: $e');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Legacy method kept for backward compat (e.g. mocked entries)
  Future<void> addEntry({
    required String userId,
    required String photoPath,
    required int score,
    required String notes,
  }) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: '',
      loggedDate: _formatDate(now),
      skinScore: score,
      photoPath: photoPath,
      notes: notes,
    );

    try {
      final addedEntry = await _supabaseService.addJournalEntry(userId, entry);
      _entries.insert(0, addedEntry);
      _calculateCurrentScore();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding journal entry: $e');
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  int _estimateScore() {
    // Slight variance around current score for organic feel
    final delta = (_entries.length % 3) - 1; // -1, 0, or +1
    return (_currentScore + delta).clamp(1, 100);
  }
}
