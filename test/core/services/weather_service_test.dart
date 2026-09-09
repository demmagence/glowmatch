import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/weather_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WeatherResult and WeatherData models', () {
    test('WeatherData properties are properly set', () {
      final data = WeatherData(
        locationName: 'Jakarta, Indonesia',
        temperature: 30.5,
        condition: 'Sunny',
      );

      expect(data.locationName, equals('Jakarta, Indonesia'));
      expect(data.temperature, equals(30.5));
      expect(data.condition, equals('Sunny'));
    });

    test('WeatherResult.success creates successful result', () {
      final data = WeatherData(
        locationName: 'Jakarta, Indonesia',
        temperature: 30.5,
        condition: 'Sunny',
      );
      final result = WeatherResult.success(data);

      expect(result.isSuccess, isTrue);
      expect(result.status, equals(WeatherStatus.success));
      expect(result.data, equals(data));
      expect(result.message, isNull);
    });

    test('WeatherResult.locationDisabled creates truthful disabled state', () {
      final result = WeatherResult.locationDisabled();

      expect(result.isSuccess, isFalse);
      expect(result.status, equals(WeatherStatus.locationDisabled));
      expect(result.data, isNull);
      expect(result.message, contains('Location services are disabled'));
    });

    test('WeatherResult.permissionDenied creates truthful denied state', () {
      final result = WeatherResult.permissionDenied();

      expect(result.isSuccess, isFalse);
      expect(result.status, equals(WeatherStatus.permissionDenied));
      expect(result.data, isNull);
      expect(result.message, contains('Location permission is needed'));
    });

    test(
      'WeatherResult.permissionPermanentlyDenied creates truthful permanently denied state',
      () {
        final result = WeatherResult.permissionPermanentlyDenied();

        expect(result.isSuccess, isFalse);
        expect(
          result.status,
          equals(WeatherStatus.permissionPermanentlyDenied),
        );
        expect(result.data, isNull);
        expect(result.message, contains('Settings'));
      },
    );

    test('WeatherResult.error creates error state', () {
      final result = WeatherResult.error('Network failure');

      expect(result.isSuccess, isFalse);
      expect(result.status, equals(WeatherStatus.error));
      expect(result.data, isNull);
      expect(result.message, equals('Network failure'));
    });
  });

  group('WeatherService – truthful location handling', () {
    late WeatherService service;

    setUp(() {
      service = WeatherService();
    });

    test(
      'fetchLocalWeatherResult does not throw and returns non-success result when platform channel is unmocked',
      () async {
        final result = await service.fetchLocalWeatherResult();

        expect(result.isSuccess, isFalse);
        expect(result.data, isNull);
        expect(result.status, isNot(WeatherStatus.success));
      },
    );

    test(
      'fetchLocalWeather returns null (not misleading mock data) when location is unavailable',
      () async {
        final result = await service.fetchLocalWeather();

        expect(result, isNull);
      },
    );
  });
}
