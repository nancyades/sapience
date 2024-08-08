import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sapience/Controller/Provider/foodvideosprovider.dart';
import 'package:sapience/Controller/Provider/generalprovider.dart';
import 'package:sapience/Screens/ParentScreen/healthyMealSyllabus.dart';
import 'package:sapience/Screens/ParentScreen/parentwelcomescreen.dart';
import 'package:sapience/Screens/qrdialogscreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/error_page.dart';
import 'package:sapience/constant/landscape_view.dart';
import 'package:sapience/constant/logout_confirmation.dart';
import 'package:sapience/constant/shimmer_skeleton.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/helper/appconstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/error_page.dart';
import '../../helper/bottomnavigationbar.dart';

class HealthyMealChart extends ConsumerStatefulWidget {
  String? foodcategory;
  String? fooday;

  HealthyMealChart({super.key, this.foodcategory, this.fooday});

  @override
  ConsumerState<HealthyMealChart> createState() => _HealthyMealChartState();
}

class _HealthyMealChartState extends ConsumerState<HealthyMealChart>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _widthAnimation;
  Animation<double>? _opacityAnimation;
  int boxSelectedIndex = 0;
  int _selectedIndex = 0;
  bool _isExpanded = false; //New

  String? foodcategoryid;
  bool _isDialogShownchart = false;

  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late bool _isOnline;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
    _isDialogShownchart = false;

    foodcategoryid = widget.foodcategory;

    getphone();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: 0, end: 130).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation =
        Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _animationController!.addListener(() {
      setState(() {});
    });
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final isOnline = result != ConnectivityResult.none;
    setState(() {
      _isOnline = isOnline;
    });
    if (isOnline) {

      await ref.read(getfoodcategoryNotifier.future);
      await ref.read(getfooddaysNotifier.future);
      await ref.read(getfoodtypesNotifier);


    } else {


    }
  }
  getphone() async {
    _isOnline = await SnackbarUtil.checkConnectivity();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppConstants.phoneno = prefs.getString('phoneno').toString();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _toggleAnimation() {
    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
    if (_isExpanded) {
      _animationController!.reverse();
    } else {
      _animationController!.forward();
    }
    _isExpanded = !_isExpanded;
  }

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

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: buildPortraitLayout(context), // Your specific screen layout method
    );
  }

  Widget buildPortraitLayout(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var sizedBox = height >= 700;
    var forSizedBox =
        sizedBox ? const SizedBox(height: 30) : const SizedBox(height: 0);

    return WillPopScope(
      onWillPop: () {
        Get.to(const ParentWelcomeScreen(),
            // duration: const Duration(milliseconds: 500)
        );
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: height,
                width: width,
                decoration: const BoxDecoration(color: AppTheme.healthyMealBg),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 34),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
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
                                    AudioPlayer().play(
                                        AssetSource("audio/Bubble 02.mp3"));
                                    Get.to(const ParentWelcomeScreen(),
                                        // duration:
                                        //     const Duration(milliseconds: 500)
                                    );
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'Healthy meal chart'.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: AppTheme.mediumFontSize,
                                      color: AppTheme.blackcolor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          forSizedBox,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Material(
                              color: Colors.white,
                              child: Container(
                                height: 30,
                                child: Row(
                                  children: [
                                    ClipRect(
                                      child: Container(
                                        height: 20,
                                        width: _widthAnimation!.value,
                                        child: Opacity(
                                          opacity: _opacityAnimation!.value,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 18.0),
                                                  child: Text(
                                                    AppConstants.phoneno
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 30,
                                      child: FloatingActionButton(
                                        onPressed: _toggleAnimation,
                                        child: const Icon(
                                            Icons.person_2_rounded,
                                            color: AppTheme.userIconGrey),
                                      ),
                                    ),
                                  ],
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
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ref.watch(getfoodcategoryNotifier).when(
                              data: (snapshot) {
                                try {
                                  if (snapshot != null) {
                                    if (snapshot == "Nocache") {
                                      if (!_isDialogShownchart) {
                                        _isDialogShownchart = true;
                                        SnackbarUtil.showNetworkError();
                                      }
                                    }
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width <=
                                                  320
                                              ? 350
                                              : 370,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: GridView.count(
                                              shrinkWrap: true,
                                              mainAxisSpacing: 0,
                                              crossAxisSpacing: 0,
                                              childAspectRatio: 1.4,
                                              crossAxisCount: 2,
                                              children: List.generate(
                                                  snapshot['data'].length,
                                                  (index) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    AudioPlayer().play(AssetSource(
                                                        "audio/Bubble 02.mp3"));
                                                    ref.refresh(
                                                        getfooddaysNotifier);
                                                    ref.read(
                                                        getfooddaysNotifier);

                                                    ref.refresh(
                                                        getfoodtypesNotifier);
                                                    ref.read(
                                                        getfoodtypesNotifier);

                                                    setState(() {
                                                      boxSelectedIndex = index;
                                                      foodcategoryid =
                                                          snapshot['data']
                                                                  [index]['id']
                                                              .toString();
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 450.0,
                                                    height: 100.0,
                                                    decoration: BoxDecoration(
                                                      color: boxSelectedIndex ==
                                                              index
                                                          ? Colors.lightBlue
                                                          : null,
                                                      gradient:
                                                          boxSelectedIndex !=
                                                                  index
                                                              ? RadialGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .white,
                                                                    Colors
                                                                        .lightBlueAccent
                                                                        .shade200,
                                                                  ],
                                                                  center: Alignment
                                                                      .topRight,
                                                                  radius: 3.0,
                                                                  stops: const [
                                                                    0.1,
                                                                    1.0
                                                                  ],
                                                                )
                                                              : null,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 10.0,
                                                            offset:
                                                                Offset(0, 10)),
                                                      ],
                                                    ),
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          snapshot['data']
                                                                      [index]
                                                                  ['name']
                                                              .toString()
                                                              .split(" ")[0],
                                                          style: TextStyle(
                                                            fontSize: AppTheme
                                                                .highMediumFontSize,
                                                            color:
                                                                boxSelectedIndex ==
                                                                        index
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .blue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          snapshot['data']
                                                                      [index]
                                                                  ['name']
                                                              .toString()
                                                              .split(" ")[1],
                                                          style: TextStyle(
                                                            fontSize: AppTheme
                                                                .highMediumFontSize,
                                                            color:
                                                                boxSelectedIndex ==
                                                                        index
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .blue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 4.0),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: CircleAvatar(
                                              radius: MediaQuery.of(context)
                                                          .size
                                                          .width <=
                                                      320
                                                  ? 45
                                                  : 55,
                                              backgroundColor: Colors.yellow,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 3.0,
                                                    vertical: 20.0),
                                                child: Text(
                                                  'HEALTHY MEAL',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        AppTheme.mediumFontSize,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted && !_isDialogShownchart) {
                                        _showTimeoutDialog();
                                      }
                                    });
                                    return ShimmerSkeleton(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    320
                                                ? 350
                                                : 370,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: GridView.count(
                                                shrinkWrap: true,
                                                mainAxisSpacing: 0,
                                                crossAxisSpacing: 0,
                                                childAspectRatio: 1.4,
                                                crossAxisCount: 2,
                                                children:
                                                    List.generate(4, (index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      AudioPlayer().play(
                                                          AssetSource(
                                                              "audio/Bubble 02.mp3"));

                                                      setState(() {
                                                        boxSelectedIndex =
                                                            index;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 450.0,
                                                      height: 100.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            boxSelectedIndex ==
                                                                    index
                                                                ? Colors
                                                                    .lightBlue
                                                                : null,
                                                        gradient:
                                                            boxSelectedIndex !=
                                                                    index
                                                                ? RadialGradient(
                                                                    colors: [
                                                                      Colors
                                                                          .white,
                                                                      Colors
                                                                          .lightBlueAccent
                                                                          .shade200,
                                                                    ],
                                                                    center: Alignment
                                                                        .topRight,
                                                                    radius: 3.0,
                                                                    stops: const [
                                                                      0.1,
                                                                      1.0
                                                                    ],
                                                                  )
                                                                : null,
                                                        boxShadow: const [
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              blurRadius: 10.0,
                                                              offset: Offset(
                                                                  0, 10)),
                                                        ],
                                                      ),
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Chart',
                                                            style: TextStyle(
                                                              fontSize: AppTheme
                                                                  .highMediumFontSize,
                                                              color:
                                                                  boxSelectedIndex ==
                                                                          index
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            ' ${index + 1}',
                                                            style: TextStyle(
                                                              fontSize: AppTheme
                                                                  .highMediumFontSize,
                                                              color:
                                                                  boxSelectedIndex ==
                                                                          index
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 4.0),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: CircleAvatar(
                                                radius: MediaQuery.of(context)
                                                            .size
                                                            .width <=
                                                        320
                                                    ? 45
                                                    : 55,
                                                backgroundColor: Colors.yellow,
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 3.0,
                                                      vertical: 20.0),
                                                  child: Text(
                                                    'HEALTHY MEAL',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: AppTheme
                                                          .mediumFontSize,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (mounted && !_isDialogShownchart) {
                                      _showTimeoutDialog();
                                    }
                                  });
                                  return ShimmerSkeleton(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width <=
                                                  320
                                              ? 350
                                              : 370,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: GridView.count(
                                              shrinkWrap: true,
                                              mainAxisSpacing: 0,
                                              crossAxisSpacing: 0,
                                              childAspectRatio: 1.4,
                                              crossAxisCount: 2,
                                              children:
                                                  List.generate(4, (index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    AudioPlayer().play(AssetSource(
                                                        "audio/Bubble 02.mp3"));

                                                    setState(() {
                                                      boxSelectedIndex = index;
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 450.0,
                                                    height: 100.0,
                                                    decoration: BoxDecoration(
                                                      color: boxSelectedIndex ==
                                                              index
                                                          ? Colors.lightBlue
                                                          : null,
                                                      gradient:
                                                          boxSelectedIndex !=
                                                                  index
                                                              ? RadialGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .white,
                                                                    Colors
                                                                        .lightBlueAccent
                                                                        .shade200,
                                                                  ],
                                                                  center: Alignment
                                                                      .topRight,
                                                                  radius: 3.0,
                                                                  stops: const [
                                                                    0.1,
                                                                    1.0
                                                                  ],
                                                                )
                                                              : null,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 10.0,
                                                            offset:
                                                                Offset(0, 10)),
                                                      ],
                                                    ),
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Chart',
                                                          style: TextStyle(
                                                            fontSize: AppTheme
                                                                .highMediumFontSize,
                                                            color:
                                                                boxSelectedIndex ==
                                                                        index
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .blue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          ' ${index + 1}',
                                                          style: TextStyle(
                                                            fontSize: AppTheme
                                                                .highMediumFontSize,
                                                            color:
                                                                boxSelectedIndex ==
                                                                        index
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .blue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 4.0),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: CircleAvatar(
                                              radius: MediaQuery.of(context)
                                                          .size
                                                          .width <=
                                                      320
                                                  ? 45
                                                  : 55,
                                              backgroundColor: Colors.yellow,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 3.0,
                                                    vertical: 20.0),
                                                child: Text(
                                                  'HEALTHY MEAL',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        AppTheme.mediumFontSize,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              error: (e, s) {
                                return const SizedBox();
                              },
                              loading: () {
                                return ShimmerSkeleton(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width <=
                                                    320
                                                ? 350
                                                : 370,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: GridView.count(
                                            shrinkWrap: true,
                                            mainAxisSpacing: 0,
                                            crossAxisSpacing: 0,
                                            childAspectRatio: 1.4,
                                            crossAxisCount: 2,
                                            children: List.generate(4, (index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  AudioPlayer().play(AssetSource(
                                                      "audio/Bubble 02.mp3"));

                                                  setState(() {
                                                    boxSelectedIndex = index;
                                                  });
                                                },
                                                child: Container(
                                                  width: 450.0,
                                                  height: 100.0,
                                                  decoration: BoxDecoration(
                                                    color: boxSelectedIndex ==
                                                            index
                                                        ? Colors.lightBlue
                                                        : null,
                                                    gradient:
                                                        boxSelectedIndex !=
                                                                index
                                                            ? RadialGradient(
                                                                colors: [
                                                                  Colors.white,
                                                                  Colors
                                                                      .lightBlueAccent
                                                                      .shade200,
                                                                ],
                                                                center: Alignment
                                                                    .topRight,
                                                                radius: 3.0,
                                                                stops: const [
                                                                  0.1,
                                                                  1.0
                                                                ],
                                                              )
                                                            : null,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 10.0,
                                                          offset:
                                                              Offset(0, 10)),
                                                    ],
                                                  ),
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Chart',
                                                        style: TextStyle(
                                                          fontSize: AppTheme
                                                              .highMediumFontSize,
                                                          color:
                                                              boxSelectedIndex ==
                                                                      index
                                                                  ? Colors.white
                                                                  : Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        ' ${index + 1}',
                                                        style: TextStyle(
                                                          fontSize: AppTheme
                                                              .highMediumFontSize,
                                                          color:
                                                              boxSelectedIndex ==
                                                                      index
                                                                  ? Colors.white
                                                                  : Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 4.0),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: CircleAvatar(
                                            radius: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    320
                                                ? 45
                                                : 55,
                                            backgroundColor: Colors.yellow,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3.0,
                                                  vertical: 20.0),
                                              child: Text(
                                                'HEALTHY MEAL',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      AppTheme.mediumFontSize,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            DayList(
                              foodcategory: foodcategoryid,
                              foodday: widget.fooday,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBarWidget(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
        ),
      ),
    );
  }

  void _showTimeoutDialog() {
    if (!mounted) return;
    _isDialogShownchart = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _isDialogShownchart = false;
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

class DayList extends ConsumerStatefulWidget {
  String? foodcategory;
  String? foodday;
  DayList({super.key, this.foodcategory, this.foodday});

  @override
  ConsumerState<DayList> createState() => _DayListState();
}

class _DayListState extends ConsumerState<DayList> {
  int selectedDay = 0;
  String? fooddays;
  bool _isDialogShowndays = false;
  bool _isDialogShownfoodtypes = false;
  String? selectedFoodItem;
  bool isLoading = false;
  int selectedIndex = -1;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();

    _isDialogShowndays = false;
    _isDialogShownfoodtypes = false;
    fooddays = widget.foodday.toString();

  }




  @override
  Widget build(BuildContext context) {
    List<Widget> dayWidgets = [];

    ref.watch(getfooddaysNotifier).when(data: (snapshot) {
      try {
        if (snapshot != null) {
          if (snapshot == "Nocache") {
            if (!_isDialogShowndays) {
              _isDialogShowndays = true;
              SnackbarUtil.showNetworkError();
            }
          }
          dayWidgets = List.generate(snapshot['data'].length, (index) {
            double radiusSize =
                MediaQuery.of(context).size.width <= 320 ? 27 : 31;
            return GestureDetector(
              onTap: () {
                AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                ref.refresh(getfoodtypesNotifier);
                ref.refresh(getfoodtypesNotifier);

                setState(() {
                  selectedDay = index;
                  fooddays = snapshot['data'][index]['id'].toString();
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width <= 375 ? 2.6 : 4.5),
                child: CircleAvatar(
                  backgroundColor: selectedDay == index
                      ? Colors.blue
                      : AppTheme.userIconGrey,
                  radius: radiusSize,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          snapshot['data'][index]['name']
                              .toString()
                              .split(" ")[0],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppTheme.verySmallFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text('${index + 1}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.mediumFontSize,
                                fontWeight: FontWeight
                                    .bold)), // Dynamically setting the day
                        // Text styling
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isDialogShowndays) {
              _showTimeoutDialog();
            }
          });
          return ShimmerSkeleton(
            child: GestureDetector(
              onTap: () {
                AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width <= 375 ? 2.6 : 4.5),
                child: const CircleAvatar(
                  backgroundColor: AppTheme.userIconGrey,
                  radius: 27,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Day',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTheme.verySmallFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text('${1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.mediumFontSize,
                                fontWeight: FontWeight
                                    .bold)), // Dynamically setting the day
                        // Text styling
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDialogShowndays) {
            _showTimeoutDialog();
          }
        });
        return ShimmerSkeleton(
          child: GestureDetector(
            onTap: () {
              AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width <= 375 ? 2.6 : 4.5),
              child: const CircleAvatar(
                backgroundColor: AppTheme.userIconGrey,
                radius: 27,
                child: Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.verySmallFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      Text('${1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTheme.mediumFontSize,
                              fontWeight: FontWeight
                                  .bold)), // Dynamically setting the day
                      // Text styling
                    ],
                  ),
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
        child: GestureDetector(
          onTap: () {
            AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width <= 375 ? 2.6 : 4.5),
            child: const CircleAvatar(
              backgroundColor: AppTheme.userIconGrey,
              radius: 27,
              child: Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTheme.verySmallFontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    Text('${1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.mediumFontSize,
                            fontWeight: FontWeight
                                .bold)), // Dynamically setting the day
                    // Text styling
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Wrap(
            children: dayWidgets,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Visibility(
          visible: selectedDay != -1,
          child: ref.watch(getfoodtypesNotifier).when(data: (snapshot) {
            try {
              if (snapshot != null) {
                if (snapshot == "Nocache") {
                  if (!_isDialogShownfoodtypes) {
                    _isDialogShownfoodtypes = true;
                    SnackbarUtil.showNetworkError();
                  }
                }
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot['data'].length,
                  itemBuilder: (BuildContext context, int index) {
                    Color? backgroundColor = index.isEven
                        ? const Color(0xffeeda55)
                        : Colors.yellow[700];

                    bool isSelected = selectedFoodItem ==
                        snapshot['data'][index]['id'].toString();

                    return InkWell(
                      onTap: () async {
                        try {
                          setState(() {
                            isLoading = true;
                            selectedIndex = index;
                          });
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          AudioPlayer()
                              .play(AssetSource("audio/Bubble 02.mp3"));

                          ref
                              .read(addfoodvideosNotifier.notifier)
                              .addfoodvideos(
                                  widget.foodcategory.toString(),
                                  snapshot['data'][index]['id'].toString(),
                                  fooddays.toString());

                          var foodvideos =
                              await ref.read(addfoodvideosNotifier).id.value;
                          if (foodvideos == "Nocache") {
                            SnackbarUtil.showNetworkError();
                          } else {
                            if (widget.foodcategory.toString() == null ||
                                snapshot['data'][index]['id'].toString() ==
                                    null ||
                                fooddays.toString() == null) {
                              Get.to(() => errorPage(),
                                  // transition: Transition.rightToLeft,
                                  // duration: const Duration(milliseconds: 1)
                              );
                            } else {
                              Get.to(
                                  () => HealthyMealSyllabus(
                                        meals: snapshot['data'][index]['name'].toString(),
                                    foodcategory: widget.foodcategory.toString(),
                                    foodtype: snapshot['data'][index]['id'].toString(),
                                    foodday: fooddays.toString(),

                                      ),
                                  // transition: Transition.rightToLeft,
                                  // duration: const Duration(milliseconds: 500)
                              );
                            }
                          }
                        } catch (e) {
                        } finally {
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          setState(() {
                            isLoading = false;
                            selectedIndex = -1;
                          });
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width <= 320
                              ? 280
                              : 375,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? const Color(0xff868318)
                                : backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: selectedIndex == index
                                  ? Center(
                                      child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: LoadingAnimationWidget
                                          .staggeredDotsWave(
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ))
                                  : Text(
                                      snapshot['data'][index]['name']
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                );
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isDialogShownfoodtypes) {
                    _showTimeoutDialog();
                  }
                });
                return ShimmerSkeleton(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index) {
                      Color? backgroundColor = index.isEven
                          ? const Color(0xffeeda55)
                          : Colors.yellow[700];
                      return InkWell(
                        onTap: () {
                          AudioPlayer()
                              .play(AssetSource("audio/Bubble 02.mp3"));
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width <= 320
                                ? 280
                                : 375,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Breakfast",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                  ),
                );
              }
            } catch (e) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_isDialogShownfoodtypes) {
                  _showTimeoutDialog();
                }
              });
              return ShimmerSkeleton(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    Color? backgroundColor = index.isEven
                        ? const Color(0xffeeda55)
                        : Colors.yellow[700];
                    return InkWell(
                      onTap: () {
                        AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width <= 320
                              ? 280
                              : 375,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Breakfast",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                ),
              );
            }
          }, error: (e, s) {
            return const SizedBox();
          }, loading: () {
            return ShimmerSkeleton(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  Color? backgroundColor = index.isEven
                      ? const Color(0xffeeda55)
                      : Colors.yellow[700];
                  return InkWell(
                    onTap: () {
                      AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));

                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width <= 320
                            ? 280
                            : 375,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Breakfast",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
              ),
            );
          }),
        )
      ],
    );
  }

  void _showTimeoutDialog() {
    if (!mounted) return;
    _isDialogShowndays = true;
    _isDialogShownfoodtypes = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _isDialogShowndays = false;
            _isDialogShownfoodtypes = false;
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
