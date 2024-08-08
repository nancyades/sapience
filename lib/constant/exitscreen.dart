import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:sapience/Controller/Provider/generalprovider.dart';
import 'package:sapience/Services/apiservice.dart';
import 'package:sapience/constant/app_theme.dart';
import 'package:sapience/helper/appconstant.dart';

class ExitConfirmation {
  static Future<bool?> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0)),
            child: Container(
              width: 100,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 280,
                        height: 58,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(
                                0xFF0064ab), // Set the border color here
                            width: 2, // Set the border width here
                          ),
                          shape: BoxShape.rectangle,
                          color: const Color(0xFF0064ab),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'See you soon!',
                            style: TextStyle(
                                color: AppTheme.whitecolor,
                                fontSize: AppTheme.highMediumFontSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 30),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: AppTheme.mediumFontSize,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Are you sure you want \n to Exit?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: AppTheme.highMediumFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                              'No',
                              style: TextStyle(
                                backgroundColor: AppTheme.cancelBtn,
                                color: Colors.white,
                                fontSize: AppTheme
                                    .mediumFontSize, // You can use AppTheme.mediumFontSize if you have set up a theme
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Consumer(builder: (context, ref, child) {
                            return ElevatedButton(
                              onPressed: () async {
                                SystemNavigator.pop();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(
                                        color: Colors.red,
                                        width: 2.0), // Initial border color
                                  ),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(100, 42)),
                                overlayColor:
                                MaterialStateProperty.all(Colors.red),
                                side: MaterialStateProperty.resolveWith<
                                    BorderSide>(
                                      (Set<MaterialState> states) {
                                    return const BorderSide(
                                        color: Colors.red,
                                        width:
                                        2.0); // Keep border color consistent
                                  },
                                ),
                              ),
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                  backgroundColor: Colors.red,
                                  color: Colors.white,
                                  fontSize: AppTheme
                                      .mediumFontSize, // You can use AppTheme.mediumFontSize if you have set up a theme
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }
}
