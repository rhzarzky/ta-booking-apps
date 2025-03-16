// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        elevation: 0,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ColorPallete.primaryColor,
        unselectedItemColor: ColorPallete.darkGreySilver,
        selectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon-home.svg',
                    colorFilter: ColorFilter.mode(
                      widget.currentIndex == 0
                          ? ColorPallete.primaryColor
                          : ColorPallete.darkGreySilver,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon-calendar.svg',
                    colorFilter: ColorFilter.mode(
                      widget.currentIndex == 1
                          ? ColorPallete.primaryColor
                          : ColorPallete.darkGreySilver,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon-bell.svg',
                    colorFilter: ColorFilter.mode(
                      widget.currentIndex == 2
                          ? ColorPallete.primaryColor
                          : ColorPallete.darkGreySilver,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon-profile.svg',
                    colorFilter: ColorFilter.mode(
                      widget.currentIndex == 3
                          ? ColorPallete.primaryColor
                          : ColorPallete.darkGreySilver,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}