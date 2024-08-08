import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final healthydownloadManagerProvider = StateNotifierProvider<HealthyDownloadManager, Map<int, dynamic>>(
  (ref) => HealthyDownloadManager(),
);

class HealthyDownloadManager extends StateNotifier<Map<int, dynamic>> {
  HealthyDownloadManager() : super({});

  final Map<int, bool> downloading = {};
  final Map<int, double> downloadProgress = {};
  final Map<int, String?> downloadedFiles = {};
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> downloadVideoFile(int index, String url, String filename, String imageurl) async {
    downloading[index] = true;
    downloadProgress[index] = 0.0;
    state = {...state};

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final dio = Dio();
      audioPlayer.play(AssetSource("audio/downloading_audio.mp3"));
      Timer(const Duration(seconds: 4), () {
        audioPlayer.resume();
      });

      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        downloadProgress[index] = received / total;
        state = {...state};
      });

      if (File(filePath).existsSync()) {
        downloading[index] = false;
        downloadProgress[index] = 1.0;
        downloadedFiles[index] = filePath;
        state = {...state};

        audioPlayer.play(AssetSource("audio/download_completed.mp3"));
        Timer(const Duration(seconds: 2), () {
          audioPlayer.resume();
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(filename, filePath);
        await prefs.setString('image$filename', imageurl);
      } else {
        throw Exception("File not found after download");
      }
    } catch (e) {
      downloading[index] = false;
      downloadProgress[index] = 0.0;
      downloadedFiles[index] = null;
      state = {...state};
    }
  }

  Future<void> loadDownloadStatuses(List<dynamic> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < videos.length; i++) {
      var video = videos[i];
      String key = "${video['title']}.mp4";
      String? filePath = prefs.getString(key);

      if (filePath != null && File(filePath).existsSync()) {
        downloadedFiles[i] = filePath;
        state = {...state};
      } else {
        downloadedFiles[i] = null;
        state = {...state};
      }
    }
  }
}
