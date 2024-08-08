import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:sapience/Screens/qrdialogscreen.dart';
import 'package:sapience/Screens/welcomescreen.dart';
import 'package:sapience/constant/app_theme.dart';

class QRSucessScreen extends ConsumerStatefulWidget {
  const QRSucessScreen({super.key});

  @override
  ConsumerState<QRSucessScreen> createState() => _QRSucessScreenState();
}

class _QRSucessScreenState extends ConsumerState<QRSucessScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.to(const WelcomeScreen(),
        );
        return Future.value(false);
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewScanner(),
            ));
          },
          child: Column(
            children: [
              Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/sapience/Scanning-img1.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
            ],
          )

         /* Column(
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.27,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Color(0xFF10a8b3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 120,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Scan your QR Code',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: AppTheme.largeFontSize,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/sapience/scansucess1.jpeg',
                ),
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF10a8b3),
                        size: 60.0,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const QRViewScanner(),
                        ));
                      },
                    ),
            ],
          ),*/
        ),
      ),
    );
  }
}
