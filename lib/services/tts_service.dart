import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  TtsService() {
    _initTts();
  }

  // Initialisierung: Sprache auf Englisch setzen
  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5); // Etwas langsamer für besseres Lernen
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  // Die Funktion, die das Sprechen auslöst
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }
}