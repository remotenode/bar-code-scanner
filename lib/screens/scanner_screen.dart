import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/barcode_format.dart' as models;
import '../models/scan_result.dart';
import '../services/services.dart';
import '../widgets/scanner_overlay.dart';
import 'result_screen.dart';

/// Scanner screen with camera preview and overlay
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _hasPermission = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _controller?.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _controller?.stop();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();

    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _errorMessage = null;
      });
      _startScanner();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'permission_denied_permanent';
      });
    } else {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'permission_denied';
      });
    }
  }

  void _startScanner() {
    _controller = MobileScannerController(
      facing: _isFrontCamera ? CameraFacing.front : CameraFacing.back,
      torchEnabled: _isFlashOn,
      formats: const [
        BarcodeFormat.qrCode,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.pdf417,
        BarcodeFormat.aztec,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.itf,
        BarcodeFormat.codabar,
      ],
    );
    setState(() {});
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    await _controller!.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _switchCamera() async {
    if (_controller == null) return;
    await _controller!.switchCamera();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isFlashOn = false;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null || barcode.rawValue!.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Convert mobile_scanner format to our format
    final format = _convertFormat(barcode.format);
    final result = ScanResult.fromScan(
      rawValue: barcode.rawValue!,
      format: format,
    );

    // Provide feedback
    final settingsService = context.read<SettingsService>();
    final feedbackService = context.read<FeedbackService>();
    await feedbackService.provideFeedback(
      vibrationEnabled: settingsService.vibrationEnabled,
      soundEnabled: settingsService.soundEnabled,
    );

    // Save to history
    final historyService = context.read<HistoryService>();
    await historyService.addScan(result);

    // Navigate to result screen
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: result),
        ),
      );
    }

    // Reset processing state after returning
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  models.BarcodeFormat _convertFormat(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return models.BarcodeFormat.qrCode;
      case BarcodeFormat.dataMatrix:
        return models.BarcodeFormat.dataMatrix;
      case BarcodeFormat.pdf417:
        return models.BarcodeFormat.pdf417;
      case BarcodeFormat.aztec:
        return models.BarcodeFormat.aztec;
      case BarcodeFormat.ean13:
        return models.BarcodeFormat.ean13;
      case BarcodeFormat.ean8:
        return models.BarcodeFormat.ean8;
      case BarcodeFormat.upcA:
        return models.BarcodeFormat.upcA;
      case BarcodeFormat.upcE:
        return models.BarcodeFormat.upcE;
      case BarcodeFormat.code128:
        return models.BarcodeFormat.code128;
      case BarcodeFormat.code39:
        return models.BarcodeFormat.code39;
      case BarcodeFormat.code93:
        return models.BarcodeFormat.code93;
      case BarcodeFormat.itf:
        return models.BarcodeFormat.itf;
      case BarcodeFormat.codabar:
        return models.BarcodeFormat.codabar;
      default:
        return models.BarcodeFormat.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scannerTitle),
        actions: [
          if (_hasPermission && !_isFrontCamera)
            IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              tooltip: _isFlashOn ? l10n.flashOff : l10n.flashOn,
              onPressed: _toggleFlash,
            ),
          if (_hasPermission)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              tooltip: l10n.switchCamera,
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: _buildBody(l10n, theme),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    if (_errorMessage != null) {
      return _buildErrorView(l10n, theme);
    }

    if (!_hasPermission) {
      return _buildLoadingView();
    }

    return Stack(
      children: [
        if (_controller != null)
          MobileScanner(
            controller: _controller!,
            onDetect: _onBarcodeDetected,
          ),
        const ScannerOverlay(),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.pointCameraAtCode,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n, ThemeData theme) {
    final isPermanent = _errorMessage == 'permission_denied_permanent';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.cameraPermissionDenied,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.cameraPermissionRequired,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isPermanent)
              FilledButton.icon(
                icon: const Icon(Icons.settings),
                label: Text(l10n.openSettings),
                onPressed: () => openAppSettings(),
              )
            else
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _initializeCamera,
              ),
          ],
        ),
      ),
    );
  }
}
