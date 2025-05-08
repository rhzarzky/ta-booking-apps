import 'package:Appointly/core/common/navigation/main_navigation_bar.dart';
import 'package:Appointly/module/home/presentation/screen/home_screen.dart';
import 'package:Appointly/module/meetings/presentation/screen/meetings_screen.dart';
import 'package:Appointly/module/notification/presentation/screen/notification_screen.dart';
import 'package:Appointly/module/profile/presentation/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  // get userId from auth repository
  final AuthRepository _authRepository = AuthRepository();
  String userId = '';
  int bookingId = 0;
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getUserId() async {
    final user = await _authRepository.getUserData();
    if (user != null) {
      setState(() {
        userId = user.id.toString();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create screens list dynamically to use current userId
    final List<Widget> screens = [
      HomeScreen(
        bookingId: bookingId,
      ),
      // and pass it to meetings and notification screens
      MeetingsScreen(
        userId: userId,
        bookingId: bookingId,
      ),
      NotificationScreen(
        userId: userId,
        bookingId: bookingId,
      ),
      ProfileScreen(),
    ];

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
