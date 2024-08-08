import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:sapience/constant/custom_progressBar.dart';
import 'package:video_player/video_player.dart';
// Adjust the import path as necessary

class CustomControls extends StatefulWidget {
  final ChewieController chewieController;
  final bool showControls;
  final VoidCallback onForward;
  final VoidCallback onRewind;
  final bool isBuffering;

  const CustomControls({
    Key? key,
    required this.chewieController,
    required this.showControls,
    required this.onForward,
    required this.onRewind,
    required this.isBuffering,
  }) : super(key: key);

  @override
  _CustomControlsState createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  bool _dragging = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _updateSystemUIOverlay();
  // }
  //
  // @override
  // void didUpdateWidget(covariant CustomControls oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _updateSystemUIOverlay();
  // }
  //
  // void _updateSystemUIOverlay() {
  //   if (widget.showControls) {
  //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //         overlays: SystemUiOverlay.values);
  //   } else {
  //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //       overlays: SystemUiOverlay.values);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      // visible: widget.showControls,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(
                flex: 3,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        size: 40,
                        Icons.replay_10,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: widget.onRewind,
                  ),
                  IconButton(
                    icon: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isBuffering
                            ? Colors.transparent
                            : Colors.grey.shade900.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: widget.isBuffering
                          ? Icon(
                              color: Colors.transparent,
                              Icons.circle_outlined,
                              size: 60,
                            )
                          : Icon(
                              size: 60,
                              widget.chewieController.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                    ),
                    onPressed: widget.isBuffering
                        ? null
                        : () {
                            setState(() {
                              if (widget.chewieController.isPlaying) {
                                widget.chewieController.pause();
                              } else {
                                widget.chewieController.play();
                              }
                            });
                          },
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        size: 40,
                        Icons.forward_10,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: widget.onForward,
                  ),
                ],
              ),
              Spacer(
                flex: 2,
              ),
              CustomProgressBar(
                controller: widget.chewieController.videoPlayerController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
