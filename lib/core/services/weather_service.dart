import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

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

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  Future<WeatherData> fetchLocalWeather() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _mockFallback('Location Services Disabled');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _mockFallback('Permission Denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _mockFallback('Permission Permanently Denied');
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,weather_code',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

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

        return WeatherData(
          locationName:
              'My Location (${position.latitude.toStringAsFixed(1)}°, ${position.longitude.toStringAsFixed(1)}°)',
          temperature: temp,
          condition: condition,
        );
      } else {
        return _mockFallback('API Error');
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e. Using fallback.');
      return _mockFallback('Offline / Timeout');
    }
  }

  WeatherData _mockFallback(String status) {
    return WeatherData(
      locationName: '${AppConstants.defaultMockLocation} ($status)',
      temperature: AppConstants.defaultMockTemperature,
      condition: 'Sunny',
    );
  }
}
