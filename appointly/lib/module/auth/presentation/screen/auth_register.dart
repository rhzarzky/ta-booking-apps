import 'package:appointly/core/common/main_tab_screen.dart';
import 'package:appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:appointly/module/auth/presentation/screen/auth_signin.dart';
import 'package:appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:appointly/module/auth/presentation/widget/link_button.dart';
import 'package:appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthRegister extends StatefulWidget {
  const AuthRegister({super.key});

  @override
  State<AuthRegister> createState() => _AuthRegisterState();
}

class _AuthRegisterState extends State<AuthRegister> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              header(),
              SizedBox(height: 8),
              Text(
                'Join Us Today!',
                style: GoogleFonts.sourceSans3(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create an account and unlock your next great scheduling.',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: ColorPallete.darkGreySilver,
                ),
              ),
              SizedBox(height: 24),
              AuthField(
                controller: fullNameController,
                hintText: 'John Doe',
                labelText: 'Full Name',
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 16),
              AuthField(
                controller: confirmPasswordController,
                hintText: 'Max. 8 Characters',
                labelText: 'Confirm Password',
                isPassword: true,
              ),
              SizedBox(height: 24),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registered successfully!')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainTabScreen()),
                    );
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.failure)),
                    );
                  }
                },
                builder: (context, state) {
                  return AuthButton(
                    text: state is AuthLoading ? 'Loading...' : 'Get Started',
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(RegisterUser(
                              name: fullNameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              confirmPassword: confirmPasswordController.text,
                            ));
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
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
                        MaterialPageRoute(builder: (context) => AuthSignin()),
                      );
                    },
                    text: 'Sign In',
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

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
}
