import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const CustomProgressBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _CustomProgressBarState createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar> {
  late double _currentValue;
  late Duration _videoDuration;

  @override
  void initState() {
    super.initState();
    _videoDuration = widget.controller.value.duration;
    _currentValue = widget.controller.value.position.inMilliseconds.toDouble();

    widget.controller.addListener(() {
      if (!mounted) return;

      setState(() {
        _currentValue =
            widget.controller.value.position.inMilliseconds.toDouble();
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  _formatDuration(
                      Duration(milliseconds: _currentValue.toInt())),
                  style: TextStyle(color: Colors.white)),
              Text(_formatDuration(_videoDuration),
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 12.0,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
            activeTrackColor: Colors.grey.shade900,
            inactiveTrackColor: Colors.grey.shade400,
            thumbColor: Colors.grey.shade800,
          ),
          child: Slider(
            value: _currentValue,
            min: 0.0,
            max: _videoDuration.inMilliseconds.toDouble(),
            onChanged: (value) {
              setState(() {
                _currentValue = value;
                widget.controller.seekTo(Duration(milliseconds: value.toInt()));
              });
            },
          ),
        ),
      ],
    );
  }
}
