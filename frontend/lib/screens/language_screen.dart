// lib/screens/language_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/tts_service.dart';
import '../widgets/accessible_button.dart';

class _Lang { final String name, code, native;
  const _Lang(this.name, this.code, this.native); }

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final _tts = TtsService();
  String _selected = 'en-IN';
  bool _saving = false;

  static const _langs = [
    _Lang('English (India)', 'en-IN', 'English'),
    _Lang('English (US)',    'en-US', 'English (US)'),
    _Lang('Hindi',           'hi-IN', 'हिन्दी'),
    _Lang('Tamil',           'ta-IN', 'தமிழ்'),
    _Lang('Telugu',          'te-IN', 'తెలుగు'),
    _Lang('Kannada',         'kn-IN', 'ಕನ್ನಡ'),
    _Lang('Malayalam',       'ml-IN', 'മലയാളം'),
    _Lang('Marathi',         'mr-IN', 'मराठी'),
    _Lang('Bengali',         'bn-IN', 'বাংলা'),
    _Lang('Gujarati',        'gu-IN', 'ગુજરાતી'),
  ];

  @override
  void initState() {
    super.initState();
    _tts.getSavedLanguage().then((v) => setState(() => _selected = v));
    Future.delayed(const Duration(milliseconds: 400), () =>
      _tts.speak('Language settings. Select a language and tap Save.'));
  }

  Future<void> _preview(_Lang lang) async {
    HapticFeedback.selectionClick();
    setState(() => _selected = lang.code);
    await _tts.setLanguage(lang.code);
    await _tts.speak('This is ${lang.name}.');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    HapticFeedback.heavyImpact();
    final name = _langs.firstWhere((l) => l.code == _selected).name;
    await _tts.setLanguage(_selected);
    await _tts.speak('$name saved.');
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) { setState(() => _saving = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Semantics(label: 'Go back', button: true,
                child: GestureDetector(
                  onTap: () { _tts.stop(); Navigator.pop(context); },
                  child: Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(13)),
                    child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppStrings.settings,
                  style: Theme.of(context).textTheme.titleLarge),
                Text('Select your preferred language',
                  style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ]),
            const SizedBox(height: 18),

            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.touch_app, color: AppTheme.primary, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Tap a language to preview, then save.',
                  style: TextStyle(color: AppTheme.primary, fontSize: 14))),
              ]),
            ),
            const SizedBox(height: 14),

            // List
            Expanded(
              child: ListView.separated(
                itemCount: _langs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 7),
                itemBuilder: (_, i) {
                  final lang = _langs[i];
                  final sel = lang.code == _selected;
                  return Semantics(
                    label: '${lang.name}. ${sel ? 'Selected. ' : ''}Double tap to select.',
                    selected: sel, button: true,
                    child: GestureDetector(
                      onTap: () => _preview(lang),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary.withOpacity(0.13) : AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel ? AppTheme.primary : AppTheme.primary.withOpacity(0.08),
                            width: sel ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          // Radio circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sel ? AppTheme.primary : Colors.transparent,
                              border: Border.all(
                                color: sel ? AppTheme.primary : AppTheme.textSecondary, width: 2),
                            ),
                            child: sel ? const Icon(Icons.check, color: Colors.black, size: 13) : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(lang.name, style: TextStyle(
                              color: sel ? AppTheme.primary : AppTheme.textPrimary,
                              fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(lang.native, style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14)),
                          ])),
                          Icon(Icons.volume_up,
                            color: sel ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.4),
                            size: 20),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            AccessibleButton(
              label: 'Save Language', semanticLabel: 'Save selected language',
              onPressed: _save, icon: Icons.save_alt, isLoading: _saving,
            ),
          ]),
        ),
      ),
    );
  }
}