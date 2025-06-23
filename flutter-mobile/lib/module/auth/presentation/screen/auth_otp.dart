import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_changepassword.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'dart:async';

class AuthOtp extends StatefulWidget {
  final String email;

  const AuthOtp({super.key, required this.email});

  @override
  State<AuthOtp> createState() => _AuthOtpState();
}

class _AuthOtpState extends State<AuthOtp> {
  String otpCode = '';
  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;

    final maskedUsername =
        username.substring(0, 2) + '*' * (username.length - 2);

    return '$maskedUsername@$domain';
  }

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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthVerifyOTPSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP berhasil diverifikasi'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthChangepassword(),
              ),
            );
          } else if (state is AuthVerifyOTPFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthResendOTPSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP baru telah dikirim'),
                backgroundColor: Colors.green,
              ),
            );
            _startTimer();
          } else if (state is AuthResendOTPFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
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
                    'We\'ve sent OTP to your email at ${_maskEmail(widget.email)}. Please enter 6 digits code you received.',
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
                numberOfFields: 6,
                fieldWidth: 52,
                fieldHeight: 52,
                borderRadius: BorderRadius.circular(12.0),
                focusedBorderColor: ColorPallete.primaryColor,
                enabledBorderColor: ColorPallete.primaryColor,
                disabledBorderColor: ColorPallete.greySilverChalice950,
                borderColor: ColorPallete.primaryColor,
                filled: false,
                textStyle: TextStyle(
                  fontSize: 18.0,
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
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                onCodeChanged: (String code) {
                  // Handle validation
                },
                onSubmit: (String verificationCode) {
                  setState(() {
                    otpCode = verificationCode;
                  });
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              Column(
                children: [
                  if (!_canResend)
                    Text(
                      'Resend in $_countdown s',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                  Text(
                    'Didn\'t receive code?',
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorPallete.greySilverChalice950,
                    ),
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return TextButton(
                        onPressed: _canResend && state is! AuthLoading
                            ? () {
                                context.read<AuthBloc>().add(
                                      ResendOTP(email: widget.email),
                                    );
                              }
                            : null,
                        child: Text(
                          state is AuthLoading ? 'Sending...' : 'Resend code',
                          style: GoogleFonts.ubuntu(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _canResend && state is! AuthLoading
                                ? ColorPallete.primaryColor
                                : ColorPallete.greySilverChalice950,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
              Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AuthButton(
                    text: state is AuthLoading ? 'Verifying...' : 'Next',
                    onTap: state is AuthLoading || otpCode.length != 6
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                                  VerifyOTP(otp: otpCode),
                                );
                          },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
