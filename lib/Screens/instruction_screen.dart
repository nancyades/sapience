import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapience/Screens/welcomescreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/landscape_view.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  State<InstructionScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<InstructionScreen> {
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();
  List<Map<String, dynamic>> carouselItems = [
    {
      'imagePath': "assets/images/sapience/OB-1.png",
      'step': 'Step - 1',
      'paragraphText':
          "Enter the ten digits mobile number\n      which is given in the school\n           for communication.",
    },
    {
      'imagePath': "assets/images/sapience/OB-2.png",
      'step': 'Step - 2',
      'paragraphText':
          "You will receive a four-digit OTP.\n     Enter the OTP number and\n           get into the app.",
    },
    {
      'imagePath': "assets/images/sapience/OB-3.png",
      'step': 'Step - 3',
      'paragraphText':
          "Parents can Scan the QR code\n        given by the School.\n  Download the given videos\n  and enjoy watching it offline.",
    },
    {
      'imagePath': "assets/images/sapience/OB-4.png",
      'step': 'Step - 4',
      'paragraphText':
          "              If the mobile storage is less,\n               then play online in the app.\n        The complete syllabus is provided\nin the app, Enjoy the benefits of the app...",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: ResponsiveWrapper(
        child: buildPortraitLayout(), // Your specific screen layout method
      ),
    );
  }

  Widget buildPortraitLayout() {
    double screenheightsizedbox = MediaQuery.of(context).size.height;
    var sizedBox = screenheightsizedbox >= 670
        ? const SizedBox(height: 50)
        : const SizedBox();


    double screenWidth = MediaQuery.of(context).size.width;
    double skipTextSize = screenWidth <= 320 ? 12.0 : 12.0;
    double stepsTextSize =
        screenWidth <= 320 ? AppTheme.mediumFontSize : AppTheme.largeFontSize;

    double paraTextSize = screenWidth <= 320
        ? AppTheme.verySmallFontSize
        : AppTheme.smallFontSize;
    double imageHeight = screenWidth <= 320 ? 300 : 300;
    double lineSpacing = screenWidth <= 320 ? 2 : 2;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/sapience/1-intro-scr-bg-transform.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
            children: [
              Positioned(
                top: 30,
                right: 0,
                child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      child: Container(
                        height: AppTheme.skipbutheight,
                        width: AppTheme.smallbutwidth,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: const BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.all(
                            Radius.circular(9),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
                            Get.offAll(
                                  () => const WelcomeScreen(),
                              // transition: Transition.rightToLeft,
                              // duration: const Duration(milliseconds: 500),
                            );
                          },
                          child: Center(
                            child: Text(
                              'Skip <<'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: skipTextSize,
                                color: const Color(0xff04328c),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              sizedBox,
              CarouselSlider(
                items: carouselItems.map((item) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                            height: imageHeight,
                            width: 600,
                            child: Image.asset(item['imagePath'])),
                      ),
                      Text(
                        item['step'],
                        style: TextStyle(
                          color: AppTheme.onprimary,
                          fontSize: stepsTextSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          item['paragraphText'],
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: paraTextSize,
                              height: lineSpacing,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  );
                }).toList(),
                carouselController: _controller,
                options: CarouselOptions(
                  height: 500,
                  autoPlay: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  aspectRatio: 17 / 9,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.9,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              //applySizedBox3,
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () {
                        _controller.animateToPage(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (index == _currentIndex
                                ? Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : const Color(0xff307d81)
                                : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.4)
                                    : const Color(0xff307d81).withOpacity(0.4)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            ],
          ),


        ]),
      ),
    );
  }
}
