// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:appointly/core/common/main_tab_screen.dart';
import 'package:appointly/module/auth/presentation/screen/auth_register.dart';
import 'package:appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:appointly/module/auth/presentation/widget/link_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appointly/core/theme/color_pallete.dart';

class AuthSignin extends StatefulWidget {
  const AuthSignin({super.key});

  @override
  State<AuthSignin> createState() => _AuthSigninState();
}

class _AuthSigninState extends State<AuthSignin> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 36.0),
          Image.asset('assets/image/Logo.png'),
        ],
      );
    }

    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            header(),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: ColorPallete.darkBlack,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete the form to access your account',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.darkGreySilver,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            AuthField(
              controller: emailController,
              hintText: 'johndoe@gmail.com',
              labelText: 'Email Address',
            ),
            SizedBox(height: 16),
            AuthField(
              controller: passwordController,
              hintText: 'Max. 8 Characters',
              labelText: 'Password',
              isPassword: true,
            ),
            SizedBox(height: 24),
            AuthButton(
              text: 'Sign In',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainTabScreen()),
                );
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don’t have an account?',
                  style: GoogleFonts.ubuntu(
                    fontSize: 14,
                    color: ColorPallete.darkBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                LinkButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthRegister()),
                    );
                  },
                  text: 'Create Account',
                ),
              ],
            ),
            SizedBox(height: 16), // Tambahan agar tidak terlalu mepet di bawah
          ],
        ),
      ),
    );
  }
}
