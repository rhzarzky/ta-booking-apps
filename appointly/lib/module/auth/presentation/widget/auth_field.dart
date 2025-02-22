import 'package:flutter/material.dart';
import 'package:appointly/core/theme/color_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final String labelText;

  const AuthField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: ColorPallete.darkGreySilver,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ColorPallete.primary50,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          obscureText: isPassword,
          validator: (value) {
            if (value!.isEmpty) {
              return '$labelText is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
