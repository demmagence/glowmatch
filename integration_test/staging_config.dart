import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Configuration loader for real Supabase staging integration tests.
///
/// Loads staging credentials from non-committed sources in priority order:
/// 1. Compile-time defines (--dart-define or --dart-define-from-file=secrets.json)
/// 2. Process environment variables (SUPABASE_TEST_URL, SUPABASE_TEST_ANON_KEY)
/// 3. Local secrets.json file (git-ignored)
///
/// Throws [TestFailure] when required staging configuration is absent.
class StagingConfig {
  final String url;
  final String anonKey;
  final String? testEmail;
  final String? testPassword;

  const StagingConfig({
    required this.url,
    required this.anonKey,
    this.testEmail,
    this.testPassword,
  });

  bool get isConfigured {
    if (url.isEmpty || anonKey.isEmpty) return false;
    if (url == 'YOUR_URL' || url == 'YOUR_SUPABASE_URL') return false;
    if (anonKey == 'YOUR_KEY' || anonKey == 'YOUR_SUPABASE_ANON_KEY') {
      return false;
    }
    if (url.contains('YOUR_') || anonKey.contains('YOUR_')) return false;
    return true;
  }

  bool get hasTestCredentials =>
      testEmail != null &&
      testEmail!.isNotEmpty &&
      testPassword != null &&
      testPassword!.isNotEmpty;

  /// Attempts to load staging configuration without throwing if absent.
  static StagingConfig? tryLoad() {
    // 1. From compile-time defines
    String url = const String.fromEnvironment(
      'SUPABASE_TEST_URL',
      defaultValue: '',
    );
    if (url.isEmpty) {
      url = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    }

    String anonKey = const String.fromEnvironment(
      'SUPABASE_TEST_ANON_KEY',
      defaultValue: '',
    );
    if (anonKey.isEmpty) {
      anonKey = const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      );
    }

    String testEmail = const String.fromEnvironment(
      'SUPABASE_TEST_EMAIL',
      defaultValue: '',
    );
    String testPassword = const String.fromEnvironment(
      'SUPABASE_TEST_PASSWORD',
      defaultValue: '',
    );

    // 2. From runtime platform environment
    try {
      if (url.isEmpty || url.contains('YOUR_')) {
        url =
            Platform.environment['SUPABASE_TEST_URL'] ??
            Platform.environment['SUPABASE_URL'] ??
            url;
      }
      if (anonKey.isEmpty || anonKey.contains('YOUR_')) {
        anonKey =
            Platform.environment['SUPABASE_TEST_ANON_KEY'] ??
            Platform.environment['SUPABASE_ANON_KEY'] ??
            anonKey;
      }
      if (testEmail.isEmpty) {
        testEmail = Platform.environment['SUPABASE_TEST_EMAIL'] ?? testEmail;
      }
      if (testPassword.isEmpty) {
        testPassword =
            Platform.environment['SUPABASE_TEST_PASSWORD'] ?? testPassword;
      }
    } catch (_) {
      // Platform.environment unavailable on some test targets
    }

    // 3. From non-committed secrets.json at repo root or parent directories
    if (url.isEmpty ||
        anonKey.isEmpty ||
        url.contains('YOUR_') ||
        anonKey.contains('YOUR_')) {
      for (final candidate in [
        'secrets.json',
        '../secrets.json',
        '../../secrets.json',
      ]) {
        try {
          final file = File(candidate);
          if (file.existsSync()) {
            final raw = file.readAsStringSync();
            final parsed = jsonDecode(raw);
            if (parsed is Map<String, dynamic>) {
              url =
                  parsed['SUPABASE_TEST_URL']?.toString() ??
                  parsed['SUPABASE_URL']?.toString() ??
                  url;
              anonKey =
                  parsed['SUPABASE_TEST_ANON_KEY']?.toString() ??
                  parsed['SUPABASE_ANON_KEY']?.toString() ??
                  anonKey;
              testEmail =
                  parsed['SUPABASE_TEST_EMAIL']?.toString() ?? testEmail;
              testPassword =
                  parsed['SUPABASE_TEST_PASSWORD']?.toString() ?? testPassword;
              if (url.isNotEmpty && !url.contains('YOUR_')) {
                break;
              }
            }
          }
        } catch (_) {}
      }
    }

    final config = StagingConfig(
      url: url.trim(),
      anonKey: anonKey.trim(),
      testEmail: testEmail.trim().isEmpty ? null : testEmail.trim(),
      testPassword: testPassword.trim().isEmpty ? null : testPassword.trim(),
    );

    return config.isConfigured ? config : null;
  }

  /// Loads staging configuration or throws a descriptive [TestFailure].
  static StagingConfig loadOrThrow() {
    final config = tryLoad();
    if (config == null || !config.isConfigured) {
      throw TestFailure(
        'STAGING SECRETS ABSENT:\n'
        'Real Supabase staging integration tests require non-committed test/CI credentials.\n'
        'Please provide valid credentials via one of the following non-committed mechanisms:\n'
        '  1. Environment variables: SUPABASE_TEST_URL & SUPABASE_TEST_ANON_KEY\n'
        '  2. CLI defines: flutter test integration_test/... --dart-define-from-file=secrets.json\n'
        '  3. Non-committed secrets.json file at the project root\n'
        'See docs/INTEGRATION_TEST_MATRIX.md for complete staging test configuration instructions.',
      );
    }
    return config;
  }
}
