import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sapience/Controller/Provider/bookqrprovider.dart';
import 'package:sapience/Controller/Provider/generalprovider.dart';
import 'package:sapience/Screens/ParentScreen/parentwelcomescreen.dart';
import 'package:sapience/Screens/screensuccess.dart';
import 'package:sapience/Services/apiservice.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../constant/app_theme.dart';

class QRViewScanner extends ConsumerStatefulWidget {
  const QRViewScanner({super.key});

  @override
  ConsumerState<QRViewScanner> createState() => _QRViewScannerState();
}

class _QRViewScannerState extends ConsumerState<QRViewScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool hasScanned = false; // Flag to track if a scan has already occurred
  bool hasShownPermissionSnackBar = false; // Flag to track if the SnackBar has been shown

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade100,
        leading: IconButton(
          iconSize: AppTheme.mediumFontSize,
          icon: SvgPicture.asset(
            'assets/images/sapience/back-arrow.svg',
            color: Color(0xff1564a2),
            width: AppTheme.largeFontSize,
          ),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Get.back();
          },
        ),
        title: const Text(
          "Scan QR",
          style:  TextStyle(
            fontSize: AppTheme.highMediumFontSize,
            color: Color(0xff1564a2),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (hasScanned) return; // Prevent multiple scans

      setState(() {
        result = scanData;
        hasScanned = true; // Set the flag to true after the first scan
      });

      await ref
          .read(addbookqrNotifier.notifier)
          .addbookqr(result!.code.toString());

      ref.watch(addbookqrNotifier).id.when(
        data: (snapshot) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snapshot["message"]),
            ),
          );

          if (snapshot["success"] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SuccessScreen()),
            );
            // ref.refresh(getSectionNotifier);
            // ref.refresh(getsettingNotifier);
             DefaultCacheManager().emptyCache(); 
             ref.read(apiprovider).clearAllCacheWithPrefix("API_Section");
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ParentWelcomeScreen()),
            );
            ref.refresh(getSectionNotifier);
            ref.refresh(getsettingNotifier);
          }
          controller.pauseCamera(); // Pause the camera after the first scan
        },
        error: (e, s) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
            ),
          );
          controller.pauseCamera();// Pause the camera if there is an error
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ParentWelcomeScreen()),
          );
        },
        loading: () {
          // Optionally show a loading indicator
        },
      );
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p && !hasShownPermissionSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission')),
      );
      hasShownPermissionSnackBar = true;// Set the flag to true after showing the SnackBar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const ParentWelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
