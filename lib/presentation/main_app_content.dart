import 'package:flutter/material.dart';
import 'package:rich_up/presentation/screens/utilities_screen.dart';
import 'package:rich_up/presentation/screens/business_screen.dart';
import 'package:rich_up/presentation/screens/management_screen.dart';
import 'package:rich_up/presentation/screens/profile_screen.dart';
import 'package:rich_up/presentation/screens/sale_report_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/custom_app_bar.dart';

class MainAppContent extends StatefulWidget { 
  const MainAppContent({super.key});

  @override
  State<MainAppContent> createState() => _MainAppContentState();
}

class _MainAppContentState extends State<MainAppContent> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BusinessScreen(),
    ManagementScreen(),
    SaleReportScreen(),
    UtilitiesScreen(),
    ProfileScreen()
  ];

  final List<String> _titles = [
    "Home",
    "Business",
    "Management",
    "SaleReport",
    "Utilities",
    "Profile",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: CustomAppBar(title: _titles[_selectedIndex]),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}