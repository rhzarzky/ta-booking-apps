// ignore_for_file: depend_on_referenced_packages

import 'package:appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldProfile extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final bool isOptional;
  final TextEditingController controller;
  final String labelText;
  const FieldProfile(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.labelText,
      this.isOptional = false,
      this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    bool isPasswordVisible = false;
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
        StatefulBuilder(builder: (context, setState) {
          return TextFormField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
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
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: ColorPallete.darkGreySilver,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    )
                  : null,
            ),
            validator: (value) {
              if (isOptional && value!.isEmpty) {
                return '$labelText is required';
              }
              return null;
            },
          );
        })
      ],
    );
  }
}
