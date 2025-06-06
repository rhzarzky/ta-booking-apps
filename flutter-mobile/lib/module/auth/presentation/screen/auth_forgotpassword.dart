import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_otp.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthForgotpassword extends StatefulWidget {
  const AuthForgotpassword({super.key});

  @override
  State<AuthForgotpassword> createState() => _AuthForgotpasswordState();
}

class _AuthForgotpasswordState extends State<AuthForgotpassword> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
          if (state is AuthForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP telah dikirim ke email Anda'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthOtp(email: emailController.text),
              ),
            );
          } else if (state is AuthForgotPasswordFailure) {
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
                    'Oops, forgot your password? Pop in your email, and we\'ll send you a reset link!',
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
                key: _formKey,
                child: AuthField(
                  hintText: 'Jhon@mail.com',
                  controller: emailController,
                  labelText: 'Email Address',
                ),
              ),
              Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AuthButton(
                    text: state is AuthLoading ? 'Loading...' : 'Continue',
                    onTap: state is AuthLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    ForgotPassword(
                                        email: emailController.text.trim()),
                                  );
                            }
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
