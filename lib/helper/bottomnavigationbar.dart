import 'package:flutter/material.dart';
import 'package:sapience/constant/app_theme.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavigationBarWidget({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedFontSize: 10,
      selectedIconTheme:
          IconThemeData(color: Color(0xFF10a8b3), size: AppTheme.largeFontSize),
      selectedItemColor: Color(0xFF10a8b3),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      currentIndex: selectedIndex,
      onTap: onItemSelected,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: '',
        ),
      ],
    );
  }
}
