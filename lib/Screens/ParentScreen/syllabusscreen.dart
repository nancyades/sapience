import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sapience/Controller/Provider/generalprovider.dart';
import 'package:sapience/Controller/Provider/monthprovider.dart';
import 'package:sapience/Controller/Provider/termsprovider.dart';
import 'package:sapience/Screens/ParentScreen/landscapesildervideoplayer.dart';
import 'package:sapience/Screens/ParentScreen/parentwelcomescreen.dart';
import 'package:sapience/Screens/ParentScreen/subscreen/weekscreen.dart';
import 'package:sapience/Screens/loaderscreen/sliderloader.dart';
import 'package:sapience/Screens/qrdialogscreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/landscape_view.dart';
import 'package:sapience/constant/logout_confirmation.dart';
import 'package:sapience/constant/shimmer_skeleton.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/helper/appconstant.dart';
import 'package:sapience/helper/bottomnavigationbar.dart';
import 'package:sapience/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/connectivity_manager.dart';

class Syllabus extends ConsumerStatefulWidget {
  final String? section;
  final String? sectionid;
  final String? termid;

  Syllabus({super.key, this.section, this.sectionid, this.termid});

  @override
  ConsumerState<Syllabus> createState() => _SyllabusState();
}

class _SyllabusState extends ConsumerState<Syllabus>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _animationController;
  Animation<double>? _widthAnimation;
  Animation<double>? _opacityAnimation;
  ConnectivityManager connectivityManager = ConnectivityManager();

  int _current = 0;
  bool _isExpanded = false;
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late bool _isOnline;

  List<dynamic> items = [];
  final List<String> imgList = [
    'assets/images/sapience/slide.png',
    'assets/images/sapience/slide.png',
    'assets/images/sapience/slide.png',
    'assets/images/sapience/slide.png',
    'assets/images/sapience/slide.png'
  ];

  final CarouselController _controller = CarouselController();
  int _selectedIndex = 0;

  String termid = "1";
  String termname = "Term 1";
  String monthid = "";

  late TabController _tabController;

  bool _isDialogShown = false;
  bool _isDialogShowncarousel = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    ref.read(getslidervideoNotifier);

    _isDialogShown = false;
    _isDialogShowncarousel = false;

    termid = widget.termid.toString();
    getphone();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _connectivity = Connectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _animationController!.dispose();
    _connectivitySubscription.cancel();

    super.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final isOnline = result != ConnectivityResult.none;
    setState(() {
      _isOnline = isOnline;
    });
    if (isOnline) {
      await ref.read(addtermsNotifier.notifier)
          .addterms(widget.sectionid.toString());
      await ref.read(addmonthNotifier.notifier)
          .addmonth(widget.sectionid.toString(), termid);
      selected = -1;
    }
  }

  getphone() async {
    _isOnline = await SnackbarUtil.checkConnectivity();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppConstants.phoneno = prefs.getString('phoneno').toString();
  }

  void _onItemTapped(int index) {
    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/ParentWelcomeScreen');
          break;
        case 1:
          if (_isOnline) {
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
          LogoutConfirmation.showLogoutDialog(context);

          break;
      }
    });
  }

  void _handleTabSelection() async {
    if (!_tabController.indexIsChanging) {
      ref.watch(addtermsNotifier).id.when(
        data: (snapshot) async {
          try {
            if (snapshot != null) {
              if (!mounted) return;
              switch (_tabController.index) {
                case 0:

                  setState(() {

                    selected = -1;
                    termid = snapshot["data"][_tabController.index]["id"]
                        .toString();
                    termname = snapshot["data"][_tabController.index]["name"]
                        .toString();
                    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                    ref.read(addmonthNotifier.notifier).addmonth(
                        widget.sectionid.toString(),
                        snapshot["data"][_tabController.index]["id"]
                            .toString());
                  });
                  ConnectivityManager connectivityManager =
                  ConnectivityManager();
                  bool isOnline = await connectivityManager.isConnected();
                  if (!isOnline) {
                    SnackbarUtil.showNetworkError();
                    return;
                  }
                  break;
                case 1:

                  setState(() {
                    selected = -1;
                    termid = snapshot["data"][_tabController.index]["id"]
                        .toString();
                    termname = snapshot["data"][_tabController.index]["name"]
                        .toString();
                    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                    ref.read(addmonthNotifier.notifier).addmonth(
                        widget.sectionid.toString(),
                        snapshot["data"][_tabController.index]["id"]
                            .toString());
                  });
                  ConnectivityManager connectivityManager =
                  ConnectivityManager();
                  bool isOnline = await connectivityManager.isConnected();
                  if (!isOnline) {
                    SnackbarUtil.showNetworkError();
                    return;
                  }
                  break;
                case 2:

                  setState(() {
                    selected = -1;
                    termid = snapshot["data"][_tabController.index]["id"]
                        .toString();
                    termname = snapshot["data"][_tabController.index]["name"]
                        .toString();
                    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                    ref.read(addmonthNotifier.notifier).addmonth(
                        widget.sectionid.toString(),
                        snapshot["data"][_tabController.index]["id"]
                            .toString());

                  });
                  ConnectivityManager connectivityManager =
                  ConnectivityManager();
                  bool isOnline = await connectivityManager.isConnected();
                  if (!isOnline) {
                    SnackbarUtil.showNetworkError();
                    return;
                  }
                  break;
              }
            } else {
              _showTimeoutDialog();
            }
          } catch (e) {
            _showTimeoutDialog();
          }
        },
        error: (e, s) {},
        loading: () {},
      );
    }
  }

  void _showTimeoutDialog() {
    if (!mounted) return;
    _isDialogShown = true;
    _isDialogShowncarousel = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _isDialogShown = false;
            _isDialogShowncarousel = false;
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

  void _toggleAnimation() {
    AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
    if (_isExpanded) {
      _animationController!.reverse();
    } else {
      _animationController!.forward();
    }
    _isExpanded = !_isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return isTvScreen ? buildLandscapeLayout() : buildPortraitLayout(context);

  }

  Widget buildPortraitLayout(BuildContext context) {
    final carouselDataState = ref.watch(getslidervideoNotifier);

    return WillPopScope(
      onWillPop: () {
        setState(() {
          GlobalState.isLoadingList = [false];
        });
        Get.to(
          const ParentWelcomeScreen(),
          // duration: const Duration(milliseconds: 500)
        );
        return Future.value(false);
      },
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: widget.section == "LKG"
              ? const Color(0xffebe7f8)
              : const Color(0xfff5cfe8),
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
                        Text(
                          widget.section.toString(),
                          style: const TextStyle(
                            fontSize: AppTheme.mediumFontSize,
                            color: AppTheme.blackcolor,
                          ),
                        ),
                      ],
                    ),
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
                                            padding: const EdgeInsets.only(
                                                left: 18.0),
                                            child: Text(
                                              AppConstants.phoneno.toString(),
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
                                  child: Icon(
                                    Icons.person_2_rounded,
                                    color: widget.section == "LKG"
                                        ? const Color(0xffb673d0)
                                        : const Color(0xffffa8e6),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(

                flex: 5,
                child: carouselDataState.when(
                  data: (data) {
                    try {
                      if (data != null) {
                        if (data == "Nocache") {
                          if (!_isDialogShowncarousel) {
                            _isDialogShowncarousel = true;
                            SnackbarUtil.showNetworkError();
                          }
                        }
                        List<dynamic> imgList =
                        (data as Map<String, dynamic>)['data']
                        as List<dynamic>;
                        return Column(
                          children: [
                            Flexible(
                              child: CarouselSlider(
                                items: imgList.map((item) {
                                  return GestureDetector(
                                      onTap: () {
                                        if (_isOnline) {
                                          if(item['image_url'] == null){

                                          }else{
                                            Get.off(
                                                  () => LandscapeSlideloader(
                                                termid: widget.termid,
                                                section: widget.section,
                                                sectionid: widget.sectionid,
                                                filepath: item['video_url'],
                                                image: item['image_url'],
                                              ),
                                              // transition: Transition.fadeIn,
                                              // duration:
                                              // const Duration(milliseconds: 500)
                                            );

                                            selected = -1;
                                          }

                                        } else {
                                          SnackbarUtil.showNetworkError();
                                        }
                                      },
                                      child: Container(
                                        width: 500,
                                        height: 120,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                        child:item['image_url'] == null
                                            ? Image.asset(
                                          'assets/images/sapience/Slide1.png', // Your local asset image
                                          fit: BoxFit.fill,
                                        )
                                            : CachedNetworkImage(
                                          imageUrl: item['image_url'],
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) =>
                                              ShimmerSkeleton(
                                                child: Container(
                                                  width: 500,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                    BorderRadius.circular(15),
                                                  ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                  width: 500,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        15),
                                                  ),
                                                  child: const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.grey,
                                                    size: 40,
                                                  )),
                                        ),
                                      ));
                                }).toList(),
                                carouselController: _controller,
                                options: CarouselOptions(
                                    autoPlay: true,
                                    enlargeCenterPage: true,
                                    aspectRatio: 1.9,
                                    viewportFraction: 0.9,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _current = index;
                                      });
                                    }),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: imgList.asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () =>
                                      _controller.animateToPage(entry.key),
                                  child: Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? const Color(0xffc8c6c7)
                                          : const Color(0xff6c6c6e))
                                          .withOpacity(
                                          _current == entry.key ? 0.9 : 0.4),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && !_isDialogShowncarousel) {
                            _showTimeoutDialog();
                          }
                        });
                        return ShimmerSkeleton(
                          child: Column(
                            children: [
                              CarouselSlider(
                                items: imgList.map((item) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: 500,
                                      height: 120,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(15),
                                        image: const DecorationImage(
                                          image: AssetImage(''),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                carouselController: _controller,
                                options: CarouselOptions(
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                    aspectRatio: 2.5,
                                    viewportFraction: 0.9,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _current = index;
                                      });
                                    }),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: imgList.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _controller.animateToPage(entry.key),
                                    child: Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 2.0),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_isDialogShowncarousel) {
                          _showTimeoutDialog();
                        }
                      });
                      return ShimmerSkeleton(
                        child: Column(
                          children: [
                            CarouselSlider(
                              items: imgList.map((item) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 500,
                                    height: 120,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(15),
                                      image: const DecorationImage(
                                        image: AssetImage(''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              carouselController: _controller,
                              options: CarouselOptions(
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  aspectRatio: 2.5,
                                  viewportFraction: 0.9,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _current = index;
                                    });
                                  }),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: imgList.asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () =>
                                      _controller.animateToPage(entry.key),
                                  child: Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 2.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
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
                        children: [
                          CarouselSlider(
                            items: imgList.map((item) {
                              return GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 500,
                                  height: 120,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: const DecorationImage(
                                      image: AssetImage(''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            carouselController: _controller,
                            options: CarouselOptions(
                                autoPlay: false,
                                enlargeCenterPage: true,
                                aspectRatio: 2.5,
                                viewportFraction: 0.9,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imgList.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () =>
                                    _controller.animateToPage(entry.key),
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 2.0),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ref.watch(addtermsNotifier).id.when(
                data: (snapshot) {
                  return Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      padding: const EdgeInsets.all(2),
                      width: 380,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DefaultTabController(
                        initialIndex: 0,
                        length: 3,
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(
                              text: snapshot['data'][0]['name']
                                  .toUpperCase(),
                            ),
                            Tab(
                              text: snapshot['data'][1]['name']
                                  .toUpperCase(),
                            ),
                            Tab(
                              text: snapshot['data'][2]['name']
                                  .toUpperCase(),
                            ),
                          ],
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xffb673d0),
                          ),
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xffb673d0),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppTheme.mediumFontSize),
                          unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.normal),
                          indicatorSize: TabBarIndicatorSize.tab,
                        ),
                      ),
                    ),
                  );
                },
                error: (e, s) {
                  return const SizedBox();
                },
                loading: () {
                  return ShimmerSkeleton(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      padding: const EdgeInsets.all(2),
                      width: 380,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DefaultTabController(
                        initialIndex: 0,
                        length: 3,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              text: "Term 1",
                            ),
                            Tab(
                              text: "Term 2",
                            ),
                            Tab(
                              text: "Term 3",
                            ),
                          ],
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xffb673d0),
                          ),
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xffb673d0),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppTheme.mediumFontSize),
                          unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.normal),
                          indicatorSize: TabBarIndicatorSize.tab,
                        ),
                      ),
                    ),
                  );
                },
              ),
              WeeksList(
                section: widget.section.toString(),
                sectionid: widget.sectionid.toString(),
                termid: termid,
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildLandscapeLayout() {
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
                                  setState(() {
                                    GlobalState.isLoadingList = [false];
                                  });
                                  Get.to(
                                    const ParentWelcomeScreen(),
                                    // duration: const Duration(milliseconds: 500)
                                  );
                                },
                              ),
                              Text(widget.section.toString(),
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
                            if (!_isDialogShowncarousel) {
                              _isDialogShowncarousel = true;
                              SnackbarUtil.showNetworkError();
                            }
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
                                              termid: widget.termid,
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
                            if (mounted && !_isDialogShowncarousel) {
                              _showTimeoutDialog();
                            }
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
                    ref.watch(addtermsNotifier).id.when(
                      data: (snapshot) {
                        return Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                            padding: const EdgeInsets.all(2),
                            width:  MediaQuery.of(context).size.width * 0.43,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DefaultTabController(
                              initialIndex: 0,
                              length: 3,
                              child: TabBar(
                                controller: _tabController,
                                tabs: [
                                  Tab(
                                    text: snapshot['data'][0]['name']
                                        .toUpperCase(),
                                  ),
                                  Tab(
                                    text: snapshot['data'][1]['name']
                                        .toUpperCase(),
                                  ),
                                  Tab(
                                    text: snapshot['data'][2]['name']
                                        .toUpperCase(),
                                  ),
                                ],
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: const Color(0xffb673d0),
                                ),
                                dividerColor: Colors.transparent,
                                labelColor: Colors.white,
                                unselectedLabelColor: const Color(0xffb673d0),
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppTheme.mediumFontSize),
                                unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.normal),
                                indicatorSize: TabBarIndicatorSize.tab,
                              ),
                            ),
                          ),
                        );
                      },
                      error: (e, s) {
                        return const SizedBox();
                      },
                      loading: () {
                        return ShimmerSkeleton(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            padding: const EdgeInsets.all(2),
                            width: 380,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DefaultTabController(
                              initialIndex: 0,
                              length: 3,
                              child: TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(
                                    text: "Term 1",
                                  ),
                                  Tab(
                                    text: "Term 2",
                                  ),
                                  Tab(
                                    text: "Term 3",
                                  ),
                                ],
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: const Color(0xffb673d0),
                                ),
                                dividerColor: Colors.transparent,
                                labelColor: Colors.white,
                                unselectedLabelColor: const Color(0xffb673d0),
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppTheme.mediumFontSize),
                                unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.normal),
                                indicatorSize: TabBarIndicatorSize.tab,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    WeeksList(
                      section: widget.section.toString(),
                      sectionid: widget.sectionid.toString(),
                      termid: termid,
                    )
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

  // Widget _buildCard(String imagePath) {
  //   return Card(
  //     margin: EdgeInsets.all(10),
  //     child: Column(
  //       children: [
  //         Image.asset(imagePath),
  //       ],
  //     ),
  //   );
  // }


}









