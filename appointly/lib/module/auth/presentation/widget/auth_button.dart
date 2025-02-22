import 'package:flutter/material.dart';
import 'package:appointly/core/theme/color_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AuthButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(32),
          ),
          color: ColorPallete.primaryColor),
      child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(500, 60),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            text,
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )),
    );
  }
}
