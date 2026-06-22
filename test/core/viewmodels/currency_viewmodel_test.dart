import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowmatch/core/viewmodels/currency_viewmodel.dart';

void main() {
  group('CurrencyViewModel', () {
    late CurrencyViewModel viewModel;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      viewModel = CurrencyViewModel();
    });

    test('initial state and supported list', () {
      expect(viewModel.selectedCurrency, equals('USD'));
      expect(viewModel.currencySymbol, equals('\$'));
      expect(viewModel.supportedCurrencies, containsAll(['USD', 'IDR', 'EUR', 'SGD', 'MYR', 'JPY', 'GBP', 'AUD']));
    });

    test('setSelectedCurrency updates preferences and currency symbol', () async {
      bool notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      await viewModel.setSelectedCurrency('EUR');
      expect(viewModel.selectedCurrency, equals('EUR'));
      expect(viewModel.currencySymbol, equals('€'));
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('preferred_currency'), equals('EUR'));
    });

    test('formatPrice formats USD correctly', () {
      // 16400 IDR base -> should be 1 USD -> formatted as $1.00
      final formatted = viewModel.formatPrice(16400.0);
      expect(formatted, equals('\$1.00'));
    });

    test('formatPrice formats IDR correctly', () async {
      await viewModel.setSelectedCurrency('IDR');
      // 16400 IDR base -> formatted as Rp 16.400 (Indonesian regional separator format)
      final formatted = viewModel.formatPrice(16400.0);
      expect(formatted, equals('Rp 16.400'));
    });

    test('formatPrice formats JPY correctly', () async {
      await viewModel.setSelectedCurrency('JPY');
      final jpyRate = viewModel.service.rates['JPY']!;
      final idrRate = viewModel.service.rates['IDR']!;
      final expectedJpy = (16400.0 * (jpyRate / idrRate)).toStringAsFixed(0);
      final formatted = viewModel.formatPrice(16400.0);
      expect(formatted, equals('¥$expectedJpy'));
    });

    test('formatPriceWithoutSymbol formats values correctly without currency prefix', () async {
      expect(viewModel.formatPriceWithoutSymbol(16400.0), equals('1.00'));

      await viewModel.setSelectedCurrency('IDR');
      expect(viewModel.formatPriceWithoutSymbol(16400.0), equals('16400'));
    });
  });
}
