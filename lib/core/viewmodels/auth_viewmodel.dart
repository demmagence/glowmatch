import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String get userId => _currentUser?.id ?? 'offline-guest-user';
  bool get isGuest => _currentUser == null;

  AuthViewModel() {
    initSession();
  }

  Future<void> initSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _supabaseService.getOrCreateUser();
    } catch (e) {
      debugPrint('AuthViewModel initSession error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAnonymously() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _supabaseService.getOrCreateUser();
    } catch (e) {
      debugPrint('AuthViewModel loginAnonymously error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
