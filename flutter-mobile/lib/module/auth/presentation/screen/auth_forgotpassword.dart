import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_otp.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthForgotpassword extends StatefulWidget {
  const AuthForgotpassword({super.key});

  @override
  State<AuthForgotpassword> createState() => _AuthForgotpasswordState();
}

class _AuthForgotpasswordState extends State<AuthForgotpassword> {
  final emailController = TextEditingController();

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
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 4.0,
            ),
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
                  height: 4.0,
                ),
                Text(
                  'Oops, forgot your password? Pop in your email, and we’ll send you a reset link!',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.greySilverChalice950,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Form(
              child: AuthField(
                hintText: 'Jhon@mail.com',
                controller: emailController,
                labelText: 'Email Address',
              ),
            ),
            Spacer(),
            AuthButton(
              text: 'Continue',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthOtp(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
