import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:glowmatch/features/scanner/scanner_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scanner_viewmodel_test.mocks.dart';

@GenerateMocks([TextRecognizer])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScannerViewModel vm;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vm = ScannerViewModel();
  });

  group('ScannerViewModel – runOfflineFallbackAnalysis', () {
    test(
      'detects Niacinamide in ingredient text',
      () async {
        await vm.runOfflineFallbackAnalysis(
          'Water, Niacinamide, Glycerin, Panthenol',
        );
        expect(vm.analysisResult, isNotNull);
        expect(
          vm.analysisResult!.detectedIngredients.contains('Niacinamide'),
          isTrue,
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'detects Hyaluronic Acid when "hyaluronic" and "acid" present',
      () async {
        await vm.runOfflineFallbackAnalysis(
          'Hyaluronic Acid, Ceramide, Niacinamide',
        );
        expect(
          vm.analysisResult!.detectedIngredients.contains('Hyaluronic Acid'),
          isTrue,
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'detects Retinol in ingredient text',
      () async {
        await vm.runOfflineFallbackAnalysis('Retinol 0.1%, Squalane, Glycerin');
        expect(
          vm.analysisResult!.detectedIngredients.contains('Retinol'),
          isTrue,
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'Paraben → safetyRating is "Moderate Risk" and isSafe is false',
      () async {
        await vm.runOfflineFallbackAnalysis(
          'Water, Methylparaben, Glycerin, Panthenol',
        );
        expect(vm.analysisResult, isNotNull);
        expect(vm.analysisResult!.isSafe, isFalse);
        expect(vm.analysisResult!.safetyRating, contains('Moderate Risk'));
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'result is safe and "Highly Safe" when no harsh ingredients detected',
      () async {
        await vm.runOfflineFallbackAnalysis('Glycerin, Panthenol, Niacinamide');
        expect(vm.analysisResult!.isSafe, isTrue);
        expect(vm.analysisResult!.safetyRating, contains('Highly Safe'));
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'returns empty list and fallback message when text has no known keywords',
      () async {
        await vm.runOfflineFallbackAnalysis('xyz abc 123 unknown compound');
        expect(vm.analysisResult!.detectedIngredients, isEmpty);
        expect(
          vm.analysisResult!.recommendations,
          contains('No skincare ingredients detected. Try scanning an ingredient list on a product label.'),
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'clearScan resets analysisResult and scannedText',
      () async {
        await vm.runOfflineFallbackAnalysis('Niacinamide, Glycerin');
        expect(vm.analysisResult, isNotNull);
        vm.clearScan();
        expect(vm.analysisResult, isNull);
        expect(vm.scannedText, isEmpty);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test('detectBlocksInImage processes image file path and returns blocks', () async {
      final mockRecognizer = MockTextRecognizer();
      final vmWithMock = ScannerViewModel(textRecognizer: mockRecognizer);

      final textBlock = TextBlock(
        text: 'Niacinamide, Glycerin',
        lines: const [],
        boundingBox: const Rect.fromLTWH(0, 0, 100, 50),
        recognizedLanguages: const [],
        cornerPoints: const [],
      );
      final recognizedText = RecognizedText(
        text: 'Niacinamide, Glycerin',
        blocks: [textBlock],
      );

      when(mockRecognizer.processImage(any))
          .thenAnswer((_) async => recognizedText);

      final result = await vmWithMock.detectBlocksInImage('dummy_path.png');

      expect(result, isNotEmpty);
      expect(result.first.text, equals('Niacinamide, Glycerin'));
      verify(mockRecognizer.processImage(any)).called(1);
    });
  });
}
