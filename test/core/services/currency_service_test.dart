import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/currency_service.dart';

void main() {
  group('CurrencyService', () {
    late CurrencyService service;

    setUp(() {
      service = CurrencyService();
    });

    test('default rates are loaded correctly', () {
      expect(service.rates['USD'], equals(1.0));
      expect(service.rates['IDR'], equals(16400.0));
      expect(service.rates['EUR'], equals(0.92));
    });

    test('conversion from IDR to USD works correctly using default rates', () {
      // 16400 IDR should be equal to 1.0 USD
      final usdValue = service.convertFromIDR(16400.0, 'USD');
      expect(usdValue, closeTo(1.0, 0.001));
    });

    test('conversion from USD to IDR works correctly using default rates', () {
      // 1.0 USD should be equal to 16400 IDR
      final idrValue = service.convertToIDR(1.0, 'USD');
      expect(idrValue, closeTo(16400.0, 0.001));
    });

    test('arbitrary cross conversion (EUR to JPY) works correctly', () {
      // 0.92 EUR = 1 USD = 158.0 JPY
      final jpyValue = service.convert(0.92, 'EUR', 'JPY');
      expect(jpyValue, closeTo(158.0, 0.01));
    });

    test('conversion with zero amount returns zero', () {
      final val = service.convert(0.0, 'USD', 'IDR');
      expect(val, equals(0.0));
    });
  });
}
