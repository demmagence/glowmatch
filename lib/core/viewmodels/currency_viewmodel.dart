import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';

class CurrencyViewModel extends ChangeNotifier {
  final CurrencyService _currencyService = CurrencyService();
  String _selectedCurrency = 'USD';

  String get selectedCurrency => _selectedCurrency;
  CurrencyService get service => _currencyService;

  final List<String> supportedCurrencies = [
    'USD',
    'IDR',
    'EUR',
    'SGD',
    'MYR',
    'JPY',
    'GBP',
    'AUD',
  ];

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'IDR': 'Rp ',
    'EUR': '€',
    'SGD': 'S\$',
    'MYR': 'RM ',
    'JPY': '¥',
    'GBP': '£',
    'AUD': 'A\$',
  };

  String get currencySymbol => _currencySymbols[_selectedCurrency] ?? '\$';

  /// Initializes preferred currency preference and the exchange rate service.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedCurrency = prefs.getString('preferred_currency') ?? 'USD';
      
      // Initialize rates service
      await _currencyService.init();
      notifyListeners();
    } catch (e) {
      debugPrint('CurrencyViewModel init error: $e');
    }
  }

  /// Updates the preferred currency, persists it, and triggers a background sync.
  Future<void> setSelectedCurrency(String currencyCode) async {
    if (!supportedCurrencies.contains(currencyCode)) return;
    _selectedCurrency = currencyCode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_currency', currencyCode);
      
      // Refresh rates dynamically
      await _currencyService.fetchRates();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving currency preference: $e');
    }
  }

  /// Converts from base IDR to current selected preferred currency.
  double convertFromIDR(double amountIDR) {
    return _currencyService.convertFromIDR(amountIDR, _selectedCurrency);
  }

  /// Converts from current selected preferred currency to base IDR.
  double convertToIDR(double amountTarget) {
    return _currencyService.convertToIDR(amountTarget, _selectedCurrency);
  }

  /// Helper to convert a value from USD to IDR (useful for initializing fields from static USD defaults).
  double convertUSDToIDR(double amountUSD) {
    return _currencyService.convert(amountUSD, 'USD', 'IDR');
  }

  /// Formats an IDR price value into the preferred currency with regional formatting (thousand separators, decimals).
  String formatPrice(double priceInIDR) {
    final converted = convertFromIDR(priceInIDR);
    final symbol = currencySymbol;

    if (_selectedCurrency == 'IDR') {
      final formatted = _formatNumber(
        converted,
        decimals: 0,
        thousandSep: '.',
        decimalSep: ',',
      );
      return '$symbol$formatted';
    } else if (_selectedCurrency == 'JPY') {
      final formatted = _formatNumber(
        converted,
        decimals: 0,
        thousandSep: ',',
        decimalSep: '.',
      );
      return '$symbol$formatted';
    } else {
      final formatted = _formatNumber(
        converted,
        decimals: 2,
        thousandSep: ',',
        decimalSep: '.',
      );
      return '$symbol$formatted';
    }
  }

  /// Formats a converted price value without the currency symbol.
  String formatPriceWithoutSymbol(double priceInIDR) {
    final converted = convertFromIDR(priceInIDR);

    if (_selectedCurrency == 'IDR' || _selectedCurrency == 'JPY') {
      return _formatNumber(
        converted,
        decimals: 0,
        thousandSep: '',
        decimalSep: '',
      );
    } else {
      return _formatNumber(
        converted,
        decimals: 2,
        thousandSep: '',
        decimalSep: '.',
      );
    }
  }

  /// Helper format function to perform custom number punctuation.
  String _formatNumber(
    double val, {
    required int decimals,
    required String thousandSep,
    required String decimalSep,
  }) {
    if (val.isNaN || val.isInfinite) return val.toString();

    final String fixedStr = val.toStringAsFixed(decimals);
    final parts = fixedStr.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts.length > 1 ? parts[1] : '';

    // Format integer part with thousand separator
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedInteger = integerPart;
    if (thousandSep.isNotEmpty) {
      formattedInteger = integerPart.replaceAllMapped(
        reg,
        (Match m) => '${m[1]}$thousandSep',
      );
    }

    if (decimals > 0 && decimalPart.isNotEmpty) {
      return '$formattedInteger$decimalSep$decimalPart';
    }
    return formattedInteger;
  }
}
