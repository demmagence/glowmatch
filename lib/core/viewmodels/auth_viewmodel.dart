import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String get userId => _currentUser?.id ?? 'offline-guest-user';

  bool get isGuest => _currentUser == null;

  bool get isAnonymous =>
      _currentUser == null ||
      _currentUser?.email == null ||
      _currentUser!.email!.isEmpty;

  AuthViewModel() {
    initSession();
  }

  Future<void> initSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_supabaseService.isOfflineMode) {
        final prefs = await SharedPreferences.getInstance();
        final mockEmail = prefs.getString('mock_user_email');
        final mockId = prefs.getString('mock_user_id');
        if (mockId != null) {
          _currentUser = User(
            id: mockId,
            appMetadata: const {},
            userMetadata: const {},
            aud: '',
            createdAt: DateTime.now().toIso8601String(),
            email: mockEmail,
          );
        } else {
          _currentUser = null;
        }
      } else {
        final client = Supabase.instance.client;
        final session = client.auth.currentSession;
        if (session != null) {
          _currentUser = session.user;
        } else {
          _currentUser = null;
        }
      }
    } catch (e) {
      debugPrint('AuthViewModel initSession error: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_supabaseService.isOfflineMode) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mock_user_id', 'offline-guest-user');
        await prefs.remove('mock_user_email');

        _currentUser = User(
          id: 'offline-guest-user',
          appMetadata: const {},
          userMetadata: const {},
          aud: '',
          createdAt: DateTime.now().toIso8601String(),
          email: null,
        );
      } else {
        final client = Supabase.instance.client;
        final response = await client.auth.signInAnonymously();
        _currentUser = response.user;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      debugPrint('AuthViewModel loginAnonymously auth error: $e');
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('AuthViewModel loginAnonymously error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_supabaseService.isOfflineMode) {
        final prefs = await SharedPreferences.getInstance();
        final userId = 'mock-user-${email.split('@')[0]}';
        await prefs.setString('mock_user_id', userId);
        await prefs.setString('mock_user_email', email);

        _currentUser = User(
          id: userId,
          appMetadata: const {},
          userMetadata: const {},
          aud: '',
          createdAt: DateTime.now().toIso8601String(),
          email: email,
        );
      } else {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        _currentUser = response.user;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_supabaseService.isOfflineMode) {
        final prefs = await SharedPreferences.getInstance();
        final userId = 'mock-user-${email.split('@')[0]}';
        await prefs.setString('mock_user_id', userId);
        await prefs.setString('mock_user_email', email);

        _currentUser = User(
          id: userId,
          appMetadata: const {},
          userMetadata: const {},
          aud: '',
          createdAt: DateTime.now().toIso8601String(),
          email: email,
        );
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        _currentUser = response.user;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_user_id');
      await prefs.remove('mock_user_email');

      if (!_supabaseService.isOfflineMode) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (e) {
      debugPrint('AuthViewModel signOut error: $e');
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> linkEmailAccount(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_supabaseService.isOfflineMode) {
        final prefs = await SharedPreferences.getInstance();
        final newUserId = 'mock-user-${email.split('@')[0]}';
        await prefs.setString('mock_user_id', newUserId);
        await prefs.setString('mock_user_email', email);

        _currentUser = User(
          id: newUserId,
          appMetadata: const {},
          userMetadata: const {},
          aud: '',
          createdAt: DateTime.now().toIso8601String(),
          email: email,
        );
      } else {
        final response = await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: email, password: password),
        );
        _currentUser = response.user;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
