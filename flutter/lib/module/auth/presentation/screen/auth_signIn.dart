// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:appointly/core/common/main_tab_screen.dart';
import 'package:appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:appointly/module/auth/presentation/screen/auth_register.dart';
import 'package:appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:appointly/module/auth/presentation/widget/link_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                header(),
                SizedBox(height: 8.0),
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
                SizedBox(height: 24.0),
                Column(
                  spacing: 16.0,
                  children: [
                    AuthField(
                      controller: emailController,
                      hintText: 'johndoe@gmail.com',
                      labelText: 'Email Address',
                    ),
                    AuthField(
                      controller: passwordController,
                      hintText: 'Max. 8 Characters',
                      labelText: 'Password',
                      isPassword: true,
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Success Loggedin'),
                        ),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainTabScreen(),
                        ),
                        (route) => false,
                      );
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.failure),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return AuthButton(
                      text: state is AuthLoading ? 'Loading' : 'Sign In',
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                LoginUser(
                                    email: emailController.text,
                                    password: passwordController.text),
                              );
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: 4.0),
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
                          MaterialPageRoute(
                              builder: (context) => AuthRegister()),
                        );
                      },
                      text: 'Create Account',
                    ),
                  ],
                ),
               // Tambahan agar tidak terlalu mepet di bawah
              ],
            ),
          ),
        ));
  }
}
