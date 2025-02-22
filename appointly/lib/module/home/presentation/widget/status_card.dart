// ignore_for_file: depend_on_referenced_packages

import 'package:appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final String timeRange;
  final int difference;
  final Color startColor;
  final Color endColor;
  final String iconAsset;

  const StatusCard({
    super.key,
    required this.title,
    required this.count,
    required this.timeRange,
    required this.difference,
    required this.startColor,
    required this.endColor,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      height: 228,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Spacer(),
          Text(
            count.toString(),
            style: GoogleFonts.ubuntu(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Last $timeRange days',
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              SizedBox(width: 8),
              if (difference != 0)
                Row(
                  children: [
                    Text(
                      '${difference > 0 ? '+' : ''}$difference',
                      style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: difference > 0
                            ? ColorPallete.greenMalachite
                            : ColorPallete.redCinnabar,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      difference > 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 14,
                      color: difference > 0
                          ? ColorPallete.greenMalachite
                          : ColorPallete.redCinnabar,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
