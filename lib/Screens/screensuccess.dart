import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:sapience/Controller/Provider/generalprovider.dart';
import 'package:sapience/Screens/ParentScreen/parentwelcomescreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/landscape_view.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
    Timer(const Duration(seconds: 1), () {

      ref.refresh(getSectionNotifier);
      ref.read(getSectionNotifier);
      ref.refresh(getsettingNotifier);
      ref.read(getsettingNotifier);
      Get.offAll(() => const ParentWelcomeScreen(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return isTvScreen ? buildLandscapeLayout() : buildPortraitLayout(context); // Your specific screen layout method

  }

  Widget buildPortraitLayout(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
                    child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/sapience/SS-bg.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 300,
                      width: 270,
                      child:
                          Image.asset('assets/images/sapience/SS-Rocket.png'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Success!",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          letterSpacing: 0.9,
                          decoration: TextDecoration.none,
                          fontSize: AppTheme.extralargeFontSize,
                          color: AppTheme.onprimary,
                          fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      "Lets get Started!",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                          fontSize: AppTheme.largeFontSize,
                          color: AppTheme.onsecondary,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ))
                .animate(
                    onPlay: (controller) => controller.loop(reverse: false))
                .shimmer(duration: 2000.ms),
          ],
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
                    image: AssetImage("assets/images/sapience/landscapeimages/Success-scr1.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ).animate(
                onPlay: (controller) => controller.loop(reverse: false))
                .shimmer(duration: 2000.ms),

          ],
        ),
      ],
    );
  }
}
