import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/route_manager.dart';
import 'package:sapience/Screens/carousel_intro_screen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/landscape_view.dart';
import 'package:sapience/helper/audiofile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () {
        Get.offAll(
          () => const CarouselIntroScreen(),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      AudioService().stopMusic();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().playMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
        child: isTvScreen ?buildLandscapeLayout() : buildPortraitLayout()

    );
  }

  Widget buildPortraitLayout() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/sapience/FS-Bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(
                        //   height: 100,
                        // ),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/images/sapience/logo.png',
                              width: 250,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.03,
          bottom: 10,
          child: Container(
            height: 320,
            child: Image.asset(
              'assets/images/sapience/splash_image.png',
              width: 320,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 60,
          child: Container(
            height: 60,
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
              .slideX(begin: -0.1, end: 0, duration: 3000.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.096,
          right: MediaQuery.of(context).size.width * 0.13,
          child: Container(
            height: 110,
            width: 110,
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
              .scaleXY(begin: 0.9, end: 1.0, duration: 1000.ms, delay: 200.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.17,
          right: 0,
          child: Container(
            height: 60,
            width: 130,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sapience/FS-Cloud4.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.loop(reverse: true),
              )
              .slideX(begin: 0, end: 0.1, duration: 3000.ms),
        ),
        Positioned(
          bottom: 290,
          left: 60,
          child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/sapience/FS-Star1.png'),
              fit: BoxFit.cover,
            )),
          )
              .animate(
                onPlay: (controller) => controller.loop(reverse: true),
              )
              .scaleXY(begin: 0.7, end: 1, duration: 1000.ms),
        ),
        Positioned(
          bottom: 240,
          left: 45,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/sapience/FS-Star2.png'),
              fit: BoxFit.cover,
            )),
          )
              .animate(
                onPlay: (controller) => controller.loop(reverse: true),
              )
              .scaleXY(begin: 0.5, end: 1, duration: 2000.ms, delay: 500.ms),
        ),
        Positioned(
          bottom: 280,
          left: 170,
          child: Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/sapience/FS-Star5.png'),
              fit: BoxFit.cover,
            )),
          )
              .animate(
                onPlay: (controller) => controller.loop(reverse: true),
              )
              .scaleXY(begin: 0.5, end: 1, delay: 800.ms, duration: 1000.ms),
        ),
        Positioned(
          bottom: 280,
          left: 270,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/sapience/FS-Star5.png'),
              fit: BoxFit.cover,
            )),
          )
              .animate(
                onPlay: (controller) => controller.loop(reverse: true),
              )
              .scaleXY(begin: 0.7, end: 1.5, duration: 1500.ms),
        ),
        Positioned(
          bottom: 210,
          right: 25,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/sapience/FS-Star4.png'),
              fit: BoxFit.contain,
            )),
          )
              .animate(
                onPlay: (controller) => controller.loop(reverse: true),
              )
              .scaleXY(begin: 0.5, end: 1.2, duration: 600.ms),
        )
      ],
    );
  }

  Widget buildLandscapeLayout() {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/sapience/landscapeimages/Splash-scr1.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.14,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              height:MediaQuery.of(context).size.height * 0.35,
              child: Image.asset(
                'assets/images/sapience/splash_image.png',
                width:MediaQuery.of(context).size.width *0.35,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height *0.09,
            left: MediaQuery.of(context).size.width* 0.06,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.13,
              width: MediaQuery.of(context).size.width*  0.13,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sapience/FS-Cloud2.png'),
                  fit: BoxFit.contain,
                ),
              ),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .slideX(begin: -0.1, end: 0.5, duration: 3000.ms),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.09,
            right: MediaQuery.of(context).size.width * 0.13,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.13,
              width: MediaQuery.of(context).size.width * 0.13,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sapience/FS-Sun.png'),
                  fit: BoxFit.contain,
                ),
              ),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .scaleXY(begin: 0.9, end: 1.0, duration: 1000.ms, delay: 200.ms),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            right: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.13,
              width: MediaQuery.of(context).size.width * 0.13,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sapience/FS-Cloud4.png'),
                  fit: BoxFit.contain,
                ),
              ),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .slideX(begin: 0, end: 0.1, duration: 3000.ms),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.47,
            right: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.047,
              width: MediaQuery.of(context).size.width * 0.03,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sapience/FS-Star1.png'),
                    fit: BoxFit.cover,
                  )),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .scaleXY(begin: 0.7, end: 1, duration: 1000.ms),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            right: MediaQuery.of(context).size.width * 0.42,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.047,
              width: MediaQuery.of(context).size.width * 0.03,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sapience/FS-Star2.png'),
                    fit: BoxFit.cover,
                  )),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .scaleXY(begin: 0.5, end: 1, duration: 2000.ms, delay: 500.ms),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.49,
            right: MediaQuery.of(context).size.width * 0.28,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.047,
              width: MediaQuery.of(context).size.width * 0.03,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sapience/FS-Star5.png'),
                    fit: BoxFit.cover,
                  )),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .scaleXY(begin: 0.5, end: 1, delay: 800.ms, duration: 1000.ms),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.5,
          right: MediaQuery.of(context).size.width * 0.17,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.047,
              width: MediaQuery.of(context).size.width * 0.03,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sapience/FS-Star5.png'),
                    fit: BoxFit.cover,
                  )),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .scaleXY(begin: 0.7, end: 1.5, duration: 1500.ms),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.12,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.047,
              width: MediaQuery.of(context).size.width * 0.03,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sapience/FS-Star4.png'),
                    fit: BoxFit.contain,
                  )),
            )
                .animate(
              onPlay: (controller) => controller.loop(reverse: true),
            )
                .scaleXY(begin: 0.5, end: 1.2, duration: 600.ms),
          )
        ],
      ),
    );
  }
}
