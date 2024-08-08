import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadManager extends StateNotifier<Map<int, Map<int, dynamic>>> {
  DownloadManager() : super({});

  final Map<int, Map<int, bool>> downloading = {};
  final Map<int, Map<int, double>> downloadProgress = {};
  final Map<int, Map<int, String?>> downloadedFiles = {};
  final Map<int, Map<int, CancelToken>> cancelTokens = {};
  final Map<int, Map<int, Map<String, String>>> pausedDownloads = {};
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> downloadVideoFile(int tabIndex, int index, String url, String filename, String imageurl) async {
    downloading[tabIndex] ??= {};
    downloadProgress[tabIndex] ??= {};
    cancelTokens[tabIndex] ??= {};
    cancelTokens[tabIndex]![index] = CancelToken();

    downloading[tabIndex]![index] = true;
    downloadProgress[tabIndex]![index] = 0.0;
    state = {...state};

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final dio = Dio();
      audioPlayer.play(AssetSource("audio/downloading_audio.mp3"));
      Timer(const Duration(seconds: 4), () {
        audioPlayer.resume();
      });

      await dio.download(url, filePath, cancelToken: cancelTokens[tabIndex]![index], onReceiveProgress: (received, total) {
        downloadProgress[tabIndex]![index] = received / total;
        state = {...state};
      });

      if (File(filePath).existsSync()) {
        downloading[tabIndex]![index] = false;
        downloadProgress[tabIndex]![index] = 1.0;
        downloadedFiles[tabIndex]![index] = filePath;
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
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        pausedDownloads[tabIndex] ??= {};
        pausedDownloads[tabIndex]![index] = {'url': url, 'filename': filename, 'imageurl': imageurl};
      } else {
        downloading[tabIndex]![index] = false;
        downloadProgress[tabIndex]![index] = 0;
        downloadedFiles[tabIndex]![index] = null;
        state = {...state};
      }
    }
  }

  Future<void> loadDownloadStatuses(int tabIndex, List<dynamic> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < videos.length; i++) {
      var video = videos[i];
      String key = "${video['title']}.mp4";
      String? filePath = prefs.getString(key);

      if (filePath != null && File(filePath).existsSync()) {
        downloadedFiles[tabIndex] ??= {};
        downloadedFiles[tabIndex]![i] = filePath;
      } else {
        downloadedFiles[tabIndex] ??= {};
        downloadedFiles[tabIndex]![i] = null;
      }
    }
    state = {...state};
  }

  void pauseDownload(int tabIndex, int index) {
    if (cancelTokens[tabIndex]?[index]?.isCancelled == false) {
      cancelTokens[tabIndex]?[index]?.cancel();
    }
  }

  void pauseAllDownloads() {
    for (var tabEntry in cancelTokens.entries) {
      for (var entry in tabEntry.value.entries) {
        if (entry.value.isCancelled == false) {
          entry.value.cancel();
        }
      }
    }
  }

  Future<void> resumePausedDownloads() async {
    for (var tabEntry in pausedDownloads.entries) {
      for (var entry in tabEntry.value.entries) {
        var videoInfo = entry.value;
        await downloadVideoFile(tabEntry.key, entry.key, videoInfo['url']!, videoInfo['filename']!, videoInfo['imageurl']!);
      }
    }
    pausedDownloads.clear();
  }
}

final downloadManagerProvider = StateNotifierProvider<DownloadManager, Map<int, Map<int, dynamic>>>(
      (ref) => DownloadManager(),
);
