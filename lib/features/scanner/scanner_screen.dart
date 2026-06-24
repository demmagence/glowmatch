import 'dart:io';
import 'package:flutter/foundation.dart' show WriteBuffer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'scanner_viewmodel.dart';

enum CameraState {
  loading,
  initialized,
  permissionDenied,
  error,
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  CameraDescription? _camera;
  bool _isFlashOn = false;
  bool _isStreaming = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraState _cameraState = CameraState.loading;
  String? _cameraErrorMessage;

  // ponytail: auto device orientation → correct ML Kit rotation
  DeviceOrientation _deviceOrientation = DeviceOrientation.portraitUp;

  static const _orientationAngles = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isStreaming) {
      _cameraController?.stopImageStream().catchError((_) {});
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Auto-detect orientation from window physical size—no extra package needed
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize;
    final isLandscape = size.width > size.height;
    setState(() {
      _deviceOrientation = isLandscape
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp;
    });
  }

  /// Auto-computes correct rotation for ML Kit:
  /// Android: (sensorOrientation - deviceAngle + 360) % 360
  /// iOS:     (sensorOrientation + deviceAngle) % 360
  InputImageRotation _getRotation() {
    if (_camera == null) return InputImageRotation.rotation90deg;
    final sensorAngle = _camera!.sensorOrientation;
    final deviceAngle = _orientationAngles[_deviceOrientation] ?? 0;

    final angle = Platform.isIOS
        ? (sensorAngle + deviceAngle) % 360
        : (sensorAngle - deviceAngle + 360) % 360;

    return InputImageRotationValue.fromRawValue(angle)
        ?? InputImageRotation.rotation90deg;
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _cameraState = CameraState.loading;
    });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available.');
        setState(() {
          _cameraState = CameraState.error;
          _cameraErrorMessage = 'Kamera Tidak Tersedia';
        });
        return;
      }

      _camera = cameras.first;
      _cameraController = CameraController(
        _camera!,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      try {
        await _cameraController!.setZoomLevel(1.0);
      } catch (e) {
        debugPrint('Camera zoom setting error: $e');
      }
      if (!mounted) return;

      setState(() {
        _cameraState = CameraState.initialized;
      });
      _startImageStream();
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (!mounted) return;
      setState(() {
        if (e is CameraException &&
            (e.code == 'CameraAccessDenied' ||
             e.code == 'CameraAccessDeniedWithoutPrompt')) {
          _cameraState = CameraState.permissionDenied;
        } else {
          _cameraState = CameraState.error;
          _cameraErrorMessage = 'Kabel/kamera bermasalah atau tidak tersedia';
        }
      });
    }
  }

  void _startImageStream() {
    if (_isStreaming || _cameraController == null || _cameraState != CameraState.initialized) {
      return;
    }
    setState(() => _isStreaming = true);

    _cameraController!.startImageStream((CameraImage image) {
      if (!mounted) return;
      final vm = Provider.of<ScannerViewModel>(context, listen: false);
      // ponytail: skip frames while analyzing — _isProcessing check inside vm
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;
      vm.processFrame(
        inputImage,
        Size(image.width.toDouble(), image.height.toDouble()),
      );
    });
  }

  InputImage? _convertCameraImage(CameraImage image) {
    if (image.planes.isEmpty) return null;
    final rotation = _getRotation();
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_cameraState != CameraState.initialized || _cameraController == null) return;
    try {
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  void _handleTap(Offset tapPos, ScannerViewModel vm, Size screenSize) {
    if (vm.isProcessing || vm.detectedBlocks.isEmpty) return;

    final imgSize = vm.imageSize;
    if (imgSize == Size.zero) return;

    final rotation = _getRotation();
    final isRotated = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    // After rotation, display dimensions swap if rotated 90/270
    final displayW = isRotated ? imgSize.height : imgSize.width;
    final displayH = isRotated ? imgSize.width : imgSize.height;

    final scaleX = screenSize.width / displayW;
    final scaleY = screenSize.height / displayH;

    for (final block in vm.detectedBlocks) {
      final scaledRect = Rect.fromLTRB(
        block.boundingBox.left * scaleX,
        block.boundingBox.top * scaleY,
        block.boundingBox.right * scaleX,
        block.boundingBox.bottom * scaleY,
      );

      if (scaledRect.contains(tapPos)) {
        vm.analyzeTextBlock(block.text).then((_) {
          if (!mounted) return;
          final result = vm.analysisResult;
          if (result != null) {
            _showResultSheet(context, result, vm).then((_) {
              // Restart stream after sheet dismissed if it was stopped
              if (mounted && _cameraState == CameraState.initialized && !_isStreaming) {
                _startImageStream();
              }
            });
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ScannerViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildHistoryDrawer(context, vm, isDark, textColor, bgColor, borderColor),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera or simulator ───────────────────────────────────
          _cameraState == CameraState.initialized && _cameraController != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final camRatio =
                        _cameraController!.value.aspectRatio; // w/h
                    final screenRatio =
                        constraints.maxWidth / constraints.maxHeight;
                    // ponytail: cover-fit — scale to fill, never downscale
                    final scale = (camRatio < screenRatio
                            ? screenRatio / camRatio
                            : camRatio / screenRatio)
                        .clamp(1.0, double.infinity);
                    return Transform.scale(
                      scale: scale,
                      child: AspectRatio(
                        aspectRatio: camRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    );
                  },
                )
              : _buildCameraStateView(context),

          // ── Bounding box overlay + tap detector ───────────────────
          if (_cameraState == CameraState.initialized)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (d) => _handleTap(d.localPosition, vm, screenSize),
              child: CustomPaint(
                painter: _TextBlockOverlayPainter(
                  blocks: vm.detectedBlocks,
                  imageSize: vm.imageSize,
                  rotation: _getRotation(),
                ),
                child: const SizedBox.expand(),
              ),
            ),

          // ── Analyzing overlay ─────────────────────────────────────
          if (vm.isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing ingredients...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Top bar + bottom instruction ──────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  // Top row: close, brand, flash + history
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleBtn(
                        icon: Icons.close,
                        onTap: () => Navigator.pop(context),
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
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _circleBtn(
                            icon: _isFlashOn
                                ? Icons.flashlight_on
                                : Icons.flashlight_off,
                            onTap: _toggleFlash,
                          ),
                          const SizedBox(width: 8),
                          _circleBtn(
                            icon: Icons.history,
                            onTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom: dynamic instruction label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey(vm.detectedBlocks.length),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: vm.detectedBlocks.isNotEmpty
                            ? Colors.yellow.withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vm.detectedBlocks.isNotEmpty
                            ? '${vm.detectedBlocks.length} blok teks terdeteksi — TAP untuk analisis'
                            : 'Arahkan kamera ke daftar ingredients',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  Widget _buildCameraStateView(BuildContext context) {
    if (_cameraState == CameraState.loading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Menginisialisasi Kamera...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraState == CameraState.permissionDenied) {
      return Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.videocam_off_outlined,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Izin Kamera Ditolak',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'GlowMatch memerlukan akses kamera untuk memindai bahan kosmetik secara langsung. Silakan berikan izin kamera di pengaturan perangkat Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  onPressed: _initializeCamera,
                  child: const Text(
                    'COBA LAGI',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // CameraState.error or other issues
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white30, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.no_photography_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _cameraErrorMessage ?? 'Kamera Tidak Tersedia',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GlowMatch tidak dapat mendeteksi kamera fisik pada perangkat atau simulator ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onPressed: _initializeCamera,
                child: const Text(
                  'COBA LAGI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildHistoryDrawer(
    BuildContext context,
    ScannerViewModel vm,
    bool isDark,
    Color textColor,
    Color bgColor,
    Color borderColor,
  ) {
    return Drawer(
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
                if (vm.scanHistory.isNotEmpty)
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
                            'Hapus semua riwayat scan?',
                            style: TextStyle(color: textColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await vm.clearScanHistory();
                      }
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: vm.scanHistory.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada scan',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: vm.scanHistory.length,
                    itemBuilder: (context, index) {
                      final item = vm.scanHistory[index];
                      final score = item.overallSafetyScore;
                      final scoreColor = score >= 80
                          ? Colors.green
                          : (score >= 50 ? Colors.amber : Colors.red);
                      return ListTile(
                        title: Text(
                          item.detectedIngredients.take(3).join(', ') +
                              (item.detectedIngredients.length > 3
                                  ? '...'
                                  : ''),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Score: $score/100 | ${item.safetyRating}',
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
                          _showResultSheet(context, item, vm);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResultSheet(
    BuildContext context,
    ScanAnalysisResult result,
    ScannerViewModel vm,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;

    final score = result.overallSafetyScore;
    final scoreColor = score >= 80
        ? Colors.green
        : (score >= 50 ? Colors.amber : Colors.red);

    await showModalBottomSheet<void>(
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
                    // ── Header row ────────────────────────────────
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

                    // ── No ingredients found ──────────────────────
                    if (result.detectedIngredients.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.amber, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search_off, color: Colors.amber),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tidak ada ingredients ditemukan.\nCoba tap blok teks yang berisi daftar ingredients.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Interaction warnings ──────────────────────
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
                                  'INTERAKSI INGREDIENTS',
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
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  '• $w',
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

                    // ── Detected ingredients chips ────────────────
                    if (result.detectedIngredients.isNotEmpty) ...[
                      const Text(
                        'Ingredients Terdeteksi:',
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
                          String emoji = '🟢 ';
                          if (level == 'Avoid') {
                            chipColor = Colors.red.shade100
                                .withValues(alpha: isDark ? 0.2 : 0.9);
                            textChipColor = isDark
                                ? Colors.red.shade300
                                : Colors.red.shade800;
                            emoji = '🔴 ';
                          } else if (level == 'Caution') {
                            chipColor = Colors.amber.shade100
                                .withValues(alpha: isDark ? 0.2 : 0.9);
                            textChipColor = isDark
                                ? Colors.amber.shade300
                                : Colors.amber.shade800;
                            emoji = '🟡 ';
                          } else {
                            chipColor = Colors.green.shade100
                                .withValues(alpha: isDark ? 0.2 : 0.9);
                            textChipColor = isDark
                                ? Colors.green.shade300
                                : Colors.green.shade800;
                          }
                          return Chip(
                            backgroundColor: chipColor,
                            side: BorderSide(color: textChipColor, width: 1.5),
                            label: Text(
                              '$emoji$ing',
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

                      // ── Per-ingredient detail cards ─────────────
                      const Text(
                        'Safety & Deskripsi Ingredient:',
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
                        final detail = result.ingredientDetails[ing] ??
                            'Tidak ada detail tersedia.';
                        final detailColor = level == 'Avoid'
                            ? Colors.red
                            : (level == 'Caution'
                                ? Colors.amber
                                : Colors.green);
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
                              'Status: $level',
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

                      // ── Skin suitability & recommendations ───────
                      const Text(
                        'Kesesuaian Kulit:',
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
                        'Rekomendasi:',
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
                    ],

                    const SizedBox(height: 28),

                    // ── SCAN AGAIN button (no Save to Shelf) ──────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.white : Colors.black,
                          foregroundColor:
                              isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(color: borderColor, width: 2),
                          ),
                        ),
                        onPressed: () {
                          vm.clearScan();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'SCAN LAGI',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
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

// ── CustomPainter: draws yellow bounding boxes on detected text blocks ──────
class _TextBlockOverlayPainter extends CustomPainter {
  final List<TextBlock> blocks;
  final Size imageSize;
  final InputImageRotation rotation;

  const _TextBlockOverlayPainter({
    required this.blocks,
    required this.imageSize,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (blocks.isEmpty || imageSize == Size.zero) return;

    final isRotated = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final displayW = isRotated ? imageSize.height : imageSize.width;
    final displayH = isRotated ? imageSize.width : imageSize.height;

    final scaleX = size.width / displayW;
    final scaleY = size.height / displayH;

    final fillPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final boxPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final block in blocks) {
      final rect = Rect.fromLTRB(
        block.boundingBox.left * scaleX,
        block.boundingBox.top * scaleY,
        block.boundingBox.right * scaleX,
        block.boundingBox.bottom * scaleY,
      );
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rRect, fillPaint);
      canvas.drawRRect(rRect, boxPaint);
    }
  }

  @override
  bool shouldRepaint(_TextBlockOverlayPainter old) =>
      blocks != old.blocks || imageSize != old.imageSize;
}
