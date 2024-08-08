import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapience/constant/connectivity_manager.dart'; // Adjust the import path accordingly

class SnackbarUtil {
  static void showNetworkError() {
    Get.snackbar(
      "No internet",
      "Please check your internet connection and try again.",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static Future<bool> checkConnectivity() async {
    ConnectivityManager connectivityManager = ConnectivityManager();
    bool isOnline = await connectivityManager.isConnected();
    if (!isOnline) {
      // showNetworkError();
    }
    connectivityManager.dispose();
    return isOnline;
  }
}
