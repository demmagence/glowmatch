import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final String locationName;
  final double temperature;
  final String condition;

  WeatherData({
    required this.locationName,
    required this.temperature,
    required this.condition,
  });
}

enum WeatherStatus {
  success,
  locationDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  error,
}

class WeatherResult {
  final WeatherData? data;
  final WeatherStatus status;
  final String? message;

  const WeatherResult({
    this.data,
    required this.status,
    this.message,
  });

  bool get isSuccess => status == WeatherStatus.success && data != null;

  factory WeatherResult.success(WeatherData data) =>
      WeatherResult(data: data, status: WeatherStatus.success);

  factory WeatherResult.locationDisabled([String? message]) =>
      WeatherResult(
        status: WeatherStatus.locationDisabled,
        message: message ?? 'Location services are disabled on your device.',
      );

  factory WeatherResult.permissionDenied([String? message]) =>
      WeatherResult(
        status: WeatherStatus.permissionDenied,
        message:
            message ?? 'Location permission is needed to show local weather.',
      );

  factory WeatherResult.permissionPermanentlyDenied([String? message]) =>
      WeatherResult(
        status: WeatherStatus.permissionPermanentlyDenied,
        message: message ??
            'Location permission is permanently denied. Enable it in Settings.',
      );

  factory WeatherResult.error(String message) =>
      WeatherResult(status: WeatherStatus.error, message: message);
}

class WeatherService {
  @visibleForTesting
  WeatherService.internal();

  static WeatherService instance = WeatherService.internal();

  factory WeatherService() => instance;

  Future<WeatherResult> fetchLocalWeatherResult() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return WeatherResult.locationDisabled();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return WeatherResult.permissionDenied();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return WeatherResult.permissionPermanentlyDenied();
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,weather_code',
      );

      final response =
          await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data['current']['temperature_2m'] as double;
        final code = data['current']['weather_code'] as int;

        String condition = 'Sunny';
        if (code >= 1 && code <= 3) {
          condition = 'Partly Cloudy';
        } else if (code >= 51 && code <= 67) {
          condition = 'Rainy';
        } else if (code >= 71 && code <= 86) {
          condition = 'Snowy';
        } else if (code >= 95) {
          condition = 'Thunderstorm';
        }

        String address = 'My Location';
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(const Duration(seconds: 3));
          if (placemarks.isNotEmpty) {
            final pm = placemarks.first;
            final List<String> parts = [];
            if (pm.subLocality != null && pm.subLocality!.isNotEmpty) {
              parts.add(pm.subLocality!);
            } else if (pm.locality != null && pm.locality!.isNotEmpty) {
              parts.add(pm.locality!);
            }
            if (pm.subAdministrativeArea != null &&
                pm.subAdministrativeArea!.isNotEmpty) {
              parts.add(pm.subAdministrativeArea!);
            }
            if (pm.administrativeArea != null &&
                pm.administrativeArea!.isNotEmpty) {
              parts.add(pm.administrativeArea!);
            }
            if (parts.isNotEmpty) {
              address = parts.join(', ');
            }
          }
        } catch (e) {
          debugPrint('Geocoding failed: $e');
        }

        return WeatherResult.success(
          WeatherData(
            locationName:
                '$address (${position.latitude.toStringAsFixed(1)}°, ${position.longitude.toStringAsFixed(1)}°)',
            temperature: temp,
            condition: condition,
          ),
        );
      } else {
        return WeatherResult.error(
          'Weather API returned status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e');
      return WeatherResult.error(e.toString());
    }
  }

  /// Backward-compatible method returning nullable WeatherData (null if permission denied or error)
  Future<WeatherData?> fetchLocalWeather() async {
    final result = await fetchLocalWeatherResult();
    return result.data;
  }
}
