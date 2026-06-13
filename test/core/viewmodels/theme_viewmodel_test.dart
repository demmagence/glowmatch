import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/viewmodels/theme_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeViewModel Tests', () {
    late ThemeViewModel themeVm;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeVm = ThemeViewModel();
    });

    test('toggleThemeMode(true) sets ThemeMode.dark and persists', () async {
      await themeVm.toggleThemeMode(true);
      expect(themeVm.themeMode, equals(ThemeMode.dark));
      expect(themeVm.isDarkMode, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    test('toggleThemeMode(false) sets ThemeMode.light and persists', () async {
      await themeVm.toggleThemeMode(false);
      expect(themeVm.themeMode, equals(ThemeMode.light));
      expect(themeVm.isDarkMode, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('light'));
    });
  });
}
