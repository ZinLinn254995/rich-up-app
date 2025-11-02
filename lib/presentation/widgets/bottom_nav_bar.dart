import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.blueGrey, // bottom bar background
      selectedItemColor: Colors.white, // selected icon + label
      unselectedItemColor: Colors.white70, // unselected icon + label
      type: BottomNavigationBarType.fixed, // more than 3 items
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Business"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Management"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Sale Report"),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: "Utilities"),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
      ],
    );
  }
}
