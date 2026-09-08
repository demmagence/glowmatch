import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationPermissionStatus {
  granted,
  notificationDenied,
  exactAlarmDenied,
  error,
}

class ScheduleResult {
  final bool success;
  final NotificationPermissionStatus status;
  final String? errorMessage;

  const ScheduleResult({
    required this.success,
    required this.status,
    this.errorMessage,
  });

  const ScheduleResult.success()
      : success = true,
        status = NotificationPermissionStatus.granted,
        errorMessage = null;

  const ScheduleResult.denied({
    this.status = NotificationPermissionStatus.notificationDenied,
    String? message,
  })  : success = false,
        errorMessage = message;

  const ScheduleResult.error(String message)
      : success = false,
        status = NotificationPermissionStatus.error,
        errorMessage = message;
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  @visibleForTesting
  NotificationService.internal({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static NotificationService instance = NotificationService.internal();

  static const int amNotificationId = 0;
  static const int pmNotificationId = 1;
  static const String scheduledTimezoneKey = 'scheduled_timezone';

  bool _initialized = false;
  bool get isInitialized => _initialized;

  bool _timezoneConfigured = false;

  String _currentTimeZone = 'UTC';
  String get currentTimeZone => _currentTimeZone;

  /// Initializes timezone database and local notification plugin.
  /// If [ianaTimeZone] is provided, sets local timezone directly (useful for tests).
  Future<void> init({String? ianaTimeZone}) async {
    if (_initialized && ianaTimeZone == null) return;

    try {
      if (ianaTimeZone != null || !_timezoneConfigured) {
        await configureLocalTimeZone(ianaTimeZone);
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Configures local timezone using IANA timezone string or device timezone.
  /// Falls back safely to UTC if location cannot be resolved.
  Future<void> configureLocalTimeZone([String? ianaTimeZone]) async {
    try {
      tz.initializeTimeZones();
      String timeZoneName;
      if (ianaTimeZone != null && ianaTimeZone.isNotEmpty) {
        timeZoneName = ianaTimeZone;
      } else {
        try {
          final info = await FlutterTimezone.getLocalTimezone();
          timeZoneName = info.identifier;
        } catch (e) {
          debugPrint('FlutterTimezone getLocalTimezone error: $e');
          timeZoneName = 'UTC';
        }
      }

      try {
        final location = tz.getLocation(timeZoneName);
        tz.setLocalLocation(location);
        _currentTimeZone = timeZoneName;
      } catch (e) {
        debugPrint(
          'tz.getLocation failed for $timeZoneName, falling back to UTC: $e',
        );
        tz.setLocalLocation(tz.getLocation('UTC'));
        _currentTimeZone = 'UTC';
      }
    } catch (e) {
      debugPrint('NotificationService configureLocalTimeZone error: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
      _currentTimeZone = 'UTC';
    } finally {
      _timezoneConfigured = true;
    }
  }

  /// Checks and requests notifications and exact-alarm permissions.
  Future<NotificationPermissionStatus> checkAndRequestPermissions() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final notifGranted =
            await android.requestNotificationsPermission() ?? false;
        if (!notifGranted) {
          return NotificationPermissionStatus.notificationDenied;
        }

        final canExact =
            await android.canScheduleExactNotifications() ?? true;
        if (!canExact) {
          try {
            await android.requestExactAlarmsPermission();
            final canExactAfter =
                await android.canScheduleExactNotifications() ?? true;
            if (!canExactAfter) {
              return NotificationPermissionStatus.exactAlarmDenied;
            }
          } catch (e) {
            debugPrint('requestExactAlarmsPermission error: $e');
            return NotificationPermissionStatus.exactAlarmDenied;
          }
        }
        return NotificationPermissionStatus.granted;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final granted = await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        return granted
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.notificationDenied;
      }

      return NotificationPermissionStatus.granted;
    } catch (e) {
      debugPrint('NotificationService checkAndRequestPermissions error: $e');
      return NotificationPermissionStatus.error;
    }
  }

  /// Backward compatible requestPermission method.
  Future<bool> requestPermission() async {
    final status = await checkAndRequestPermissions();
    return status == NotificationPermissionStatus.granted;
  }

  /// Schedules AM reminder. Automatically replaces existing AM schedule.
  Future<ScheduleResult> scheduleAmReminder(TimeOfDay time) async {
    await cancelAmReminder();
    return _scheduleDailyNotification(
      id: amNotificationId,
      title: '🌅 Morning Routine',
      body: 'Time for your AM skincare routine. Start glowing!',
      time: time,
    );
  }

  /// Schedules PM reminder. Automatically replaces existing PM schedule.
  Future<ScheduleResult> schedulePmReminder(TimeOfDay time) async {
    await cancelPmReminder();
    return _scheduleDailyNotification(
      id: pmNotificationId,
      title: '🌙 Evening Routine',
      body: 'Wind down with your PM skincare routine.',
      time: time,
    );
  }

  Future<void> cancelAmReminder() async => _cancelById(amNotificationId);
  Future<void> cancelPmReminder() async => _cancelById(pmNotificationId);

  Future<void> cancelAllReminders() async {
    await _cancelById(amNotificationId);
    await _cancelById(pmNotificationId);
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint(
        'NotificationService getPendingNotificationRequests error: $e',
      );
      return [];
    }
  }

  Future<void> _cancelById(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('NotificationService cancel error: $e');
    }
  }

  Future<ScheduleResult> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final permStatus = await checkAndRequestPermissions();
    if (permStatus != NotificationPermissionStatus.granted) {
      final msg = permStatus == NotificationPermissionStatus.exactAlarmDenied
          ? 'Exact alarm permission is required for scheduled routine reminders.'
          : 'Notification permission is required to receive routine reminders.';
      return ScheduleResult.denied(
        status: permStatus,
        message: msg,
      );
    }

    const androidDetails = AndroidNotificationDetails(
      'glowmatch_routine_channel',
      'Routine Reminders',
      channelDescription: 'Daily AM and PM skincare routine reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        nextInstanceOfTime(time),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return const ScheduleResult.success();
    } catch (e) {
      debugPrint('NotificationService zonedSchedule error: $e');
      return ScheduleResult.error(e.toString());
    }
  }

  /// Calculates next valid instance of [time] in local or given [location].
  /// If the time has already passed today (or is right now), schedules for tomorrow.
  tz.TZDateTime nextInstanceOfTime(
    TimeOfDay time, {
    tz.Location? location,
    DateTime? fromTime,
  }) {
    final loc = location ?? tz.local;
    final now = fromTime != null
        ? tz.TZDateTime.from(fromTime, loc)
        : tz.TZDateTime.now(loc);
    var scheduled = tz.TZDateTime(
      loc,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Reconciles active reminder preferences against pending notifications
  /// and detects device timezone changes or restarts.
  Future<void> reconcileReminders({
    required bool isNotificationsEnabled,
    required bool amEnabled,
    required TimeOfDay amTime,
    required bool pmEnabled,
    required TimeOfDay pmTime,
    SharedPreferences? prefs,
  }) async {
    await init();

    final sp = prefs ?? await SharedPreferences.getInstance();
    final lastScheduledTz = sp.getString(scheduledTimezoneKey);
    final currentTz = _currentTimeZone;
    final timezoneChanged =
        lastScheduledTz != null && lastScheduledTz != currentTz;

    if (!isNotificationsEnabled) {
      await cancelAllReminders();
      await sp.remove(scheduledTimezoneKey);
      return;
    }

    final pending = await getPendingNotificationRequests();
    final pendingIds = pending.map((e) => e.id).toSet();

    // AM Reminder reconciliation
    if (amEnabled) {
      if (timezoneChanged || !pendingIds.contains(amNotificationId)) {
        await scheduleAmReminder(amTime);
      }
    } else {
      if (pendingIds.contains(amNotificationId)) {
        await cancelAmReminder();
      }
    }

    // PM Reminder reconciliation
    if (pmEnabled) {
      if (timezoneChanged || !pendingIds.contains(pmNotificationId)) {
        await schedulePmReminder(pmTime);
      }
    } else {
      if (pendingIds.contains(pmNotificationId)) {
        await cancelPmReminder();
      }
    }

    await sp.setString(scheduledTimezoneKey, currentTz);
  }
}
