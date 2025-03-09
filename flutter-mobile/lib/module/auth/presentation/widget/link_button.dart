// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const LinkButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              text,
              style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorPallete.primaryColor),
            )),
      ],
    );
  }
}
