import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // WICHTIG: Für debugPrint

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccess() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/success.wav'));
    } catch (e) {
      // debugPrint statt print ist Best Practice
      debugPrint("Fehler beim Abspielen von Success-Sound: $e");
    }
  }

  Future<void> playError() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/error.wav'));
    } catch (e) {
      debugPrint("Fehler beim Abspielen von Error-Sound: $e");
    }
  }
}