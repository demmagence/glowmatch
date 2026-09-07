import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/services/notification_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;
  final NotificationService notificationService;

  // ── notification master toggle ──────────────────────────────────────────
  bool _isNotificationsEnabled = true;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  // ── AM reminder ─────────────────────────────────────────────────────────
  bool _amEnabled = false;
  bool get amEnabled => _amEnabled;

  TimeOfDay _amTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay get amTime => _amTime;

  // ── PM reminder ─────────────────────────────────────────────────────────
  bool _pmEnabled = false;
  bool get pmEnabled => _pmEnabled;

  TimeOfDay _pmTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay get pmTime => _pmTime;

  // ── notification error state ────────────────────────────────────────────
  String? _notificationError;
  String? get notificationError => _notificationError;

  void clearNotificationError() {
    _notificationError = null;
    notifyListeners();
  }

  // ── account linking ─────────────────────────────────────────────────────
  bool _isSubmittingLink = false;
  bool get isSubmittingLink => _isSubmittingLink;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({
    required this.authViewModel,
    NotificationService? notificationService,
  }) : notificationService =
            notificationService ?? NotificationService.instance {
    _load();
  }

  // ── persistence helpers ─────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isNotificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;
      _amEnabled = prefs.getBool('am_reminder_enabled') ?? false;
      _pmEnabled = prefs.getBool('pm_reminder_enabled') ?? false;

      final amH = prefs.getInt('am_hour') ?? 7;
      final amM = prefs.getInt('am_minute') ?? 0;
      _amTime = TimeOfDay(hour: amH, minute: amM);

      final pmH = prefs.getInt('pm_hour') ?? 20;
      final pmM = prefs.getInt('pm_minute') ?? 0;
      _pmTime = TimeOfDay(hour: pmH, minute: pmM);

      notifyListeners();

      // Re-apply schedules after restart and reconcile timezone shifts
      await notificationService.reconcileReminders(
        isNotificationsEnabled: _isNotificationsEnabled,
        amEnabled: _amEnabled,
        amTime: _amTime,
        pmEnabled: _pmEnabled,
        pmTime: _pmTime,
        prefs: prefs,
      );
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _isNotificationsEnabled);
      await prefs.setBool('am_reminder_enabled', _amEnabled);
      await prefs.setBool('pm_reminder_enabled', _pmEnabled);
      await prefs.setInt('am_hour', _amTime.hour);
      await prefs.setInt('am_minute', _amTime.minute);
      await prefs.setInt('pm_hour', _pmTime.hour);
      await prefs.setInt('pm_minute', _pmTime.minute);
    } catch (_) {}
  }

  // ── public setters ───────────────────────────────────────────────────────

  Future<void> toggleNotifications(bool value) async {
    _isNotificationsEnabled = value;
    _notificationError = null;
    notifyListeners();

    if (!value) {
      await notificationService.cancelAllReminders();
    } else {
      if (_amEnabled) {
        final res = await notificationService.scheduleAmReminder(_amTime);
        if (!res.success) {
          _notificationError = res.errorMessage;
        }
      }
      if (_pmEnabled) {
        final res = await notificationService.schedulePmReminder(_pmTime);
        if (!res.success) {
          _notificationError = res.errorMessage;
        }
      }
    }
    notifyListeners();
    await _save();
  }

  Future<void> toggleAmReminder(bool value) async {
    _amEnabled = value;
    _notificationError = null;
    notifyListeners();

    if (value && _isNotificationsEnabled) {
      final res = await notificationService.scheduleAmReminder(_amTime);
      if (!res.success) {
        _notificationError = res.errorMessage;
      }
    } else {
      await notificationService.cancelAmReminder();
    }
    notifyListeners();
    await _save();
  }

  Future<void> setAmTime(TimeOfDay time) async {
    _amTime = time;
    _notificationError = null;
    notifyListeners();

    if (_amEnabled && _isNotificationsEnabled) {
      final res = await notificationService.scheduleAmReminder(time);
      if (!res.success) {
        _notificationError = res.errorMessage;
      }
    }
    notifyListeners();
    await _save();
  }

  Future<void> togglePmReminder(bool value) async {
    _pmEnabled = value;
    _notificationError = null;
    notifyListeners();

    if (value && _isNotificationsEnabled) {
      final res = await notificationService.schedulePmReminder(_pmTime);
      if (!res.success) {
        _notificationError = res.errorMessage;
      }
    } else {
      await notificationService.cancelPmReminder();
    }
    notifyListeners();
    await _save();
  }

  Future<void> setPmTime(TimeOfDay time) async {
    _pmTime = time;
    _notificationError = null;
    notifyListeners();

    if (_pmEnabled && _isNotificationsEnabled) {
      final res = await notificationService.schedulePmReminder(time);
      if (!res.success) {
        _notificationError = res.errorMessage;
      }
    }
    notifyListeners();
    await _save();
  }

  // ── account linking ──────────────────────────────────────────────────────

  Future<bool> linkEmail(String email, String password) async {
    _isSubmittingLink = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authViewModel.linkEmailAccount(email, password);
      _isSubmittingLink = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmittingLink = false;
      notifyListeners();
      return false;
    }
  }
}
