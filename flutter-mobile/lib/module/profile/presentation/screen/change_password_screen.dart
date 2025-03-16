// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/profile/presentation/screen/profile_screen.dart';
import 'package:Appointly/module/profile/presentation/widget/button.dart';
import 'package:Appointly/module/profile/presentation/widget/field_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to the controllers to update the UI when text changes
    oldPassword.addListener(_updateButtonVisibility);
    newPassword.addListener(_updateButtonVisibility);
  }

  @override
  void dispose() {
    oldPassword.removeListener(_updateButtonVisibility);
    newPassword.removeListener(_updateButtonVisibility);
    oldPassword.dispose();
    newPassword.dispose();
    super.dispose();
  }

  void _updateButtonVisibility() {
    setState(() {
      // This will trigger a rebuild of the widget with the updated button visibility
    });
  }

  bool _areFieldsFilled() {
    return newPassword.text.isNotEmpty && oldPassword.text.isNotEmpty;
  }

  void _confirmChangePassword() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text(
              'Save New Password',
              style: GoogleFonts.sourceSans3(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
            content: Text(
              'Are you sure you want to change your password?',
              style: GoogleFonts.ubuntu(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ColorPallete.darkGreySilver,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorPallete.darkBlack,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorPallete.primaryColor,
                  ),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          _fieldItem(isKeyboardVisible),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: ColorPallete.darkBlack,
            ),
          ),
          Text(
            'Change Password',
            style: GoogleFonts.sourceSans3(
              fontSize: 20,
              color: ColorPallete.darkBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldItem(bool isKeyboardVisible) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          bottom: 24.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          children: [
            FieldProfile(
              labelText: 'Old Password',
              hintText: 'Min.8 Characters',
              controller: oldPassword,
              isPassword: true,
              isOptional: true,
            ),
            SizedBox(
              height: 24.0,
            ),
            FieldProfile(
              labelText: 'New Password',
              hintText: 'Min.8 Characters',
              controller: newPassword,
              isPassword: true,
              isOptional: true,
            ),
            SizedBox(
              height: isKeyboardVisible ? 24.0 : 24.0,
            ),
            Visibility(
              visible: _areFieldsFilled(),
              child: Button(
                text: 'Save Changes',
                onTap: _confirmChangePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
