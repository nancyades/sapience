import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sapience/Controller/Provider/downloadmanagerprovider.dart';
import 'package:sapience/Screens/loaderscreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/connectivity_manager.dart';
import 'package:sapience/constant/custom_video_contols.dart';
import 'package:sapience/constant/shimmer_skeleton.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/helper/audiofile.dart';
import 'package:sapience/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../../Controller/Provider/video.dart';

class LandscapeVideoViewer extends ConsumerStatefulWidget {
  String? filePath;
  String? image;
  final int? subcatlen;
  String? section;
  String? sectionid;
  String? subjectName;
  int? titleid;
  String? subcatid;

  LandscapeVideoViewer({
    super.key,
    this.filePath,
    this.image,
    this.subjectName,
    this.subcatlen,
    this.section,
    this.sectionid,
    this.titleid,
    this.subcatid,
  });

  @override
  _LandscapeVideoViewerState createState() => _LandscapeVideoViewerState();
}

class _LandscapeVideoViewerState extends ConsumerState<LandscapeVideoViewer>
    with WidgetsBindingObserver {
  bool isCarouselVisible = false; // State to track visibility
  bool _showControls = false;
  bool _isBuffering = false;
  Timer? _hideTimer;

  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isVideoPlaying = false;
  String? _error;

  void toggleCarouselVisibility() {
    // Toggle the state to show or hide the Carousel
    setState(() {
      isCarouselVisible = !isCarouselVisible;
    });
  }

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: SystemUiOverlay.values);
    _startHideTimer();
    GlobalState.activeScreen = 'SpecificScreen';
    AudioService().stopMusic();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setLandscape();
    Wakelock.enable();

    _playVideo(widget.filePath!);
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  void _playVideo(String path) async {
    setState(() {
      _error = null;
      _isBuffering = true;
    });

    try {
      if (_controller != null) {
        _controller!.dispose();
      }
      if (_chewieController != null) {
        _chewieController!.dispose();
      }

      _controller = VideoPlayerController.networkUrl(Uri.parse(path));

      await _controller!.initialize();
      _controller!.addListener(_checkBufferingState);

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _controller!,
          showControls: false,
          autoPlay: true,
          looping: false,
          allowFullScreen: false,
          allowedScreenSleep: true,

          fullScreenByDefault: false,
          aspectRatio: _controller!.value.aspectRatio,
        );
        _isVideoPlaying = true;
        _isBuffering = false;
      });

      _controller!.addListener(() {
        if (_controller!.value.position == _controller!.value.duration) {
          setState(() {
            _isVideoPlaying = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isBuffering = false;
      });
    }
  }

  void _checkBufferingState() {
    if (_controller!.value.isBuffering) {
      setState(() {
        _isBuffering = true;
      });
    } else {
      setState(() {
        _isBuffering = false;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startHideTimer();
      }
    });
  }

  @override
  void dispose() async {
    GlobalState.activeScreen = null;
    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();
    super.dispose();

    _controller!.dispose();
    _chewieController?.dispose();
    AudioService().playMusic();
  }

  Future setLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _forward() {
    final currentPosition = _controller!.value.position;
    final duration = _controller!.value.duration;
    final forwardPosition = currentPosition + const Duration(seconds: 10);
    _controller!
        .seekTo(forwardPosition < duration ? forwardPosition : duration);
  }

  void _rewind() {
    final currentPosition = _controller!.value.position;
    final rewindPosition = currentPosition - const Duration(seconds: 10);
    _controller!.seekTo(
        rewindPosition > Duration.zero ? rewindPosition : Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final downloadManager = ref.watch(downloadManagerProvider.notifier);
    return WillPopScope(
      onWillPop: () async {
        Get.off(
              () => loadertvScreen(
            subcatid: widget.subcatid,
            titleid: widget.titleid,
            section: widget.section,
            sectionid: widget.sectionid,
            subcatlen: widget.subcatlen,
            subjectName: widget.subjectName,
          ),
          // transition: Transition.rightToLeft,
          // duration: const Duration(milliseconds: 500),
        );
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            if (_controller != null && _controller!.value.isInitialized)
              GestureDetector(
                  onTap: _toggleControls,
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! < 0) {
                      if (!isCarouselVisible) toggleCarouselVisibility();
                    } else if (details.primaryDelta! > 0) {
                      if (isCarouselVisible) toggleCarouselVisibility();
                    }
                  },
                  child: Stack(
                    children: [
                      Chewie(
                        controller: _chewieController!,
                      ),
                      GestureDetector(
                        child: CustomControls(
                          chewieController: _chewieController!,
                          showControls: _showControls,
                          onForward: _forward,
                          onRewind: _rewind,
                          isBuffering: _isBuffering,
                        ),
                      ),
                      if (_isBuffering)
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 20,
                        left: 0,
                        child: IconButton(
                          iconSize: AppTheme.mediumFontSize,
                          icon: SvgPicture.asset(
                            'assets/images/sapience/back-arrow.svg',
                            color: Colors.white,
                            width: AppTheme.largeFontSize,
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            AudioPlayer()
                                .play(AssetSource("audio/Bubble 02.mp3"));

                            Get.off(
                                  () => loadertvScreen(
                                subcatid: widget.subcatid,
                                titleid: widget.titleid,
                                section: widget.section,
                                sectionid: widget.sectionid,
                                subcatlen: widget.subcatlen,
                                subjectName: widget.subjectName,
                              ),
                              // transition: Transition.rightToLeft,
                              // duration: const Duration(milliseconds: 500),
                            );
                          },
                        ),
                      ),
                    ],
                  ))
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      widget.image.toString() == "null"
                          ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                          : widget.image.toString(),
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 0,
                      child: IconButton(
                        iconSize: AppTheme.mediumFontSize,
                        icon: SvgPicture.asset(
                          'assets/images/sapience/back-arrow.svg',
                          color: Colors.white,
                          width: AppTheme.largeFontSize,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          AudioPlayer()
                              .play(AssetSource("audio/Bubble 02.mp3"));

                          Get.off(
                                () => loaderScreen(
                              subcatid: widget.subcatid,
                              titleid: widget.titleid,
                              section: widget.section,
                              sectionid: widget.sectionid,
                              subcatlen: widget.subcatlen,
                              subjectName: widget.subjectName,
                            ),
                            // transition: Transition.rightToLeft,
                            // duration: const Duration(milliseconds: 500),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            Consumer(
              builder: (context, ref, child) {
                final videoState = ref.watch(addvideoNotifier);
                return videoState.id.when(
                  data: (data) {
                    if (data is Map<String, dynamic> &&
                        data.containsKey('data')) {
                      List<dynamic> videos = data['data'] as List<dynamic>;

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        bottom: isCarouselVisible ? 0 : -200,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _toggleControls,
                          onVerticalDragUpdate: (details) {
                            if (details.primaryDelta! < 0) {
                              if (!isCarouselVisible) toggleCarouselVisibility();
                            } else if (details.primaryDelta! > 0) {
                              if (isCarouselVisible) toggleCarouselVisibility();
                            }
                          },
                          child: CarouselSlider(
                            items: videos.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: ()async {
                                      AudioPlayer().play(
                                          AssetSource("audio/Bubble 02.mp3"));

                                      print("subvideoindex ---> ${downloadManager.downloadedFiles[widget.titleid]?[i]}");

                                      print("subvideoindex titleid ---> ${widget.titleid}");
                                      print("subvideoindex i ---> ${i}");

                                      if (i != null) {
                                        final prefs = await SharedPreferences.getInstance();
                                        final filePath = prefs
                                            .getString("${i['title']}.mp4");
                                        final fileimage = prefs.getString(
                                            "image${i['title']}.mp4");

                                        if (filePath != null &&
                                            await File(filePath).exists()) {
                                          widget.image = widget.image == null
                                              ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                                              : fileimage.toString();
                                          _playVideo(filePath);

                                        }  else {
                                          ConnectivityManager
                                          connectivityManager =
                                          ConnectivityManager();
                                          bool isOnline =
                                          await connectivityManager
                                              .isConnected();
                                          if (!isOnline) {
                                            Get.snackbar("Network Error",
                                                "Please turn on your network to download video.",
                                                snackPosition: SnackPosition.TOP,
                                                duration:
                                                const Duration(seconds: 1),
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                                snackStyle: SnackStyle.FLOATING);
                                            return;
                                          } else {
                                            widget.image = widget.image == null
                                                ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                                                : i['image_url'].toString();
                                            _playVideo(i['video_url']);

                                          }
                                        }
                                      }



                                      // widget.image = widget.image == null
                                      //     ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                                      //     : i['image_url'].toString();
                                      //
                                      // _playVideo(i['video_url']);

                                      isCarouselVisible = false;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 15, left: 10, right: 2),
                                      width:
                                      MediaQuery.of(context).size.width / 3,
                                      margin: const EdgeInsets.only(
                                          bottom: 0, left: 5, right: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: i['image_url'] == null
                                            ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                                            : i['image_url'],
                                        fit: BoxFit.fill,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                        placeholder: (context, url) =>
                                            ShimmerSkeleton(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            options: CarouselOptions(
                              padEnds: false,
                              height: 180.0,
                              autoPlay: false,
                              initialPage: 0,
                              viewportFraction: 1 / 3,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: false,
                              onPageChanged: (index, reason) {
                                // Handle page change if needed
                              },
                            ),
                          ),
                        ),
                      );
                    } else {
                      return  Center(
                          child: GestureDetector(
                            onTap: ()async{
                              ConnectivityManager connectivityManager =
                              ConnectivityManager();
                              bool isOnline = await connectivityManager.isConnected();
                              if (!isOnline) {
                                SnackbarUtil.showNetworkError();
                                return;
                              }
                            },

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 600,
                                  width: 350,
                                  child:
                                  Image.asset('assets/images/sapience/404 Error.png'),
                                ),
                              ],
                            ),));
                    }
                  },
                  loading: () => ShimmerSkeleton(
                    child: AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      bottom: isCarouselVisible ? 0 : -200,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: CarouselSlider(
                          items: [1, 2, 3, 4, 5, 6].map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: () {
                                    _controller =
                                        VideoPlayerController.networkUrl(
                                          Uri.parse(
                                              "https://cdn.pixabay.com/video/2023/07/31/174003-850361299_large.mp4"),
                                        );

                                    _controller!.addListener(() {
                                      setState(() {});
                                    });
                                    _controller!.setLooping(true);
                                    _controller!.initialize().then((_) {
                                      setState(() {});
                                      AudioService().stopMusic();
                                      _controller!.play();
                                      setLandscape();
                                    });
                                    isCarouselVisible = false;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 15, left: 10, right: 10),
                                    width:
                                    MediaQuery.of(context).size.width / 3,
                                    margin: const EdgeInsets.only(
                                        bottom: 20, left: 8, right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                      image: const DecorationImage(
                                        image: AssetImage(''),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Text(
                                      'text $i',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            padEnds: false,
                            height: 180.0,
                            autoPlay: false,
                            initialPage: 0,
                            viewportFraction: 1 / 3,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: false,
                            onPageChanged: (index, reason) {
                              // Handle page change if needed
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  error: (err, stack) => Text('Error: $err'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
