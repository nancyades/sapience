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
import 'package:sapience/Controller/Provider/foodvideosprovider.dart';
import 'package:sapience/Screens/loaderscreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/connectivity_manager.dart';
import 'package:sapience/constant/custom_video_contols.dart';
import 'package:sapience/constant/shimmer_skeleton.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/helper/appconstant.dart';
import 'package:sapience/helper/audiofile.dart';
import 'package:sapience/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class HealthyMealVideoPlayer extends ConsumerStatefulWidget {
  String? filePath;
  String? image;
  String? meals;
  String? foodcategory;
  String? foodtype;
  String? foodday;

  HealthyMealVideoPlayer(
      {super.key,
      this.filePath,
      this.image,
      this.meals,
      this.foodcategory,
      this.foodtype,
      this.foodday});

  @override
  ConsumerState<HealthyMealVideoPlayer> createState() =>
      _HealthyMealVideoPlayerState();
}

class _HealthyMealVideoPlayerState extends ConsumerState<HealthyMealVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isVideoPlaying = false;
  String? _error;
  bool isCarouselVisible = false;
  bool _showControls = false;
  bool _isBuffering = false;
  Timer? _hideTimer; // State to track visibility

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
    Wakelock.enable();
    setLandscape();
    GlobalState.activeScreen = 'SpecificScreen';
    AudioService().stopMusic();
    WidgetsBinding.instance.addObserver(this);
    super.initState();

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

  Future setLandscape() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() async {
    GlobalState.activeScreen = null;
    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();
    UserPreferences.videoroute("");
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();

    _controller!.dispose();
    AudioService().playMusic();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(
          () => Healthyloader(
            meals: widget.meals,
            foodcategory: widget.foodcategory.toString(),
            foodtype: widget.foodtype.toString(),
            foodday: widget.foodday.toString(),
          ),
          // transition: Transition.rightToLeft,
          // duration: const Duration(milliseconds: 500),
        );
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            /// we need to use below code
            (_controller != null && _controller!.value.isInitialized)
                ? GestureDetector(
                    onTap: _toggleControls,
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! < 0) {
                        if (!isCarouselVisible) toggleCarouselVisibility();
                      } else if (details.primaryDelta! > 0) {
                        if (isCarouselVisible) toggleCarouselVisibility();
                      }
                    },
                    child: Stack(
                      children: <Widget>[
                        Chewie(
                          controller: _chewieController!,
                        ),
                        CustomControls(
                          chewieController: _chewieController!,
                          showControls: _showControls,
                          onForward: _forward,
                          onRewind: _rewind,
                          isBuffering: _isBuffering,
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
                                () => Healthyloader(
                                  meals: widget.meals,
                                  foodcategory: widget.foodcategory.toString(),
                                  foodtype: widget.foodtype.toString(),
                                  foodday: widget.foodday.toString(),
                                ),

                                // transition: Transition.rightToLeft,
                                // duration: const Duration(milliseconds: 500),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(widget.image
                                      .toString() ==
                                  null
                              ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                              : widget.image
                                  .toString()), // Use CachedNetworkImageProvider

                          fit: BoxFit
                              .contain, // Covers the container size as much as possible without changing the aspect ratio
                        )),
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
                                () => Healthyloader(
                                  meals: widget.meals,
                                  foodcategory: widget.foodcategory.toString(),
                                  foodtype: widget.foodtype.toString(),
                                  foodday: widget.foodday.toString(),
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
                final videoState = ref.watch(addfoodvideosNotifier);
                return videoState.id.when(
                  data: (data) {
                    // Ensuring that we are accessing the 'data' field of your JSON correctly
                    if (data is Map<String, dynamic> &&
                        data.containsKey('data')) {
                      List<dynamic> videos = data['data'] as List<dynamic>;

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        bottom: isCarouselVisible ? 0 : -200,
                        // Show/Hide animation
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



                                        if (i != null) {
                                          final prefs = await SharedPreferences
                                              .getInstance();
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
                                          } else {
                                            ConnectivityManager
                                            connectivityManager =
                                            ConnectivityManager();
                                            bool isOnline =
                                            await connectivityManager
                                                .isConnected();
                                            if (!isOnline) {
                                              Get.snackbar("Network Error",
                                                  "Please turn on your network to download video.",
                                                  snackPosition:
                                                  SnackPosition.TOP,
                                                  duration:
                                                  const Duration(seconds: 1),
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                  snackStyle:
                                                  SnackStyle.FLOATING);
                                              return;
                                            } else {
                                              widget.image = widget.image == null
                                                  ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                                                  : i['image_url'].toString();
                                              _playVideo(i['video_url']);
                                            }
                                          }
                                        }



                                        isCarouselVisible = false;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            bottom: 15, left: 10, right: 2),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        // Ensure this matches exactly for 3 items per view
                                        margin: const EdgeInsets.only(
                                            bottom: 0, left: 5, right: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: i['image_url'] == null
                                              ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                                              : i['image_url'],
                                          fit: BoxFit.fill,
                                          // Covers the container size as much as possible without changing the aspect ratio
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
                                      ));
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
                      // This block handles unexpected data format
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
                      // Show/Hide animation
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
                                    // Ensure this matches exactly for 3 items per view
                                    margin: const EdgeInsets.only(
                                        bottom: 20, left: 8, right: 8),

                                    // EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10.0,
                                            offset: Offset(0, 10)),
                                      ],
                                      image: const DecorationImage(
                                        image: AssetImage(''),
                                        fit: BoxFit
                                            .fill, // Covers the container size as much as possible without changing the aspect ratio
                                      ),
                                      /*borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),

                                    ),*/
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
