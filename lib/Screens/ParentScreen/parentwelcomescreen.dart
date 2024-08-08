import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sapience/Controller/Provider/generalprovider.dart';
import 'package:sapience/Controller/Provider/monthprovider.dart';
import 'package:sapience/Controller/Provider/termsprovider.dart';
import 'package:sapience/Screens/ParentScreen/healthy_meal_screen.dart';
import 'package:sapience/Screens/ParentScreen/subscreen/weekscreen.dart';
import 'package:sapience/Screens/ParentScreen/syllabusscreen.dart';
import 'package:sapience/Screens/qrdialogscreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/error_page.dart';
import 'package:sapience/constant/exitscreen.dart';
import 'package:sapience/constant/landscape_view.dart';
import 'package:sapience/constant/logout_confirmation.dart';
import 'package:sapience/constant/shimmer_skeleton.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/main.dart';

import '../../constant/connectivity_manager.dart';
import '../../helper/bottomnavigationbar.dart';

class ParentWelcomeScreen extends ConsumerStatefulWidget {
  const ParentWelcomeScreen({
    super.key,
  });

  @override
  ConsumerState<ParentWelcomeScreen> createState() =>
      _ParentWelcomeScreenState();
}

class _ParentWelcomeScreenState extends ConsumerState<ParentWelcomeScreen> {
  ConnectivityManager connectivityManager = ConnectivityManager();

  bool isloading = false;
  bool _isDialogShown = false;
  bool _isDialogShownsetting = false;
  late List<bool> _isLoadingList;
  int? _loadingIndex; // To track which button is loading

  bool _disableButtons = false; // New variable to disable buttons

  late bool _isOnline;
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {

    gettoken();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
    _connectivity = Connectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _isDialogShown = false;
    _isDialogShownsetting = false;
    _isLoadingList = [];
    GlobalState.isLoadingList = [];

  }

  gettoken() async {
    await getsections();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final isOnline = result != ConnectivityResult.none;
    setState(() {
      _isOnline = isOnline;
    });

    if (isOnline) {
        ref.refresh(getSectionNotifier);
        ref.refresh(getsettingNotifier);
       await ref.read(getSectionNotifier);
       await ref.read(getsettingNotifier);
    } else {

    }
  }

  @override
  void dispose() async {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getsections() async {
    _isOnline = await SnackbarUtil.checkConnectivity();
    await ref.read(getSectionNotifier);
    final sectionData = await ref.read(getSectionNotifier.future);
    if (sectionData != null) {
      setState(() {
        GlobalState.isLoadingList =
            List<bool>.filled(sectionData['data'].length, false);
        _isLoadingList = List<bool>.filled(sectionData['data'].length, false);
      });
    }
    ref.read(getsettingNotifier);
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (index) {
      case 0:
        if (currentRoute == '/ParentWelcomeScreen') {
          return;
        } else {
          Navigator.pushNamed(context, '/ParentWelcomeScreen');
        }
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

  var foodcategory;
  var fooddays;

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return  Scaffold(body: isTvScreen ? buildLandscapeLayout() : buildPortraitLayout());

  }

  Widget buildPortraitLayout() {
    return PopScope(
        onPopInvoked: (popDisposition) async {
          exit(0);
        },
        child: Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/sapience/1-intro-scr-bg-transform.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 130,
                          ),
                          Container(
                            width: 200.0,
                            height: 120.0,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/sapience/logo.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Flexible(
                            child: ref.watch(getSectionNotifier).when(
                                  data: (snapshot) {
                                    try {
                                      if (snapshot != null) {
                                        if (snapshot == "Nocache") {
                                          if (!_isOnline) {
                                            if (!_isDialogShown) {
                                              _isDialogShown = true;
                                              SnackbarUtil.showNetworkError();
                                            }
                                          }
                                        }

                                        if (_isLoadingList.isEmpty) {
                                          _isLoadingList = List<bool>.filled(
                                              snapshot['data'].length, false);
                                        }

                                        return ListView.builder(
                                          padding: const EdgeInsets.all(2),
                                          shrinkWrap: true,
                                          itemCount: snapshot['data'].length,
                                          itemBuilder: (context, index) {
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: ElevatedButton(
                                                  onPressed: _disableButtons
                                                      ? null
                                                      : _loadingIndex != null
                                                          ? null
                                                          : () async {
                                                              setState(() {
                                                                _loadingIndex =
                                                                    index;
                                                                _disableButtons =
                                                                    true;
                                                              });

                                                              AudioPlayer().play(
                                                                  AssetSource(
                                                                      "audio/Bubble 02.mp3"));
                                                              await handleAPIsAndNavigate(
                                                                  context,
                                                                  index,
                                                                  snapshot);
                                                            },
                                                  style: ButtonStyle(
                                                    elevation:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                double>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        return states.contains(
                                                                MaterialState
                                                                    .disabled)
                                                            ? 0.0
                                                            : 10.0;
                                                      },
                                                    ),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        return states.contains(
                                                                MaterialState
                                                                    .disabled)
                                                            ? (snapshot['data'][index]
                                                                            [
                                                                            'name']
                                                                        .toString() ==
                                                                    "LKG"
                                                                ? Colors.purple
                                                                    .shade600
                                                                : Colors.pink
                                                                    .shade600)
                                                            : (snapshot['data'][index]
                                                                            [
                                                                            'name']
                                                                        .toString() ==
                                                                    "LKG"
                                                                ? Colors.purple
                                                                    .shade300
                                                                : Colors.pink
                                                                    .shade300);
                                                      },
                                                    ),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        return states.contains(
                                                                MaterialState
                                                                    .disabled)
                                                            ? (snapshot['data'][index]
                                                                            [
                                                                            'name']
                                                                        .toString() ==
                                                                    "LKG"
                                                                ? Colors.purple
                                                                    .shade600
                                                                : Colors.pink
                                                                    .shade600)
                                                            : (snapshot['data'][index]
                                                                            [
                                                                            'name']
                                                                        .toString() ==
                                                                    "LKG"
                                                                ? Colors.purple
                                                                    .shade300
                                                                : Colors.pink
                                                                    .shade300);
                                                      },
                                                    ),
                                                    minimumSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                const Size(
                                                                    160, 45)),
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .resolveWith<
                                                                Color?>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .pressed)) {
                                                          return snapshot['data']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'name']
                                                                      .toString() ==
                                                                  "LKG"
                                                              ? Colors
                                                                  .purple[600]
                                                              : Colors
                                                                  .pink[600];
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  child: _loadingIndex == index
                                                      ? LoadingAnimationWidget
                                                          .staggeredDotsWave(
                                                          color: Colors.white,
                                                          size: 30,
                                                        )
                                                      : Text(
                                                          snapshot['data']
                                                                      [index]
                                                                  ['name']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: AppTheme
                                                                .mediumFontSize,
                                                            color: AppTheme
                                                                .whitecolor,
                                                            letterSpacing: 2,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (mounted && !_isDialogShown) {
                                            _showTimeoutDialog();
                                          }
                                        });
                                        return ShimmerSkeleton(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(2),
                                            shrinkWrap: true,
                                            itemCount: 2,
                                            itemBuilder: (context, index) {
                                              return Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: ElevatedButton(
                                                    onPressed: () async {},
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 10.0,
                                                      backgroundColor:
                                                          Colors.pink[300],
                                                      minimumSize:
                                                          const Size(160, 45),
                                                    ),
                                                    child: const Text(
                                                      "LKG",
                                                      style: TextStyle(
                                                        fontSize: AppTheme
                                                            .mediumFontSize,
                                                        color:
                                                            AppTheme.whitecolor,
                                                        letterSpacing: 2,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      return ShimmerSkeleton(
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(2),
                                          shrinkWrap: true,
                                          itemCount: 2,
                                          itemBuilder: (context, index) {
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: ElevatedButton(
                                                  onPressed: () async {},
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 10.0,
                                                    backgroundColor:
                                                        Colors.pink[300],
                                                    minimumSize:
                                                        const Size(160, 45),
                                                  ),
                                                  child: const Text(
                                                    "LKG",
                                                    style: TextStyle(
                                                      fontSize: AppTheme
                                                          .mediumFontSize,
                                                      color:
                                                          AppTheme.whitecolor,
                                                      letterSpacing: 2,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  error: (e, s) {
                                    return const SizedBox();
                                  },
                                  loading: () => ShimmerSkeleton(
                                    child: ListView.builder(
                                        padding: const EdgeInsets.all(2),
                                        shrinkWrap: true,
                                        itemCount: 2,
                                        //widget.loginModel!.data!.subscriptionListSection.length,
                                        itemBuilder: (context, index) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: ElevatedButton(
                                                onPressed: () async {},
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 10.0,
                                                  backgroundColor:
                                                      Colors.pink[300],
                                                  minimumSize:
                                                      const Size(160, 45),
                                                ),
                                                child: const Text(
                                                  "LKG",
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppTheme.mediumFontSize,
                                                    color: AppTheme.whitecolor,
                                                    letterSpacing: 2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                          ),
                          ref.watch(getsettingNotifier).when(data: (snapshot) {
                            try {
                              if (snapshot != null) {
                                if (snapshot == "Nocache") {
                                  if (!_isOnline) {
                                    if (!_isDialogShownsetting) {
                                      _isDialogShownsetting = true;
                                      SnackbarUtil.showNetworkError();
                                    }
                                  }
                                }

                                return snapshot != null &&
                                        snapshot['data']['food_videos'] ==
                                            "enabled"
                                    ? ElevatedButton(
                                  onPressed: _disableButtons
                                      ? null
                                      : () async {
                                     ref.refresh(getfoodcategoryNotifier);
                                      ref.refresh(getfooddaysNotifier);
                                     ref.refresh(getfoodtypesNotifier);
                                    AudioPlayer().play(
                                        AssetSource(
                                            "audio/Bubble 02.mp3"));
                                    setState(() {
                                      isloading = true;
                                      _disableButtons = true;
                                    });
                                    await Future.delayed(
                                        const Duration(
                                            milliseconds: 500));
                                    await ref.read(getfoodcategoryNotifier.future);
                                    await ref.read(getfooddaysNotifier.future);
                                     await ref.read(getfoodtypesNotifier);

                                    var videocategorydata = await ref.read(getfoodcategoryNotifier).value;

                                     var foodays = await ref.read(getfooddaysNotifier).value;


                                    if (videocategorydata ==
                                        "Nocache" || foodays  == "Nocache") {
                                       SnackbarUtil.showNetworkError();
                                      setState(() {
                                        isloading = false; // Stop showing loading indicator on error
                                        _disableButtons = false;
                                      });
                                    } else {

                                      foodcategory = videocategorydata['data'][0]['id'].toString();
                                      fooddays = foodays['data'][0]['id'].toString();





                                      Get.to(
                                            () => HealthyMealChart(
                                          foodcategory:
                                          foodcategory,
                                          fooday: fooddays,
                                        ),
                                        // transition: Transition
                                        //     .rightToLeft,
                                        // duration: const Duration(
                                        //     milliseconds: 500),
                                      );
                                        setState(() {
                                          isloading = false;
                                          _disableButtons = false;
                                        });

                                    }
                                  },
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty
                                        .resolveWith<double>(
                                          (Set<MaterialState>
                                      states) {
                                        return states.contains(
                                            MaterialState
                                                .disabled)
                                            ? 0.0
                                            : 10.0;
                                      },
                                    ),
                                    foregroundColor:
                                    MaterialStateProperty
                                        .resolveWith<Color>(
                                          (Set<MaterialState>
                                      states) {
                                        return states.contains(
                                            MaterialState
                                                .disabled)

                                        ? const Color(0xffa96414)
                                            : const Color(0xffF3933F);

                                      },
                                    ),
                                    backgroundColor:
                                    MaterialStateProperty
                                        .resolveWith<Color>(
                                          (Set<MaterialState>
                                      states) {
                                        return states.contains(
                                            MaterialState
                                                .disabled)
                                            ? const Color(0xffa96414)
                                            : const Color(0xffF3933F);
                                      },
                                    ),
                                    /*backgroundColor: isloading
                                        ? const Color(0xffa96414)
                                        : Color(0xffF3933F),*/

                                          minimumSize:
                                              MaterialStateProperty.all<Size>(
                                                  const Size(250, 45)),
                                        ),
                                        child: isloading
                                            ? LoadingAnimationWidget
                                                .staggeredDotsWave(
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            : const Text(
                                                "HEALTHY MEAL CHART",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: 2,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      )
                                    : const SizedBox();
                              } else {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted && !_isDialogShownsetting) {
                                     _showTimeoutDialog();
                                  }
                                });
                                return ShimmerSkeleton(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        AudioPlayer().play(
                                            AssetSource("audio/Bubble 02.mp3"));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        // shape: StadiumBorder(),
                                        elevation: 0.0,
                                        backgroundColor:
                                            const Color(0xffF3933F),
                                        minimumSize: const Size(250, 45),
                                      ),
                                      child: isloading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              "HEALTHY MEAL CHART",
                                              style: TextStyle(
                                                color: Colors.white,
                                                letterSpacing: 2,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                              //   if (mounted && !_isDialogShownsetting) {
                              //     _showTimeoutDialog();
                              //   }
                              // });
                              return ShimmerSkeleton(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: ElevatedButton(
                                    onPressed: () async {},
                                    style: ElevatedButton.styleFrom(
                                      // shape: StadiumBorder(),
                                      elevation: 0.0,
                                      backgroundColor: const Color(0xffF3933F),
                                      minimumSize: const Size(250, 45),
                                    ),
                                    child: isloading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            "HEALTHY MEAL CHART",
                                            style: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }
                          }, error: (e, s) {
                            return const SizedBox();
                          }, loading: () {
                            return ShimmerSkeleton(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: ElevatedButton(
                                  onPressed: () async {},
                                  style: ElevatedButton.styleFrom(
                                    // shape: StadiumBorder(),
                                    elevation: 0.0,
                                    backgroundColor: const Color(0xffF3933F),
                                    minimumSize: const Size(250, 45),
                                  ),
                                  child: isloading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          "HEALTHY MEAL CHART",
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                left: 0,
                child: Container(
                  height: 70,
                  width: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Cloud2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .slideX(
                        begin: 0, end: 0.2, duration: 1000.ms, delay: 500.ms),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.4,
                child: Container(
                  height: 70,
                  width: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Cloud2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .slideX(
                        begin: 0, end: 0.3, duration: 2000.ms, delay: 100.ms),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.09,
                right: 0,
                child: Container(
                  height: 70,
                  width: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Cloud2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .slideX(
                        begin: 0, end: 0.3, duration: 2000.ms, delay: 100.ms),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.08,
                right: MediaQuery.of(context).size.width * 0.04,
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Sun.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .scaleXY(begin: 0.8, end: 1, duration: 1000.ms),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                right: MediaQuery.of(context).size.width * 0.065,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/sapience/HS-Butterfly1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .scaleX(begin: 0.7, end: 1, duration: 400.ms),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.43,
                left: MediaQuery.of(context).size.width * 0.02,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/sapience/HS-Butterfly2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .scaleX(begin: 0.7, end: 1, duration: 200.ms),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.56,
                left: MediaQuery.of(context).size.width * 0.35,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/sapience/HS-Bee2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .then(delay: 100.ms)
                    .shake(hz: 10, duration: 2000.ms)
                    .slideX(begin: 0, end: 0.5, duration: 2000.ms)
                    .slideY(begin: 0, end: -0.5, duration: 2000.ms)
                    .then(delay: 1000.ms),
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.78,
                  right: MediaQuery.of(context).size.width * 0.12,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/sapience/HS-Bee1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: true),
                      )
                      .shake(hz: 10, duration: 1000.ms)
                      .slideX(begin: 0, end: 1, duration: 1000.ms)),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: 250,
                  width: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/sapience/HS-Earth.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ).animate().shimmer(duration: 1800.ms),
              ),
             /* Positioned(
                  bottom: 10,
                  right: 20,
                  child: Text("v${GlobalState.version.toString()}"))*/
            ],
          ),
          bottomNavigationBar: BottomNavigationBarWidget(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
        ));
  }

  Widget buildLandscapeLayout() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/sapience/landscapeimages/Home-scr1.png"),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Padding(
                  padding:  EdgeInsets.only(
                      right:  MediaQuery.of(context).size.width * 0.6,
                      top: MediaQuery.of(context).size.height * 0.46,

                  ),
                  child: Column(
                    children: [
                      Flexible(
                        child: ref.watch(getSectionNotifier).when(
                          data: (snapshot) {
                            try {
                              if (snapshot != null) {
                                if (snapshot == "Nocache") {
                                  if (!_isOnline) {
                                    if (!_isDialogShown) {
                                      _isDialogShown = true;
                                      SnackbarUtil.showNetworkError();
                                    }
                                  }
                                }

                                if (_isLoadingList.isEmpty) {
                                  _isLoadingList = List<bool>.filled(
                                      snapshot['data'].length, false);
                                }

                                return ListView.builder(
                                  padding: const EdgeInsets.all(2),
                                  shrinkWrap: true,
                                  itemCount: snapshot['data'].length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0),
                                        child: ElevatedButton(
                                          onPressed: _disableButtons
                                              ? null
                                              : _loadingIndex != null
                                              ? null
                                              : () async {
                                            setState(() {
                                              _loadingIndex =
                                                  index;
                                              _disableButtons =
                                              true;
                                            });

                                            AudioPlayer().play(
                                                AssetSource(
                                                    "audio/Bubble 02.mp3"));
                                            await handleAPIsAndNavigate(
                                                context,
                                                index,
                                                snapshot);
                                          },
                                          style: ButtonStyle(
                                            elevation:
                                            MaterialStateProperty
                                                .resolveWith<
                                                double>(
                                                  (Set<MaterialState>
                                              states) {
                                                return states.contains(
                                                    MaterialState
                                                        .disabled)
                                                    ? 0.0
                                                    : 10.0;
                                              },
                                            ),
                                            foregroundColor:
                                            MaterialStateProperty
                                                .resolveWith<Color>(
                                                  (Set<MaterialState>
                                              states) {
                                                return states.contains(
                                                    MaterialState
                                                        .disabled)
                                                    ? (snapshot['data'][index]
                                                [
                                                'name']
                                                    .toString() ==
                                                    "LKG"
                                                    ? Colors.purple
                                                    .shade600
                                                    : Colors.pink
                                                    .shade600)
                                                    : (snapshot['data'][index]
                                                [
                                                'name']
                                                    .toString() ==
                                                    "LKG"
                                                    ? Colors.purple
                                                    .shade300
                                                    : Colors.pink
                                                    .shade300);
                                              },
                                            ),
                                            backgroundColor:
                                            MaterialStateProperty
                                                .resolveWith<Color>(
                                                  (Set<MaterialState>
                                              states) {
                                                return states.contains(
                                                    MaterialState
                                                        .disabled)
                                                    ? (snapshot['data'][index]
                                                [
                                                'name']
                                                    .toString() ==
                                                    "LKG"
                                                    ? Colors.purple
                                                    .shade600
                                                    : Colors.pink
                                                    .shade600)
                                                    : (snapshot['data'][index]
                                                [
                                                'name']
                                                    .toString() ==
                                                    "LKG"
                                                    ? Colors.purple
                                                    .shade300
                                                    : Colors.pink
                                                    .shade300);
                                              },
                                            ),
                                            minimumSize:
                                            MaterialStateProperty
                                                .all<Size>(
                                                 Size(
                                                      MediaQuery.of(context).size.width * 0.17,
                                                    MediaQuery.of(context).size.height * 0.09,
                                                     )),
                                            overlayColor:
                                            MaterialStateProperty
                                                .resolveWith<
                                                Color?>(
                                                  (Set<MaterialState>
                                              states) {
                                                if (states.contains(
                                                    MaterialState
                                                        .pressed)) {
                                                  return snapshot['data']
                                                  [
                                                  index]
                                                  [
                                                  'name']
                                                      .toString() ==
                                                      "LKG"
                                                      ? Colors
                                                      .purple[600]
                                                      : Colors
                                                      .pink[600];
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          child: _loadingIndex == index
                                              ? LoadingAnimationWidget
                                              .staggeredDotsWave(
                                            color: Colors.white,
                                            size: 50,
                                          )
                                              : Text(
                                            snapshot['data']
                                            [index]
                                            ['name']
                                                .toString(),
                                            style:
                                             TextStyle(
                                              fontSize: MediaQuery.of(context).size.width * 0.015,
                                              color: AppTheme
                                                  .whitecolor,
                                              letterSpacing: 2,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted && !_isDialogShown) {
                                    _showTimeoutDialog();
                                  }
                                });
                                return ShimmerSkeleton(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(2),
                                    shrinkWrap: true,
                                    itemCount: 2,
                                    itemBuilder: (context, index) {
                                      return Center(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: ElevatedButton(
                                            onPressed: () async {},
                                            style: ElevatedButton
                                                .styleFrom(
                                              elevation: 10.0,
                                              backgroundColor:
                                              Colors.pink[300],
                                              minimumSize:
                                               Size(  MediaQuery.of(context).size.width * 0.17,
                                                MediaQuery.of(context).size.height * 0.09,),
                                            ),
                                            child: const Text(
                                              "LKG",
                                              style: TextStyle(
                                                fontSize: AppTheme
                                                    .mediumFontSize,
                                                color:
                                                AppTheme.whitecolor,
                                                letterSpacing: 2,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            } catch (e) {
                              return ShimmerSkeleton(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(2),
                                  shrinkWrap: true,
                                  itemCount: 2,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0),
                                        child: ElevatedButton(
                                          onPressed: () async {},
                                          style:
                                          ElevatedButton.styleFrom(
                                            elevation: 10.0,
                                            backgroundColor:
                                            Colors.pink[300],
                                            minimumSize:
                                             Size(  MediaQuery.of(context).size.width * 0.17,
                                              MediaQuery.of(context).size.height * 0.09,),
                                          ),
                                          child: const Text(
                                            "LKG",
                                            style: TextStyle(
                                              fontSize: AppTheme
                                                  .mediumFontSize,
                                              color:
                                              AppTheme.whitecolor,
                                              letterSpacing: 2,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          error: (e, s) {
                            return const SizedBox();
                          },
                          loading: () => ShimmerSkeleton(
                            child: ListView.builder(
                                padding: const EdgeInsets.all(2),
                                shrinkWrap: true,
                                itemCount: 2,
                                //widget.loginModel!.data!.subscriptionListSection.length,
                                itemBuilder: (context, index) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () async {},
                                        style: ElevatedButton.styleFrom(
                                          elevation: 10.0,
                                          backgroundColor:
                                          Colors.pink[300],
                                          minimumSize:
                                           Size(  MediaQuery.of(context).size.width * 0.17,
                                            MediaQuery.of(context).size.height * 0.09,),
                                        ),
                                        child: const Text(
                                          "LKG",
                                          style: TextStyle(
                                            fontSize:
                                            AppTheme.mediumFontSize,
                                            color: AppTheme.whitecolor,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      ref.watch(getsettingNotifier).when(data: (snapshot) {
                        try {
                          if (snapshot != null) {
                            if (snapshot == "Nocache") {
                              if (!_isOnline) {
                                if (!_isDialogShownsetting) {
                                  _isDialogShownsetting = true;
                                  SnackbarUtil.showNetworkError();
                                }
                              }
                            }

                            return snapshot != null &&
                                snapshot['data']['food_videos'] ==
                                    "enabled"
                                ? ElevatedButton(
                              onPressed: _disableButtons
                                  ? null
                                  : () async {
                                ref.refresh(getfoodcategoryNotifier);
                                ref.refresh(getfooddaysNotifier);
                                ref.refresh(getfoodtypesNotifier);
                                AudioPlayer().play(
                                    AssetSource(
                                        "audio/Bubble 02.mp3"));
                                setState(() {
                                  isloading = true;
                                  _disableButtons = true;
                                });
                                await Future.delayed(
                                    const Duration(
                                        milliseconds: 500));
                                await ref.read(getfoodcategoryNotifier.future);
                                await ref.read(getfooddaysNotifier.future);
                                await ref.read(getfoodtypesNotifier);

                                var videocategorydata = await ref.read(getfoodcategoryNotifier).value;

                                var foodays = await ref.read(getfooddaysNotifier).value;


                                if (videocategorydata ==
                                    "Nocache" || foodays  == "Nocache") {
                                  SnackbarUtil.showNetworkError();
                                  setState(() {
                                    isloading = false; // Stop showing loading indicator on error
                                    _disableButtons = false;
                                  });
                                } else {

                                  foodcategory = videocategorydata['data'][0]['id'].toString();
                                  fooddays = foodays['data'][0]['id'].toString();





                                  Get.to(
                                        () => HealthyMealChart(
                                      foodcategory:
                                      foodcategory,
                                      fooday: fooddays,
                                    ),
                                    // transition: Transition
                                    //     .rightToLeft,
                                    // duration: const Duration(
                                    //     milliseconds: 500),
                                  );
                                  setState(() {
                                    isloading = false;
                                    _disableButtons = false;
                                  });

                                }
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty
                                    .resolveWith<double>(
                                      (Set<MaterialState>
                                  states) {
                                    return states.contains(
                                        MaterialState
                                            .disabled)
                                        ? 0.0
                                        : 10.0;
                                  },
                                ),
                                foregroundColor:
                                MaterialStateProperty
                                    .resolveWith<Color>(
                                      (Set<MaterialState>
                                  states) {
                                    return states.contains(
                                        MaterialState
                                            .disabled)

                                        ? const Color(0xffa96414)
                                        : const Color(0xffF3933F);

                                  },
                                ),
                                backgroundColor:
                                MaterialStateProperty
                                    .resolveWith<Color>(
                                      (Set<MaterialState>
                                  states) {
                                    return states.contains(
                                        MaterialState
                                            .disabled)
                                        ? const Color(0xffa96414)
                                        : const Color(0xffF3933F);
                                  },
                                ),
                                /*backgroundColor: isloading
                                        ? const Color(0xffa96414)
                                        : Color(0xffF3933F),*/

                                minimumSize:
                                MaterialStateProperty.all<Size>(
                                    const Size(250, 45)),
                              ),
                              child: isloading
                                  ? LoadingAnimationWidget
                                  .staggeredDotsWave(
                                color: Colors.white,
                                size: 30,
                              )
                                  : const Text(
                                "HEALTHY MEAL CHART",
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                                : const SizedBox();
                          } else {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) {
                              if (mounted && !_isDialogShownsetting) {
                                _showTimeoutDialog();
                              }
                            });
                            return ShimmerSkeleton(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    AudioPlayer().play(
                                        AssetSource("audio/Bubble 02.mp3"));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    // shape: StadiumBorder(),
                                    elevation: 0.0,
                                    backgroundColor:
                                    const Color(0xffF3933F),
                                    minimumSize: const Size(250, 45),
                                  ),
                                  child: isloading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 5,
                                      valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(Colors.white),
                                    ),
                                  )
                                      : const Text(
                                    "HEALTHY MEAL CHART",
                                    style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          // WidgetsBinding.instance.addPostFrameCallback((_) {
                          //   if (mounted && !_isDialogShownsetting) {
                          //     _showTimeoutDialog();
                          //   }
                          // });
                          return ShimmerSkeleton(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
                              child: ElevatedButton(
                                onPressed: () async {},
                                style: ElevatedButton.styleFrom(
                                  // shape: StadiumBorder(),
                                  elevation: 0.0,
                                  backgroundColor: const Color(0xffF3933F),
                                  minimumSize: const Size(250, 45),
                                ),
                                child: isloading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                                    : const Text(
                                  "HEALTHY MEAL CHART",
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }, error: (e, s) {
                        return const SizedBox();
                      }, loading: () {
                        return ShimmerSkeleton(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: ElevatedButton(
                              onPressed: () async {},
                              style: ElevatedButton.styleFrom(
                                // shape: StadiumBorder(),
                                elevation: 0.0,
                                backgroundColor: const Color(0xffF3933F),
                                minimumSize:  Size(  MediaQuery.of(context).size.width * 0.22,
                                  MediaQuery.of(context).size.height * 0.09,),
                              ),
                              child: isloading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 5,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                                  : const Text(
                                "HEALTHY MEAL CHART",
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            )

          ],
        ),

        Positioned(
          top: MediaQuery.of(context).size.height * 0.05,
          left: 0,
          child: IconButton(
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
              ExitConfirmation.showLogoutDialog(context);
            },
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).size.height * 0.05,
          left: 0,
          child: Container(
            height: 70,
            width: 180,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sapience/FS-Cloud2.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .slideX(
              begin: 0, end: 0.2, duration: 1000.ms, delay: 500.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.01,
          left: MediaQuery.of(context).size.width * 0.4,
          child: Container(
            height: 70,
            width: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sapience/FS-Cloud2.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .slideX(
              begin: 0, end: 0.3, duration: 2000.ms, delay: 100.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.09,
          right: 0,
          child: Container(
            height: 70,
            width: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sapience/FS-Cloud2.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .slideX(
              begin: 0, end: 0.3, duration: 2000.ms, delay: 100.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.08,
          right: MediaQuery.of(context).size.width * 0.04,
          child: Container(
            height: 90,
            width: 90,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sapience/FS-Sun.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .scaleXY(begin: 0.8, end: 1, duration: 1000.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          right: MediaQuery.of(context).size.width * 0.38,
          child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/sapience/HS-Butterfly1.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .scaleX(begin: 0.7, end: 1, duration: 400.ms),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.07,
          left: MediaQuery.of(context).size.width * 0.39,
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/sapience/HS-Butterfly2.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .scaleX(begin: 0.7, end: 1, duration: 200.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: MediaQuery.of(context).size.width * 0.4,
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sapience/HS-Bee2.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .then(delay: 100.ms)
              .shake(hz: 10, duration: 2000.ms)
              .slideX(begin: 0, end: 0.5, duration: 2000.ms)
              .slideY(begin: 0, end: -0.5, duration: 2000.ms)
              .then(delay: 1000.ms),
        ),
        Positioned(
            top: MediaQuery.of(context).size.height * 0.56,
            left: MediaQuery.of(context).size.width * 0.45,

            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sapience/HS-Bee1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .shake(hz: 10, duration: 1000.ms)
                .slideX(begin: 0, end: 1, duration: 1000.ms)),
      ],
    );
  }

  handleAPIsAndNavigate(
      BuildContext context, int index, Map<String, dynamic> snapshot) async {
    // Capture the start time when the function begins
    // DateTime startTime = DateTime.now();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      //await ref.read(getslidervideoNotifier);

      await ref.refresh(addtermsNotifier);
      await ref.refresh(addmonthNotifier);
      selected = -1;
      await ref
          .read(addtermsNotifier.notifier)
          .addterms(snapshot['data'][index]['id'].toString());
      var monthdata = await ref.read(addtermsNotifier).id.value;
      // Handle response
      if (monthdata == "Nocache") {
        SnackbarUtil.showNetworkError();
        setState(() {
          _loadingIndex = null; // Stop showing loading indicator on error
          _disableButtons = false;
        });
      } else {
        String sectionId = snapshot['data'][index]['id'].toString();
        String termId = monthdata['data'][0]['id'].toString();

        await ref.read(getslidervideoNotifier);
        await ref.read(addmonthNotifier.notifier).addmonth(sectionId, termId);
        if (sectionId.isNotEmpty || termId.isNotEmpty) {
          await Get.to(
            () => Syllabus(
              section: snapshot['data'][index]['name'].toString(),
              sectionid: sectionId,
              termid: termId,
            ),
          );
          setState(() {
            _loadingIndex = null;
            _disableButtons = false;

          });
        } else {
          Get.to(
            () => errorPage(),
            // transition: Transition.rightToLeft,
            // duration: const Duration(milliseconds: 500),
          );
          setState(() {
            _loadingIndex = null;
            _disableButtons = false;
          });
        }
      }
    } catch (error) {
      setState(() {
        _loadingIndex = null;
        _disableButtons = false;
      });
    }
  }

  void _showTimeoutDialog() {
    if (!mounted) return;
    _isDialogShown = true;
    _isDialogShownsetting = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _isDialogShown = false;
            _isDialogShownsetting = false;
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
}
