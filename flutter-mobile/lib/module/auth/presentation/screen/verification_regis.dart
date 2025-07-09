import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_signIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationRegis extends StatefulWidget {
  const VerificationRegis({super.key});

  @override
  State<VerificationRegis> createState() => _VerificationRegisState();
}

class _VerificationRegisState extends State<VerificationRegis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorPallete.backgroundBody,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: ColorPallete.backgroundBody,
          elevation: 0,
          title: Image.asset(
            'assets/image/Logo.png',
            height: 32,
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          String email = '';
          if (state is AuthSuccess) {
            email = state.user.email;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 64),
                          Image.asset(
                            'assets/image/email-success.png',
                          ),
                          Text(
                            'Let’s get you verified!',
                            style: GoogleFonts.ubuntu(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorPallete.darkBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'We sent a verification link to ',
                              style: GoogleFonts.ubuntu(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: ColorPallete.greySilverChalice950,
                              ),
                              children: [
                                TextSpan(
                                  text: email.isNotEmpty
                                      ? email
                                      : 'your email address',
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w600,
                                    color: ColorPallete.primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: '. Tap it to complete your setup 🔥',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  // Fixed Buttons at Bottom
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPallete.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthSignin(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In Now',
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Resend email
                          },
                          child: Text(
                            'Resend Email',
                            style: GoogleFonts.ubuntu(
                              color: ColorPallete.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }));
  }
}
