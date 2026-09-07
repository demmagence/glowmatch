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

  group('ThemeViewModel Locale Management', () {
    test('defaults to null locale (system default) on first launch', () {
      expect(vm.locale, isNull);
    });

    test('setLocale with languageCode updates locale and persists to SharedPreferences', () async {
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      await vm.setLocale('id');

      expect(vm.locale, equals(const Locale('id')));
      expect(notifyCount, greaterThanOrEqualTo(1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale_code'), equals('id'));
    });

    test('setLocale(null) resets locale to system default and clears SharedPreferences', () async {
      await vm.setLocale('en');
      expect(vm.locale, equals(const Locale('en')));

      await vm.setLocale(null);
      expect(vm.locale, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('locale_code'), isFalse);
    });

    test('loads saved locale from SharedPreferences on construction', () async {
      SharedPreferences.setMockInitialValues({'locale_code': 'id'});
      final vm2 = ThemeViewModel();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(vm2.locale, equals(const Locale('id')));
    });
  });
}
