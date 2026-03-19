// lib/services/tts_web.dart
// Used on Chrome/Web. Calls window.speechSynthesis directly.

import 'dart:js_interop';

@JS('window.speechSynthesis.speak')
external void _jsSpeech(JSObject utterance);

@JS('window.speechSynthesis.cancel')
external void _jsCancel();

@JS('SpeechSynthesisUtterance')
@staticInterop
class _Utterance {
  external factory _Utterance(String text);
}

extension _UtteranceExt on _Utterance {
  external set lang(String v);
  external set rate(double v);
  external set pitch(double v);
  external set volume(double v);
}

class TtsPlatform {
  String _lang = 'en-US';

  Future<void> init(String lang) async {
    _lang = lang;
  }

  Future<void> speak(String text) async {
    _jsCancel();
    final u = _Utterance(text);
    u.lang   = _lang;
    u.rate   = 0.85;   // slightly faster on web — sounds more natural
    u.pitch  = 1.0;
    u.volume = 1.0;
    _jsSpeech(u as JSObject);
  }

  Future<void> stop() async {
    _jsCancel();
  }

  Future<void> setLanguage(String code) async {
    _lang = code;
  }
}