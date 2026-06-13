import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/features/profile/profile_viewmodel.dart';

class MockAuthViewModel extends AuthViewModel {
  bool shouldFail = false;

  @override
  Future<void> linkEmailAccount(String email, String password) async {
    if (shouldFail) {
      throw Exception('Link failed');
    }
    await super.linkEmailAccount(email, password);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  group('ProfileViewModel Tests', () {
    late MockAuthViewModel authVm;
    late ProfileViewModel profileVm;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authVm = MockAuthViewModel();
      profileVm = ProfileViewModel(authViewModel: authVm);
    });

    test('linkEmail success path', () async {
      authVm.shouldFail = false;
      final success = await profileVm.linkEmail('test@example.com', 'password123');
      expect(success, isTrue);
      expect(profileVm.errorMessage, isNull);
      expect(profileVm.isSubmittingLink, isFalse);
    });

    test('linkEmail failure path', () async {
      authVm.shouldFail = true;
      final success = await profileVm.linkEmail('test@example.com', 'password123');
      expect(success, isFalse);
      expect(profileVm.errorMessage, equals('Link failed'));
      expect(profileVm.isSubmittingLink, isFalse);
    });

    test('toggleNotifications persistence', () async {
      SharedPreferences.setMockInitialValues({});
      
      // Toggle to false
      await profileVm.toggleNotifications(false);
      expect(profileVm.isNotificationsEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), isFalse);

      // Toggle to true
      await profileVm.toggleNotifications(true);
      expect(profileVm.isNotificationsEnabled, isTrue);
      expect(prefs.getBool('notifications_enabled'), isTrue);
    });
  });
}
