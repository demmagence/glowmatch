import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/supabase_service.dart';

class JournalViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = false;
  bool _isUploading = false;
  int _currentScore = 84;

  List<Map<String, dynamic>> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
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
    if (_entries.isEmpty) {
      _currentScore = 80;
    } else {
      _currentScore = (80 + (_entries.length * 2)).clamp(1, 100);
    }
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
      final entry = {
        'logged_date': dateLabel,
        'skin_score': _estimateScore(),
        'photo_path': photoUrl,
        'notes': notes.isEmpty ? 'Progress photo logged on $dateLabel.' : notes,
      };

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
    final entry = {
      'logged_date': _formatDate(now),
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
