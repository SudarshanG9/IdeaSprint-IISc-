// lib/screens/playback_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/product_model.dart';
import '../services/tts_service.dart';
import '../widgets/accessible_button.dart';
import 'home_screen.dart';

enum _PlayState { playing, paused, finished }

class PlaybackScreen extends StatefulWidget {
  final Product product;
  final bool fromCache;
  const PlaybackScreen({super.key, required this.product, this.fromCache = false});
  @override State<PlaybackScreen> createState() => _PlaybackScreenState();
}

import 'package:audioplayers/audioplayers.dart';

class _PlaybackScreenState extends State<PlaybackScreen>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  final _tts = TtsService(); // fallback for basic announcements if needed
  _PlayState _ps = _PlayState.playing;

  late final AnimationController _wave = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          if (state == PlayerState.playing) _ps = _PlayState.playing;
          else if (state == PlayerState.paused) _ps = _PlayState.paused;
          else if (state == PlayerState.completed) _ps = _PlayState.finished;
          else if (state == PlayerState.stopped) _ps = _PlayState.finished;
        });
      }
    });
    _play();
  }

  @override
  void dispose() { 
    _wave.dispose(); 
    _player.dispose(); 
    _tts.stop(); 
    super.dispose(); 
  }

  Future<void> _play() async {
    setState(() => _ps = _PlayState.playing);
    if (widget.product.audioUrl.isNotEmpty) {
      await _player.play(UrlSource(widget.product.audioUrl));
    } else {
      await _tts.speak(widget.product.description);
      if (mounted) setState(() => _ps = _PlayState.finished);
    }
  }

  Future<void> _replay() async {
    HapticFeedback.mediumImpact();
    setState(() => _ps = _PlayState.playing);
    if (widget.product.audioUrl.isNotEmpty) {
      await _player.seek(Duration.zero);
      await _player.resume();
    } else {
      await _tts.speak(widget.product.description);
      if (mounted) setState(() => _ps = _PlayState.finished);
    }
  }

  Future<void> _togglePause() async {
    HapticFeedback.selectionClick();
    if (_ps == _PlayState.playing) {
      if (widget.product.audioUrl.isNotEmpty) await _player.pause();
      else await _tts.stop();
      setState(() => _ps = _PlayState.paused);
    } else {
      setState(() => _ps = _PlayState.playing);
      if (widget.product.audioUrl.isNotEmpty) await _player.resume();
      else {
        await _tts.speak(widget.product.description);
        if (mounted) setState(() => _ps = _PlayState.finished);
      }
    }
  }

  void _goHome() {
    _player.stop();
    _tts.stop();
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
  }

  Color get _stateColor => _ps == _PlayState.paused ? AppTheme.secondary : AppTheme.primary;
  String get _stateLabel => switch (_ps) {
    _PlayState.playing  => AppStrings.playingDesc,
    _PlayState.paused   => 'Paused',
    _PlayState.finished => 'Ready to replay',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(children: [
              _IconBtn(icon: Icons.home, onTap: _goHome, label: 'Go home'),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(liveRegion: true, label: _stateLabel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: _stateColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: _stateColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        _ps == _PlayState.playing ? Icons.graphic_eq
                            : _ps == _PlayState.paused  ? Icons.pause_circle
                            : Icons.check_circle_outline,
                        color: _stateColor, size: 17),
                      const SizedBox(width: 7),
                      Text(_stateLabel, style: TextStyle(
                        color: _stateColor, fontSize: 13, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Category
            if (widget.product.category.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(widget.product.category.toUpperCase(),
                  style: const TextStyle(color: AppTheme.primary, fontSize: 11,
                      fontWeight: FontWeight.w800, letterSpacing: 1.4)),
              ),
            const SizedBox(height: 10),

            // Product name
            Semantics(header: true, label: 'Product: ${widget.product.name}',
              child: Text(widget.product.name,
                style: const TextStyle(color: AppTheme.textPrimary,
                    fontSize: 30, fontWeight: FontWeight.w900, height: 1.1))),
            const SizedBox(height: 14),

            // Waveform
            _WaveBar(playing: _ps == _PlayState.playing, anim: _wave, color: _stateColor),
            const SizedBox(height: 18),

            // Description card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
              ),
              child: Text(widget.product.description,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, height: 1.6)),
            ),
            const SizedBox(height: 20),

            // Replay / Pause
            Row(children: [
              Expanded(child: AccessibleButton(
                label: AppStrings.replay, semanticLabel: 'Replay audio',
                onPressed: _replay, icon: Icons.replay, height: 62,
                backgroundColor: AppTheme.cardBg, foregroundColor: AppTheme.primary,
              )),
              const SizedBox(width: 10),
              Expanded(child: AccessibleButton(
                label: _ps == _PlayState.playing ? AppStrings.pause : AppStrings.resume,
                semanticLabel: _ps == _PlayState.playing ? 'Pause audio' : 'Resume audio',
                onPressed: _togglePause,
                icon: _ps == _PlayState.playing ? Icons.pause : Icons.play_arrow,
                height: 62,
                backgroundColor: AppTheme.secondary.withOpacity(0.13),
                foregroundColor: AppTheme.secondary,
              )),
            ]),
            
            const SizedBox(height: 18),
            AccessibleButton(
               label: AppStrings.scanAnother, semanticLabel: 'Scan another product',
               onPressed: _goHome, icon: Icons.qr_code_scanner,
            ),
          ]),
        ),
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  final bool playing;
  final Animation<double> anim;
  final Color color;
  const _WaveBar({required this.playing, required this.anim, required this.color});

  @override
  Widget build(BuildContext context) {
    final heights = [4.0, 8.0, 14.0, 20.0, 28.0, 20.0, 14.0, 8.0, 4.0,
                     8.0, 16.0, 24.0, 16.0, 8.0, 4.0, 10.0, 18.0, 10.0, 4.0, 8.0];
    return Semantics(label: playing ? 'Audio playing' : 'Audio stopped',
      child: SizedBox(height: 52,
        child: AnimatedBuilder(
          animation: anim,
          builder: (_, __) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: heights.map((h) {
              final animated = playing ? (h * (0.3 + 0.7 * anim.value)).clamp(4.0, 36.0) : 4.0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 5, height: animated,
                  decoration: BoxDecoration(
                    color: playing ? color : color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;
  const _DetailSection({required this.title, required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$title: ${items.join(', ')}',
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 7),
          Text(title, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 8, right: 9),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            Expanded(child: Text(item, style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 15, height: 1.5))),
          ]),
        )),
      ]),
    ),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  const _IconBtn({required this.icon, required this.onTap, required this.label});
  @override
  Widget build(BuildContext context) => Semantics(label: label, button: true,
    child: GestureDetector(onTap: onTap,
      child: Container(width: 44, height: 44,
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: AppTheme.textPrimary, size: 22))));
}