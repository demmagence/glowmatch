import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/services/notification_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

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

  // ── account linking ─────────────────────────────────────────────────────
  bool _isSubmittingLink = false;
  bool get isSubmittingLink => _isSubmittingLink;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({required this.authViewModel}) {
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

      // Re-apply schedules after restart
      final svc = NotificationService.instance;
      await svc.init();
      if (_isNotificationsEnabled && _amEnabled) {
        await svc.scheduleAmReminder(_amTime);
      }
      if (_isNotificationsEnabled && _pmEnabled) {
        await svc.schedulePmReminder(_pmTime);
      }
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
    notifyListeners();

    final svc = NotificationService.instance;
    await svc.init();

    if (!value) {
      await svc.cancelAmReminder();
      await svc.cancelPmReminder();
    } else {
      if (_amEnabled) await svc.scheduleAmReminder(_amTime);
      if (_pmEnabled) await svc.schedulePmReminder(_pmTime);
    }
    await _save();
  }

  Future<void> toggleAmReminder(bool value) async {
    _amEnabled = value;
    notifyListeners();

    final svc = NotificationService.instance;
    await svc.init();

    if (value && _isNotificationsEnabled) {
      await svc.scheduleAmReminder(_amTime);
    } else {
      await svc.cancelAmReminder();
    }
    await _save();
  }

  Future<void> setAmTime(TimeOfDay time) async {
    _amTime = time;
    notifyListeners();

    if (_amEnabled && _isNotificationsEnabled) {
      final svc = NotificationService.instance;
      await svc.init();
      await svc.scheduleAmReminder(time);
    }
    await _save();
  }

  Future<void> togglePmReminder(bool value) async {
    _pmEnabled = value;
    notifyListeners();

    final svc = NotificationService.instance;
    await svc.init();

    if (value && _isNotificationsEnabled) {
      await svc.schedulePmReminder(_pmTime);
    } else {
      await svc.cancelPmReminder();
    }
    await _save();
  }

  Future<void> setPmTime(TimeOfDay time) async {
    _pmTime = time;
    notifyListeners();

    if (_pmEnabled && _isNotificationsEnabled) {
      final svc = NotificationService.instance;
      await svc.init();
      await svc.schedulePmReminder(time);
    }
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
