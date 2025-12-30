import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccess() async {
    try {
      await _player.stop();
      // Bei audioplayers 6.x nutzen wir AssetSource
      // Hinweis: Wenn deine Datei in assets/audio/success.wav liegt,
      // lautet der Pfad für AssetSource oft nur 'audio/success.wav'
      await _player.play(AssetSource('audio/success.wav'));
    } catch (e) {
      print("Fehler beim Abspielen von Success-Sound: $e");
    }
  }

  Future<void> playError() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/error.wav'));
    } catch (e) {
      print("Fehler beim Abspielen von Error-Sound: $e");
    }
  }
}