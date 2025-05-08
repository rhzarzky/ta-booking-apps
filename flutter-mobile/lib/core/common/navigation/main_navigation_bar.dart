import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Appointly/core/theme/color_pallete.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<_NavItemData> items = [
      _NavItemData('assets/icons/icon-home.svg', 'Home'),
      _NavItemData('assets/icons/icon-calendar.svg', 'Meetings'),
      _NavItemData('assets/icons/icon-bell.svg', 'Notif'),
      _NavItemData('assets/icons/icon-profile.svg', 'Profile'),
    ];

    double itemWidth = MediaQuery.of(context).size.width / items.length;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Top indicator
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: itemWidth * currentIndex,
            top: 0,
            child: Container(
              width: itemWidth,
              alignment: Alignment.center,
              child: Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorPallete.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPallete.primary400
                          .withOpacity(0.3), // subtle glow
                      blurRadius: 7,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Bottom nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == currentIndex;
              final item = items[index];

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        item.iconPath,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? ColorPallete.primaryColor
                              : ColorPallete.darkGreySilver,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.sourceSans3(
                          fontSize: isSelected ? 14 : 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? ColorPallete.primaryColor
                              : ColorPallete.darkGreySilver,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final String iconPath;
  final String label;

  _NavItemData(this.iconPath, this.label);
}
