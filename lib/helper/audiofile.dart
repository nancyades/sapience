import 'package:audioplayers/audioplayers.dart';

class AudioService {
  late AudioPlayer _audioPlayer;
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
  }



  /// Play music with looping enabled
  Future<void> playMusic() async {
    await _audioPlayer.setSource(AssetSource('audio/Happy_Kids.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Ensures the audio loops
    await _audioPlayer.setVolume(0.3);
    await _audioPlayer.resume();
  }


  void resumeMusic(){
    _audioPlayer.resume();
  }
  void pauseMusic() {
    _audioPlayer.pause();
  }

  void stopMusic() {
    _audioPlayer.stop();
  }

  void disposeMusic() {
    _audioPlayer.dispose();
  }
}





