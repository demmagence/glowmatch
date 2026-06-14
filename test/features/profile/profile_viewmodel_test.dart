import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/features/profile/profile_viewmodel.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';

/// A minimal fake AuthViewModel that simulates linkEmailAccount behavior.
class _FakeAuthViewModel extends AuthViewModel {
  bool shouldThrow = false;
  String? lastLinkedEmail;
  String? lastLinkedPassword;

  @override
  Future<void> linkEmailAccount(String email, String password) async {
    lastLinkedEmail = email;
    lastLinkedPassword = password;
    if (shouldThrow) {
      throw Exception('Linking failed: email already in use');
    }
    // Simulate successful linking (no-op in fake)
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProfileViewModel vm;
  late _FakeAuthViewModel fakeAuth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeAuth = _FakeAuthViewModel();
    vm = ProfileViewModel(authViewModel: fakeAuth);
  });

  group('ProfileViewModel – linkEmail', () {
    test('succeeds and returns true on valid link', () async {
      final result = await vm.linkEmail('test@example.com', 'password123');

      expect(result, isTrue);
      expect(vm.errorMessage, isNull);
      expect(vm.isSubmittingLink, isFalse);
      expect(fakeAuth.lastLinkedEmail, equals('test@example.com'));
      expect(fakeAuth.lastLinkedPassword, equals('password123'));
    });

    test('returns false and sets errorMessage on failure', () async {
      fakeAuth.shouldThrow = true;

      final result = await vm.linkEmail('test@example.com', 'password123');

      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(vm.errorMessage, contains('email already in use'));
      expect(vm.isSubmittingLink, isFalse);
    });

    test('sets isSubmittingLink to true during submission', () async {
      // Capture the submitting state mid-flight
      bool wasSubmitting = false;
      vm.addListener(() {
        if (vm.isSubmittingLink) wasSubmitting = true;
      });

      await vm.linkEmail('test@example.com', 'password123');

      expect(wasSubmitting, isTrue);
      expect(vm.isSubmittingLink, isFalse);
    });
  });

  group('ProfileViewModel – toggleNotifications', () {
    test('defaults to notifications enabled', () {
      expect(vm.isNotificationsEnabled, isTrue);
    });

    test('toggles notifications off and persists', () async {
      await vm.toggleNotifications(false);

      expect(vm.isNotificationsEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), isFalse);
    });

    test('toggles notifications on and persists', () async {
      await vm.toggleNotifications(false);
      await vm.toggleNotifications(true);

      expect(vm.isNotificationsEnabled, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), isTrue);
    });

    test('loads persisted notification setting on construction', () async {
      SharedPreferences.setMockInitialValues({'notifications_enabled': false});
      final vm2 = ProfileViewModel(authViewModel: fakeAuth);

      // Wait for async _loadNotifications
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm2.isNotificationsEnabled, isFalse);
    });
  });
}
