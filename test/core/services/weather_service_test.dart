import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/weather_service.dart';

void main() {
  group('WeatherService – fallback mock data', () {
    late WeatherService service;

    setUp(() {
      service = WeatherService();
    });

    test('fetchLocalWeather returns fallback WeatherData when location '
        'unavailable (MissingPluginException or disabled)', () async {
      final result = await service.fetchLocalWeather();

      expect(result, isA<WeatherData>());
      expect(result.temperature, equals(33.0));
      expect(result.condition, equals('Sunny'));
      expect(result.locationName, contains('Los Angeles'));
    });

    test('fallback locationName contains the reason string', () async {
      final result = await service.fetchLocalWeather();

      expect(result.locationName, isNotEmpty);
      expect(result.locationName, contains('Los Angeles, CA'));
    });

    test('fallback temperature is exactly 33.0 degrees Celsius', () async {
      final result = await service.fetchLocalWeather();
      expect(result.temperature, equals(33.0));
    });
  });
}
