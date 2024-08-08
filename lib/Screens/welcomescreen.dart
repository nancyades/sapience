
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:sapience/Controller/Provider/otpprovider.dart';
import 'package:sapience/Screens/otpscreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/connectivity_manager.dart';
import 'package:sapience/constant/snackbar_util.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();

  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _buttonFocusNode = FocusNode();

  bool errormsg = false;
  bool _isDialogShown = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
    _isDialogShown = false;
    _controller.addListener(playSound);
    _controller.addListener(() => setState(() {
        }));
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    _buttonFocusNode.dispose();
    _controller.dispose();
    AudioPlayer().dispose();
    super.dispose();
  }

  void playSound() {
    if (_controller.text.isNotEmpty) {
      AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return PopScope(
        onPopInvoked: (popDisposition) async {
          exit(0); // This disables the back button
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: isTvScreen ? buildLandscapeLayout()  :buildPortraitLayout(context),
        ));
  }

  Widget buildPortraitLayout(context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double butterflyHeight = screenHeight >= 720 ? 280 : 270;
    double screenWidthFooter = MediaQuery.of(context).size.width * 1.00;

    var sizedBoxForScreenHeight1 = screenHeight >= 720
        ? const SizedBox(height: 90)
        : const SizedBox(height: 0);
    var sizedBoxForScreenHeight2 = screenHeight < 720
        ? const SizedBox(height: 30)
        : const SizedBox(height: 0);
    double subtext2FontSize = screenWidth <= 425 ? 10 : 13;
    double footerWidth = screenWidth <= 540 ? screenWidthFooter : 500;

    return Column(
      children: [
        Expanded(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
                  bottom: 0,
                  child: Container(
                    height: 300,
                    width: footerWidth,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('assets/images/sapience/LS-Footer.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 380,
                    width: 380,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/sapience/LS-Childrens.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.25,
                  left: MediaQuery.of(context).size.width * 0.05,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Star2.png'),
                      fit: BoxFit.cover,
                    )),
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: false),
                      )
                      .scaleXY(begin: 0.7, end: 1, duration: 1000.ms),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.10,
                  left: 170,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Star2.png'),
                      fit: BoxFit.cover,
                    )),
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: true),
                      )
                      .scaleXY(begin: 0.7, end: 1, duration: 2000.ms),
                ),
                Positioned(
                  bottom: 250,
                  right: 120,
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
                      .scaleXY(begin: 0.7, end: 1, duration: 500.ms),
                ),
                Positioned(
                  bottom: 240,
                  right: 80,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Star2.png'),
                      fit: BoxFit.cover,
                    )),
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: true),
                      )
                      .scaleXY(begin: 0.7, end: 1, duration: 800.ms),
                ),
                Positioned(
                  bottom: 220,
                  right: 10,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/sapience/FS-Star4.png'),
                      fit: BoxFit.cover,
                    )),
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: true),
                      )
                      .scaleXY(
                          begin: 0.7, end: 1, duration: 1500.ms, delay: 200.ms),
                ),
                Positioned(
                  bottom: butterflyHeight,
                  left: 150,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(
                          'assets/images/sapience/HS-Butterfly1.png'),
                      fit: BoxFit.cover,
                    )),
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: true),
                      )
                      .scaleX(begin: 0.7, end: 1, duration: 500.ms),
                ),
                Positioned(
                  bottom: 170,
                  right: 20,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image:
                          AssetImage('assets/images/sapience/LS-Balloons.png'),
                      fit: BoxFit.contain,
                    )),
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: false),
                      )
                      .slideY(begin: 0, end: -2, duration: 7000.ms),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          sizedBoxForScreenHeight1,
                          sizedBoxForScreenHeight2,
                          Container(
                            // margin: EdgeInsets.only(top: 30.0),
                            child: const Text(
                              'Hello!',
                              style: TextStyle(
                                fontSize: AppTheme.largeFontSize,
                                color: AppTheme.onprimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Container(
                            child: const Text(
                              'Welcome to Sapience Learning!',
                              style: TextStyle(
                                  fontSize: AppTheme.mediumFontSize,
                                  color: AppTheme.onprimary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.7),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            child: const Text(
                              'Sign in to get your account',
                              style: TextStyle(
                                fontSize: AppTheme.smallFontSize,
                                color: AppTheme.onprimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      width: 350,
                                      height:
                                          50, // Fixed height of the container
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        boxShadow: const [], // No shadows
                                      ),
                                      child: TextFormField(
                                        cursorColor: AppTheme.commoncolor,
                                        controller: _controller,
                                        maxLength: 10,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Enter your mobile number',
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: AppTheme.mediumFontSize,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal:
                                                      20), // Adjusted padding
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide
                                                .none, // No visible border
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          errorStyle: const TextStyle(
                                            color: Colors
                                                .red, // Color of the error text
                                            height:
                                                0.4, // Ensures error text takes minimal vertical space
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: const BorderSide(
                                                color: Colors.red),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: const BorderSide(
                                                color: Colors.red),
                                          ),
                                          counterText: '',
                                        ),
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly, // Ensure only digits can be entered
                                          LengthLimitingTextInputFormatter(
                                              10), // Limit to 10 digits
                                        ],
                                        style: const TextStyle(
                                          fontSize: AppTheme.mediumFontSize,
                                          color: AppTheme.commoncolor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onSaved: (value) {
                                          _phoneNumber = value!;
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.0,
                                      bottom: 10.0,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20,
                                              bottom:
                                                  10), // Ensures padding inside the field
                                          child: Text(
                                            '${_controller.text.length}/10',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: subtext2FontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                              visible: errormsg,
                              child: validate().toString() == "true"
                                  ? const SizedBox()
                                  : validate()),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            child: const Text(
                              'We will send you one time password (OTP)',
                              style: TextStyle(
                                fontSize: AppTheme.smallFontSize,
                                color: AppTheme.onsecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 45,
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      );
                                      AudioPlayer().play(
                                          AssetSource("audio/Bubble 02.mp3"));

                                      getOtpAndNavigate();
                                    },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 0),
                                // fixedSize: Size.fromWidth(100),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Get OTP',
                                      style: TextStyle(
                                          fontSize: AppTheme.smallFontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                    image: AssetImage("assets/images/sapience/landscapeimages/Mobile-number-scr2.png"),
                    fit: BoxFit.contain,
                  ),
                ),
                child:  Row(
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.04, top: MediaQuery.of(context).size.height * 0.29
                      ),
                      child: Column(
                        children: [
                          Container(
                            child:  Text(
                              'Hello!',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.025,
                                color: AppTheme.onprimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Container(
                            child:  Text(
                              'Welcome to Sapience Learning!',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.025,
                                  color: AppTheme.onprimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.7),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            child:  Text(
                              'Sign in to get your account',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.015,
                                color: AppTheme.onprimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Focus(
                            focusNode: _textFieldFocusNode,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        width:  MediaQuery.of(context).size.width * 0.3,
                                        height: MediaQuery.of(context).size.height * 0.06, // Fixed height of the container
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(30.0),
                                          boxShadow: const [], // No shadows
                                        ),
                                        child: TextFormField(
                                          cursorColor: AppTheme.commoncolor,
                                          controller: _controller,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: 'Enter your mobile number',
                                            hintStyle:  TextStyle(
                                              color: Colors.grey,
                                              fontSize: MediaQuery.of(context).size.width * 0.015,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 20), // Adjusted padding
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30.0),
                                              borderSide: BorderSide
                                                  .none, // No visible border
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            errorStyle: const TextStyle(
                                              color: Colors
                                                  .red, // Color of the error text
                                              height:
                                              0.4, // Ensures error text takes minimal vertical space
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30.0),
                                              borderSide: const BorderSide(
                                                  color: Colors.red),
                                            ),
                                            focusedErrorBorder:
                                            OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(30.0),
                                              borderSide: const BorderSide(
                                                  color: Colors.red),
                                            ),
                                            counterText: '',
                                          ),
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly, // Ensure only digits can be entered
                                            LengthLimitingTextInputFormatter(
                                                10), // Limit to 10 digits
                                          ],
                                          style:  TextStyle(
                                            fontSize: MediaQuery.of(context).size.height * 0.03,
                                            color: AppTheme.commoncolor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onSaved: (value) {
                                            _phoneNumber = value!;
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        right: 10.0,
                                        bottom: 10.0,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                                right: 20,
                                                bottom: 0), // Ensures padding inside the field
                                            child: Text(
                                              '${_controller.text.length}/10',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                              visible: errormsg,
                              child: validate().toString() == "true"
                                  ? const SizedBox()
                                  : validate()),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 8, right: 20),
                                child:  Text(
                                  'We will send you one time password (OTP)',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.01,
                                    color: AppTheme.onsecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Focus(
                            focusNode: _buttonFocusNode,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05 ,
                              width: MediaQuery.of(context).size.width * 0.09 ,
                              child: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                  const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  );
                                  AudioPlayer().play(
                                      AssetSource("audio/Bubble 02.mp3"));

                                  getOtpAndNavigate();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 0),
                                  // fixedSize: Size.fromWidth(100),
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                                    :  Text(
                                  'Get OTP',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.013,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
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

          ],
        ),




        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.32,
          right: MediaQuery.of(context).size.width * 0.45,
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
            onPlay: (controller) => controller.loop(reverse: false),
          )
              .scaleXY(begin: 0.7, end: 1, duration: 1000.ms),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.55,
          right: MediaQuery.of(context).size.width  * 0.3,
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
              .scaleXY(begin: 0.7, end: 1, duration: 2000.ms),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.5,
          right: MediaQuery.of(context).size.width  * 0.18,

          child: Container(
            height: MediaQuery.of(context).size.height * 0.049,
            width: MediaQuery.of(context).size.width * 0.036,

            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sapience/FS-Star1.png'),
                  fit: BoxFit.cover,
                )),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .scaleXY(begin: 0.7, end: 1, duration: 500.ms),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.45,
          right: MediaQuery.of(context).size.width  * 0.12,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.035,
            width: MediaQuery.of(context).size.width * 0.02,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sapience/FS-Star2.png'),
                  fit: BoxFit.cover,
                )),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .scaleXY(begin: 0.7, end: 1, duration: 800.ms),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.4,
          right: MediaQuery.of(context).size.width  * 0.05,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.04,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sapience/FS-Star4.png'),
                  fit: BoxFit.cover,
                )),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .scaleXY(
              begin: 0.7, end: 1, duration: 1500.ms, delay: 200.ms),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.57,
          right: MediaQuery.of(context).size.width  * 0.23,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.04,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/sapience/HS-Butterfly1.png'),
                  fit: BoxFit.cover,
                )),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: true),
          )
              .scaleX(begin: 0.7, end: 1, duration: 500.ms),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.59,
          right: MediaQuery.of(context).size.width  * 0.09,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image:
                  AssetImage('assets/images/sapience/LS-Balloons.png'),
                  fit: BoxFit.contain,
                )),
          )
              .animate(
            onPlay: (controller) => controller.loop(reverse: false),
          )
              .slideY(begin: 0, end: -1.5, duration: 7000.ms),
        ),

      ],
    );
  }

  validate() {
    if (_controller.text.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(right: 370),
        child: const Text(
          "  Please enter the phone number",
          style: TextStyle(color: Colors.red, fontSize: 10),
        ),
      );
    } else if (!RegExp(r'^\d{10}$').hasMatch(_controller.text)) {
      return Container(
        margin: const EdgeInsets.only(right: 300),
        child: const Text(
          '  Please enter a valid 10-digit phone number',
          style: TextStyle(color: Colors.red, fontSize: 10),
        ),
      );
    } else {
      return true;
    }
  }

  void getOtpAndNavigate() async {
    if (validate() == true) {
      errormsg = false;
      _formKey.currentState!.save();

      FocusScope.of(context).unfocus();

      ConnectivityManager connectivityManager = ConnectivityManager();
      bool isOnline = await connectivityManager.isConnected();
      if (!isOnline) {
        SnackbarUtil.showNetworkError();

        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(addotpNotifier.notifier).addotp(_phoneNumber);
        ref.watch(addotpNotifier).id.when(
              data: (data) async {
                if (data.contains('successfully')) {
                  Get.to(
                    () => OtpScreen(
                      phonenumber: _phoneNumber,
                    ),
                    // transition: Transition.rightToLeft,
                    // duration: const Duration(milliseconds: 500),
                  );
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please try again!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              error: (e, s) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.amberAccent,
                    content: Text(" Please try again"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              loading: () {},
            );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please try again!"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        errormsg = true;
      });
    }
  }

}
















