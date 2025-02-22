import 'package:appointly/core/common/navigation/main_navigation_bar.dart';
import 'package:appointly/module/home/presentation/screen/home_screen.dart';
import 'package:appointly/module/meetings/presentation/screen/meetings_screen.dart';
import 'package:appointly/module/notification/presentation/screen/notification_screen.dart';
import 'package:appointly/module/profile/presentation/screen/profile_screen.dart';
import 'package:flutter/material.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screen = [
    HomeScreen(),
    MeetingsScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_selectedIndex],
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
