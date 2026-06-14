import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/viewmodels/theme_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeViewModel vm;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vm = ThemeViewModel();
  });

  group('ThemeViewModel', () {
    test('defaults to light mode on first launch', () {
      expect(vm.themeMode, equals(ThemeMode.light));
      expect(vm.isDarkMode, isFalse);
    });

    test('toggleThemeMode(true) sets ThemeMode.dark', () async {
      await vm.toggleThemeMode(true);
      expect(vm.themeMode, equals(ThemeMode.dark));
      expect(vm.isDarkMode, isTrue);
    });

    test('toggleThemeMode(false) sets ThemeMode.light', () async {
      await vm.toggleThemeMode(true);
      expect(vm.isDarkMode, isTrue);

      await vm.toggleThemeMode(false);
      expect(vm.themeMode, equals(ThemeMode.light));
      expect(vm.isDarkMode, isFalse);
    });

    test('persists dark mode to SharedPreferences', () async {
      await vm.toggleThemeMode(true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    test('persists light mode to SharedPreferences', () async {
      await vm.toggleThemeMode(true);
      await vm.toggleThemeMode(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('light'));
    });

    test('loads saved dark theme on construction', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final vm2 = ThemeViewModel();

      // Wait for async _loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm2.themeMode, equals(ThemeMode.dark));
      expect(vm2.isDarkMode, isTrue);
    });

    test('loads saved light theme on construction', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final vm2 = ThemeViewModel();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm2.themeMode, equals(ThemeMode.light));
      expect(vm2.isDarkMode, isFalse);
    });

    test('notifies listeners on toggle', () async {
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      await vm.toggleThemeMode(true);
      expect(notifyCount, greaterThanOrEqualTo(1));
    });
  });
}
