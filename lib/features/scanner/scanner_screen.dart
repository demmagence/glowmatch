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
      // Simulator fallback simulation
      await vm.scanImage('assets/mock_ingredients.png'); // Trigger local OCR mock parser
      if (mounted) _showAnalysisResults(context, vm);
      return;
    }

    try {
      final file = await _cameraController!.takePicture();
      await vm.scanImage(file.path);
      if (mounted) _showAnalysisResults(context, vm);
    } catch (e) {
      debugPrint('Capture error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take picture: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerVm = Provider.of<ScannerViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Live Preview (or dark mockup background if simulator)
          _isCameraInitialized && _cameraController != null
              ? CameraPreview(_cameraController!)
              : _buildSimulatorViewfinder(),

          // 2. Camera Overlay Details
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // Header Row: Close, Title Capsule, Flashlight
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button "X"
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
                      
                      // GLOWMATCH Capsule logo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'GLOWMATCH',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      // Flashlight toggle
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
                            _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),

                  // ALIGN INGREDIENTS overlay text/box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85), // ignore: deprecated_member_use
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
                  
                  // Scanning text status
                  Text(
                    scannerVm.isProcessing ? 'Analyzing ingredients...' : 'Scanning ingredients list...',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Shutter Button
                  GestureDetector(
                    onTap: () => _captureAndScan(scannerVm),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white.withOpacity(scannerVm.isProcessing ? 0.5 : 1.0), // ignore: deprecated_member_use
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
          // Simulated blurry ingredients packaging background to wow the user
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
          // Viewfinder box borders
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

  void _showAnalysisResults(BuildContext context, ScannerViewModel vm) {
    if (vm.analysisResult == null) return;
    final result = vm.analysisResult!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                  Icon(
                    result.isSafe ? Icons.check_circle : Icons.warning_rounded,
                    color: result.isSafe ? Colors.green : Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Detected ingredients list
              const Text('Detected Ingredients:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.detectedIngredients.map((ing) {
                  return Chip(
                    backgroundColor: Colors.pink.shade50,
                    label: Text(
                      ing,
                      style: TextStyle(fontSize: 12, color: Colors.pink.shade400, fontWeight: FontWeight.bold),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Suitability profile
              const Text('Skin Suitability:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                result.skinTypeSuitability,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // AI Safety summary
              const Text('Safety & Details:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                result.recommendations,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Close / OK Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    vm.clearScan();
                    Navigator.pop(context);
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
