import 'package:flutter_test/flutter_test.dart';
import '../../../integration_test/staging_config.dart';

void main() {
  group('StagingConfig Tests', () {
    test('isConfigured is false for empty or placeholder values', () {
      const config1 = StagingConfig(url: '', anonKey: '');
      expect(config1.isConfigured, isFalse);

      const config2 = StagingConfig(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
      expect(config2.isConfigured, isFalse);

      const config3 = StagingConfig(
        url: 'https://YOUR_PROJECT.supabase.co',
        anonKey: 'YOUR_KEY',
      );
      expect(config3.isConfigured, isFalse);
    });

    test('isConfigured is true for real URL and anonKey', () {
      const config = StagingConfig(
        url: 'https://xyzcompany.supabase.co',
        anonKey: 'sample-anon-key-12345',
      );
      expect(config.isConfigured, isTrue);
    });

    test('loadOrThrow fails clearly with TestFailure when not configured', () {
      // In an environment where url is empty, loadOrThrow throws TestFailure
      // StagingConfig.tryLoad() returns existing secrets.json if present
      final config = StagingConfig.tryLoad();
      if (config == null) {
        expect(() => StagingConfig.loadOrThrow(), throwsA(isA<TestFailure>()));
      } else {
        expect(config.isConfigured, isTrue);
        expect(config.url, startsWith('http'));
      }
    });
  });
}
