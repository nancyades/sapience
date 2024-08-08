import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sapience/Controller/Provider/otpprovider.dart';
import 'package:sapience/Screens/qrscannersucessscreen.dart';
import 'package:sapience/Screens/screensuccess.dart';
import 'package:sapience/Screens/welcomescreen.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/constant/connectivity_manager.dart';
import 'package:sapience/constant/landscape_view.dart';
import 'package:sapience/helper/appconstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/Provider/loginprovider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  String? phonenumber;

  OtpScreen({super.key, this.phonenumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  TextEditingController textEditingController = TextEditingController();

  String enteredPin = '';
  bool _isLoading = false;
  Timer? _timer;
  int _start = 50;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          if (mounted) {
            // Check if the widget is still mounted
            setState(() {
              _start--;
            });
          } else {
            timer.cancel(); // Cancel the timer if the widget is not mounted
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks and errors
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          Get.to(
            const WelcomeScreen(),
            // duration: const Duration(milliseconds: 500)
          );
          return Future.value(false);
        },
        child: isTvScreen
            ? buildLandscapeLayout()
            : buildPortraitLayout(
                context), // Your specific screen layout method
      ),
    );
  }

  Widget buildPortraitLayout(context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/sapience/Otp bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 55,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        iconSize: AppTheme.mediumFontSize,
                        icon: SvgPicture.asset(
                          'assets/images/sapience/back-arrow.svg',
                          color: const Color(0xFFFFFFFF),
                          width: AppTheme.largeFontSize,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          AudioPlayer()
                              .play(AssetSource("audio/Bubble 02.mp3"));

                          Get.to(
                            const WelcomeScreen(),
                            //duration: const Duration(milliseconds: 500)
                          );
                        },
                      ),
                      const Text(
                        'Enter Verification Code',
                        style: TextStyle(
                            fontSize: AppTheme.mediumFontSize,
                            color: AppTheme.whitecolor,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Image.asset(
                    'assets/images/sapience/Otp-scr-boy.png',
                  )
                      .animate(
                        onPlay: (controller) => controller.loop(reverse: true),
                      )
                      .shimmer(duration: 1800.ms)
                      .then(delay: 1000.ms)
                      .shake(hz: 5, duration: 500.ms),
                ),
                const Text(
                  'We have sent OTP to your mobile',
                  style: TextStyle(
                      fontSize: AppTheme.smallFontSize,
                      color: AppTheme.whitecolor,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.white),
                        child: index < enteredPin.length
                            ? Center(
                                child: Text(
                                  enteredPin[index],
                                  style: const TextStyle(
                                    fontSize: AppTheme.smallFontSize,
                                    color: AppTheme.commoncolor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: AppTheme.skipbutheight,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            // Ensuring all form validations are passed

                            AudioPlayer()
                                .play(AssetSource("audio/Bubble 02.mp3"));
                            FocusScope.of(context)
                                .unfocus(); // Close the keyboard

                            ConnectivityManager connectivityManager =
                                ConnectivityManager();
                            bool isOnline =
                                await connectivityManager.isConnected();

// First Phase: Connectivity and UI Validation
                            if (!isOnline) {
                              Get.snackbar("Network Error",
                                  "Please turn on your network to proceed.",
                                  snackPosition: SnackPosition.TOP,
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackStyle: SnackStyle.FLOATING);

                              return;
                            } else {
                              if (enteredPin.isEmpty && isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill the Pin'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              } else if (enteredPin.length < 4 && isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter the missing pin!!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                            }

                            setState(() {
                              _isLoading =
                                  true; // Set loading to true when button is pressed
                            });
                            // Second Phase: Backend Validation
                            try {
                              // Start of try block to catch exceptions
                              await ref
                                  .read(addloginNotifier.notifier)
                                  .addlogin(widget.phonenumber.toString(),
                                      enteredPin);
                              await ref.watch(addloginNotifier).id.when(
                                  data: (snapshot) {
                                if (snapshot['success'] == true) {
                                  gettoken();
                                  if (snapshot['data']['user_subscription'] ==
                                      true) {
                                    setLoginStatus(true);
                                    Get.to(
                                      () => const SuccessScreen(),
                                      // transition: Transition.rightToLeft,
                                      // duration:
                                      //     const Duration(milliseconds: 500),
                                    );
                                  } else {
                                    Get.to(
                                      () => const QRSucessScreen(),
                                      // transition: Transition.rightToLeft,
                                      // duration:
                                      //     const Duration(milliseconds: 500),
                                    );

                                    //  _showOTPDialog(context);
                                  }
                                } else if (snapshot['success'] == false) {
                                  if (snapshot['message'] ==
                                      "The selected otp is invalid.") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Incorrect pin'),
                                        duration: Duration(milliseconds: 999),
                                      ),
                                    );
                                  } else if (snapshot['message'] == "Error") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Your OTP has been expired"),
                                        duration: Duration(milliseconds: 999),
                                      ),
                                    );
                                  } else if (snapshot['message'] == "Timeout") {
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
                                }
                              }, error: (e, s) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please try again'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }, loading: () {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please try again'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } finally {
                              // Finally block to ensure _isLoading is set to false
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 89, 191, 191),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(50, 60),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                                color: AppTheme.whitecolor,
                                fontSize: AppTheme.mediumFontSize,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                _start > 0
                    ? Text(
                        "Resend OTP in:  ${formatTime(_start)}",
                        style: const TextStyle(
                            color: AppTheme.whitecolor,
                            fontSize: AppTheme.smallFontSize,
                            fontWeight: FontWeight.w700),
                      )
                    : GestureDetector(
                        onTap: () async {
                          setState(() {
                            _start = 50;
                            startTimer();
                          });
                          await ref
                              .read(addotpNotifier.notifier)
                              .addotp(widget.phonenumber.toString());
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "Didn't receive an OTP? ",
                                style: TextStyle(
                                    color: AppTheme.whitecolor,
                                    fontSize: AppTheme.smallFontSize,
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: 'Resend OTP',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AppTheme.whitecolor,
                                    fontSize: AppTheme.smallFontSize,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => numButton(1 + 3 * i + index),
                        ).toList(),
                      ),
                    ),
                  ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: TextButton(
                          onPressed: () {},
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 0),
                            child: Text(
                              "",
                              style: TextStyle(
                                color: AppTheme.whitecolor,
                                fontSize: AppTheme.smallFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: TextButton(
                            onPressed: () {
                              AudioPlayer()
                                  .play(AssetSource("audio/Bubble 02.mp3"));

                              setState(() {
                                if (enteredPin.length < 4) {
                                  enteredPin += 0.toString();
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child: Text(
                                0.toString(),
                                style: const TextStyle(
                                  color: AppTheme.whitecolor,
                                  fontSize: AppTheme.mediumFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: TextButton(
                            onPressed: () {
                              AudioPlayer()
                                  .play(AssetSource("audio/Bubble 02.mp3"));
                              setState(
                                () {
                                  if (enteredPin.isNotEmpty) {
                                    enteredPin = enteredPin.substring(
                                        0, enteredPin.length - 1);
                                  }
                                },
                              );
                            },
                            child: const Icon(
                              Icons.backspace,
                              color: AppTheme.whitecolor,
                              size: AppTheme.mediumFontSize,
                            ),
                          )),
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
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/sapience/landscapeimages/Otp Scr tv.png"),
                fit: BoxFit.contain,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:  EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.08,
                      left: MediaQuery.of(context).size.width * 0.03,

                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            iconSize: MediaQuery.of(context).size.width * 0.09,
                            icon: SvgPicture.asset(
                              'assets/images/sapience/back-arrow.svg',
                              color: const Color(0xFFFFFFFF),
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              AudioPlayer()
                                  .play(AssetSource("audio/Bubble 02.mp3"));

                              Get.to(
                                const WelcomeScreen(),
                                //duration: const Duration(milliseconds: 500)
                              );
                            },
                          ),
                           Text(
                            'Enter Verification Code',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.02,
                                color: AppTheme.whitecolor,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(
                     // top: MediaQuery.of(context).size.height * 0.09,
                      right: MediaQuery.of(context).size.width * 0.13,
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(
                            'We have sent OTP to your mobile',
                            style: TextStyle(
                                fontSize:  MediaQuery.of(context).size.width * 0.02,
                                color: AppTheme.whitecolor,
                                fontWeight: FontWeight.w700),
                          ),
                           SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 0),
                                  width: MediaQuery.of(context).size.width * 0.04,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Colors.white),
                                  child: index < enteredPin.length
                                      ? Center(
                                          child: Text(
                                            enteredPin[index],
                                            style:  TextStyle(
                                              fontSize: MediaQuery.of(context).size.width * 0.02,
                                              color: AppTheme.commoncolor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                           SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      // Ensuring all form validations are passed

                                      AudioPlayer().play(
                                          AssetSource("audio/Bubble 02.mp3"));
                                      FocusScope.of(context)
                                          .unfocus(); // Close the keyboard

                                      ConnectivityManager connectivityManager =
                                          ConnectivityManager();
                                      bool isOnline = await connectivityManager
                                          .isConnected();

                                      // First Phase: Connectivity and UI Validation
                                      if (!isOnline) {
                                        Get.snackbar("Network Error",
                                            "Please turn on your network to proceed.",
                                            snackPosition: SnackPosition.TOP,
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackStyle: SnackStyle.FLOATING);

                                        return;
                                      } else {
                                        if (enteredPin.isEmpty && isOnline) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Please fill the Pin'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        } else if (enteredPin.length < 4 &&
                                            isOnline) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please enter the missing pin!!'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                      }

                                      setState(() {
                                        _isLoading =
                                            true; // Set loading to true when button is pressed
                                      });
                                      // Second Phase: Backend Validation
                                      try {
                                        // Start of try block to catch exceptions
                                        await ref
                                            .read(addloginNotifier.notifier)
                                            .addlogin(
                                                widget.phonenumber.toString(),
                                                enteredPin);
                                        await ref
                                            .watch(addloginNotifier)
                                            .id
                                            .when(data: (snapshot) {
                                          if (snapshot['success'] == true) {
                                            gettoken();
                                            if (snapshot['data']
                                                    ['user_subscription'] ==
                                                true) {
                                              setLoginStatus(true);
                                              Get.to(
                                                () => const SuccessScreen(),
                                              );
                                            } else {
                                              Get.to(
                                                () => const WelcomeScreen(),
                                              );

                                              //  _showOTPDialog(context);
                                            }
                                          } else if (snapshot['success'] ==
                                              false) {
                                            if (snapshot['message'] ==
                                                "The selected otp is invalid.") {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Incorrect pin'),
                                                  duration: Duration(
                                                      milliseconds: 999),
                                                ),
                                              );
                                            } else if (snapshot['message'] ==
                                                "Error") {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Your OTP has been expired"),
                                                  duration: Duration(
                                                      milliseconds: 999),
                                                ),
                                              );
                                            } else if (snapshot['message'] ==
                                                "Timeout") {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text("Please try again!"),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          }
                                        }, error: (e, s) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Please try again'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }, loading: () {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        });
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Please try again'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } finally {
                                        // Finally block to ensure _isLoading is set to false
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 0),
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 89, 191, 191),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(50, 60),
                              ),
                              child: _isLoading
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
                                  :  Text(
                                      'Submit',
                                      style: TextStyle(
                                          color: AppTheme.whitecolor,
                                          fontSize: MediaQuery.of(context).size.width * 0.02,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                           SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          _start > 0
                              ? Text(
                                  "Resend OTP in:  ${formatTime(_start)}",
                                  style:  TextStyle(
                                      color: AppTheme.whitecolor,
                                      fontSize: MediaQuery.of(context).size.width * 0.02,
                                      fontWeight: FontWeight.w700),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _start = 50;
                                      startTimer();
                                    });
                                    await ref
                                        .read(addotpNotifier.notifier)
                                        .addotp(widget.phonenumber.toString());
                                  },
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text:  TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: "Didn't receive an OTP? ",
                                          style: TextStyle(
                                              color: AppTheme.whitecolor,
                                              fontSize: MediaQuery.of(context).size.width * 0.02,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        TextSpan(
                                          text: 'Resend OTP',
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AppTheme.whitecolor,
                                              fontSize: MediaQuery.of(context).size.width * 0.02,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                           SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          for (var i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (index) => numButton(1 + 3 * i + index),
                                  ).toList(),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: TextButton(
                                    onPressed: () {},
                                    child:  Padding(
                                      padding:  EdgeInsets.symmetric(horizontal:  30,vertical: 0),

                                      child: Text(
                                        " ",
                                        style: TextStyle(
                                          color: AppTheme.whitecolor,
                                          fontSize: MediaQuery.of(context).size.width * 0.02,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: TextButton(
                                      onPressed: () {
                                        AudioPlayer().play(
                                            AssetSource("audio/Bubble 02.mp3"));

                                        setState(() {
                                          if (enteredPin.length < 4) {
                                            enteredPin += 0.toString();
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(horizontal:  23,vertical: 0),

                                        child: Text(
                                          0.toString(),
                                          style:  TextStyle(
                                            color: AppTheme.whitecolor,
                                            fontSize: MediaQuery.of(context).size.width * 0.02,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Padding(
                                      padding:  EdgeInsets.symmetric(horizontal:  24,vertical: 0),
                                      child: TextButton(
                                        onPressed: () {
                                          AudioPlayer().play(
                                              AssetSource("audio/Bubble 02.mp3"));
                                          setState(
                                            () {
                                              if (enteredPin.isNotEmpty) {
                                                enteredPin = enteredPin.substring(
                                                    0, enteredPin.length - 1);
                                              }
                                            },
                                          );
                                        },
                                        child:  Icon(
                                          Icons.backspace,
                                          color: AppTheme.whitecolor,
                                          size: MediaQuery.of(context).size.width * 0.02,
                                        ),
                                      ),
                                    )),
                              ],
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

  Widget numButton(int number) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: TextButton(
        onPressed: () {
          AudioPlayer().play(AssetSource("audio/Bubble 02.mp3"));

          setState(() {
            if (enteredPin.length < 4) {
              enteredPin += number.toString();
            }
          });
        },
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: isTvScreen ? 25 : 0, vertical: 0),
          child: Text(
            number.toString(),
            style:  TextStyle(
              color: AppTheme.whitecolor,
              fontSize: isTvScreen ? MediaQuery.of(context).size.width * 0.02 :  AppTheme.mediumFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void validatePin(String pin) {
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill the Pin'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the missing pin!!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String formatTime(int seconds) {
    int minute = seconds ~/ 60;
    int second = seconds % 60;
    return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  gettoken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppConstants.usertoken = prefs.getString('userToken').toString();
  }

  Future<void> setLoginStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
