// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:appointly/core/theme/color_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isOutline;

  const OnboardButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(32)),
        color: isOutline ? Colors.transparent : ColorPallete.primaryColor,
        border: isOutline
            ? Border.all(color: ColorPallete.primaryColor, width: 2)
            : null,
      ),
      child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
              fixedSize: Size(500, 60),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent),
          child: Text(
            text,
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOutline ? ColorPallete.primaryColor : Colors.white,
            ),
          )),
    );
  }
}
