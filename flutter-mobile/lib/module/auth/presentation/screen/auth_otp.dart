import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_changepassword.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class AuthOtp extends StatefulWidget {
  const AuthOtp({super.key});

  @override
  State<AuthOtp> createState() => _AuthOtpState();
}

class _AuthOtpState extends State<AuthOtp> {
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
                  'Verification',
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
                  'We`ve send OTP to your email at **@gmail.com. Please enter 4 digits code you received.',
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
            OtpTextField(
              numberOfFields: 4,
              fieldWidth: 72,
              fieldHeight: 72,
              borderRadius: BorderRadius.circular(12.0),
              focusedBorderColor: ColorPallete.primaryColor,
              enabledBorderColor: ColorPallete.primaryColor,
              disabledBorderColor: ColorPallete.greySilverChalice950,
              borderColor: ColorPallete.primaryColor,
              filled: false,
              textStyle: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w500,
                color: ColorPallete.primaryColor,
              ),
              showFieldAsBox: true,
              cursorColor: ColorPallete.primaryColor,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              autoFocus: true,
              fillColor: ColorPallete.primaryColor,
              enabled: true,
              clearText: true,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            SizedBox(
              height: 24.0,
            ),
            Column(
              children: [
                Text(
                  'Resend in 32 s',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorPallete.darkBlack,
                  ),
                ),
                Text(
                  'Didn`t receive code?',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.greySilverChalice950,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Resend code',
                    style: GoogleFonts.ubuntu(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorPallete.primaryColor,
                    ),
                  ),
                )
              ],
            ),
            Spacer(),
            AuthButton(
              text: 'Next',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthChangepassword(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
