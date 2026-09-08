import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

enum SignUpResult { signedIn, emailConfirmationRequired }

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _pendingConfirmationEmail;
  String? get pendingConfirmationEmail => _pendingConfirmationEmail;

  bool _isPasswordRecovery = false;
  bool get isPasswordRecovery => _isPasswordRecovery;

  final bool simulateEmailConfirmation;
  StreamSubscription<AuthState>? _authSubscription;

  String get userId => _currentUser?.id ?? 'offline-guest-user';

  bool get isGuest => _currentUser == null;

  bool get isAnonymous =>
      _currentUser == null ||
      _currentUser?.email == null ||
      _currentUser!.email!.isEmpty;

  AuthViewModel({this.simulateEmailConfirmation = false}) {
    initSession();
    _listenForAuthChanges();
  }

  void _listenForAuthChanges() {
    if (_supabaseService.isOfflineMode) return;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) async {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        _currentUser = event.session?.user;
        _isPasswordRecovery = true;
        notifyListeners();
      } else if (event.event == AuthChangeEvent.signedIn &&
          event.session != null) {
        _currentUser = event.session!.user;
        _pendingConfirmationEmail = null;
        final prefs = await SharedPreferences.getInstance();
        final pendingGuestId = prefs.getString('pending_guest_migration_id');
        if (pendingGuestId != null) {
          await _migrateGuestDataOnce(_currentUser!, oldUserId: pendingGuestId);
        }
        notifyListeners();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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

    final String oldUserId = userId;

    try {
      if (_supabaseService.isOfflineMode) {
        final prefs = await SharedPreferences.getInstance();
        final mockId = 'mock-user-${email.split('@')[0]}';
        await prefs.setString('mock_user_id', mockId);
        await prefs.setString('mock_user_email', email);

        _currentUser = User(
          id: mockId,
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

      if (_currentUser != null) {
        await _migrateGuestDataOnce(_currentUser!, oldUserId: oldUserId);
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

  Future<SignUpResult> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final String oldUserId = userId;

    try {
      if (_supabaseService.isOfflineMode) {
        if (simulateEmailConfirmation) {
          _pendingConfirmationEmail = email;
          _currentUser = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('pending_guest_migration_id', oldUserId);
          return SignUpResult.emailConfirmationRequired;
        }
        final prefs = await SharedPreferences.getInstance();
        final mockId = 'mock-user-${email.split('@')[0]}';
        await prefs.setString('mock_user_id', mockId);
        await prefs.setString('mock_user_email', email);

        _currentUser = User(
          id: mockId,
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
        if (response.session == null) {
          _pendingConfirmationEmail = email;
          _currentUser = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('pending_guest_migration_id', oldUserId);
          return SignUpResult.emailConfirmationRequired;
        }
        _currentUser = response.session!.user;
      }

      if (_currentUser != null) {
        await _migrateGuestDataOnce(_currentUser!, oldUserId: oldUserId);
      }
      return SignUpResult.signedIn;
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

  Future<void> resendConfirmationEmail([String? email]) async {
    final target = email ?? _pendingConfirmationEmail;
    if (target == null || target.isEmpty) {
      throw StateError('No email address is waiting for confirmation.');
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (!_supabaseService.isOfflineMode) {
        await Supabase.instance.client.auth.resend(
          type: OtpType.signup,
          email: target,
        );
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (!_supabaseService.isOfflineMode) {
        await Supabase.instance.client.auth.resetPasswordForEmail(
          email,
          redirectTo: 'io.supabase.glowmatch://reset-password',
        );
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

  Future<void> updatePassword(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (!_supabaseService.isOfflineMode) {
        final response = await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: password),
        );
        _currentUser = response.user;
      }
      _isPasswordRecovery = false;
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

  Future<void> _migrateGuestDataOnce(User user, {String? oldUserId}) async {
    final prefs = await SharedPreferences.getInstance();
    final marker = 'guest_data_migrated_to_${user.id}';
    if (prefs.getBool(marker) ?? false) return;
    await _supabaseService.migrateLocalData(
      oldUserId ?? 'offline-guest-user',
      user.id,
    );
    await prefs.setBool(marker, true);
    await prefs.remove('pending_guest_migration_id');
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
