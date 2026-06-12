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
  bool get isAnonymous => _currentUser == null || _currentUser?.email == null || _currentUser!.email!.isEmpty;

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

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_supabaseService.isOfflineMode) {
        await Supabase.instance.client.auth.signOut();
      }
      _currentUser = null;
    } catch (e) {
      debugPrint('AuthViewModel signOut error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> linkEmailAccount(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_supabaseService.isOfflineMode) {
        // Mock linking email in offline mode
        _currentUser = User(
          id: userId,
          appMetadata: const {},
          userMetadata: const {},
          aud: '',
          createdAt: DateTime.now().toIso8601String(),
          email: email,
        );
      } else {
        final response = await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            email: email,
            password: password,
          ),
        );
        _currentUser = response.user;
      }
    } catch (e) {
      debugPrint('AuthViewModel linkEmailAccount error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
