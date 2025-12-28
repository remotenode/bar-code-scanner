import 'package:flutter/material.dart';

/// Custom overlay widget for the scanner screen with animated scan line
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScanLinePainter(_animation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.75;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw semi-transparent overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Create a path that covers the entire screen except the scan area
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw corner accents
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top + 8),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(left, top, 16, 16),
      3.14159,
      1.5708,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + 8, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top),
      Offset(left + scanAreaSize - 8, top),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(left + scanAreaSize - 16, top, 16, 16),
      -1.5708,
      1.5708,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + 8),
      Offset(left + scanAreaSize, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cornerLength),
      Offset(left, top + scanAreaSize - 8),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(left, top + scanAreaSize - 16, 16, 16),
      1.5708,
      1.5708,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + 8, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      Offset(left + scanAreaSize - 8, top + scanAreaSize),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(left + scanAreaSize - 16, top + scanAreaSize - 16, 16, 16),
      0,
      1.5708,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - 8),
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLinePainter extends CustomPainter {
  final double animationValue;

  _ScanLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.75;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    // Calculate scan line position
    final lineY = top + 20 + (scanAreaSize - 40) * animationValue;

    // Draw gradient scan line
    final gradient = LinearGradient(
      colors: [
        Colors.blue.withOpacity(0),
        Colors.blue.withOpacity(0.8),
        Colors.blue.withOpacity(0.8),
        Colors.blue.withOpacity(0),
      ],
      stops: const [0.0, 0.2, 0.8, 1.0],
    );

    final linePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(left + 10, lineY - 2, scanAreaSize - 20, 4),
      )
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(left + 20, lineY),
      Offset(left + scanAreaSize - 20, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
