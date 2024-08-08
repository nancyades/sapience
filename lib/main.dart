import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:sapience/Screens/ParentScreen/parentwelcomescreen.dart';
import 'package:sapience/Screens/ParentScreen/videoplayerscreen.dart';
import 'package:sapience/constant/error_page.dart';
import 'package:sapience/constant/snackbar_util.dart';
import 'package:sapience/helper/audiofile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/splash_screen.dart';
import 'helper/appconstant.dart';


class GlobalState {
  static String? activeScreen;
  static String? version;
  static List<bool>? isLoadingList;
}
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await getLoginStatus();
  HttpOverrides.global = MyHttpOverrides();
 ErrorWidget.builder = (_) => errorPage();
  runApp(ProviderScope(
      child: MyApp(
    isLoggedIn: isLoggedIn,
  )));
  await SharedPreferences.getInstance();
}

Future<bool> getLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false; // Default to false if not set
}

class MyApp extends ConsumerStatefulWidget {
  final bool? isLoggedIn;

  const MyApp({Key? key, this.isLoggedIn}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late bool _isOnline;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();

    GlobalState.version = '1.3';
    getroute();
    WidgetsBinding.instance.addObserver(this);
    AudioService().playMusic();
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final isOnline = result != ConnectivityResult.none;
    setState(() {
      _isOnline = isOnline;
    });
    if (isOnline) {

    } else {
      SnackbarUtil.showNetworkError();
    }
  }

  getroute() async {
    _isOnline = await SnackbarUtil.checkConnectivity();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppConstants.route = prefs.getString('route').toString();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    WidgetsBinding.instance.removeObserver(this);
    AudioService().disposeMusic();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      AudioService().stopMusic();
    } else if (state == AppLifecycleState.resumed) {
      if (GlobalState.activeScreen == 'SpecificScreen') {
        AudioService().stopMusic();
      } else {
        AudioService().playMusic();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width and set orientation accordingly
    final isTvScreen = MediaQuery.of(context).size.width >= 540;
    final preferredOrientation = isTvScreen
        ? DeviceOrientation.landscapeLeft
        : DeviceOrientation.portraitUp;

    // Set preferred orientation
    SystemChrome.setPreferredOrientations([preferredOrientation]);

    return GetMaterialApp(
      key: _scaffoldKey,
      title: 'Sapience',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: widget.isLoggedIn! ? '/ParentWelcomeScreen' : '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => SplashScreen(),
        ),
        GetPage(
            name: '/ParentWelcomeScreen', page: () => ParentWelcomeScreen()),
        GetPage(
          name: '/videoPlayerScreen',
          page: () => VideoViewer(),
        ),
        // Add other routes as needed
      ],
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
