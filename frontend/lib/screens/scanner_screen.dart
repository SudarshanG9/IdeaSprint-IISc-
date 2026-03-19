// lib/screens/scanner_screen.dart
//
// mobile_scanner v5 supports:
//   Android  → native camera
//   Chrome   → MediaDevices.getUserMedia (webcam)
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme.dart';
import '../services/tts_service.dart';
import '../services/product_service.dart';
import '../widgets/accessible_button.dart';
import 'playback_screen.dart';

enum _State { scanning, detected, loading, error }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _tts  = TtsService();
  final _svc  = ProductService();
  final _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  _State _state = _State.scanning;
  String _msg   = AppStrings.scanning;
  bool   _done  = false;

  @override
  void initState() {
    super.initState();
    _tts.speak('Camera open. Point camera at QR code. Scanning automatically.');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ── On QR detected ────────────────────────────────────────────────────────
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_done) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    _done = true;
    HapticFeedback.heavyImpact();
    await _ctrl.stop();

    setState(() { _state = _State.detected; _msg = AppStrings.productDetected; });
    await _tts.speak('Product detected. Loading information.');

    // Extract ID from URL like https://yourbackend.com/product/DEMO001
    String id = raw;
    if (raw.contains('/product/')) {
      id = raw.split('/product/').last.split('?').first;
    }

    await _load(id);
  }

  Future<void> _load(String id) async {
    setState(() { _state = _State.loading; _msg = 'Fetching product…'; });

    // ── Switch to fetchProduct(id) once backend is ready ──────────────────
    final result = await _svc.fetchMock(id);
    // final result = await _svc.fetchProduct(id);

    if (!mounted) return;

    if (result.isSuccess) {
      await _tts.stop();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => PlaybackScreen(product: result.product!, fromCache: result.fromCache),
      ));
    } else {
      setState(() { _state = _State.error; _msg = result.error!; });
      await _tts.speak(result.error!);
    }
  }

  void _retry() {
    setState(() { _state = _State.scanning; _msg = AppStrings.scanning; _done = false; });
    _ctrl.start();
    _tts.speak('Scanning resumed.');
  }

  Color get _color => switch (_state) {
    _State.scanning  => AppTheme.primary,
    _State.detected  => AppTheme.secondary,
    _State.loading   => AppTheme.primary,
    _State.error     => AppTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // ── Camera / webcam feed ──────────────────────────────────────────
        if (_state == _State.scanning || _state == _State.detected)
          MobileScanner(controller: _ctrl, onDetect: _onDetect)
        else
          Container(color: AppTheme.background),

        // ── Scanner overlay corners ───────────────────────────────────────
        if (_state == _State.scanning) _ScanOverlay(color: _color),

        // ── Bottom panel ──────────────────────────────────────────────────
        Positioned(left: 0, right: 0, bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.95)],
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Status chip
              Semantics(label: _msg, liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: _color.withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (_state == _State.loading)
                      SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: _color, strokeWidth: 2))
                    else
                      Icon(_state == _State.error ? Icons.error_outline
                          : _state == _State.detected ? Icons.check_circle
                          : Icons.radio_button_on, color: _color, size: 18),
                    const SizedBox(width: 8),
                    Text(_msg, style: TextStyle(color: _color, fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              if (_state == _State.scanning)
                Text('Point camera at the QR code on the product',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                  textAlign: TextAlign.center),

              if (_state == _State.error) ...[
                const SizedBox(height: 12),
                AccessibleButton(
                  label: 'Try Again', semanticLabel: 'Try scanning again',
                  onPressed: _retry, icon: Icons.refresh,
                  height: 60, backgroundColor: AppTheme.danger.withOpacity(0.2),
                  foregroundColor: AppTheme.danger,
                ),
              ],

              const SizedBox(height: 12),

              // Cancel
              Semantics(label: 'Cancel and go back', button: true,
                child: GestureDetector(
                  onTap: () { _tts.stop(); Navigator.pop(context); },
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Center(child: Text('Cancel',
                      style: TextStyle(color: Colors.white60, fontSize: 17, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
            ]),
          ),
        ),

        // ── Back button (top) ─────────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 10, left: 16,
          child: Semantics(label: 'Go back', button: true,
            child: GestureDetector(
              onTap: () { _tts.stop(); Navigator.pop(context); },
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.black54,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── QR corner brackets overlay ────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  final Color color;
  const _ScanOverlay({required this.color});

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    final box = sz.width * 0.65;
    final left = (sz.width - box) / 2;
    final top  = (sz.height - box) / 2 - 60;
    const c = 28.0; // corner arm length

    return Stack(children: [
      // Dark overlay — use CustomPaint for a cutout effect
      CustomPaint(
        size: sz,
        painter: _OverlayPainter(left: left, top: top, box: box),
      ),
      // Corner brackets
      Positioned(left: left, top: top, width: box, height: box,
        child: CustomPaint(painter: _BracketPainter(c: c, color: color)),
      ),
    ]);
  }
}

class _OverlayPainter extends CustomPainter {
  final double left, top, box;
  _OverlayPainter({required this.left, required this.top, required this.box});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final hole = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, box, box), const Radius.circular(16));
    canvas.drawPath(
      Path()..addRect(full)..addRRect(hole)..fillType = PathFillType.evenOdd,
      paint,
    );
  }
  @override bool shouldRepaint(_) => false;
}

class _BracketPainter extends CustomPainter {
  final double c;
  final Color color;
  _BracketPainter({required this.c, required this.color});
  @override
  void paint(Canvas canvas, Size sz) {
    final p = Paint()..color = color..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    // TL
    canvas.drawLine(Offset(0, c), Offset.zero, p);
    canvas.drawLine(Offset.zero, Offset(c, 0), p);
    // TR
    canvas.drawLine(Offset(sz.width - c, 0), Offset(sz.width, 0), p);
    canvas.drawLine(Offset(sz.width, 0), Offset(sz.width, c), p);
    // BL
    canvas.drawLine(Offset(0, sz.height - c), Offset(0, sz.height), p);
    canvas.drawLine(Offset(0, sz.height), Offset(c, sz.height), p);
    // BR
    canvas.drawLine(Offset(sz.width - c, sz.height), Offset(sz.width, sz.height), p);
    canvas.drawLine(Offset(sz.width, sz.height), Offset(sz.width, sz.height - c), p);
  }
  @override bool shouldRepaint(_) => false;
}