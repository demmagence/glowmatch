import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale_code';
  ThemeMode _themeMode = ThemeMode.light;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Locale? get locale => _locale;

  ThemeViewModel() {
    _loadTheme();
    _loadLocale();
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
        _themeMode = ThemeMode.light;
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

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null && localeCode.isNotEmpty) {
        _locale = Locale(localeCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ThemeViewModel: Failed to load locale: $e');
    }
  }

  Future<void> setLocale(String? languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (languageCode == null || languageCode.isEmpty) {
        _locale = null;
        await prefs.remove(_localeKey);
      } else {
        _locale = Locale(languageCode);
        await prefs.setString(_localeKey, languageCode);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ThemeViewModel: Failed to save locale: $e');
    }
  }
}
