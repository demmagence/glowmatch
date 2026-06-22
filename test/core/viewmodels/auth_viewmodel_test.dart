import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseService supabaseService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    supabaseService = SupabaseService();
    supabaseService.resetForTesting();
    await supabaseService.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('AuthViewModel Tests', () {
    test('initSession sets currentUser to null when no credentials cached', () async {
      final authVm = AuthViewModel();
      
      // Wait for async initSession to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authVm.currentUser, isNull);
      expect(authVm.isGuest, isTrue);
      expect(authVm.isAnonymous, isTrue);
      expect(authVm.isLoading, isFalse);
    });

    test('initSession restores currentUser from cached mock credentials', () async {
      SharedPreferences.setMockInitialValues({
        'mock_user_id': 'mock-id-123',
        'mock_user_email': 'test@example.com',
      });

      final authVm = AuthViewModel();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authVm.currentUser, isNotNull);
      expect(authVm.currentUser!.id, equals('mock-id-123'));
      expect(authVm.currentUser!.email, equals('test@example.com'));
      expect(authVm.isGuest, isFalse);
      expect(authVm.isAnonymous, isFalse);
    });

    test('loginAnonymously logs in as anonymous guest and persists', () async {
      final authVm = AuthViewModel();
      await Future.delayed(const Duration(milliseconds: 50));

      await authVm.loginAnonymously();

      expect(authVm.currentUser, isNotNull);
      expect(authVm.currentUser!.id, equals('offline-guest-user'));
      expect(authVm.currentUser!.email, isNull);
      expect(authVm.isGuest, isFalse);
      expect(authVm.isAnonymous, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mock_user_id'), equals('offline-guest-user'));
      expect(prefs.getString('mock_user_email'), isNull);
    });

    test('signIn authenticates with email/password and persists', () async {
      final authVm = AuthViewModel();
      await Future.delayed(const Duration(milliseconds: 50));

      await authVm.signIn('user@glowmatch.com', 'password123');

      expect(authVm.currentUser, isNotNull);
      expect(authVm.currentUser!.email, equals('user@glowmatch.com'));
      expect(authVm.currentUser!.id, contains('user'));
      expect(authVm.isGuest, isFalse);
      expect(authVm.isAnonymous, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mock_user_id'), isNotNull);
      expect(prefs.getString('mock_user_email'), equals('user@glowmatch.com'));
    });

    test('signUp creates user account with email/password and persists', () async {
      final authVm = AuthViewModel();
      await Future.delayed(const Duration(milliseconds: 50));

      await authVm.signUp('new@glowmatch.com', 'password123');

      expect(authVm.currentUser, isNotNull);
      expect(authVm.currentUser!.email, equals('new@glowmatch.com'));
      expect(authVm.isGuest, isFalse);
      expect(authVm.isAnonymous, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mock_user_email'), equals('new@glowmatch.com'));
    });

    test('signOut clears currentUser and removes cached credentials', () async {
      SharedPreferences.setMockInitialValues({
        'mock_user_id': 'mock-id-123',
        'mock_user_email': 'test@example.com',
      });

      final authVm = AuthViewModel();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authVm.currentUser, isNotNull);

      await authVm.signOut();

      expect(authVm.currentUser, isNull);
      expect(authVm.isGuest, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mock_user_id'), isNull);
      expect(prefs.getString('mock_user_email'), isNull);
    });

    test('linkEmailAccount upgrades/links credentials and updates local user', () async {
      final authVm = AuthViewModel();
      await Future.delayed(const Duration(milliseconds: 50));

      await authVm.loginAnonymously();
      expect(authVm.isAnonymous, isTrue);

      await authVm.linkEmailAccount('linked@glowmatch.com', 'password123');

      expect(authVm.currentUser, isNotNull);
      expect(authVm.currentUser!.email, equals('linked@glowmatch.com'));
      expect(authVm.isAnonymous, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mock_user_email'), equals('linked@glowmatch.com'));
    });
  });
}
