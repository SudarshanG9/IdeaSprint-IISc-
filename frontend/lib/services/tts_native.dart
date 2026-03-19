// lib/services/tts_native.dart
// Used on Android/iOS. flutter_tts works natively here.

import 'package:flutter_tts/flutter_tts.dart';

class TtsPlatform {
  final FlutterTts _tts = FlutterTts();

  Future<void> init(String lang) async {
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setLanguage(String code) async {
    await _tts.setLanguage(code);
  }
}