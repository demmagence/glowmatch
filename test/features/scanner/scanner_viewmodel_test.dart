import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/features/scanner/scanner_viewmodel.dart';

void main() {
  // Required: platform channel calls (TextRecognizer.close) need binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScannerViewModel vm;

  setUp(() {
    vm = ScannerViewModel();
  });

  // No tearDown dispose – TextRecognizer.close() is a platform channel call
  // that is irrelevant to the logic under test.

  group('ScannerViewModel – runOfflineFallbackAnalysis', () {
    test('detects Niacinamide in ingredient text', () async {
      await vm.runOfflineFallbackAnalysis(
          'Water, Niacinamide, Glycerin, Panthenol');
      expect(vm.analysisResult, isNotNull);
      expect(
        vm.analysisResult!.detectedIngredients.contains('Niacinamide'),
        isTrue,
      );
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('detects Hyaluronic Acid when "hyaluronic" and "acid" present',
        () async {
      await vm.runOfflineFallbackAnalysis(
          'Hyaluronic Acid, Ceramide, Niacinamide');
      expect(
        vm.analysisResult!.detectedIngredients.contains('Hyaluronic Acid'),
        isTrue,
      );
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('detects Retinol in ingredient text', () async {
      await vm.runOfflineFallbackAnalysis('Retinol 0.1%, Squalane, Glycerin');
      expect(
        vm.analysisResult!.detectedIngredients.contains('Retinol'),
        isTrue,
      );
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('Paraben → safetyRating is "Moderate Risk" and isSafe is false',
        () async {
      await vm.runOfflineFallbackAnalysis(
          'Water, Methylparaben, Glycerin, Panthenol');
      expect(vm.analysisResult, isNotNull);
      expect(vm.analysisResult!.isSafe, isFalse);
      expect(vm.analysisResult!.safetyRating, contains('Moderate Risk'));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('result is safe and "Highly Safe" when no harsh ingredients detected',
        () async {
      await vm.runOfflineFallbackAnalysis('Glycerin, Panthenol, Niacinamide');
      expect(vm.analysisResult!.isSafe, isTrue);
      expect(vm.analysisResult!.safetyRating, contains('Highly Safe'));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('seeds default ingredients when text has no known keywords', () async {
      await vm.runOfflineFallbackAnalysis('xyz abc 123 unknown compound');
      expect(vm.analysisResult!.detectedIngredients, isNotEmpty);
      // Default fallback list has exactly 3 items
      expect(vm.analysisResult!.detectedIngredients.length, equals(3));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('clearScan resets analysisResult and scannedText', () async {
      await vm.runOfflineFallbackAnalysis('Niacinamide, Glycerin');
      expect(vm.analysisResult, isNotNull);
      vm.clearScan();
      expect(vm.analysisResult, isNull);
      expect(vm.scannedText, isEmpty);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
