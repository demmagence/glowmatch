import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'scanner_viewmodel.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available. Running in simulator fallback mode.');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _captureAndScan(ScannerViewModel vm) async {
    if (vm.isProcessing) return;

    if (!_isCameraInitialized || _cameraController == null) {
      await vm.scanImage('assets/mock_ingredients.png');
      if (mounted && vm.analysisResult != null) {
        _showResultSheet(context, vm.analysisResult!, vm);
      }
      return;
    }

    try {
      final file = await _cameraController!.takePicture();
      await vm.scanImage(file.path);
      if (mounted && vm.analysisResult != null) {
        _showResultSheet(context, vm.analysisResult!, vm);
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to take picture: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerVm = Provider.of<ScannerViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scan History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Past product scans',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (scannerVm.scanHistory.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.red,
                      ),
                      tooltip: 'Clear history',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: bgColor,
                            title: Text(
                              'Clear History?',
                              style: TextStyle(color: textColor),
                            ),
                            content: Text(
                              'Do you want to delete all past scans?',
                              style: TextStyle(color: textColor),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await scannerVm.clearScanHistory();
                        }
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: scannerVm.scanHistory.isEmpty
                  ? Center(
                      child: Text(
                        'No past scans found',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: scannerVm.scanHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem = scannerVm.scanHistory[index];
                        final score = historyItem.overallSafetyScore;
                        final scoreColor = score >= 80
                            ? Colors.green
                            : (score >= 50 ? Colors.amber : Colors.red);
                        return ListTile(
                          title: Text(
                            historyItem.detectedIngredients.take(3).join(', ') +
                                (historyItem.detectedIngredients.length > 3
                                    ? '...'
                                    : ''),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Score: $score/100 | ${historyItem.safetyRating}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: scoreColor, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$score',
                              style: TextStyle(
                                color: scoreColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showResultSheet(context, historyItem, scannerVm);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _isCameraInitialized && _cameraController != null
              ? CameraPreview(_cameraController!)
              : _buildSimulatorViewfinder(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'GLOWMATCH',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleFlash,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFlashOn
                                    ? Icons.flashlight_on
                                    : Icons.flashlight_off,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ALIGN INGREDIENTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    scannerVm.isProcessing
                        ? 'Analyzing ingredients...'
                        : 'Scanning ingredients list...',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => _captureAndScan(scannerVm),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white.withValues(
                          alpha: scannerVm.isProcessing ? 0.5 : 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorViewfinder() {
    return Container(
      color: const Color(0xFF0F0F0F),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.25,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&q=80&w=600',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Container(
            width: 280,
            height: 380,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultSheet(
    BuildContext context,
    ScanAnalysisResult result,
    ScannerViewModel vm,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;

    final score = result.overallSafetyScore;
    final scoreColor = score >= 80
        ? Colors.green
        : (score >= 50 ? Colors.amber : Colors.red);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        side: BorderSide(color: borderColor, width: 2),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SCAN ANALYSIS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.1),
                            border: Border.all(color: scoreColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Score: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '$score/100',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (result.interactionWarnings.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50.withValues(
                            alpha: isDark ? 0.1 : 0.85,
                          ),
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'INGREDIENT INTERACTIONS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.red,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...result.interactionWarnings.map(
                              (warning) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  '• $warning',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.red.shade300
                                        : Colors.red.shade800,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'Detected Ingredients:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.detectedIngredients.map((ing) {
                        final level =
                            result.ingredientSafetyLevels[ing] ?? 'Safe';
                        Color chipColor;
                        Color textChipColor;
                        String emojiPrefix = '🟢 ';
                        if (level == 'Avoid') {
                          chipColor = Colors.red.shade100.withValues(
                            alpha: isDark ? 0.2 : 0.9,
                          );
                          textChipColor = isDark
                              ? Colors.red.shade300
                              : Colors.red.shade800;
                          emojiPrefix = '🔴 ';
                        } else if (level == 'Caution') {
                          chipColor = Colors.amber.shade100.withValues(
                            alpha: isDark ? 0.2 : 0.9,
                          );
                          textChipColor = isDark
                              ? Colors.amber.shade300
                              : Colors.amber.shade800;
                          emojiPrefix = '🟡 ';
                        } else {
                          chipColor = Colors.green.shade100.withValues(
                            alpha: isDark ? 0.2 : 0.9,
                          );
                          textChipColor = isDark
                              ? Colors.green.shade300
                              : Colors.green.shade800;
                          emojiPrefix = '🟢 ';
                        }

                        return Chip(
                          backgroundColor: chipColor,
                          side: BorderSide(color: textChipColor, width: 1.5),
                          label: Text(
                            '$emojiPrefix$ing',
                            style: TextStyle(
                              fontSize: 12,
                              color: textChipColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Ingredient Safety & Details (Tap to expand):',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...result.detectedIngredients.map((ing) {
                      final level =
                          result.ingredientSafetyLevels[ing] ?? 'Safe';
                      final detail =
                          result.ingredientDetails[ing] ??
                          'No details available.';
                      Color detailColor = level == 'Avoid'
                          ? Colors.red
                          : (level == 'Caution' ? Colors.amber : Colors.green);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor, width: 1.5),
                        ),
                        color: isDark
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey.shade50,
                        child: ExpansionTile(
                          collapsedIconColor: textColor,
                          iconColor: textColor,
                          title: Text(
                            ing,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            'Safety status: $level',
                            style: TextStyle(
                              color: detailColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                bottom: 12.0,
                              ),
                              child: Text(
                                detail,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    const Text(
                      'Skin Suitability:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.skinTypeSuitability,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'AI Recommendations & Summary:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.recommendations,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textColor,
                                side: BorderSide(color: borderColor, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(
                                  context,
                                  result.detectedIngredients,
                                );
                              },
                              child: const Text(
                                'Save to Shelf',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                vm.clearScan();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
