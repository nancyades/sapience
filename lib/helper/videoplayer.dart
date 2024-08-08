import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService();
});

class VideoService {
  VideoPlayerController? _controller;

  VideoPlayerController? get controller => _controller;

  void initializeController(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller!.initialize();
  }

  void play() {
    _controller?.play();
  }

  void pause() {
    _controller?.pause();
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
