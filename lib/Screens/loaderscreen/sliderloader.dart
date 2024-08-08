import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sapience/Screens/ParentScreen/landscapesildervideoplayer.dart';
import 'package:sapience/Screens/ParentScreen/sildervideoplayer.dart';
import 'package:sapience/Screens/ParentScreen/syllabusscreen.dart';

class Slideloader extends StatefulWidget {
  String? termid;
  String? section;
  String? sectionid;
  Slideloader({super.key, this.termid, this.section, this.sectionid});

  @override
  State<Slideloader> createState() => _SlideloaderState();
}

class _SlideloaderState extends State<Slideloader> {
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
        () => Syllabus(
          termid: widget.termid,
          section: widget.section,
          sectionid: widget.sectionid,
        ),
        // transition: Transition.rightToLeft,
        // duration: Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LandscapeSlideloader extends StatefulWidget {
  String? section;
  String? sectionid;
  String? filepath;
  String? image;
  String? termid;

  LandscapeSlideloader(
      {super.key,
      this.filepath,
      this.image,
      this.section,
      this.sectionid,
      this.termid});

  @override
  State<LandscapeSlideloader> createState() => _LandscapeSlideloaderState();
}

class _LandscapeSlideloaderState extends State<LandscapeSlideloader> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
        () => SliderPlayer(
          termid: widget.termid,
          section: widget.section,
          sectionid: widget.sectionid,
          filePath: widget.filepath,
          image: widget.image,
        ),
        // transition: Transition.fadeIn,
        // duration: Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
    ;
  }
}




class LandscapetvSlideloader extends StatefulWidget {
  String? section;
  String? sectionid;
  String? filepath;
  String? image;
  String? termid;

  LandscapetvSlideloader(
      {super.key,
        this.filepath,
        this.image,
        this.section,
        this.sectionid,
        this.termid});

  @override
  State<LandscapetvSlideloader> createState() => _LandscapetvSlideloaderState();
}

class _LandscapetvSlideloaderState extends State<LandscapetvSlideloader> {
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(
            () => LandscapeSilderplayer(
          termid: widget.termid,
          section: widget.section,
          sectionid: widget.sectionid,
          filePath: widget.filepath,
          image: widget.image,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
    ;
  }
}







