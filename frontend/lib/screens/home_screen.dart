// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/tts_service.dart';
import '../widgets/accessible_button.dart';
import 'scanner_screen.dart';
import 'language_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tts = TtsService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      _tts.speak('ScanSpeak. Tap the large button to scan a product.');
    });
  }

  void _goScan() {
    _tts.stop();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
  }

  void _goSettings() {
    _tts.stop();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(children: [
              // ── Top bar ───────────────────────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ScanSpeak',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: AppTheme.primary)),
                  Text('Accessibility QR',
                    style: Theme.of(context).textTheme.bodyMedium),
                ]),
                Semantics(
                  label: 'Language settings', button: true,
                  child: GestureDetector(
                    onTap: _goSettings,
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.language, color: AppTheme.primary, size: 26),
                    ),
                  ),
                ),
              ]),

              const Spacer(),

              // ── Pulsing scan button ───────────────────────────────────────
              PulsingScanButton(onPressed: _goScan),
              const SizedBox(height: 28),

              // ── Voice hint ────────────────────────────────────────────────
              Text('Tap or say "Scan"',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.mic, color: AppTheme.primary.withOpacity(0.6), size: 16),
                const SizedBox(width: 6),
                Text('Voice activation ready',
                  style: TextStyle(color: AppTheme.primary.withOpacity(0.6), fontSize: 13)),
              ]),

              const Spacer(),

              // ── Feature pills ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Pill(icon: Icons.volume_up,     label: 'Audio'),
                    _Pill(icon: Icons.offline_bolt,  label: 'Offline'),
                    _Pill(icon: Icons.language,      label: 'Multilingual'),
                    _Pill(icon: Icons.accessibility, label: 'Accessible'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Big tap area alternative ──────────────────────────────────
              AccessibleButton(
                label: 'Open Scanner',
                semanticLabel: 'Open product QR scanner',
                onPressed: _goScan,
                icon: Icons.camera_alt,
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: AppTheme.primary, size: 22),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
  ]);
}