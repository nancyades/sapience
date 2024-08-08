import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sapience/Controller/Provider/downloadmanagerprovider.dart';
import 'package:sapience/Controller/Provider/generalprovider.dart';
import 'package:sapience/Screens/ParentScreen/landscapevideoplayerscreen.dart';
import 'package:sapience/Screens/ParentScreen/parentwelcomescreen.dart';
import 'package:sapience/Screens/ParentScreen/subscreen/weekscreen.dart';
import 'package:sapience/Screens/ParentScreen/videoplayerscreen.dart';
import 'package:sapience/Screens/loaderscreen/sliderloader.dart';
import 'package:sapience/constant/logout_confirmation.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/helper/appconstant.dart';
import 'package:sapience/helper/audiofile.dart';
import 'package:sapience/helper/bottomnavigationbar.dart';
import 'package:sapience/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Controller/Provider/video.dart';
import '../../Controller/Provider/videocategory.dart';
import '../../constant/app_theme.dart';
import '../../constant/connectivity_manager.dart';
import '../../constant/shimmer_skeleton.dart';
import '../qrdialogscreen.dart';

class Syllabusvideo extends ConsumerStatefulWidget {
  final String? section;
  final String? sectionid;
  final String? subjectName;
  int titleid;
  final int? subcatlen;
  String subcatid;

  Syllabusvideo({
    super.key,
    this.subcatlen,
    this.section,
    this.sectionid,
    this.subjectName,
    required this.titleid,
    required this.subcatid,
  });

  @override
  ConsumerState<Syllabusvideo> createState() => _SyllabusvideoState();
}

class _SyllabusvideoState extends ConsumerState<Syllabusvideo>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
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

  TabController? _tabController;
  late AudioPlayer audioPlayer;
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool _isDialogtitle = false;
  bool _isDialogShownvideocate = false;
  ValueNotifier<int> _tabIndexNotifier = ValueNotifier<int>(0);
  String? videotitleid;
  late bool _isOnline;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();

    videotitleid = widget.subcatid;
    _isDialogtitle = false;
    _isDialogShownvideocate = false;
    audioPlayer = AudioPlayer();
    _tabController = TabController(
        length: widget.subcatlen!, vsync: this, initialIndex: widget.titleid);
    _tabController?.addListener(_handleTabSelection);
    idslist();
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _showTimeoutDialog() {
    if (!mounted) return;
    _isDialogtitle = true;
    _isDialogShownvideocate = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _isDialogtitle = false;
            _isDialogShownvideocate = false;
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

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      ref.watch(addvideocategoryNotifier).id.when(
          data: (snapshot) {
            setState(() {
              widget.titleid = _tabController!.index;
            });

            AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
            ref.read(addvideoNotifier.notifier).addvideo(
                AppConstants.sectionid,
                AppConstants.termid,
                AppConstants.monthid,
                AppConstants.weekid,
                AppConstants.subjectid,
                snapshot['data'][_tabController!.index]['id'].toString());
            videotitleid = snapshot['data'][widget.titleid]['id'].toString();
          },
          error: (e, s) {},
          loading: () {});
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final isOnline = result != ConnectivityResult.none;
    setState(() {
      _isOnline = isOnline;
    });
    if (isOnline) {
      ref.refresh(addvideoNotifier);
      print("ides---------> ${AppConstants.sectionid}, ${AppConstants.termid}, ${AppConstants.monthid}, ${AppConstants.weekid}, ${AppConstants.subjectid}, ${videotitleid.toString()}");
      await ref.read(addvideoNotifier.notifier).addvideo(
          AppConstants.sectionid,
          AppConstants.termid,
          AppConstants.monthid,
          AppConstants.weekid,
          AppConstants.subjectid,
          videotitleid.toString());
    }
  }

  idslist() async {
    _isOnline = await SnackbarUtil.checkConnectivity();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppConstants.sectionid = await prefs.getString('sectionid').toString();
    AppConstants.termid = await prefs.getString('termid').toString();
    AppConstants.monthid = await prefs.getString('monthid').toString();
    AppConstants.weekid = await prefs.getString('weekid').toString();
    AppConstants.subjectid = await prefs.getString('subjectid').toString();
  }

  bool isdownloaded = false;
  String? videoname;

  Future<void> loadDownloadStatuses(List<dynamic> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < videos.length; i++) {
      var video = videos[i];
      String key = "${video['title']}.mp4";
      String? filePath = prefs.getString(key);

      if (filePath != null && File(filePath).existsSync()) {
        setState(() {
          ref.watch(downloadManagerProvider.notifier).downloadedFiles[widget.titleid] ??= {};
          ref.watch(downloadManagerProvider.notifier).downloadedFiles[widget.titleid]![i] = filePath;
        });
      } else {
        setState(() {
          ref.watch(downloadManagerProvider.notifier).downloadedFiles[widget.titleid] ??= {};
          ref.watch(downloadManagerProvider.notifier).downloadedFiles[widget.titleid]![i] = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;


    return  isTvScreen ? buildLandscapeLayout() : buildPortraitLayout(context);



  }

  Widget buildPortraitLayout(BuildContext context) {
    final downloadManager = ref.watch(downloadManagerProvider.notifier);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: const Color(0xffefcbf5),
        child: Column(
          children: [
            const SizedBox(height: 55),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 30),
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
                          AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                          Get.back();
                        },
                      ),
                      Text(
                        widget.subjectName ?? 'No Subject Name',
                        style: const TextStyle(
                          fontSize: AppTheme.mediumFontSize,
                          color: AppTheme.blackcolor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ref.watch(addvideocategoryNotifier).id.when(data: (snapshot) {
              try {
                if (snapshot == "Nocache") {
                  SnackbarUtil.showNetworkError();
                }
               if (snapshot != null) {
  return widget.subjectName == "Tamil" ? SizedBox() : Container(
    margin: const EdgeInsets.only(left: 10, right: 10),
    padding: const EdgeInsets.all(2),
    width: 350,
    height: 42,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
    ),
    child: snapshot['data'].length == 0
        ? Container()
        : DefaultTabController(
      length: snapshot['data'].length,
      child: TabBar(
        controller: _tabController,
        tabs: List<Widget>.generate(snapshot['data'].length, (index) {
          return Tab(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  snapshot['data'][index]['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width <= 360 ? 11 : 12,
                  ),
                ),
              ),
            ),
          );
        }),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xffb673d0),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xffb673d0),
        labelStyle: const TextStyle(fontSize: AppTheme.smallFontSize),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    ),
  );
}
 else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_isDialogtitle) _showTimeoutDialog();
                  });
                  return ShimmerSkeleton(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      padding: const EdgeInsets.all(2),
                      width: 350,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: DefaultTabController(
                        initialIndex: 0,
                        length: 3,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Pinky Phonics'),
                            Tab(text: 'Jingles'),
                            Tab(text: 'Stories'),
                          ],
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.purple,
                          ),
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.purple,
                          labelStyle:
                          const TextStyle(fontSize: AppTheme.smallFontSize),
                          unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                          indicatorSize: TabBarIndicatorSize.tab,
                        ),
                      ),
                    ),
                  );
                }
              } catch (e) {
                return ShimmerSkeleton(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    padding: const EdgeInsets.all(2),
                    width: 350,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DefaultTabController(
                      initialIndex: 0,
                      length: 3,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Pinky Phonics'),
                          Tab(text: 'Jingles'),
                          Tab(text: 'Stories'),
                        ],
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.purple,
                        ),
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.purple,
                        labelStyle:
                        const TextStyle(fontSize: AppTheme.smallFontSize),
                        unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.normal),
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                  ),
                );
              }
            }, error: (e, s) {
              return const SizedBox();
            }, loading: () {
              return ShimmerSkeleton(
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.all(2),
                  width: 350,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: DefaultTabController(
                    initialIndex: 0,
                    length: 3,
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Pinky Phonics'),
                        Tab(text: 'Jingles'),
                        Tab(text: 'Stories'),
                      ],
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.purple,
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.purple,
                      labelStyle:
                      const TextStyle(fontSize: AppTheme.smallFontSize),
                      unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.normal),
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),
                ),
              );
            }),
            Expanded(
              child: Consumer(builder: (context, ref, child) {
                final videoState = ref.watch(addvideoNotifier);
                return videoState.id.when(
                  data: (data) {
                    try {
                      if (data == "Nocache") {
                        SnackbarUtil.showNetworkError();
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
                      if (data != null) {
                        if (data is Map<String, dynamic> &&
                            data.containsKey('data')) {
                          List<dynamic> videos = data['data'] as List<dynamic>;
                          loadDownloadStatuses(videos);
                          return buildVideoItem(
                              widget.section!,
                              widget.sectionid!,
                              context,
                              videos,
                              widget.subjectName.toString(),
                              downloadManager);
                        }

                        else {
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
                      }
                      else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && !_isDialogShownvideocate) {
                            _showTimeoutDialog();
                          }
                        });
                        return ShimmerSkeleton(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 15),
                            shrinkWrap: true,
                            itemCount: 5,
                            itemBuilder: (BuildContext context, int index) {
                              return buildShimmerVideoItem();
                            },
                          ),
                        );
                      }
                    } catch (e) {
                      return ShimmerSkeleton(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 15),
                          shrinkWrap: true,
                          itemCount: 5,
                          itemBuilder: (BuildContext context, int index) {
                            return buildShimmerVideoItem();
                          },
                        ),
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

  Widget buildLandscapeLayout() {
    final downloadManager = ref.watch(downloadManagerProvider.notifier);
    final ScrollController _scrollController = ScrollController();

    void _scrollUp() {
      _scrollController.animateTo(
        _scrollController.offset - 200,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }

    void _scrollDown() {
      _scrollController.animateTo(
        _scrollController.offset + 200,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color:
        widget.section == "LKG"
            ? const Color(0xffebe7f8)
            : const Color(0xfff5cfe8),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              color:
              widget.section == "LKG"
                  ? const Color(0xffb673d0)
                  : const Color(0xffffa8e6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 70.0),
                        child: Row(
                          children: [
                            IconButton(
                              iconSize: AppTheme.largeFontSize,
                              icon: SvgPicture.asset(
                                'assets/images/sapience/back-arrow.svg',
                                color: AppTheme.whitecolor,
                                width: AppTheme.largeFontSize,
                              ),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                AudioPlayer()
                                    .play(AssetSource("audio/Bubble 02.mp3"));
                                Get.back();
                              },
                            ),
                            Text(widget.subjectName ?? 'No Subject Name',
                              style: const TextStyle(
                                fontSize: AppTheme.largeFontSize,
                                color: AppTheme.whitecolor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 20),
                        child: GestureDetector(
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            AudioPlayer()
                                .play(AssetSource("audio/Bubble 02.mp3"));
                            setState(() {
                              GlobalState.isLoadingList = [false];
                            });
                            Get.to(
                              const ParentWelcomeScreen(),
                              // duration: const Duration(milliseconds: 500)
                            );
                          },
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: AppTheme.largeFontSize,
                                icon: Icon(Icons.home, color: AppTheme.whitecolor,),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  AudioPlayer()
                                      .play(AssetSource("audio/Bubble 02.mp3"));
                                  setState(() {
                                    GlobalState.isLoadingList = [false];
                                  });
                                  Get.to(
                                    const ParentWelcomeScreen(),
                                    // duration: const Duration(milliseconds: 500)
                                  );
                                },
                              ),
                              Text("HOME",
                                style: const TextStyle(
                                  fontSize: AppTheme.largeFontSize,
                                  color: AppTheme.whitecolor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 70),
                        child: GestureDetector(
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            AudioPlayer()
                                .play(AssetSource("audio/Bubble 02.mp3"));
                            LogoutConfirmation.showLogoutDialog(context);
                          },
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: AppTheme.largeFontSize,
                                icon: Icon(Icons.logout, color: AppTheme.whitecolor,),

                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  AudioPlayer()
                                      .play(AssetSource("audio/Bubble 02.mp3"));
                                  LogoutConfirmation.showLogoutDialog(context);
                                },
                              ),
                              Text("LOGOUT",
                                //widget.section.toString(),
                                style: const TextStyle(
                                  fontSize: AppTheme.largeFontSize,
                                  color: AppTheme.whitecolor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:  Column(
                        children: [

                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[900],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.keyboard_arrow_up_outlined),
                                color: Colors.white,
                                onPressed: _scrollUp,
                                iconSize: 23, // Set the icon size to fit within the smaller container
                                padding: EdgeInsets.all(0), // Remove padding to center the icon
                              ),
                            ),
                          ),

                          ref.watch(getslidervideoNotifier).when(
                      data: (data) {
                        if (data != null) {
                          if (data == "Nocache") {

                          }
                          List<dynamic> imgList =
                          (data as Map<String, dynamic>)['data']
                          as List<dynamic>;

                          return Expanded(
                            child: ListView(
                              controller: _scrollController,
                              children: imgList.map((item) {
                                return GestureDetector(
                                    onTap: () {
                                      if (_isOnline) {
                                        if(item['image_url'] == null){

                                        }else{

                                          Get.off(
                                                () => LandscapetvSlideloader(
                                              termid: AppConstants.termid,
                                              section: widget.section,
                                              sectionid: widget.sectionid,
                                              filepath: item['video_url'],
                                              image: item['image_url'],
                                            ),
                                          );



                                          selected = -1;
                                        }

                                      } else {
                                        SnackbarUtil.showNetworkError();
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 120,
                                      margin: EdgeInsets.symmetric(vertical: 10),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: item['image_url'] == null
                                          ? Image.asset(
                                        'assets/images/sapience/Slide1.png', // Your local asset image
                                        fit: BoxFit.contain,
                                      )
                                          : CachedNetworkImage(
                                        imageUrl: item['image_url'],
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) =>
                                            ShimmerSkeleton(
                                              child: Container(
                                                width: double.infinity,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                                width: double.infinity,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.grey,
                                                  size: 40,
                                                )),
                                      ),
                                    ));
                              }).toList(),
                            ),
                          );
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) {

                          });
                          return ShimmerSkeleton(
                            child: Column(
                              children: List.generate(
                                3,
                                    (index) => Container(
                                  width: double.infinity,
                                  height: 120,
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      error: (e, s) {
                        return Text('Error: $e');
                      },
                      loading: () {
                        return ShimmerSkeleton(
                          child: Column(
                            children: List.generate(
                              3,
                                  (index) => Container(
                                width: double.infinity,
                                height: 120,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),


                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[900],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.keyboard_arrow_down_outlined),
                                color: Colors.white,
                                onPressed: _scrollDown,
                                iconSize: 23, // Set the icon size to fit within the smaller container
                                padding: EdgeInsets.all(0), // Remove padding to center the icon
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 20,
                    thickness: 1,
                    indent: 20,
                    endIndent: 0,
                    color: Colors.grey,
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ref.watch(addvideocategoryNotifier).id.when(data: (snapshot) {
                            try {
                              if (snapshot == "Nocache") {
                                SnackbarUtil.showNetworkError();
                              }
                              if (snapshot != null) {
                                return widget.subjectName == "Tamil"? SizedBox() :
                                snapshot['data'].length == 0
                                    ? Container()
                               : Container(
                                    margin: const EdgeInsets.only(left: 20, right: 20),
                                    padding: const EdgeInsets.all(2),
                                    width: 350,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: snapshot['data'].length == 0
                                        ? Container()
                                        : DefaultTabController(
                                      length: snapshot['data'].length,
                                      child: TabBar(
                                        controller: _tabController,
                                        tabs: List<Widget>.generate(
                                            snapshot['data'].length, (index) {
                                          return Tab(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  snapshot['data'][index]['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width <= 360 ? 11 : 12,
                  ),
                ),
              ),
            ),
          );
                                        }),
                                        indicator: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          color: const Color(0xffb673d0),
                                        ),
                                        dividerColor: Colors.transparent,
                                        labelColor: Colors.white,
                                        unselectedLabelColor: const Color(0xffb673d0),
                                        labelStyle: const TextStyle(
                                            fontSize: AppTheme.smallFontSize),
                                        unselectedLabelStyle: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                        indicatorSize: TabBarIndicatorSize.tab,
                                      ),
                                    ));
                              } else {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted && !_isDialogtitle) _showTimeoutDialog();
                                });
                                return ShimmerSkeleton(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 20, right: 20),
                                    padding: const EdgeInsets.all(2),
                                    width: 350,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: DefaultTabController(
                                      initialIndex: 0,
                                      length: 3,
                                      child: TabBar(
                                        controller: _tabController,
                                        tabs: const [
                                          Tab(text: 'Pinky Phonics'),
                                          Tab(text: 'Jingles'),
                                          Tab(text: 'Stories'),
                                        ],
                                        indicator: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          color: Colors.purple,
                                        ),
                                        dividerColor: Colors.transparent,
                                        labelColor: Colors.white,
                                        unselectedLabelColor: Colors.purple,
                                        labelStyle:
                                        const TextStyle(fontSize: AppTheme.smallFontSize),
                                        unselectedLabelStyle:
                                        const TextStyle(fontWeight: FontWeight.normal),
                                        indicatorSize: TabBarIndicatorSize.tab,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              return ShimmerSkeleton(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20, right: 20),
                                  padding: const EdgeInsets.all(2),
                                  width: 350,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: DefaultTabController(
                                    initialIndex: 0,
                                    length: 3,
                                    child: TabBar(
                                      controller: _tabController,
                                      tabs: const [
                                        Tab(text: 'Pinky Phonics'),
                                        Tab(text: 'Jingles'),
                                        Tab(text: 'Stories'),
                                      ],
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.purple,
                                      ),
                                      dividerColor: Colors.transparent,
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.purple,
                                      labelStyle:
                                      const TextStyle(fontSize: AppTheme.smallFontSize),
                                      unselectedLabelStyle:
                                      const TextStyle(fontWeight: FontWeight.normal),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }, error: (e, s) {
                            return const SizedBox();
                          }, loading: () {
                            return ShimmerSkeleton(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20, right: 20),
                                padding: const EdgeInsets.all(2),
                                width: 350,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: DefaultTabController(
                                  initialIndex: 0,
                                  length: 3,
                                  child: TabBar(
                                    controller: _tabController,
                                    tabs: const [
                                      Tab(text: 'Pinky Phonics'),
                                      Tab(text: 'Jingles'),
                                      Tab(text: 'Stories'),
                                    ],
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.purple,
                                    ),
                                    dividerColor: Colors.transparent,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.purple,
                                    labelStyle:
                                    const TextStyle(fontSize: AppTheme.smallFontSize),
                                    unselectedLabelStyle:
                                    const TextStyle(fontWeight: FontWeight.normal),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                  ),
                                ),
                              ),
                            );
                          }),
                          Expanded(
                            child: Consumer(builder: (context, ref, child) {
                              final videoState = ref.watch(addvideoNotifier);
                              return videoState.id.when(
                                data: (data) {
                                  try {
                                    if (data == "Nocache") {
                                      SnackbarUtil.showNetworkError();
                                    }
                                    if(data['data'].length == 0){
                                      return  SingleChildScrollView(
                                        child: Column(
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
                                        ),
                                      );
                                    }
                                    if (data != null) {
                                      if (data is Map<String, dynamic> &&
                                          data.containsKey('data')) {
                                        List<dynamic> videos = data['data'] as List<dynamic>;
                                        loadDownloadStatuses(videos);
                                        return buillandscapedVideoItem
                                          (
                                            widget.section!,
                                            widget.sectionid!,
                                            context,
                                            videos,
                                            widget.subjectName.toString(),
                                            downloadManager);
                                      }

                                      else {
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
                                    }
                                    else {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (mounted && !_isDialogShownvideocate) {
                                          _showTimeoutDialog();
                                        }
                                      });
                                      return ShimmerSkeleton(
                                        child: ListView.builder(
                                          padding: const EdgeInsets.only(top: 15),
                                          shrinkWrap: true,
                                          itemCount: 5,
                                          itemBuilder: (BuildContext context, int index) {
                                            return buildShimmerVideoItem();
                                          },
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    return ShimmerSkeleton(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.only(top: 15),
                                        shrinkWrap: true,
                                        itemCount: 5,
                                        itemBuilder: (BuildContext context, int index) {
                                          return buildShimmerVideoItem();
                                        },
                                      ),
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
                  ),
                ],
              ),
            )

          ],
        ),
      ),

    );
  }

  Widget buildVideoItem(String section, String sectionid, BuildContext context,
      List<dynamic> videos, String subjectName, DownloadManager downloadManager) {
    return ListView.builder(
      controller: ScrollController(),
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 15),
      itemCount: videos.length,
      itemBuilder: (BuildContext context, int index) {
        var video = videos[index];
       // video['title'] ="We should have offline and online options for all the rhymes. After watching A, B, and C rhymes, when they click D to Z";
        return Column(
          children: [
            GestureDetector(
              onTap: () async {
                AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));


                if (downloadManager.downloadedFiles[widget.titleid]?[index] != null) {
                  final prefs = await SharedPreferences.getInstance();
                  final filePath = prefs.getString("${video['title']}.mp4");
                  final fileimage = prefs.getString("image${video['title']}.mp4");

                  if (filePath != null && await File(filePath).exists()) {
                    Get.off(
                      () => VideoViewer(
                        subcatid: videotitleid,
                        titleid: widget.titleid,
                        section: widget.section,
                        sectionid: widget.sectionid,
                        subcatlen: widget.subcatlen!,
                        filePath: filePath.toString(),
                        image: fileimage.toString(),
                        subjectName: widget.subjectName,
                      ),
                      duration: const Duration(milliseconds: 500),
                    );
                  }
                } else {
                  ConnectivityManager connectivityManager =
                      ConnectivityManager();
                  bool isOnline = await connectivityManager.isConnected();
                  if (!isOnline) {
                    Get.snackbar("Network Error",
                        "Please turn on your network to download video.",
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackStyle: SnackStyle.FLOATING);
                    return;
                  } else {
                    if(video['image_url'].toString() == "null"){

                    }else{
                      Get.off(
                            () => VideoViewer(
                          subcatid: videotitleid,
                          titleid: widget.titleid,
                          section: widget.section,
                          sectionid: widget.sectionid,
                          subcatlen: widget.subcatlen!,
                          filePath: video['video_url'].toString(),
                          image: video['image_url'].toString(),
                          subjectName: widget.subjectName,
                        ),
                        duration: const Duration(milliseconds: 500),
                      );
                    }


                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: [
                    Container(
                      width: 328,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight:Radius.circular(12) ),
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
                            child: video['image_url'] == null
                                ? Image.asset(
                              'assets/images/sapience/Slide1.png', // Your local asset image
                              fit: BoxFit.contain,
                            )
                                : CachedNetworkImage(
                              imageUrl: video['image_url'],
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
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

                        ],
                      ),
                    ),
                    Container(
                      width: 328,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12) , bottomRight: Radius.circular(12)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                               //"We should have offline and online options for all the rhymes. After watching A, B, and C rhymes, when they click D to Z",
                                video['title'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: AppTheme.mediumFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            downloadManager.downloading[widget.titleid]?[index] == true
                                ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    value: downloadManager.downloadProgress[widget.titleid]
                                    ?[index] ??
                                        0,
                                  ),
                                ),
                                Text(
                                  "${((downloadManager.downloadProgress[widget.titleid]?[index] ?? 0) * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                                : InkWell(
                              onTap: () async {
                                if (downloadManager.downloadedFiles[widget.titleid]?[index] != null) {
                                  // Already downloaded, no action needed
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
                                    return;
                                  } else {
                                    if (!downloadManager.downloading.containsKey(widget.titleid) ||
                                        !downloadManager.downloading[widget.titleid]!.containsKey(index) ||
                                        !downloadManager.downloading[widget.titleid]![index]!) {
                                      await downloadManager.downloadVideoFile(
                                          widget.titleid,
                                          index,
                                          video['video_url'],
                                          "${video['title']}.mp4",
                                          video['image_url']);
                                    }
                                  }
                                }
                              },
                              child: Icon(
                                downloadManager.downloadedFiles[widget.titleid]?[index] != null
                                    ? Icons.check_circle
                                    : Icons.download_for_offline,
                                color: downloadManager.downloadedFiles[widget.titleid]?[index] != null
                                    ? Colors.green
                                    : Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              )


            ),
            const SizedBox(height: 15),
          ],
        );
      },
    );
  }

  Widget buillandscapedVideoItem(String section, String sectionid, BuildContext context,
      List<dynamic> videos, String subjectName, DownloadManager downloadManager) {
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


                if (downloadManager.downloadedFiles[widget.titleid]?[index] != null) {
                  final prefs = await SharedPreferences.getInstance();
                  final filePath = prefs.getString("${video['title']}.mp4");
                  final fileimage = prefs.getString("image${video['title']}.mp4");

                  if (filePath != null && await File(filePath).exists()) {
                    Get.off(
                          () =>  LandscapeVideoViewer(
                        subcatid: videotitleid,
                        titleid: widget.titleid,
                        section: widget.section,
                        sectionid: widget.sectionid,
                        subcatlen: widget.subcatlen!,
                        filePath: filePath.toString(),
                        image: fileimage.toString(),
                        subjectName: widget.subjectName,
                      ),
                      duration: const Duration(milliseconds: 500),
                    );
                  }
                } else {
                  ConnectivityManager connectivityManager =
                  ConnectivityManager();
                  bool isOnline = await connectivityManager.isConnected();
                  if (!isOnline) {
                    Get.snackbar("Network Error",
                        "Please turn on your network to download video.",
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackStyle: SnackStyle.FLOATING);
                    return;
                  } else {
                    if(video['image_url'].toString() == "null"){

                    }else{
                      Get.off(
                            () =>  LandscapeVideoViewer(
                          subcatid: videotitleid,
                          titleid: widget.titleid,
                          section: widget.section,
                          sectionid: widget.sectionid,
                          subcatlen: widget.subcatlen!,
                          filePath: video['video_url'].toString(),
                          image: video['image_url'].toString(),
                          subjectName: widget.subjectName,
                        ),
                        duration: const Duration(milliseconds: 500),
                      );
                    }


                  }
                }
              },
              child: Column(
              children: [
                Container(
                  width: 340,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight:Radius.circular(12) ),
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
                        child: video['image_url'] == null
                            ? Image.asset(
                          'assets/images/sapience/Slide1.png', // Your local asset image
                          fit: BoxFit.fill,
                        )
                            : CachedNetworkImage(
                          imageUrl: video['image_url'],
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

                    ],
                  ),
                ),
                Container(
                  width: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12) , bottomRight: Radius.circular(12)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                           // "We should have offline and online options for all the rhymes. After watching A, B, and C rhymes, when they click D to Z",
                           video['title'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: AppTheme.mediumFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        downloadManager.downloading[widget.titleid]?[index] == true
                            ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                value: downloadManager.downloadProgress[widget.titleid]
                                ?[index] ??
                                    0,
                              ),
                            ),
                            Text(
                              "${((downloadManager.downloadProgress[widget.titleid]?[index] ?? 0) * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                            : InkWell(
                          onTap: () async {
                            if (downloadManager.downloadedFiles[widget.titleid]?[index] != null) {
                              // Already downloaded, no action needed
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
                                return;
                              } else {
                                if (!downloadManager.downloading.containsKey(widget.titleid) ||
                                    !downloadManager.downloading[widget.titleid]!.containsKey(index) ||
                                    !downloadManager.downloading[widget.titleid]![index]!) {
                                  await downloadManager.downloadVideoFile(
                                      widget.titleid,
                                      index,
                                      video['video_url'],
                                      "${video['title']}.mp4",
                                      video['image_url']);
                                }
                              }
                            }
                          },
                          child: Icon(
                            downloadManager.downloadedFiles[widget.titleid]?[index] != null
                                ? Icons.check_circle
                                : Icons.download_for_offline,
                            color: downloadManager.downloadedFiles[widget.titleid]?[index] != null
                                ? Colors.green
                                : Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
              )








            ),
            const SizedBox(height: 15),
          ],
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
}
