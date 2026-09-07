import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/features/profile/profile_viewmodel.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/core/services/notification_service.dart';

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
  }
}

class MockNotificationService extends NotificationService {
  MockNotificationService() : super.internal();

  int amScheduleCalls = 0;
  int pmScheduleCalls = 0;
  int amCancelCalls = 0;
  int pmCancelCalls = 0;
  int cancelAllCalls = 0;
  int reconcileCalls = 0;

  ScheduleResult amScheduleResult = const ScheduleResult.success();
  ScheduleResult pmScheduleResult = const ScheduleResult.success();

  @override
  Future<void> init({String? ianaTimeZone}) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<ScheduleResult> scheduleAmReminder(TimeOfDay time) async {
    amScheduleCalls++;
    return amScheduleResult;
  }

  @override
  Future<ScheduleResult> schedulePmReminder(TimeOfDay time) async {
    pmScheduleCalls++;
    return pmScheduleResult;
  }

  @override
  Future<void> cancelAmReminder() async {
    amCancelCalls++;
  }

  @override
  Future<void> cancelPmReminder() async {
    pmCancelCalls++;
  }

  @override
  Future<void> cancelAllReminders() async {
    cancelAllCalls++;
  }

  @override
  Future<void> reconcileReminders({
    required bool isNotificationsEnabled,
    required bool amEnabled,
    required TimeOfDay amTime,
    required bool pmEnabled,
    required TimeOfDay pmTime,
    SharedPreferences? prefs,
  }) async {
    reconcileCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProfileViewModel vm;
  late _FakeAuthViewModel fakeAuth;
  late MockNotificationService mockNotif;

  setUp(() {
    mockNotif = MockNotificationService();
    NotificationService.instance = mockNotif;
    SharedPreferences.setMockInitialValues({});
    fakeAuth = _FakeAuthViewModel();
    vm = ProfileViewModel(
      authViewModel: fakeAuth,
      notificationService: mockNotif,
    );
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

    test('toggles notifications off and persists, cancels all reminders', () async {
      await vm.toggleNotifications(false);

      expect(vm.isNotificationsEnabled, isFalse);
      expect(mockNotif.cancelAllCalls, equals(1));

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
      final vm2 = ProfileViewModel(
        authViewModel: fakeAuth,
        notificationService: mockNotif,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm2.isNotificationsEnabled, isFalse);
      expect(mockNotif.reconcileCalls, greaterThan(0));
    });
  });

  group('ProfileViewModel – Routine Reminders scheduling & error handling', () {
    test('toggling AM reminder on calls scheduleAmReminder', () async {
      await vm.toggleAmReminder(true);

      expect(vm.amEnabled, isTrue);
      expect(mockNotif.amScheduleCalls, equals(1));
      expect(vm.notificationError, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('am_reminder_enabled'), isTrue);
    });

    test('toggling AM reminder off calls cancelAmReminder', () async {
      await vm.toggleAmReminder(true);
      await vm.toggleAmReminder(false);

      expect(vm.amEnabled, isFalse);
      expect(mockNotif.amCancelCalls, equals(1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('am_reminder_enabled'), isFalse);
    });

    test('setting AM time updates time and reschedules if enabled', () async {
      await vm.toggleAmReminder(true);
      mockNotif.amScheduleCalls = 0;

      await vm.setAmTime(const TimeOfDay(hour: 8, minute: 30));

      expect(vm.amTime, equals(const TimeOfDay(hour: 8, minute: 30)));
      expect(mockNotif.amScheduleCalls, equals(1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('am_hour'), equals(8));
      expect(prefs.getInt('am_minute'), equals(30));
    });

    test('setting PM time updates time and reschedules if enabled', () async {
      await vm.togglePmReminder(true);
      mockNotif.pmScheduleCalls = 0;

      await vm.setPmTime(const TimeOfDay(hour: 21, minute: 15));

      expect(vm.pmTime, equals(const TimeOfDay(hour: 21, minute: 15)));
      expect(mockNotif.pmScheduleCalls, equals(1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('pm_hour'), equals(21));
      expect(prefs.getInt('pm_minute'), equals(15));
    });

    test('surfaces notification error when scheduling is denied', () async {
      mockNotif.amScheduleResult = const ScheduleResult.denied(
        status: NotificationPermissionStatus.notificationDenied,
        message: 'Notification permission is required.',
      );

      await vm.toggleAmReminder(true);

      expect(vm.notificationError, equals('Notification permission is required.'));
    });

    test('surfaces exact alarm error when exact alarms are denied', () async {
      mockNotif.pmScheduleResult = const ScheduleResult.denied(
        status: NotificationPermissionStatus.exactAlarmDenied,
        message: 'Exact alarm permission is required.',
      );

      await vm.togglePmReminder(true);

      expect(vm.notificationError, equals('Exact alarm permission is required.'));
    });

    test('clearNotificationError resets error message', () async {
      mockNotif.amScheduleResult = const ScheduleResult.denied(
        message: 'Error occurred',
      );
      await vm.toggleAmReminder(true);
      expect(vm.notificationError, isNotNull);

      vm.clearNotificationError();
      expect(vm.notificationError, isNull);
    });
  });
}
