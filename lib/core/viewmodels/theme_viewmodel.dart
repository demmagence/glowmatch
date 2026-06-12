import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeViewModel() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_themeKey);
      if (modeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (modeString == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.light; // Default to light mode for GlowMatch
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ThemeViewModel: Failed to load theme: $e');
    }
  }

  Future<void> toggleThemeMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('ThemeViewModel: Failed to save theme: $e');
    }
  }
}
