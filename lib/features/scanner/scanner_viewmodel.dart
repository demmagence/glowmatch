import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScanAnalysisResult {
  final List<String> detectedIngredients;
  final String safetyRating;
  final String skinTypeSuitability;
  final String recommendations;
  final bool isSafe;
  final Map<String, String> ingredientSafetyLevels;
  final Map<String, String> ingredientDetails;
  final int overallSafetyScore;
  final List<String> interactionWarnings;

  ScanAnalysisResult({
    required this.detectedIngredients,
    required this.safetyRating,
    required this.skinTypeSuitability,
    required this.recommendations,
    required this.isSafe,
    required this.ingredientSafetyLevels,
    required this.ingredientDetails,
    required this.overallSafetyScore,
    required this.interactionWarnings,
  });

  factory ScanAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ScanAnalysisResult(
      detectedIngredients: List<String>.from(json['detectedIngredients'] ?? []),
      safetyRating: json['safetyRating'] ?? 'Unknown',
      skinTypeSuitability: json['skinTypeSuitability'] ?? 'N/A',
      recommendations:
          json['recommendations'] ?? 'No recommendations available.',
      isSafe: json['isSafe'] ?? true,
      ingredientSafetyLevels: Map<String, String>.from(
        json['ingredientSafetyLevels'] ?? {},
      ),
      ingredientDetails: Map<String, String>.from(
        json['ingredientDetails'] ?? {},
      ),
      overallSafetyScore: json['overallSafetyScore'] ?? 100,
      interactionWarnings: List<String>.from(json['interactionWarnings'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detectedIngredients': detectedIngredients,
      'safetyRating': safetyRating,
      'skinTypeSuitability': skinTypeSuitability,
      'recommendations': recommendations,
      'isSafe': isSafe,
      'ingredientSafetyLevels': ingredientSafetyLevels,
      'ingredientDetails': ingredientDetails,
      'overallSafetyScore': overallSafetyScore,
      'interactionWarnings': interactionWarnings,
    };
  }
}

class ScannerViewModel extends ChangeNotifier {
  static const List<String> _curatedIngredients = [
    'niacinamide',
    'hyaluronic',
    'salicylic',
    'glycolic',
    'retinol',
    'centella',
    'glycerin',
    'panthenol',
    'paraben',
    'alcohol denat',
    'ceramide',
    'tocopherol',
    'vitamin c',
    'zinc oxide',
    'titanium dioxide',
    'aloe vera',
    'tea tree',
    'squalane',
    'peptides',
    'collagen',
  ];

  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String _scannedText = '';
  String get scannedText => _scannedText;

  ScanAnalysisResult? _analysisResult;
  ScanAnalysisResult? get analysisResult => _analysisResult;

  List<ScanAnalysisResult> _scanHistory = [];
  List<ScanAnalysisResult> get scanHistory => _scanHistory;

  ScannerViewModel() {
    loadScanHistory();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> loadScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('scan_history') ?? [];
      _scanHistory = historyJson
          .map((item) => ScanAnalysisResult.fromJson(jsonDecode(item)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load scan history: $e');
    }
  }

  Future<void> _saveScanToHistory(ScanAnalysisResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('scan_history') ?? [];

      if (historyJson.length >= 20) {
        historyJson.removeLast();
      }

      historyJson.insert(0, jsonEncode(result.toJson()));
      await prefs.setStringList('scan_history', historyJson);

      _scanHistory.insert(0, result);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save scan to history: $e');
    }
  }

  Future<void> clearScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scan_history');
      _scanHistory.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear scan history: $e');
    }
  }

  List<String> _parseIngredientsList(String text) {
    if (text.isEmpty) return [];
    var cleaned = text.trim();
    final lowerCleaned = cleaned.toLowerCase();
    if (lowerCleaned.startsWith('ingredients:')) {
      cleaned = cleaned.substring('ingredients:'.length).trim();
    } else if (lowerCleaned.startsWith('ingredients')) {
      cleaned = cleaned.substring('ingredients'.length).trim();
    }

    cleaned = cleaned.replaceAll('\n', ' ');
    final rawParts = cleaned.split(RegExp(r'[,;]'));
    final List<String> result = [];
    for (var part in rawParts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && trimmed.length > 1) {
        final lowerPart = trimmed.toLowerCase();
        final matchesCurated = _curatedIngredients.any((kw) => lowerPart.contains(kw));
        if (matchesCurated) {
          result.add(trimmed);
        }
      }
    }
    return result;
  }

  Future<void> scanImage(String filePath) async {
    _isProcessing = true;
    _analysisResult = null;
    notifyListeners();

    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      _scannedText = recognizedText.text;
      final ingredients = _parseIngredientsList(_scannedText);

      await _analyzeIngredientsWithAIList(ingredients);
    } catch (e) {
      debugPrint('OCR Scanning Error: $e');
      _scannedText =
          'Failed to extract text. Please try again with clear lighting.';
      _analysisResult = ScanAnalysisResult(
        detectedIngredients: ['Unknown'],
        safetyRating: 'N/A',
        skinTypeSuitability: 'Unknown',
        recommendations:
            'Unable to scan text clearly. Make sure ingredients are aligned within the box.',
        isSafe: false,
        ingredientSafetyLevels: {},
        ingredientDetails: {},
        overallSafetyScore: 0,
        interactionWarnings: [],
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> analyzeWithAI(List<String> ingredients) async {
    _isProcessing = true;
    _analysisResult = null;
    notifyListeners();

    try {
      await _analyzeIngredientsWithAIList(ingredients);
    } catch (e) {
      debugPrint('Error in analyzeWithAI: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _analyzeIngredientsWithAIList(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      _analysisResult = ScanAnalysisResult(
        detectedIngredients: [],
        safetyRating: 'No ingredients detected',
        skinTypeSuitability: 'N/A',
        recommendations: 'No skincare ingredients detected. Try scanning an ingredient list on a product label.',
        isSafe: true,
        ingredientSafetyLevels: {},
        ingredientDetails: {},
        overallSafetyScore: 0,
        interactionWarnings: [],
      );
      notifyListeners();
      return;
    }

    final supabaseUrl = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    final supabaseAnonKey = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    if (supabaseUrl.isEmpty ||
        supabaseUrl.startsWith('YOUR_') ||
        supabaseAnonKey.isEmpty ||
        supabaseAnonKey.startsWith('YOUR_')) {
      await _runOfflineFallbackAnalysis(ingredients.join(', '));
      return;
    }

    try {
      final url = Uri.parse('$supabaseUrl/functions/v1/analyze-ingredients');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $supabaseAnonKey',
              'apikey': supabaseAnonKey,
            },
            body: jsonEncode({'ingredients': ingredients}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        _analysisResult = ScanAnalysisResult.fromJson(parsedJson);
        await _saveScanToHistory(_analysisResult!);
      } else {
        throw Exception(
          'Edge function returned status code ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint(
        'AI Ingredient Analysis failed: $e. Falling back to offline fallback.',
      );
      await _runOfflineFallbackAnalysis(ingredients.join(', '));
    }
  }

  Future<void> _runOfflineFallbackAnalysis(String text) =>
      runOfflineFallbackAnalysis(text);

  @visibleForTesting
  Future<void> runOfflineFallbackAnalysis(String text) async {
    await Future.delayed(const Duration(seconds: 2));

    final String lowerText = text.toLowerCase();
    final List<String> found = [];
    final Map<String, String> safetyLevels = {};
    final Map<String, String> details = {};
    final List<String> warnings = [];

    if (lowerText.contains('niacinamide')) {
      found.add('Niacinamide');
      safetyLevels['Niacinamide'] = 'Safe';
      details['Niacinamide'] =
          'Improves skin elasticity, strengthens the skin barrier, and evens out tone.';
    }
    if (lowerText.contains('acid') || lowerText.contains('salicylic')) {
      if (lowerText.contains('hyaluronic')) {
        found.add('Hyaluronic Acid');
        safetyLevels['Hyaluronic Acid'] = 'Safe';
        details['Hyaluronic Acid'] =
            'Powerful humectant that draws moisture into the skin for hydration.';
      } else if (lowerText.contains('salicylic')) {
        found.add('Salicylic Acid');
        safetyLevels['Salicylic Acid'] = 'Caution';
        details['Salicylic Acid'] =
            'Exfoliates inside pores. Can cause drying or irritation in high concentrations.';
      } else {
        found.add('Glycolic Acid');
        safetyLevels['Glycolic Acid'] = 'Caution';
        details['Glycolic Acid'] =
            'Alpha hydroxy acid that helps exfoliate skin but can cause sun sensitivity.';
      }
    }
    if (lowerText.contains('retinol')) {
      found.add('Retinol');
      safetyLevels['Retinol'] = 'Caution';
      details['Retinol'] =
          'Promotes skin cell turnover. May cause peeling, redness, or sun sensitivity.';
    }
    if (lowerText.contains('centella') || lowerText.contains('asiatica')) {
      found.add('Centella Asiatica');
      safetyLevels['Centella Asiatica'] = 'Safe';
      details['Centella Asiatica'] =
          'Soothes inflammation, speeds healing, and calms sensitive skin.';
    }
    if (lowerText.contains('glycerin')) {
      found.add('Glycerin');
      safetyLevels['Glycerin'] = 'Safe';
      details['Glycerin'] =
          'Classic humectant that keeps the skin barrier hydrated and soft.';
    }
    if (lowerText.contains('panthenol')) {
      found.add('Panthenol');
      safetyLevels['Panthenol'] = 'Safe';
      details['Panthenol'] =
          'Pro-vitamin B5 that hydrates and regenerates the skin barrier.';
    }

    if (found.isEmpty) {
      _analysisResult = ScanAnalysisResult(
        detectedIngredients: [],
        safetyRating: 'No ingredients detected',
        skinTypeSuitability: 'N/A',
        recommendations:
            'No skincare ingredients detected. Try scanning an ingredient list on a product label.',
        isSafe: true,
        ingredientSafetyLevels: {},
        ingredientDetails: {},
        overallSafetyScore: 0,
        interactionWarnings: [],
      );
      await _saveScanToHistory(_analysisResult!);
      return;
    }

    bool containsHarsh =
        lowerText.contains('paraben') || lowerText.contains('alcohol denat');

    if (containsHarsh) {
      if (lowerText.contains('paraben')) {
        safetyLevels['Paraben'] = 'Avoid';
        details['Paraben'] =
            'Preservative commonly avoided due to potential endocrine disruption concerns.';
      }
      if (lowerText.contains('alcohol denat')) {
        safetyLevels['Alcohol Denat'] = 'Caution';
        details['Alcohol Denat'] =
            'Drying solvent used for quick product absorption, can impair skin barrier.';
      }
    }

    if (found.contains('Salicylic Acid') && found.contains('Retinol')) {
      warnings.add(
        'Combining Salicylic Acid (BHA) and Retinol can cause extreme skin irritation and dryness. Use them at different times of the day.',
      );
    }

    int score = 100;
    for (var status in safetyLevels.values) {
      if (status == 'Avoid') {
        score -= 25;
      } else if (status == 'Caution') {
        score -= 10;
      }
    }
    score = score.clamp(0, 100);

    _analysisResult = ScanAnalysisResult(
      detectedIngredients: found,
      safetyRating: containsHarsh
          ? 'Moderate Risk (Contains Parabens/Drying Alcohols)'
          : 'Highly Safe (100% Clean)',
      skinTypeSuitability:
          'Excellent for Sensitive & Dry Skin. Relieves redness.',
      recommendations:
          'This product contains ${found.join(", ")}, which are excellent for moisture barrier support. Highly recommended for daily AM/PM routines.',
      isSafe: !containsHarsh,
      ingredientSafetyLevels: safetyLevels,
      ingredientDetails: details,
      overallSafetyScore: score,
      interactionWarnings: warnings,
    );

    await _saveScanToHistory(_analysisResult!);
  }

  void clearScan() {
    _scannedText = '';
    _analysisResult = null;
    notifyListeners();
  }
}
