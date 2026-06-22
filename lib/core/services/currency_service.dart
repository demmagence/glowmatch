import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _ratesCacheKey = 'currency_rates_cache';
  static const String _timestampCacheKey = 'currency_rates_timestamp';
  static const String _apiUrl = 'https://open.er-api.com/v6/latest/USD';

  // Base fallback rates relative to USD (1 USD = X target currency)
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'IDR': 16400.0,
    'EUR': 0.92,
    'SGD': 1.35,
    'MYR': 4.71,
    'JPY': 158.0,
    'GBP': 0.79,
    'AUD': 1.50,
  };

  Map<String, double> _rates = Map.from(_fallbackRates);
  Map<String, double> get rates => _rates;

  /// Loads rates from cache first, then triggers a background fetch if expired.
  Future<void> init() async {
    await _loadFromCache();
    if (await _isCacheExpired()) {
      // Fetch in background or block initially? Let's fetch asynchronously.
      // We don't want to block app startup, but we want the latest rates if possible.
      try {
        await fetchRates();
      } catch (e) {
        debugPrint('CurrencyService initialization fetch failed: $e');
      }
    }
  }

  /// Fetches rates from the live API.
  Future<void> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['rates'] != null) {
          final ratesMap = data['rates'] as Map<String, dynamic>;
          final Map<String, double> newRates = {};
          
          // Ensure we extract double values safely
          ratesMap.forEach((key, value) {
            if (value is num) {
              newRates[key] = value.toDouble();
            }
          });

          // Ensure our 8 required currencies are present, otherwise use fallback
          for (final currency in _fallbackRates.keys) {
            if (!newRates.containsKey(currency)) {
              newRates[currency] = _fallbackRates[currency]!;
            }
          }

          _rates = newRates;
          await _saveToCache(newRates);
          debugPrint('CurrencyService: Rates successfully fetched and cached.');
        }
      } else {
        debugPrint('CurrencyService API error status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('CurrencyService error fetching rates: $e. Using cache/fallbacks.');
    }
  }

  /// Converts an amount between any two currencies.
  double convert(double amount, String from, String to) {
    final fromRate = _rates[from] ?? _fallbackRates[from] ?? 1.0;
    final toRate = _rates[to] ?? _fallbackRates[to] ?? 1.0;
    
    if (fromRate == 0.0) return 0.0;
    
    // Convert: fromCurrency -> USD -> toCurrency
    final amountUSD = amount / fromRate;
    return amountUSD * toRate;
  }

  /// Special helper: converts IDR to target currency.
  double convertFromIDR(double amountIDR, String targetCurrency) {
    return convert(amountIDR, 'IDR', targetCurrency);
  }

  /// Special helper: converts target currency to IDR.
  double convertToIDR(double amountTarget, String sourceCurrency) {
    return convert(amountTarget, sourceCurrency, 'IDR');
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getString(_ratesCacheKey);
      if (ratesJson != null) {
        final decoded = json.decode(ratesJson) as Map<String, dynamic>;
        final Map<String, double> cachedRates = {};
        decoded.forEach((key, value) {
          if (value is num) {
            cachedRates[key] = value.toDouble();
          }
        });
        _rates = cachedRates;
        debugPrint('CurrencyService: Loaded cached rates.');
      }
    } catch (e) {
      debugPrint('CurrencyService error loading cache: $e');
    }
  }

  Future<void> _saveToCache(Map<String, double> ratesMap) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ratesCacheKey, json.encode(ratesMap));
      await prefs.setInt(_timestampCacheKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('CurrencyService error saving cache: $e');
    }
  }

  Future<bool> _isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_timestampCacheKey);
      if (timestamp == null) return true;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final difference = DateTime.now().difference(cacheTime);
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }
}
