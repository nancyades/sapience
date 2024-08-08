import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/welcomescreen.dart';

class AppConstants {
  static String usertoken = "";
  static String phoneno = "";
  static String sectionid = "";
  static String termid = "";
  static String monthid = "";
  static String weekid = "";
  static String subjectid = "";
  static String subjectName = "";
  static String? filename;
  static int subcat = 0;
  static String route = "";
}

class UserPreferences {
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
  }

  static Future<void> savePhoneno(String phoneno) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneno', phoneno);
  }

  static Future<void> sectionid(String sectionid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sectionid', sectionid);
  }

  static Future<void> termid(String termid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('termid', termid);
  }

  static Future<void> monthid(String monthid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('monthid', monthid);
  }

  static Future<void> weekid(String weekid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('weekid', weekid);
  }

  static Future<void> subjectid(String subjectid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('subjectid', subjectid);


  }

  static Future<void> videoroute(String route) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('route', route);
  }

  static Future<void> saveDownloadStatus(
      String title, bool isDownloaded) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$title.mp4', isDownloaded);
  }

  static Future<bool> isDownloaded(String title) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$title.mp4') ??
        false; // Default to false if not found
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Get.offAll(() => WelcomeScreen(),
        // transition: Transition.rightToLeft, duration: Duration(seconds: 1)
    );
  }
}
