import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FakeAndroidNotificationsPlugin extends Fake
    implements AndroidFlutterLocalNotificationsPlugin {
  bool notificationPermissionGranted = true;
  bool canScheduleExact = true;
  int requestExactAlarmsCalls = 0;

  @override
  Future<bool?> requestNotificationsPermission() async {
    return notificationPermissionGranted;
  }

  @override
  Future<bool?> canScheduleExactNotifications() async {
    return canScheduleExact;
  }

  @override
  Future<bool?> requestExactAlarmsPermission() async {
    requestExactAlarmsCalls++;
    return true;
  }
}

class FakeFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  bool initialized = false;
  final List<int> canceledIds = [];
  final List<Map<String, dynamic>> scheduledCalls = [];
  final List<PendingNotificationRequest> pendingRequests = [];
  bool throwOnSchedule = false;
  FakeAndroidNotificationsPlugin fakeAndroid = FakeAndroidNotificationsPlugin();

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    initialized = true;
    return true;
  }

  @override
  T? resolvePlatformSpecificImplementation<
      T extends FlutterLocalNotificationsPlatform>() {
    if (T == AndroidFlutterLocalNotificationsPlugin) {
      return fakeAndroid as T?;
    }
    return null;
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    canceledIds.add(id);
    pendingRequests.removeWhere((req) => req.id == id);
  }

  @override
  Future<void> cancelAll() async {
    canceledIds.addAll(pendingRequests.map((e) => e.id));
    pendingRequests.clear();
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    if (throwOnSchedule) {
      throw Exception('Failed to schedule notification');
    }
    scheduledCalls.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'notificationDetails': notificationDetails,
      'androidScheduleMode': androidScheduleMode,
    });
    pendingRequests.add(PendingNotificationRequest(id, title, body, payload));
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return List.unmodifiable(pendingRequests);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  late FakeFlutterLocalNotificationsPlugin fakePlugin;
  late NotificationService service;

  setUp(() {
    fakePlugin = FakeFlutterLocalNotificationsPlugin();
    service = NotificationService.internal(plugin: fakePlugin);
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationService – Timezone Configuration', () {
    test('configures IANA timezone Asia/Jakarta', () async {
      await service.configureLocalTimeZone('Asia/Jakarta');
      expect(service.currentTimeZone, equals('Asia/Jakarta'));
      expect(tz.local.name, equals('Asia/Jakarta'));
    });

    test('configures IANA timezone America/New_York', () async {
      await service.configureLocalTimeZone('America/New_York');
      expect(service.currentTimeZone, equals('America/New_York'));
      expect(tz.local.name, equals('America/New_York'));
    });

    test('falls back gracefully to UTC on invalid timezone without crashing', () async {
      await service.configureLocalTimeZone('Invalid/Unknown_Zone');
      expect(service.currentTimeZone, equals('UTC'));
      expect(tz.local.name, equals('UTC'));
    });

    test('init with ianaTimeZone sets local timezone and initializes plugin', () async {
      await service.init(ianaTimeZone: 'Asia/Tokyo');
      expect(service.currentTimeZone, equals('Asia/Tokyo'));
      expect(service.isInitialized, isTrue);
      expect(fakePlugin.initialized, isTrue);
    });
  });

  group('NotificationService – nextInstanceOfTime Calculation', () {
    test('schedules for same day when target time is in the future today', () {
      final loc = tz.getLocation('Asia/Jakarta');
      final fromTime = DateTime.utc(2026, 9, 7, 1, 0); // 08:00 WIB
      final targetTime = const TimeOfDay(hour: 9, minute: 30);

      final next = service.nextInstanceOfTime(
        targetTime,
        location: loc,
        fromTime: fromTime,
      );

      expect(next.year, equals(2026));
      expect(next.month, equals(9));
      expect(next.day, equals(7));
      expect(next.hour, equals(9));
      expect(next.minute, equals(30));
      expect(next.isAfter(tz.TZDateTime.from(fromTime, loc)), isTrue);
    });

    test('schedules for next day when target time has already passed today', () {
      final loc = tz.getLocation('Asia/Jakarta');
      final fromTime = DateTime.utc(2026, 9, 7, 3, 0); // 10:00 WIB
      final targetTime = const TimeOfDay(hour: 7, minute: 0);

      final next = service.nextInstanceOfTime(
        targetTime,
        location: loc,
        fromTime: fromTime,
      );

      expect(next.year, equals(2026));
      expect(next.month, equals(9));
      expect(next.day, equals(8)); // +1 day
      expect(next.hour, equals(7));
      expect(next.minute, equals(0));
      expect(next.isAfter(tz.TZDateTime.from(fromTime, loc)), isTrue);
    });

    test('schedules for next day when target time is at exact same moment', () {
      final loc = tz.getLocation('Asia/Jakarta');
      final fromTime = tz.TZDateTime(loc, 2026, 9, 7, 7, 0);
      final targetTime = const TimeOfDay(hour: 7, minute: 0);

      final next = service.nextInstanceOfTime(
        targetTime,
        location: loc,
        fromTime: fromTime,
      );

      expect(next.year, equals(2026));
      expect(next.month, equals(9));
      expect(next.day, equals(8)); // +1 day
      expect(next.hour, equals(7));
      expect(next.minute, equals(0));
    });

    test('respects different timezones for wall-clock time', () {
      final jakartaLoc = tz.getLocation('Asia/Jakarta');
      final nyLoc = tz.getLocation('America/New_York');

      final targetTime = const TimeOfDay(hour: 7, minute: 0);

      final jakartaNext = service.nextInstanceOfTime(targetTime, location: jakartaLoc);
      final nyNext = service.nextInstanceOfTime(targetTime, location: nyLoc);

      expect(jakartaNext.hour, equals(7));
      expect(nyNext.hour, equals(7));
      expect(jakartaNext.location.name, equals('Asia/Jakarta'));
      expect(nyNext.location.name, equals('America/New_York'));
    });
  });

  group('NotificationService – Scheduling & Independent Reminders', () {
    setUp(() async {
      await service.configureLocalTimeZone('Asia/Jakarta');
    });

    test('scheduleAmReminder cancels old AM reminder before scheduling new one', () async {
      final res = await service.scheduleAmReminder(const TimeOfDay(hour: 7, minute: 0));

      expect(res.success, isTrue);
      expect(fakePlugin.canceledIds, contains(NotificationService.amNotificationId));
      expect(fakePlugin.scheduledCalls.length, equals(1));
      expect(fakePlugin.scheduledCalls.first['id'], equals(NotificationService.amNotificationId));
      expect(fakePlugin.scheduledCalls.first['title'], contains('Morning Routine'));
    });

    test('rescheduling AM reminder replaces previous schedule without duplicates', () async {
      await service.scheduleAmReminder(const TimeOfDay(hour: 7, minute: 0));
      await service.scheduleAmReminder(const TimeOfDay(hour: 8, minute: 0));

      expect(fakePlugin.canceledIds.where((id) => id == NotificationService.amNotificationId).length, equals(2));
      final pending = await service.getPendingNotificationRequests();
      expect(pending.where((p) => p.id == NotificationService.amNotificationId).length, equals(1));
    });

    test('schedulePmReminder cancels old PM reminder before scheduling new one', () async {
      final res = await service.schedulePmReminder(const TimeOfDay(hour: 20, minute: 0));

      expect(res.success, isTrue);
      expect(fakePlugin.canceledIds, contains(NotificationService.pmNotificationId));
      expect(fakePlugin.scheduledCalls.length, equals(1));
      expect(fakePlugin.scheduledCalls.first['id'], equals(NotificationService.pmNotificationId));
      expect(fakePlugin.scheduledCalls.first['title'], contains('Evening Routine'));
    });

    test('AM and PM reminders are completely independent in cancelation', () async {
      await service.scheduleAmReminder(const TimeOfDay(hour: 7, minute: 0));
      await service.schedulePmReminder(const TimeOfDay(hour: 20, minute: 0));

      var pending = await service.getPendingNotificationRequests();
      expect(pending.length, equals(2));

      await service.cancelAmReminder();
      pending = await service.getPendingNotificationRequests();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals(NotificationService.pmNotificationId));

      await service.cancelPmReminder();
      pending = await service.getPendingNotificationRequests();
      expect(pending.isEmpty, isTrue);
    });

    test('cancelAllReminders cancels both AM and PM reminders', () async {
      await service.scheduleAmReminder(const TimeOfDay(hour: 7, minute: 0));
      await service.schedulePmReminder(const TimeOfDay(hour: 20, minute: 0));

      await service.cancelAllReminders();

      expect(fakePlugin.canceledIds, contains(NotificationService.amNotificationId));
      expect(fakePlugin.canceledIds, contains(NotificationService.pmNotificationId));
      final pending = await service.getPendingNotificationRequests();
      expect(pending.isEmpty, isTrue);
    });
  });

  group('NotificationService – Permission & Exact Alarm Denials', () {
    test('returns denied when notification permission is rejected', () async {
      fakePlugin.fakeAndroid.notificationPermissionGranted = false;

      final res = await service.scheduleAmReminder(const TimeOfDay(hour: 7, minute: 0));

      expect(res.success, isFalse);
      expect(res.status, equals(NotificationPermissionStatus.notificationDenied));
      expect(res.errorMessage, contains('Notification permission is required'));
      expect(fakePlugin.scheduledCalls.isEmpty, isTrue);
    });

    test('returns denied when exact alarm capability is rejected', () async {
      fakePlugin.fakeAndroid.notificationPermissionGranted = true;
      fakePlugin.fakeAndroid.canScheduleExact = false;

      final res = await service.schedulePmReminder(const TimeOfDay(hour: 20, minute: 0));

      expect(res.success, isFalse);
      expect(res.status, equals(NotificationPermissionStatus.exactAlarmDenied));
      expect(res.errorMessage, contains('Exact alarm permission is required'));
      expect(fakePlugin.scheduledCalls.isEmpty, isTrue);
    });

    test('surfaces error result when zonedSchedule throws exception', () async {
      fakePlugin.throwOnSchedule = true;

      final res = await service.scheduleAmReminder(const TimeOfDay(hour: 7, minute: 0));

      expect(res.success, isFalse);
      expect(res.status, equals(NotificationPermissionStatus.error));
      expect(res.errorMessage, contains('Failed to schedule notification'));
    });
  });

  group('NotificationService – Reconcile Reminders', () {
    test('cancels all reminders and clears timezone when notifications disabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(NotificationService.scheduledTimezoneKey, 'Asia/Jakarta');
      await service.scheduleAmReminder(const TimeOfDay(hour: 7, minute: 0));

      await service.reconcileReminders(
        isNotificationsEnabled: false,
        amEnabled: true,
        amTime: const TimeOfDay(hour: 7, minute: 0),
        pmEnabled: true,
        pmTime: const TimeOfDay(hour: 20, minute: 0),
        prefs: prefs,
      );

      expect(prefs.getString(NotificationService.scheduledTimezoneKey), isNull);
      final pending = await service.getPendingNotificationRequests();
      expect(pending.isEmpty, isTrue);
    });

    test('reschedules reminders when device timezone has changed', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(NotificationService.scheduledTimezoneKey, 'UTC');

      await service.configureLocalTimeZone('Asia/Jakarta');
      fakePlugin.scheduledCalls.clear();

      await service.reconcileReminders(
        isNotificationsEnabled: true,
        amEnabled: true,
        amTime: const TimeOfDay(hour: 7, minute: 0),
        pmEnabled: true,
        pmTime: const TimeOfDay(hour: 20, minute: 0),
        prefs: prefs,
      );

      expect(fakePlugin.scheduledCalls.length, equals(2));
      expect(prefs.getString(NotificationService.scheduledTimezoneKey), equals('Asia/Jakarta'));
    });

    test('reschedules missing pending reminders when enabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await service.configureLocalTimeZone('Asia/Jakarta');
      await prefs.setString(NotificationService.scheduledTimezoneKey, 'Asia/Jakarta');

      fakePlugin.scheduledCalls.clear();

      await service.reconcileReminders(
        isNotificationsEnabled: true,
        amEnabled: true,
        amTime: const TimeOfDay(hour: 7, minute: 0),
        pmEnabled: false,
        pmTime: const TimeOfDay(hour: 20, minute: 0),
        prefs: prefs,
      );

      expect(fakePlugin.scheduledCalls.length, equals(1));
      expect(fakePlugin.scheduledCalls.first['id'], equals(NotificationService.amNotificationId));
    });

    test('cancels lingering pending reminders when reminder was disabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await service.configureLocalTimeZone('Asia/Jakarta');
      await prefs.setString(NotificationService.scheduledTimezoneKey, 'Asia/Jakarta');

      await service.schedulePmReminder(const TimeOfDay(hour: 20, minute: 0));
      expect((await service.getPendingNotificationRequests()).length, equals(1));

      await service.reconcileReminders(
        isNotificationsEnabled: true,
        amEnabled: false,
        amTime: const TimeOfDay(hour: 7, minute: 0),
        pmEnabled: false,
        pmTime: const TimeOfDay(hour: 20, minute: 0),
        prefs: prefs,
      );

      final pending = await service.getPendingNotificationRequests();
      expect(pending.isEmpty, isTrue);
    });
  });
}
