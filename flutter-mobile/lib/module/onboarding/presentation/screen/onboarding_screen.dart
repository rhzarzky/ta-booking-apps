// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_register.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_signIn.dart';
import 'package:Appointly/module/auth/presentation/screen/verification_regis.dart';
import 'package:Appointly/module/onboarding/presentation/widget/onboard_button_filled.dart';
import 'package:Appointly/module/onboarding/repository/onboarding_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({
    super.key,
    this.onComplete,
  });

  Future<void> _markOnboardingComplete() async {
    final onBoardingRepo = OnboardingRepository();
    await onBoardingRepo.completeOnboarding();
    // Notify parent widget that onboarding is complete
    onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/onboarding-2.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Placeholder(),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/image/Logo.png',
                  width: 132,
                  height: 30,
                ),
                const SizedBox(height: 12),
                Text(
                  'Say goodbye to manual scheduling hassles👋',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ColorPallete.darkBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our smart appointment booking system allows you to manage your schedule effortlessly.',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.darkGreySilver,
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      OnboardButton(
                        text: 'Create an account',
                        onTap: () async {
                          await _markOnboardingComplete();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthRegister(),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      OnboardButton(
                        text: 'Sign In',
                        onTap: () async {
                          await _markOnboardingComplete();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthSignin(),
                              ),
                            );
                          }
                        },
                        isOutline: true,
                      ),
                      const SizedBox(height: 12),
                      // TextButton(
                      //   onPressed: () async {
                      //     await _markOnboardingComplete();
                      //     if (context.mounted) {
                      //       Navigator.pushReplacement(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => const AuthSignin(),
                      //         ),
                      //       );
                      //     }
                      //   },
                      //   child: Text(
                      //     'Skip',
                      //     style: GoogleFonts.ubuntu(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w500,
                      //       color: ColorPallete.primaryColor,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
