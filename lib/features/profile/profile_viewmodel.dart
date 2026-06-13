import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/viewmodels/auth_viewmodel.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  bool _isNotificationsEnabled = true;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  bool _isSubmittingLink = false;
  bool get isSubmittingLink => _isSubmittingLink;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({required this.authViewModel}) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleNotifications(bool value) async {
    _isNotificationsEnabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
    } catch (_) {}
  }

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
