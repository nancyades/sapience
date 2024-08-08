import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sapience/Screens/ParentScreen/healthyMealSyllabus.dart';
import 'package:sapience/Screens/ParentScreen/healthymeal_videoplayer.dart';
import 'package:sapience/Screens/ParentScreen/landscapevideoplayerscreen.dart';
import 'package:sapience/Screens/ParentScreen/syllabusvideos.dart';

import 'ParentScreen/videoplayerscreen.dart';

class loaderScreen extends StatefulWidget {
  int? subcatlen;
  String? section;
  String? sectionid;
  String? subjectName;
  int? titleid;
  String? subcatid;
  loaderScreen(
      {super.key,
      this.subcatlen,
      this.section,
      this.sectionid,
      this.subjectName,
      this.titleid,
        this.subcatid
      });

  @override
  State<loaderScreen> createState() => _loaderScreenState();
}

class _loaderScreenState extends State<loaderScreen> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
        () => Syllabusvideo(
          subcatid: widget.subcatid.toString(),
          titleid: widget.titleid!,
          section: widget.section,
          sectionid: widget.sectionid,
          subcatlen: widget.subcatlen,
          subjectName: widget.subjectName,
        ),
        //transition: Transition.rightToLeft,
        // duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


class loadertvScreen extends StatefulWidget {
  int? subcatlen;
  String? section;
  String? sectionid;
  String? subjectName;
  int? titleid;
  String? subcatid;
  loadertvScreen(
      {super.key,
        this.subcatlen,
        this.section,
        this.sectionid,
        this.subjectName,
        this.titleid,
        this.subcatid
      });

  @override
  State<loadertvScreen> createState() => _loadertvScreenState();
}

class _loadertvScreenState extends State<loadertvScreen> {
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
            () => Syllabusvideo(
          subcatid: widget.subcatid.toString(),
          titleid: widget.titleid!,
          section: widget.section,
          sectionid: widget.sectionid,
          subcatlen: widget.subcatlen,
          subjectName: widget.subjectName,
        ),
        //transition: Transition.rightToLeft,
        // duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}




class Landscapeloader extends StatefulWidget {
  String filepath;
  final String? image;
  int? subcatlen;
  String? section;
  String? sectionid;
  String? subjectname;
  Landscapeloader(
      {super.key,
      required this.filepath,
      this.image,
      this.subcatlen,
      this.section,
      this.sectionid,
      this.subjectname});

  @override
  State<Landscapeloader> createState() => _LandscapeloaderState();
}

class _LandscapeloaderState extends State<Landscapeloader> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
        () => VideoViewer(
          section: widget.section,
          sectionid: widget.sectionid,
          //subcatlen: widget.subcatlen!,
          filePath: widget.filepath,
          image: widget.image,
          subjectName: widget.subjectname,
        ),
        // transition: Transition.fadeIn,
        // duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}



//healthy loader

class Healthyloader extends StatefulWidget {
  String? meals;
  String? foodcategory;
  String? foodtype;
  String? foodday;
  Healthyloader({super.key, this.meals,this.foodcategory, this.foodtype, this.foodday});

  @override
  State<Healthyloader> createState() => _HealthyloaderState();
}

class _HealthyloaderState extends State<Healthyloader> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
        () => HealthyMealSyllabus(
          meals: widget.meals,
          foodcategory: widget.foodcategory,
          foodtype: widget.foodtype,
          foodday: widget.foodday,
        ),
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class HealthyLandscapeloader extends StatefulWidget {
  String? filepath;
  final String? image;
  String? meals;
  String? foodcategory;
  String? foodtype;
  String? foodday;
  HealthyLandscapeloader({super.key, this.filepath, this.image, this.meals, this.foodcategory, this.foodtype, this.foodday});

  @override
  State<HealthyLandscapeloader> createState() => _HealthyLandscapeloaderState();
}

class _HealthyLandscapeloaderState extends State<HealthyLandscapeloader> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
        () => HealthyMealVideoPlayer(
            foodcategory: widget.foodcategory.toString(),
            foodtype: widget.foodtype.toString(),
            foodday: widget.foodday.toString(),
            filePath: widget.filepath.toString(),
            image: widget.image,
            meals: widget.meals),
        // transition: Transition.fadeIn,
        // duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
