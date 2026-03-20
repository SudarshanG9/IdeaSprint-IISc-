// lib/services/tts_service.dart
//
// Android  → flutter_tts (real TTS engine)
// Web/Chrome → window.speechSynthesis via dart:js_interop
//
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

// Only imported on non-web
import 'tts_native.dart' if (dart.library.html) 'tts_web.dart';

class TtsService {
  static final TtsService _i = TtsService._();
  factory TtsService() => _i;
  TtsService._();

  final TtsPlatform _platform = TtsPlatform();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? (kIsWeb ? 'en-US' : 'en-IN');
    await _platform.init(lang);
    _ready = true;
  }

  Future<void> speak(String text) async {
    await _init();
    await _platform.speak(text);
  }

  Future<void> stop() async {
    await _platform.stop();
  }

  Future<void> setLanguage(String code) async {
    await _platform.setLanguage(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);
  }

  Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lang') ?? (kIsWeb ? 'en-US' : 'en-IN');
  }
}