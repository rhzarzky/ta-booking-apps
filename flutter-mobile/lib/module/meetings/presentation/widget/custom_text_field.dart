import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final bool isOptional;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.isOptional = false,
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
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
            cursorColor: ColorPallete.primaryColor,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle:
                  TextStyle(color: ColorPallete.darkGreySilver, fontSize: 14.0),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none),
            ),
            validator: (value) {
              if (isOptional && value!.isEmpty) {
                return '$labelText is required';
              }
              return null;
            }),
      ],
    );
  }
}
