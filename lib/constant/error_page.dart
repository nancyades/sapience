import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sapience/constant/app_theme.dart';

class errorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/sapience/Oops-img.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 270.0),
                              child: ElevatedButton(
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
                                  'Try Again',
                                  style: TextStyle(
                                    backgroundColor: AppTheme.cancelBtn,
                                    color: Colors.white,
                                    fontSize: AppTheme
                                        .mediumFontSize, // You can use AppTheme.mediumFontSize if you have set up a theme
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ))

              ],
            ),
          ],
        ),




      /*  Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child:
                Image.asset('assets/images/sapience/'),
              ),


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
                  'Try Again',
                  style: TextStyle(
                    backgroundColor: AppTheme.cancelBtn,
                    color: Colors.white,
                    fontSize: AppTheme
                        .mediumFontSize, // You can use AppTheme.mediumFontSize if you have set up a theme
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),*/
      ),
    );
  }
}
