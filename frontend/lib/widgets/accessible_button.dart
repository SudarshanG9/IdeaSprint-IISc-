// lib/widgets/accessible_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class AccessibleButton extends StatefulWidget {
  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final bool isLoading;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 72,
    this.isLoading = false,
  });

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 80),
  );
  late final Animation<double> _scale =
      Tween(begin: 1.0, end: 0.95).animate(_ctrl);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _down(_) { _ctrl.forward(); HapticFeedback.mediumImpact(); }
  void _up(_)   { _ctrl.reverse(); }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppTheme.primary;
    final fg = widget.foregroundColor ?? Colors.black;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
        onTapDown: _down, onTapUp: _up,
        onTapCancel: () => _ctrl.reverse(),
        onTap: (widget.isLoading || widget.onPressed == null)
            ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: double.infinity, height: widget.height,
            decoration: BoxDecoration(
              color: widget.isLoading ? bg.withOpacity(0.6) : bg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(
                color: bg.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6),
              )],
            ),
            child: widget.isLoading
                ? Center(child: SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(color: fg, strokeWidth: 3),
                  ))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: fg, size: 26),
                      const SizedBox(width: 10),
                    ],
                    Text(widget.label, style: TextStyle(
                      color: fg, fontSize: 20, fontWeight: FontWeight.w800,
                    )),
                  ]),
          ),
        ),
      ),
    );
  }
}

// ── Pulsing scan button ─────────────────────────────────────────────────────
class PulsingScanButton extends StatefulWidget {
  final VoidCallback onPressed;
  const PulsingScanButton({super.key, required this.onPressed});
  @override State<PulsingScanButton> createState() => _PulsingScanButtonState();
}

class _PulsingScanButtonState extends State<PulsingScanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  late final Animation<double> _pulse =
      Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Scan product. Double tap to activate camera',
      button: true,
      child: GestureDetector(
        onTap: () { HapticFeedback.heavyImpact(); widget.onPressed(); },
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
          child: Container(
            width: 190, height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 40, spreadRadius: 8),
                BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 80, spreadRadius: 20),
              ],
            ),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.qr_code_scanner, size: 70, color: Colors.black),
              SizedBox(height: 6),
              Text('SCAN', style: TextStyle(
                color: Colors.black, fontSize: 20,
                fontWeight: FontWeight.w900, letterSpacing: 3,
              )),
            ]),
          ),
        ),
      ),
    );
  }
}