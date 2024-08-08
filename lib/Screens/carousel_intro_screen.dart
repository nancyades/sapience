// import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/route_manager.dart';
import 'package:sapience/Screens/instruction_screen.dart';
import 'package:sapience/Screens/welcomescreen.dart';
import 'package:sapience/constant/app_theme.dart';

import '../constant/landscape_view.dart';

class CarouselIntroScreen extends StatefulWidget {
  const CarouselIntroScreen({super.key});

  @override
  State<CarouselIntroScreen> createState() => _CarouselIntroScreenState();
}

class _CarouselIntroScreenState extends State<CarouselIntroScreen>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(body: isTvScreen ? buildLandscapeLayout() : buildPortraitLayout(context)), // Your specific screen layout method

    );
  }

  Widget buildPortraitLayout(context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth <= 321 ? 40 : 55;
    var applySizedBox1 = screenheight <= 700
        ? const SizedBox(height: 40)
        : const SizedBox(height: 100);
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "assets/images/sapience/1-intro-scr-bg-transform.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              applySizedBox1,
              Container(
                height: 330,
                width: 330,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/sapience/IS.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    child: const Text("Welcome to ",
                        style: TextStyle(
                            fontSize: AppTheme.largeFontSize,
                            color: AppTheme.onprimary)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    child: const Text("Sapience Learning! ",
                        style: TextStyle(
                            fontSize: AppTheme.largeFontSize,
                            color: AppTheme.onprimary)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: const Text("To educate the parents on the syllabus,",
                        style: TextStyle(
                            fontSize: AppTheme.smallFontSize,
                            color: AppTheme.onsecondary)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    child: const Text("we have launched 'Sapience App'",
                        style: TextStyle(
                            fontSize: AppTheme.smallFontSize,
                            color: AppTheme.onsecondary)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    child: const Text("on the Android platform",
                        style: TextStyle(
                            fontSize: AppTheme.smallFontSize,
                            color: AppTheme.onsecondary)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: iconSize,
                    width: iconSize,
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 30),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    alignment: Alignment.center,
                    child: InkWell(
                      child: const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      onTap: () {
                        AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                        Get.to(
                          () => const InstructionScreen(),
                          // transition: Transition.rightToLeft,
                          // duration: const Duration(milliseconds: 500),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.075,
          left: MediaQuery.of(context).size.width * 0.07,
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
                onPlay: (controller) => controller.loop(reverse: false),
              )
              .slideX(begin: 0, end: 2.5, duration: 4500.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.05,
          right: MediaQuery.of(context).size.width * 0.09,
          child: Container(
            height: 50,
            width: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sapience/FS-Cloud4.png'),
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.loop(reverse: false),
              )
              .slideX(begin: 0.2, end: 1.7, duration: 4500.ms),
        ),
      ],
    );
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
                    image: AssetImage("assets/images/sapience/landscapeimages/Welcome-scr.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

          ],
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.2,
          right: MediaQuery.of(context).size.width * 0.23,
          child: Container(

            margin: const EdgeInsets.fromLTRB(0, 5, 0, 30),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            alignment: Alignment.center,
            child: Material(
             color: Colors.transparent,
              child: InkWell(
                child:  Icon(
                  Icons.keyboard_arrow_right_rounded,
                  size: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.white,
                ),
                onTap: () {
                  AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                  Get.to(
                        () => const WelcomeScreen(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
