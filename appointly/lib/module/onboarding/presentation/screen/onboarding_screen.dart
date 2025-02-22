import 'package:appointly/module/auth/presentation/screen/auth_register.dart';
import 'package:appointly/module/auth/presentation/screen/auth_signIn.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appointly/core/theme/color_pallete.dart';
import 'package:appointly/module/onboarding/presentation/widget/onboard_button_filled.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/onboard-img.png',
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthRegister(),
                            ),
                          ).then((_) {
                            // Optionally call onComplete when returning from AuthRegister
                            onComplete();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      OnboardButton(
                        text: 'Sign In',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthSignin(),
                            ),
                          ).then((_) {
                            // Optionally call onComplete when returning from AuthSignin
                            onComplete();
                          });
                        },
                        isOutline: true,
                      ),
                      // const SizedBox(height: 12),
                      // // Or simply add a "Skip" button that directly completes onboarding:
                      // TextButton(
                      //   onPressed: onComplete,
                      //   child: const Text('Skip'),
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
