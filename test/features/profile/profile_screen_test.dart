import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/notification_service.dart';
import 'package:glowmatch/core/services/supabase_service.dart';
import 'package:glowmatch/core/viewmodels/auth_viewmodel.dart';
import 'package:glowmatch/core/viewmodels/currency_viewmodel.dart';
import 'package:glowmatch/core/viewmodels/theme_viewmodel.dart';
import 'package:glowmatch/features/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockNotificationService extends NotificationService {
  _MockNotificationService() : super.internal();

  ScheduleResult scheduleResult = const ScheduleResult.success();
  int scheduleAmCalls = 0;
  int schedulePmCalls = 0;
  int cancelAmCalls = 0;
  int cancelPmCalls = 0;
  int cancelAllCalls = 0;

  @override
  Future<void> init({String? ianaTimeZone}) async {}

  @override
  Future<ScheduleResult> scheduleAmReminder(TimeOfDay time) async {
    scheduleAmCalls++;
    return scheduleResult;
  }

  @override
  Future<ScheduleResult> schedulePmReminder(TimeOfDay time) async {
    schedulePmCalls++;
    return scheduleResult;
  }

  @override
  Future<void> cancelAmReminder() async {
    cancelAmCalls++;
  }

  @override
  Future<void> cancelPmReminder() async {
    cancelPmCalls++;
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
    String? ianaTimeZone,
  }) async {}
}

Widget _buildProfileScreen() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => CurrencyViewModel()),
    ],
    child: const MaterialApp(home: ProfileScreen()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockNotificationService mockNotif;

  setUpAll(() async {
    final svc = SupabaseService();
    svc.resetForTesting();
    await svc.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
  });

  setUp(() {
    mockNotif = _MockNotificationService();
    NotificationService.instance = mockNotif;
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': true,
      'am_reminder_enabled': true,
      'pm_reminder_enabled': true,
      'am_hour': 7,
      'am_minute': 0,
      'pm_hour': 20,
      'pm_minute': 0,
    });
  });

  testWidgets('ProfileScreen renders Routine Reminders and AM/PM rows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildProfileScreen());
    await tester.pumpAndSettle();

    expect(find.text('Routine Reminders'), findsOneWidget);
    expect(find.text('🌅  AM Reminder'), findsOneWidget);
    expect(find.text('🌙  PM Reminder'), findsOneWidget);
  });

  testWidgets(
    'ProfileScreen displays notification error banner when permission denied',
    (tester) async {
      mockNotif.scheduleResult = const ScheduleResult.denied(
        status: NotificationPermissionStatus.notificationDenied,
        message: 'Notification permission is required for routine reminders.',
      );

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildProfileScreen());
      await tester.pumpAndSettle();

      // Toggle AM switch off then back on to trigger denied scheduleResult
      final amSwitch = find.widgetWithText(SwitchListTile, '🌅  AM Reminder');
      expect(amSwitch, findsOneWidget);

      await tester.tap(amSwitch);
      await tester.pumpAndSettle();

      await tester.tap(amSwitch);
      await tester.pumpAndSettle();

      expect(
        find.text('Notification permission is required for routine reminders.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    },
  );
}
