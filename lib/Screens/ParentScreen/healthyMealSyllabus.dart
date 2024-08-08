import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sapience/Controller/Provider/foodvideosprovider.dart';
import 'package:sapience/Screens/qrdialogscreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/connectivity_manager.dart';
import 'package:sapience/constant/landscape_view.dart';
import 'package:sapience/constant/logout_confirmation.dart';
import 'package:sapience/constant/shimmer_skeleton.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/helper/audiofile.dart';
import 'package:sapience/helper/bottomnavigationbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Controller/Provider/healthymealdownloadmanagerprovider.dart';
import 'healthymeal_videoplayer.dart';

class HealthyMealSyllabus extends ConsumerStatefulWidget {
  String? meals;
  String? foodcategory;
  String? foodtype;
  String? foodday;
  HealthyMealSyllabus({super.key, this.meals, this.foodcategory, this.foodtype, this.foodday});

  @override
  ConsumerState<HealthyMealSyllabus> createState() =>
      _HealthyMealSyllabusState();
}

class _HealthyMealSyllabusState extends ConsumerState<HealthyMealSyllabus> {
  bool isloading = false;

  int _selectedIndex = 0;

  Map<int, bool> downloading = {};

  Map<int, double> downloadProgress = {};

  Map<int, String?> downloadedFiles = {};
  late bool _isOnline;

  void _onItemTapped(int index) {
    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/ParentWelcomeScreen');
        break;
      case 1:
        if(_isOnline){
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => const QRViewScanner(),
          ))
              .then((_) {
            setState(() {
              _selectedIndex = 0;
            });
          });
        } else {
          SnackbarUtil.showNetworkError();
        }
        break;
      case 2:
        LogoutConfirmation.showLogoutDialog(context).then((result) {
          if (result != true) {
            setState(() {
              _selectedIndex = 0;
            });
          }
        });
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _isDialogShownfoodvideo = false;

  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    getcheckconnectivity();
    _isDialogShownfoodvideo = false;
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  getcheckconnectivity() async {
    _isOnline = await SnackbarUtil.checkConnectivity();

  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final isOnline = result != ConnectivityResult.none;
    setState(() {
      _isOnline = isOnline;
    });
    if (isOnline) {


      ref.refresh(addfoodvideosNotifier);
      print("ideas---> ${widget.foodcategory.toString()}, ${widget.foodtype.toString()}, ${widget.foodday.toString()}");

      ref.read(addfoodvideosNotifier.notifier).addfoodvideos(
          widget.foodcategory.toString(),
          widget.foodtype.toString(),
          widget.foodday.toString());
    } else {

    }
  }


  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: buildPortraitLayout(), // Your specific screen layout method
    );
  }

  Widget buildPortraitLayout() {
    final downloadManager = ref.watch(healthydownloadManagerProvider.notifier);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppTheme.healthyMealBg,
        child: Column(
          children: [
            const SizedBox(
              height: 55,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 34),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        iconSize: AppTheme.mediumFontSize,
                        icon: SvgPicture.asset(
                          'assets/images/sapience/back-arrow.svg',
                          color: AppTheme.blackcolor,
                          width: AppTheme.largeFontSize,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          AudioPlayer()
                              .play(AssetSource("audio/Bubble 02.mp3"));
                          //Syllabus
                          Get.back();
                        },
                      ),
                      Text(
                        widget.meals.toString(),
                        style: const TextStyle(
                            fontSize: AppTheme.mediumFontSize,
                            color: AppTheme.blackcolor,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(builder: (context, ref, child) {
                final videoState = ref.watch(addfoodvideosNotifier);

                return videoState.id.when(
                  data: (data) {
                    try {
                      if (data != null) {
                        if (data == "Nocache") {
                          if (!_isDialogShownfoodvideo) {
                            _isDialogShownfoodvideo = true;
                            SnackbarUtil.showNetworkError();
                          }
                        }
                        if(data['data'].length == 0){
                          return  Column(
                            children: [
                              Container(
                                height: 400,
                                width: 350,
                                child:
                                Image.asset('assets/images/sapience/No Data img.png'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  AudioPlayer()
                                      .play(AssetSource("audio/Bubble 02.mp3"));
                                  Get.back();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(AppTheme.cancelBtn),
                                  // Text color normally

                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                          color: AppTheme.cancelBtn,
                                          width: 2.0), // Initial border color
                                    ),
                                  ),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(100, 42)),
                                  overlayColor:
                                  MaterialStateProperty.all(Colors.transparent),
                                  side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
                                        (Set<MaterialState> states) {
                                      return const BorderSide(
                                          color: AppTheme.cancelBtn,
                                          width:
                                          2.0); // Keep border color consistent
                                    },
                                  ),
                                ),
                                child: const Text(
                                  'Go Back',
                                  style: TextStyle(
                                    backgroundColor: AppTheme.cancelBtn,
                                    color: Colors.white,
                                    fontSize: AppTheme
                                        .mediumFontSize, // You can use AppTheme.mediumFontSize if you have set up a theme
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        // Ensuring that we are accessing the 'data' field of your JSON correctly
                        if (data is Map<String, dynamic> &&
                            data.containsKey('data')) {
                          List<dynamic> videos = data['data'] as List<dynamic>;
                          loadDownloadStatuses(
                              videos); // Pass the video data to the loader
                          return buildVideoItem(context, videos, downloadManager );
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
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && !_isDialogShownfoodvideo) {
                            _showTimeoutDialog();
                          }
                        });
                        return ShimmerSkeleton(
                          child: ListView.builder(
                              padding: const EdgeInsets.only(top: 15),
                              shrinkWrap: true,
                              itemCount: 5,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                          width: 340,
                                          height: 250,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10.0,
                                                  offset: Offset(0, 10)),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                      0.27,
                                                  decoration:
                                                  const BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      image: AssetImage(''),
                                                      fit: BoxFit
                                                          .cover, // Covers the container size as much as possible without changing the aspect ratio
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.only(
                                                      topLeft:
                                                      Radius.circular(12),
                                                      topRight:
                                                      Radius.circular(12),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'sample',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: AppTheme
                                                              .largeFontSize,
                                                          fontWeight:
                                                          FontWeight.w600),
                                                    ),
                                                    Row(
                                                      children: [
                                                        ClipOval(
                                                          child: Material(
                                                            color: Colors
                                                                .white, // Button color
                                                            child: InkWell(
                                                              onTap: () {
                                                                AudioPlayer().play(
                                                                    AssetSource(
                                                                        "audio/Bubble 02.mp3"));
                                                              },
                                                              child:
                                                              const SizedBox(
                                                                  width: 40,
                                                                  height:
                                                                  40,
                                                                  child:
                                                                  Icon(
                                                                    Icons
                                                                        .download_for_offline_outlined,
                                                                    color: Color(
                                                                        0xFFD71717),
                                                                    size: AppTheme
                                                                        .largeFontSize,
                                                                  )),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    )
                                  ],
                                );
                              }),
                        );
                      }
                    } catch (e) {
                      return ShimmerSkeleton(
                        child: ListView.builder(
                            padding: const EdgeInsets.only(top: 15),
                            shrinkWrap: true,
                            itemCount: 5,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                        width: 340,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10.0,
                                                offset: Offset(0, 10)),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.27,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    image: AssetImage(''),
                                                    fit: BoxFit
                                                        .cover, // Covers the container size as much as possible without changing the aspect ratio
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.only(
                                                    topLeft:
                                                    Radius.circular(12),
                                                    topRight:
                                                    Radius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'sample',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: AppTheme
                                                            .largeFontSize,
                                                        fontWeight:
                                                        FontWeight.w600),
                                                  ),
                                                  Row(
                                                    children: [
                                                      ClipOval(
                                                        child: Material(
                                                          color: Colors
                                                              .white, // Button color
                                                          child: InkWell(
                                                            onTap: () {
                                                              AudioPlayer().play(
                                                                  AssetSource(
                                                                      "audio/Bubble 02.mp3"));
                                                            },
                                                            child:
                                                            const SizedBox(
                                                                width: 40,
                                                                height: 40,
                                                                child: Icon(
                                                                  Icons
                                                                      .download_for_offline_outlined,
                                                                  color: Color(
                                                                      0xFFD71717),
                                                                  size: AppTheme
                                                                      .largeFontSize,
                                                                )),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  )
                                ],
                              );
                            }),
                      );
                    }
                  },
                  loading: () => ShimmerSkeleton(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 15),
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (BuildContext context, int index) {
                        return buildShimmerVideoItem();
                      },
                    ),
                  ),
                  error: (err, stack) => Text('Error: $err'),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  void _showTimeoutDialog() {
    if (!mounted) return;
    _isDialogShownfoodvideo = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _isDialogShownfoodvideo = false;
          }
        });

        return const AlertDialog(
          title: Text("Request timed out"),
          content: Text(
              "Server is taking too long to respond. Please try again after sometime."),
        );
      },
    );
  }

  Widget buildShimmerVideoItem() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 340,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.27,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      ClipOval(
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {},
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.download_for_offline_outlined,
                                color: Color(0xFFD71717),
                                size: AppTheme.largeFontSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget buildVideoItem(BuildContext context, List<dynamic> videos, HealthyDownloadManager downloadManager) {
    return ListView.builder(
        controller: ScrollController(),
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 15),
        itemCount: videos.length,
        itemBuilder: (BuildContext context, int index) {
          var video = videos[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () async {
                  AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));

                  if (downloadManager.downloadedFiles[index] != null) {
                    final prefs = await SharedPreferences.getInstance();
                    final filePath = prefs.getString("${video['title']}.mp4");
                    final fileimage =
                    prefs.getString("image${video['title']}.mp4");

                    if (filePath != null && await File(filePath).exists()) {
                      Get.off(
                            () => HealthyMealVideoPlayer(
                            foodcategory: widget.foodcategory.toString(),
                            foodtype: widget.foodtype.toString(),
                            foodday: widget.foodday.toString(),
                            filePath: filePath.toString(),
                            image: fileimage.toString(),
                            meals: widget.meals),
                        duration: const Duration(milliseconds: 500),
                      );
                    }
                  } else {
                    ConnectivityManager connectivityManager = ConnectivityManager();
                    bool isOnline = await connectivityManager.isConnected();
                    if (!isOnline) {
                      Get.snackbar("Network Error",
                          "Please turn on your network to download video.",
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackStyle: SnackStyle.FLOATING);
                      //  validatePin(enteredPin);
                      return;
                    } else {
                      Get.off(
                            () => HealthyMealVideoPlayer(
                            foodcategory: widget.foodcategory.toString(),
                            foodtype: widget.foodtype.toString(),
                            foodday: widget.foodday.toString(),
                            filePath: video['video_url'].toString(),
                            image: video['image_url'].toString(),
                            meals: widget.meals),
                        duration: const Duration(milliseconds: 500),
                      );
                    }
                  }
                },
                child: Container(
                  width: 340,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: video['image_url'] == null
                              ? "https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg"
                              : video['image_url'],
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          placeholder: (context, url) => ShimmerSkeleton(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: AppTheme.userIconGrey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(video['title'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: AppTheme.mediumFontSize,
                                    fontWeight: FontWeight.w600)),
                            downloadManager.downloading[index] == true
                                ? SizedBox(
                              width: 30,
                              height: 30,
                              child: Stack(
                                children: [
                                  CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    value: downloadManager.downloadProgress[index],
                                  ),
                                  Center(
                                    child: Text(
                                      '${((downloadManager.downloadProgress[index] ?? 0) * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : InkWell(
                              onTap: () async {
                                if (downloadManager.downloadedFiles[index] != null) {
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
                                        snackPosition: SnackPosition.TOP,
                                        duration:
                                        const Duration(seconds: 1),
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackStyle: SnackStyle.FLOATING);
                                    return;
                                  } else {
                                    if (!downloadManager.downloading.containsKey(index) || !downloadManager.downloading[index]!) {
                                      await downloadManager.downloadVideoFile(
                                          index,
                                          video['video_url'],
                                          "${video['title']}.mp4",
                                          video['image_url']);
                                    }
                                  }
                                }
                              },
                              child: Icon(
                                downloadManager.downloadedFiles[index] != null
                                    ? Icons.check_circle
                                    : Icons.download_for_offline,
                                color: downloadManager.downloadedFiles[index] != null
                                    ? Colors.green
                                    : Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        });
  }

  /* Future<void> downloadVideoFile(
      int index, String url, String filename, String imageurl) async {
    setState(() {
      downloading[index] = true;
      downloadProgress[index] = 0.0; // Initialize progress to 0.0
    });
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final dio = Dio();
      AudioService().pauseMusic();
      AudioPlayer().play(AssetSource("audio/downloading_audio.mp3"));
      Timer(const Duration(seconds: 4), () {
        AudioService().resumeMusic();
      });

      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        setState(() {
          downloadProgress[index] = received / total;
        });
      });

      if (File(filePath).existsSync()) {
        setState(() {
          downloading[index] = false;
          downloadProgress[index] = 1.0;
          downloadedFiles[index] = filePath;
        });

        AudioService().pauseMusic();
        AudioPlayer().play(AssetSource("audio/download_completed.mp3"));
        Timer(const Duration(seconds: 2), () {
          AudioService().resumeMusic();
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('${filename}', filePath);
        await prefs.setString('image${filename}', imageurl);
      } else {
        throw Exception("File not found after download");
      }
    } catch (e) {
      setState(() {
        downloading[index] = false;
        downloadProgress[index] = 0.0;
        downloadedFiles[index] = null;
      });
    }
  }*/

  Future<void> loadDownloadStatuses(List<dynamic> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < videos.length; i++) {
      var video = videos[i];
      String key = "${video['title']}.mp4";
      String? filePath = prefs.getString(key.toString());

      if (filePath != null && File(filePath).existsSync()) {
        setState(() {
          ref.watch(healthydownloadManagerProvider.notifier).downloadedFiles[i] = filePath; // Save the download path
        });
      } else {
        setState(() {
          ref.watch(healthydownloadManagerProvider.notifier).downloadedFiles[i] = null; // Mark as not downloaded
        });
      }
    }
  }
}
