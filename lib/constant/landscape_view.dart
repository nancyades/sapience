import 'package:flutter/material.dart';

// ResponsiveWrapper widget
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTvScreen = MediaQuery.of(context).size.width >= 540;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffb9e4e8),
              Color(0xFFbee5e9),
          Color(0xffceecee),],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width:
                isTvScreen ? 425 : double.infinity, // Limit width on TV screens
            height: isTvScreen
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height,
            child: child, // Use the passed child widget
          ),
        ),
      ),
    );
  }
}
