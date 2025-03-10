import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthChangepassword extends StatefulWidget {
  const AuthChangepassword({super.key});

  @override
  State<AuthChangepassword> createState() => _AuthChangepasswordState();
}

class _AuthChangepasswordState extends State<AuthChangepassword> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded),
          iconSize: 32.0,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password?',
                  style: GoogleFonts.ubuntu(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ColorPallete.darkBlack,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  'Create new password for your account.',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.darkGreySilver,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Column(
              children: [
                AuthField(
                  hintText: 'Max.8 Character',
                  isPassword: true,
                  controller: passwordController,
                  labelText: 'New Password',
                ),
                SizedBox(height: 24.0),
                AuthField(
                  hintText: 'Max.8 Character',
                  isPassword: true,
                  controller: confirmPasswordController,
                  labelText: 'Confirm Password',
                ),
              ],
            ),
            Spacer(),
            AuthButton(
              text: 'Continue',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainTabScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
